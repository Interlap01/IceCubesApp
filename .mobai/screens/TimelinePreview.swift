// Preview entry for the timeline row -- the screen Ice Cubes is mostly made of.
//
// The engine renders one screen, so nothing runs the root environment
// injection IceCubesApp does at launch; this wrapper is that root. It mirrors
// Env/PreviewEnv.swift's `withPreviewsEnv()`, plus the ToastCenter and
// isHomeTimeline that StatusRowView reads, and feeds it Status.placeholders(),
// the app's own sample data.
//
// It lives under .mobai/, which Xcode's synchronized group ignores, so it is
// never part of the shipped app.

import DesignSystem
import Env
import Models
import NetworkClient
import StatusKit
import SwiftUI

struct TimelinePreview: View {
  // Built once: a new client or router per body pass would reset the rows.
  private let client = MastodonClient(server: "mastodon.social")
  private let routerPath = RouterPath()

  // The engine caps dynamically generated rows per stack, and a handful of
  // rows shows the same design decisions as a full timeline.
  private let statuses = Array(Status.placeholders().prefix(8))

  var body: some View {
    NavigationStack {
      List {
        ForEach(statuses) { status in
          // StatusRowView's own initializer is internal; this is the
          // public entry point StatusKit exposes for exactly this.
          StatusRowExternalView(
            viewModel: .init(status: status, client: client, routerPath: routerPath),
            context: .timeline
          )
          .listRowBackground(Theme.shared.primaryBackgroundColor)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Home")
    }
    .environment(\.isHomeTimeline, true)
    .environment(routerPath)
    .environment(client)
    .environment(Theme.shared)
    .environment(ToastCenter.shared)
    .environment(SceneDelegate())
    .environment(CurrentAccount.shared)
    .environment(CurrentInstance.shared)
    .environment(UserPreferences.shared)
    .environment(PushNotificationsService.shared)
    .environment(QuickLook.shared)
  }
}
