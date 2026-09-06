// Preview adapter for AVFoundation.
//
// AVFoundation is native media code that cannot run inside the preview, so the
// engine substitutes this module for it in the preview build only. The app's
// own sources are never edited.
//
// It covers exactly the surface IceCubesApp touches:
//   - AVAudioSession        session category juggling around video playback
//   - AVURLAsset            wrapper the editor and compressor build from a URL
//   - AVAssetExportSession  video compression in Compressor
//   - AVAssetImageGenerator video poster frames in EditorStore
// Everything here is inert: playback and export are no-ops, and the image
// generator reports "no image" so callers take their nil path.

import CoreGraphics
import Foundation

// MARK: - Time

// CoreMedia has no Linux module, and the app only ever reaches CMTime through
// AVFoundation, so the type lives here.
public struct CMTime: Equatable, Hashable, Sendable {
  public var value: Int64
  public var timescale: Int32

  public init(value: Int64, timescale: Int32) {
    self.value = value
    self.timescale = timescale
  }

  public init(seconds: Double, preferredTimescale: Int32) {
    value = Int64(seconds * Double(preferredTimescale))
    timescale = preferredTimescale
  }

  public var seconds: Double {
    timescale == 0 ? 0 : Double(value) / Double(timescale)
  }

  public static let zero = CMTime(value: 0, timescale: 1)
}

// MARK: - File types

public struct AVFileType: RawRepresentable, Equatable, Hashable, Sendable {
  public let rawValue: String
  public init(rawValue: String) { self.rawValue = rawValue }
  public init(_ rawValue: String) { self.rawValue = rawValue }

  public static let mp4 = AVFileType("public.mpeg-4")
  public static let mov = AVFileType("com.apple.quicktime-movie")
  public static let m4v = AVFileType("public.m4v")
}

// MARK: - Export presets

public let AVAssetExportPreset1280x720: String = "AVAssetExportPreset1280x720"
public let AVAssetExportPreset1920x1080: String = "AVAssetExportPreset1920x1080"
public let AVAssetExportPresetHighestQuality: String = "AVAssetExportPresetHighestQuality"

// MARK: - Assets

public class AVAsset: @unchecked Sendable {
  public init() {}
}

public class AVURLAsset: AVAsset, @unchecked Sendable {
  public let url: URL

  public init(url: URL, options: [String: Any]? = nil) {
    self.url = url
    super.init()
  }
}

// MARK: - Export

public class AVAssetExportSession: @unchecked Sendable {
  public var outputURL: URL?
  public var outputFileType: AVFileType?
  public var shouldOptimizeForNetworkUse: Bool = false
  public let presetName: String

  public init?(asset: AVAsset, presetName: String) {
    self.presetName = presetName
  }

  /// Inert: the preview has no encoder, so an "export" simply succeeds without
  /// writing a file. Callers that read the output back get their failure path.
  public func export(to url: URL, as fileType: AVFileType) async throws {
    outputURL = url
    outputFileType = fileType
  }
}

// MARK: - Image generation

public class AVAssetImageGenerator: @unchecked Sendable {
  public var appliesPreferredTrackTransform: Bool = false
  public var requestedTimeToleranceBefore: CMTime = .zero
  public var requestedTimeToleranceAfter: CMTime = .zero

  public init(asset: AVAsset) {}

  /// Inert: reports "no image", which is the path the app already handles for
  /// a video it cannot read a poster frame from.
  public func generateCGImageAsynchronously(
    for time: CMTime,
    completionHandler: @escaping @Sendable (CGImage?, CMTime, (any Error)?) -> Void
  ) {
    completionHandler(nil, time, nil)
  }
}

// MARK: - Audio session

public class AVAudioSession: @unchecked Sendable {
  public struct Category: RawRepresentable, Equatable, Hashable, Sendable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let ambient = Category(rawValue: "AVAudioSessionCategoryAmbient")
    public static let playback = Category(rawValue: "AVAudioSessionCategoryPlayback")
    public static let soloAmbient = Category(rawValue: "AVAudioSessionCategorySoloAmbient")
  }

  public struct CategoryOptions: OptionSet, Sendable {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }

    public static let mixWithOthers = CategoryOptions(rawValue: 1 << 0)
    public static let duckOthers = CategoryOptions(rawValue: 1 << 1)
  }

  public struct SetActiveOptions: OptionSet, Sendable {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }

    public static let notifyOthersOnDeactivation = SetActiveOptions(rawValue: 1 << 0)
  }

  private static let shared = AVAudioSession()
  public static func sharedInstance() -> AVAudioSession { shared }

  public private(set) var category: Category = .ambient
  public private(set) var categoryOptions: CategoryOptions = []
  public private(set) var isActive: Bool = false

  public func setCategory(_ category: Category, options: CategoryOptions = []) throws {
    self.category = category
    categoryOptions = options
  }

  public func setActive(_ active: Bool, options: SetActiveOptions = []) throws {
    isActive = active
  }
}

// MARK: - Playback

public class AVPlayerItem: @unchecked Sendable {
  public let asset: AVAsset
  public init(asset: AVAsset) { self.asset = asset }
  public init(url: URL) { asset = AVURLAsset(url: url) }
}

public enum AVPlayerAudiovisualBackgroundPlaybackPolicy: Int, Sendable {
  case automatic, pauses, continuesIfPossible
}

/// Inert player: it tracks the state the app sets and reads back, but never
/// decodes or plays anything.
public class AVPlayer: @unchecked Sendable {
  public var currentItem: AVPlayerItem?
  public var isMuted: Bool = false
  public var rate: Float = 0
  public var audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy =
    .automatic
  public var preventsDisplaySleepDuringVideoPlayback: Bool = true
  public private(set) var currentTime: CMTime = .zero

  public init() {}

  public init(url: URL) {
    currentItem = AVPlayerItem(url: url)
  }

  public init(playerItem: AVPlayerItem?) {
    currentItem = playerItem
  }

  public func play() { rate = 1 }
  public func pause() { rate = 0 }
  public func seek(to time: CMTime) { currentTime = time }
  public func replaceCurrentItem(with item: AVPlayerItem?) { currentItem = item }
}

extension Notification.Name {
  /// Never posted in the preview: nothing plays, so nothing reaches its end.
  /// Observers register and simply stay idle.
  public static let AVPlayerItemDidPlayToEndTime = Notification.Name(
    "AVPlayerItemDidPlayToEndTimeNotification")
}
