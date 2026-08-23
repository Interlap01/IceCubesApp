import SwiftUI

/// Preview-only harness for the app's DesignSystem `ErrorView`.
/// Mirrors Packages/DesignSystem/Sources/DesignSystem/Views/ErrorView.swift.
struct ErrorScreen: View {
  let title: String = "Error"
  let message: String = "Error loading. Please try again"
  let buttonTitle: String = "Retry"

  var body: some View {
    HStack {
      Spacer()
      VStack {
        Image(systemName: "exclamationmark.triangle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(maxHeight: 50)
        Text(title)
          .font(.title)
          .padding(.top, 16)
        Text(message)
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .foregroundStyle(.secondary)
        Button {
        } label: {
          Text(buttonTitle)
        }
        .buttonStyle(.bordered)
        .padding(.top, 16)
      }
      .padding(.top, 100)
      .padding(20)
      Spacer()
    }
  }
}
