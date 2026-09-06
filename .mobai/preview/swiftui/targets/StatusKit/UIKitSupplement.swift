// Preview supplement compiled into StatusKit's preview copy.
//
// StatusKit's UIKit-backed compose text view (Editor/UITextView/TextView.swift)
// reaches two UIKit names the preview engine does not carry:
//
//   - UIViewControllerTransitionCoordinator, the type of the coordinator handed
//     to viewWillTransition(to:with:)
//   - UIViewController.loadView() and .viewWillTransition(to:with:), which the
//     engine's UIViewController does not declare, so the app's `override`s have
//     nothing to override
//
// The app's own sources are never edited, so the type is declared here and the
// controller is shadowed: `UIViewController` below is StatusKit's own name for
// a subclass of the engine's, so `TextViewController: UIViewController` binds
// to this one and its overrides compile. It still IS an engine
// UIViewController, so UIViewControllerRepresentable keeps accepting it.

import Foundation
import MobAIPreviewFoundation

public protocol UIViewControllerTransitionCoordinatorContext {}

public protocol UIViewControllerTransitionCoordinator: UIViewControllerTransitionCoordinatorContext {
  @discardableResult
  func animate(
    alongsideTransition animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?,
    completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?
  ) -> Bool
}

open class UIViewController: MobAIPreviewFoundation.UIViewController {
  public override init() { super.init() }

  public init(nibName: String?, bundle: Bundle?) { super.init() }

  public required init?(coder: NSCoder) { super.init() }

  /// UIKit calls this to build `view`. The engine never does, so `viewDidLoad`
  /// below calls it instead and the app's real `view = textView` still runs.
  open func loadView() {}

  /// Nothing rotates in the preview, so this is never called.
  open func viewWillTransition(
    to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator
  ) {}

  open override func viewDidLoad() {
    super.viewDidLoad()
    loadView()
  }
}
