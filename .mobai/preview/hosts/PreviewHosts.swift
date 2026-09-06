// Preview hosts for IceCubesApp.
//
// A screen previewed with `--entry` renders on its own, without the ancestors
// the running app would have given it. IceCubesApp's screens read their
// dependencies out of the environment, so a screen rendered bare stops with
// "No Observable of type RouterPath found".
//
// Each host below injects what IceCubesApp+Scene.swift injects around AppView
// (the same shared singletons `withEnvironments()` uses, plus the per-tab
// RouterPath) and then renders the REAL screen, unchanged. Nothing here draws
// UI of its own - these are harnesses, not stand-in screens.
//
//   mobai-dev preview run --detach --entry .mobai/preview/hosts/PreviewHosts.swift#PreviewAboutHost
//
// This file lives outside `sources/` on purpose: a file under `sources/` is
// compiled into the app module on every run, so using it as an entry too
// stages it twice and every declaration collides.

import AppAccount
import DesignSystem
import Env
import SwiftUI

/// The app's environment, as the running app assembles it.
struct PreviewEnvironment<Content: View>: View {
  @State private var routerPath = RouterPath()

  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    NavigationStack(path: $routerPath.path) {
      content
    }
    .environment(routerPath)
    .environment(CurrentAccount.shared)
    .environment(UserPreferences.shared)
    .environment(CurrentInstance.shared)
    .environment(Theme.shared)
    .environment(AppAccountsManager.shared)
    .environment(PushNotificationsService.shared)
    .environment(AppAccountsManager.shared.currentClient)
    .environment(QuickLook.shared)
    .environment(ToastCenter.shared)
  }
}

struct PreviewAboutHost: View {
  var body: some View {
    PreviewEnvironment {
      AboutView()
    }
  }
}
