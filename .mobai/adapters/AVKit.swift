// Generated from MobAI normalized Apple SDK IR.
// Module: AVKit
// Extracted SDK modules: AVKit, AVKit.AVCaptureEvent, AVKit.AVCaptureEventInteraction, AVKit.AVCaptureEventSound, AVKit.AVError, AVKit.AVInputPickerInteraction, AVKit.AVInterstitialTimeRange, AVKit.AVKitDefines, AVKit.AVKitTypes, AVKit.AVLegibleMediaOptionsMenuController, AVKit.AVPictureInPictureController, AVKit.AVPictureInPictureController_AVSampleBufferDisplayLayerSupport, AVKit.AVPictureInPictureController_VideoCallSupport, AVKit.AVPlaybackRouteSelecting, AVKit.AVPlaybackSpeed, AVKit.AVPlayerItem_AVKitAdditions, AVKit.AVPlayerViewController, AVKit.AVRoutePickerView, _AVKit_SwiftUI
// This project copy is editable; catalog expansion only appends missing declarations.

import Foundation
import SwiftUI






// mobai-ir-declaration: VideoPlayer
/// No video decoder in the preview, so the frame is a flat placeholder --
/// but the app's `videoOverlay` is a real view and is drawn over it, which
/// is where the play button and controls live.
public struct VideoPlayer<VideoOverlay>: SwiftUI.View where VideoOverlay: SwiftUI.View {
    private let videoOverlay: () -> VideoOverlay

    public var body: some SwiftUI.View {
        ZStack {
            Rectangle().fill(Color.black.opacity(0.85))
            videoOverlay()
        }
    }
}

extension VideoPlayer {
    public init(player: AVPlayer?, @SwiftUI.ViewBuilder videoOverlay: @escaping () -> VideoOverlay) {
        self.videoOverlay = videoOverlay
    }
}

extension VideoPlayer where VideoOverlay == SwiftUI.EmptyView {
    public init(player: AVPlayer?) {
        videoOverlay = { SwiftUI.EmptyView() }
    }
}


/// Thrown by everything below.
///
/// A stand-in has no behaviour to offer, and throwing is the only
/// way to satisfy a return type without inventing a value. At a
/// `try?` call site this becomes nil, so the screen renders empty
/// rather than wrong, and nothing crashes.
public enum MockUnavailable: Error { case notImplemented }


/// Playback has no backend in the preview, but the view model drives this
/// object through a real sequence of calls, so it keeps its state honestly:
/// what is written back reads back.
public enum AVPlayerAudiovisualBackgroundPlaybackPolicy: Sendable {
    case automatic
    case pauses
    case continuesIfPossible
}

open class AVPlayerItem: @unchecked Sendable {
    public let url: URL?
    nonisolated public init() { url = nil }
    nonisolated public init(url: URL) { self.url = url }
}

open class AVPlayer: @unchecked Sendable {
    nonisolated public init() {}
    nonisolated public init(url: URL) { currentItem = AVPlayerItem(url: url) }
    nonisolated public init(playerItem: AVPlayerItem?) { currentItem = playerItem }

    /// Stored, so `player?.isMuted = mute` reads back what it wrote.
    nonisolated(unsafe) public var isMuted: Bool = false
    nonisolated(unsafe) public var currentItem: AVPlayerItem?
    nonisolated(unsafe) public var audiovisualBackgroundPlaybackPolicy:
        AVPlayerAudiovisualBackgroundPlaybackPolicy = .automatic
    nonisolated(unsafe) public var preventsDisplaySleepDuringVideoPlayback: Bool = true
}

extension Notification.Name {
    public static let AVPlayerItemDidPlayToEndTime =
        Notification.Name("AVPlayerItemDidPlayToEndTime")
}


extension AVPlayer {
    /// Added because the compiler asked for it by name.
    ///
    /// Does not throw: it has a value to return, so throwing
    /// would only force `try` onto call sites that have no
    /// reason to expect it. Only the generic form throws,
    /// because that is the one with nothing to return.
    ///
    /// Returns the receiver rather than a generic value, because
    /// the libraries that need standing in for are usually
    /// fluent: `document.select("p").after("x")` chains, and a
    /// generic return has nothing to chain from, which the
    /// compiler reports as "failed to produce diagnostic for
    /// expression" rather than anything actionable.
    ///
    /// Returning self is also the only value available that is
    /// not invented: it carries no data of its own.
    @discardableResult
    nonisolated public func play(_ arguments: Any...) -> AVPlayer { self }
}


extension AVPlayer {
    /// Added because the compiler asked for it by name.
    ///
    /// Does not throw: it has a value to return, so throwing
    /// would only force `try` onto call sites that have no
    /// reason to expect it. Only the generic form throws,
    /// because that is the one with nothing to return.
    ///
    /// Returns the receiver rather than a generic value, because
    /// the libraries that need standing in for are usually
    /// fluent: `document.select("p").after("x")` chains, and a
    /// generic return has nothing to chain from, which the
    /// compiler reports as "failed to produce diagnostic for
    /// expression" rather than anything actionable.
    ///
    /// Returning self is also the only value available that is
    /// not invented: it carries no data of its own.
    @discardableResult
    nonisolated public func pause(_ arguments: Any...) -> AVPlayer { self }
}


// isMuted is a stored property on AVPlayer above, so the generated
// get-only version is gone: the app assigns to it.


