// Preview adapter for NukeUI (https://github.com/kean/Nuke).
// LazyImage decodes remote bitmaps, which the preview has no image backend
// for, so it draws a neutral placeholder at the same size and hands the
// app's content closure a settled, empty LazyImageState. Layout, sizing and
// every branch around the image are therefore real; only the pixels are not.

import Nuke
import SwiftUI

@MainActor
public struct LazyImageState {
  public let image: Image?
  public let imageContainer: ImageContainer?
  public let error: Error?
  public let isLoading: Bool
  public let progress: Progress

  public struct Progress: Equatable, Sendable {
    public var completed: Int64 = 0
    public var total: Int64 = 0
    public var fraction: Float { total > 0 ? Float(completed) / Float(total) : 0 }
  }

  init(isLoading: Bool = false) {
    image = nil
    imageContainer = nil
    error = nil
    self.isLoading = isLoading
    progress = Progress()
  }
}

/// The stand-in bitmap: a flat rounded fill sized by the surrounding layout.
private struct PreviewImagePlaceholder: View {
  var body: some View {
    Rectangle()
      .fill(Color.gray.opacity(0.22))
  }
}

@MainActor
public struct LazyImage<Content: View>: View {
  private let request: ImageRequest?
  private let content: ((LazyImageState) -> Content)?
  private let transaction: Transaction

  public var body: some View {
    if let content {
      // The state is settled rather than loading: a spinner that never
      // resolves would misrepresent the screen it is standing in for.
      content(LazyImageState())
    } else {
      PreviewImagePlaceholder()
    }
  }

  // MARK: Modifiers, kept so call sites compile unchanged

  public func processors(_ processors: [any ImageProcessing]?) -> LazyImage { self }
  public func priority(_ priority: ImageRequest.Priority?) -> LazyImage { self }
  public func pipeline(_ pipeline: ImagePipeline) -> LazyImage { self }
  public func onStart(_ closure: @escaping (Any) -> Void) -> LazyImage { self }
  public func onSuccess(_ closure: @escaping (Any) -> Void) -> LazyImage { self }
  public func onFailure(_ closure: @escaping (Error) -> Void) -> LazyImage { self }
  public func onCompletion(_ closure: @escaping (Result<ImageContainer, Error>) -> Void) -> LazyImage { self }
}

extension LazyImage where Content == AnyView {
  public init(url: URL?) {
    request = ImageRequest(url: url)
    content = nil
    transaction = Transaction()
  }

  public init(request: ImageRequest?) {
    self.request = request
    content = nil
    transaction = Transaction()
  }
}

extension LazyImage {
  public init(
    url: URL?, transaction: Transaction = Transaction(),
    @ViewBuilder content: @escaping (LazyImageState) -> Content
  ) {
    request = ImageRequest(url: url)
    self.content = content
    self.transaction = transaction
  }

  public init(
    request: ImageRequest?, transaction: Transaction = Transaction(),
    @ViewBuilder content: @escaping (LazyImageState) -> Content
  ) {
    self.request = request
    self.content = content
    self.transaction = transaction
  }
}
