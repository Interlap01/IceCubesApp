// Preview adapter for AVKit.
//
// AVKit wraps native video playback surfaces, which the preview cannot run.
// The app uses exactly one thing from it, `VideoPlayer`, plus the AVFoundation
// names AVKit re-exports (AVPlayer, AVAudioSession, .AVPlayerItemDidPlayToEndTime).
//
// VideoPlayer draws as a black frame with the app's own overlay on top, so a
// screen holding a video still lays out and still exercises its overlay
// controls in the preview.

@_exported import AVFoundation
import SwiftUI

public struct VideoPlayer<VideoOverlay: View>: View {
  private let player: AVPlayer?
  private let videoOverlay: () -> VideoOverlay

  public init(player: AVPlayer?, @ViewBuilder videoOverlay: @escaping () -> VideoOverlay) {
    self.player = player
    self.videoOverlay = videoOverlay
  }

  public var body: some View {
    Color.black
      .overlay { videoOverlay() }
  }
}

extension VideoPlayer where VideoOverlay == EmptyView {
  public init(player: AVPlayer?) {
    self.init(player: player, videoOverlay: { EmptyView() })
  }
}