/// Added because the compiler asked for it by name.
open class CMTime: @unchecked Sendable {
    nonisolated public init() {}
    nonisolated public init(seconds: Double, preferredTimescale: Int32 = 600) {
        self.seconds = seconds
    }
    nonisolated(unsafe) public var seconds: Double = 0
    public static let zero = CMTime()
}


extension AVPlayer {
    /// Added because the compiler asked for it by name.
    ///
    /// Does not throw: it has a value to return, so throwing
    /// would only force `try` onto call sites that have no
    /// reason to expect it. Only the generic form throws,
    /// because that is the one with nothing to return.
    ///
    /// Returns the receiver rather than a generic value, because
    /// the libraries that need standing in for are usually
    /// fluent: `document.select("p").after("x")` chains, and a
    /// generic return has nothing to chain from, which the
    /// compiler reports as "failed to produce diagnostic for
    /// expression" rather than anything actionable.
    ///
    /// Returning self is also the only value available that is
    /// not invented: it carries no data of its own.
    @discardableResult
    nonisolated public func seek(_ arguments: Any...) -> AVPlayer { self }
}


/// The preview has no audio session; these calls record intent and succeed,
/// which is what the `try?` call sites expect.
open class AVAudioSession: @unchecked Sendable {
    public struct Category: Sendable, Equatable {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let ambient = Category(rawValue: "ambient")
        public static let playback = Category(rawValue: "playback")
        public static let playAndRecord = Category(rawValue: "playAndRecord")
        public static let soloAmbient = Category(rawValue: "soloAmbient")
        public static let record = Category(rawValue: "record")
    }

    public struct CategoryOptions: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let mixWithOthers = CategoryOptions(rawValue: 1)
        public static let duckOthers = CategoryOptions(rawValue: 2)
        public static let allowBluetooth = CategoryOptions(rawValue: 4)
        public static let defaultToSpeaker = CategoryOptions(rawValue: 8)
    }

    public struct SetActiveOptions: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let notifyOthersOnDeactivation = SetActiveOptions(rawValue: 1)
    }

    private static let instance = AVAudioSession()

    nonisolated(unsafe) public private(set) var category: Category = .soloAmbient
    nonisolated(unsafe) public private(set) var isActive: Bool = false

    nonisolated public init() {}

    nonisolated public static func sharedInstance() -> AVAudioSession { instance }

    nonisolated public func setActive(_ active: Bool, options: SetActiveOptions = []) throws {
        isActive = active
    }

    nonisolated public func setCategory(_ category: Category, options: CategoryOptions = []) throws {
        self.category = category
    }

    nonisolated public func setCategory(
        _ category: Category, mode: String = "", options: CategoryOptions = []
    ) throws {
        self.category = category
    }
}


// VideoPlayer declares its real initializers above.


// AVAudioSession.sharedInstance() is declared on the class above.


extension AVPlayer {
    /// Added because the compiler asked for the label.
    @discardableResult
    nonisolated public func seek(to: Any, _ rest: Any...) -> AVPlayer { self }
}
// MARK: - Unfinished
//
//  4 thing(s) the compiler asked for that this engine
//  could not work out. Everything else in this file it wrote itself.
//
//  Fill these in and the screen compiles. The engine only ever ADDS to
//  this file, so what you write here stays.

//  1. `AVPlayer.audiovisualBackgroundPlaybackPolicy`, wanted at ios_MediaUIAttachmentVideoView.swift:23
//
//         player?.audiovisualBackgroundPlaybackPolicy = .pauses
//
//     a property's type cannot be inferred from the code that reads it:
//     the compiler says the member is missing, never what type it
//     should have been.
//
//     extension AVPlayer {
//         nonisolated public var audiovisualBackgroundPlaybackPolicy: <Type> { <value> }
//     }


//  2. `AVPlayer.preventsDisplaySleepDuringVideoPlayback`, wanted at ios_MediaUIAttachmentVideoView.swift:25
//
//         player?.preventsDisplaySleepDuringVideoPlayback = false
//
//     a property's type cannot be inferred from the code that reads it:
//     the compiler says the member is missing, never what type it
//     should have been.
//
//     extension AVPlayer {
//         nonisolated public var preventsDisplaySleepDuringVideoPlayback: <Type> { <value> }
//     }


//  3. `AVPlayer.currentItem`, wanted at ios_MediaUIAttachmentVideoView.swift:40
//
//         object: player.currentItem, queue: .main
//
//     this call passes a leading-dot expression, which resolves against
//     the parameter's declared type. A stand-in declares parameters as
//     `Any`, and nothing can be inferred from `Any`, so the parameter
//     needs a REAL type here - one of the types listed below is usually
//     it.
//
//     extension AVPlayer {
//         nonisolated public var currentItem: <Type> { <value> }
//     }


//  4. `CMTime.zero`, wanted at ios_MediaUIAttachmentVideoView.swift:68
//
//         player?.seek(to: CMTime.zero)
//
//     a property's type cannot be inferred from the code that reads it:
//     the compiler says the member is missing, never what type it
//     should have been.
//
//     extension CMTime {
//         nonisolated public var zero: <Type> { <value> }
//     }


//  Types this stand-in already declares, in case one of them is the
//  one a call site above is asking for:
//
//      AVAudioSession, AVPlayer, CMTime

// MARK: - End unfinished
