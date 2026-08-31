// Preview adapter for Nuke (https://github.com/kean/Nuke).
// Nuke decodes and caches real bitmaps, which the preview has no image
// backend for. This keeps the request/processor/cache vocabulary the app
// builds its views out of, backed by an in-memory data cache.

import Foundation

// MARK: - Processing

public protocol ImageProcessing: Sendable {
  var identifier: String { get }
}

public enum ImageProcessors {
  public struct Resize: ImageProcessing, Hashable, Sendable {
    public let size: CGSize
    public let unit: Unit
    public let crop: Bool

    public enum Unit: Sendable, Hashable {
      case points, pixels
    }

    public init(size: CGSize, unit: Unit = .points, crop: Bool = false) {
      self.size = size
      self.unit = unit
      self.crop = crop
    }

    public var identifier: String { "resize(\(size.width)x\(size.height),crop:\(crop))" }
  }

  public struct Circle: ImageProcessing, Hashable, Sendable {
    public init() {}
    public var identifier: String { "circle" }
  }

  public struct RoundedCorners: ImageProcessing, Hashable, Sendable {
    public let radius: CGFloat
    public init(radius: CGFloat) { self.radius = radius }
    public var identifier: String { "rounded(\(radius))" }
  }
}

extension ImageProcessing where Self == ImageProcessors.Resize {
  public static func resize(size: CGSize, unit: ImageProcessors.Resize.Unit = .points, crop: Bool = false) -> ImageProcessors.Resize {
    ImageProcessors.Resize(size: size, unit: unit, crop: crop)
  }
}

extension ImageProcessing where Self == ImageProcessors.Circle {
  public static func circle() -> ImageProcessors.Circle { ImageProcessors.Circle() }
}

// MARK: - Requests

public struct ImageRequest: Hashable, Sendable {
  public enum Priority: Int, Sendable, Comparable {
    case veryLow, low, normal, high, veryHigh
    public static func < (lhs: Priority, rhs: Priority) -> Bool { lhs.rawValue < rhs.rawValue }
  }

  public var url: URL?
  public var priority: Priority
  public let processorIdentifiers: [String]

  public init(url: URL?, processors: [any ImageProcessing] = [], priority: Priority = .normal) {
    self.url = url
    self.priority = priority
    processorIdentifiers = processors.map(\.identifier)
  }

  public init(urlRequest: URLRequest, processors: [any ImageProcessing] = [], priority: Priority = .normal) {
    self.init(url: urlRequest.url, processors: processors, priority: priority)
  }

  public var imageId: String? { url?.absoluteString }
}

// MARK: - Containers

public enum AssetType: String, Sendable {
  case png, jpeg, gif, webp, heic, mp4
}

public final class ImageContainer: @unchecked Sendable {
  public let data: Data?
  public let type: AssetType?
  public let isPreview: Bool

  public init(data: Data? = nil, type: AssetType? = nil, isPreview: Bool = false) {
    self.data = data
    self.type = type
    self.isPreview = isPreview
  }
}

// MARK: - Cache

public final class ImagePipelineCache: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [String: Data] = [:]

  public func cachedData(for request: ImageRequest) -> Data? {
    guard let key = request.imageId else { return nil }
    lock.lock(); defer { lock.unlock() }
    return storage[key]
  }

  public func storeCachedData(_ data: Data, for request: ImageRequest) {
    guard let key = request.imageId else { return }
    lock.lock(); defer { lock.unlock() }
    storage[key] = data
  }

  public func removeCachedData(for request: ImageRequest) {
    guard let key = request.imageId else { return }
    lock.lock(); defer { lock.unlock() }
    storage[key] = nil
  }

  public func removeAll() {
    lock.lock(); defer { lock.unlock() }
    storage.removeAll()
  }
}

public final class DataLoader: @unchecked Sendable {
  public static var sharedUrlCache: URLCache { URLCache.shared }
  public init() {}
}

public final class ImagePipeline: @unchecked Sendable {
  public static let shared = ImagePipeline()

  public struct Configuration: Sendable {
    public var dataLoadingQueueMaxConcurrentOperationCount: Int = 6
    public init() {}
  }

  public let cache = ImagePipelineCache()
  public var configuration = Configuration()

  public init() {}
  public init(configuration: Configuration) { self.configuration = configuration }
  public convenience init(_ configure: (inout Configuration) -> Void) {
    var configuration = Configuration()
    configure(&configuration)
    self.init(configuration: configuration)
  }

  /// Fetches through URLSession, which the preview engine intercepts.
  @discardableResult
  public func data(for request: ImageRequest) async throws -> (Data, URLResponse?) {
    guard let url = request.url else { return (Data(), nil) }
    if let cached = cache.cachedData(for: request) { return (cached, nil) }
    let (data, response) = try await URLSession.shared.data(from: url)
    cache.storeCachedData(data, for: request)
    return (data, response)
  }
}
