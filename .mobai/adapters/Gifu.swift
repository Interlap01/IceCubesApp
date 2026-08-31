// Preview adapter for Gifu (https://github.com/kaishin/Gifu).
// Gifu decodes and animates GIF frames into a UIImageView. The preview has
// no image backend, so GIFImageView is a plain UIImageView that accepts the
// same calls and animates nothing; GifView's own layout code still runs.

import UIKit

public class GIFImageView: UIImageView {
  public private(set) var isAnimatingGIF: Bool = false
  public private(set) var gifData: Data?
  public private(set) var loopCount: Int = 0

  public func prepareForAnimation(
    withGIFData data: Data, loopCount: Int = 0, preparationBlock: (() -> Void)? = nil
  ) {
    gifData = data
    self.loopCount = loopCount
    preparationBlock?()
  }

  public func prepareForAnimation(
    withGIFNamed name: String, loopCount: Int = 0, preparationBlock: (() -> Void)? = nil
  ) {
    self.loopCount = loopCount
    preparationBlock?()
  }

  public func animate(
    withGIFData data: Data, loopCount: Int = 0, preparationBlock: (() -> Void)? = nil,
    animationBlock: (() -> Void)? = nil
  ) {
    gifData = data
    self.loopCount = loopCount
    preparationBlock?()
    isAnimatingGIF = true
  }

  public func startAnimatingGIF() { isAnimatingGIF = true }
  public func stopAnimatingGIF() { isAnimatingGIF = false }
  public func prepareForReuse() {
    gifData = nil
    isAnimatingGIF = false
  }
}

public protocol GIFAnimatable: AnyObject {}
