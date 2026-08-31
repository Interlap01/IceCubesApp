// Preview adapter for EmojiText (https://github.com/Dimillian/EmojiText).
// The real package renders markdown with remote custom emoji swapped in as
// inline images. The preview has no image backend, so this renders the same
// markdown through SwiftUI's own AttributedString parsing and leaves the
// :shortcode: text in place where an emoji image would be.

import SwiftUI

public protocol CustomEmoji: Sendable {
  var shortcode: String { get }
}

public struct RemoteEmoji: CustomEmoji, Sendable {
  public let shortcode: String
  public let url: URL

  public init(shortcode: String, url: URL) {
    self.shortcode = shortcode
    self.url = url
  }
}

public struct LocalEmoji: CustomEmoji, Sendable {
  public let shortcode: String

  public init(shortcode: String) {
    self.shortcode = shortcode
  }
}

@MainActor
public struct EmojiText: View {
  private let markdown: String
  private let emojis: [any CustomEmoji]
  private var appended: (@Sendable () -> Text)?

  public init(markdown: String, emojis: [any CustomEmoji]) {
    self.markdown = markdown
    self.emojis = emojis
  }

  public init(verbatim: String, emojis: [any CustomEmoji]) {
    markdown = verbatim
    self.emojis = emojis
  }

  public var body: some View {
    if let appended {
      text + appended()
    } else {
      text
    }
  }

  private var text: Text {
    let options = AttributedString.MarkdownParsingOptions(
      allowsExtendedAttributes: true,
      interpretedSyntax: .inlineOnlyPreservingWhitespace)
    if let attributed = try? AttributedString(markdown: markdown, options: options) {
      return Text(attributed)
    }
    return Text(markdown)
  }

  /// Animation of emoji images has nothing to animate here.
  public func animated(_ animated: Bool = true) -> EmojiText { self }

  public func append(text: @escaping @Sendable () -> Text) -> EmojiText {
    var copy = self
    copy.appended = text
    return copy
  }

  public func placeholder(_ placeholder: @escaping () -> some View) -> EmojiText { self }
}

// MARK: - The `.emojiText.<knob>` modifier namespace

public struct EmojiTextNamespace<Content: View> {
  let content: Content

  /// Sizing knobs act on the emoji images, which are absent here; the
  /// surrounding text keeps its own font, so these pass the view through.
  public func size(_ size: CGFloat?) -> Content { content }
  public func baselineOffset(_ offset: CGFloat?) -> Content { content }
  public func animatedMode(_ mode: Int) -> Content { content }
  public func omitSpacesBetweenEmojis(_ omit: Bool) -> Content { content }
}

extension View {
  public var emojiText: EmojiTextNamespace<Self> { EmojiTextNamespace(content: self) }
}

