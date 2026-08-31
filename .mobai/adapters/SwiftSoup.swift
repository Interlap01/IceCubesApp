// Preview adapter for SwiftSoup (https://github.com/scinfu/SwiftSoup).
//
// Models/Alias/HTMLString.swift turns a status' HTML into markdown, so the
// preview needs a real parse, not a stub: without one every post body renders
// empty. This is a small tree-building HTML parser covering exactly the
// surface HTMLString uses -- parse, clean, select/remove/after, node walking
// and entity unescaping -- and nothing else.

import Foundation

public enum SwiftSoupError: Error {
  case parseFailure(String)
}

// MARK: - Output settings

public class OutputSettings {
  public private(set) var prettyPrintEnabled: Bool = true

  public init() {}

  @discardableResult
  public func prettyPrint(pretty: Bool) -> OutputSettings {
    prettyPrintEnabled = pretty
    return self
  }
}

// MARK: - Whitelist

public class Whitelist {
  /// Tags permitted through `clean`. `none` keeps no tags, which is how
  /// HTMLString extracts plain text.
  public private(set) var allowedTags: Set<String> = []

  public init() {}

  public static func none() throws -> Whitelist { Whitelist() }

  public static func basic() throws -> Whitelist {
    let list = Whitelist()
    list.allowedTags = ["a", "b", "blockquote", "br", "code", "em", "i", "li", "ol", "p", "strong", "ul"]
    return list
  }
}

// MARK: - Entities

public enum Entities {
  private static let named: [String: String] = [
    "amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": "\u{00A0}",
    "hellip": "…", "mdash": "—", "ndash": "–", "lsquo": "\u{2018}", "rsquo": "\u{2019}",
    "ldquo": "\u{201C}", "rdquo": "\u{201D}", "laquo": "«", "raquo": "»", "copy": "©",
    "reg": "®", "trade": "™", "deg": "°", "middot": "·", "bull": "•", "eacute": "é",
    "egrave": "è", "agrave": "à", "ccedil": "ç", "uuml": "ü", "ouml": "ö", "auml": "ä",
    "szlig": "ß", "euro": "€", "pound": "£", "yen": "¥", "sect": "§", "para": "¶",
  ]

  public static func unescape(_ string: String) throws -> String {
    guard string.contains("&") else { return string }
    var out = ""
    out.reserveCapacity(string.count)
    var rest = Substring(string)

    while let amp = rest.firstIndex(of: "&") {
      out += rest[rest.startIndex..<amp]
      let afterAmp = rest.index(after: amp)
      // An entity is short; look at most 12 characters ahead for its ';'.
      let limit = rest.index(afterAmp, offsetBy: 12, limitedBy: rest.endIndex) ?? rest.endIndex
      guard let semi = rest[afterAmp..<limit].firstIndex(of: ";") else {
        out.append("&")
        rest = rest[afterAmp...]
        continue
      }
      let body = String(rest[afterAmp..<semi])
      if let replacement = decode(body) {
        out += replacement
      } else {
        out += "&\(body);"
      }
      rest = rest[rest.index(after: semi)...]
    }
    out += rest
    return out
  }

  private static func decode(_ body: String) -> String? {
    if body.hasPrefix("#") {
      let digits = String(body.dropFirst())
      let scalarValue: UInt32?
      if digits.hasPrefix("x") || digits.hasPrefix("X") {
        scalarValue = UInt32(digits.dropFirst(), radix: 16)
      } else {
        scalarValue = UInt32(digits, radix: 10)
      }
      guard let value = scalarValue, let scalar = Unicode.Scalar(value) else { return nil }
      return String(Character(scalar))
    }
    return named[body]
  }

  static func escape(_ string: String) -> String {
    var out = ""
    out.reserveCapacity(string.count)
    for character in string {
      switch character {
      case "&": out += "&amp;"
      case "<": out += "&lt;"
      case ">": out += "&gt;"
      default: out.append(character)
      }
    }
    return out
  }
}

// MARK: - Nodes

public class Node: CustomStringConvertible {
  public internal(set) var childNodes: [Node] = []
  public internal(set) weak var parentNode: Node?
  var attributes: [String: String] = [:]

  init() {}

  public func nodeName() -> String { "#node" }

  public func getChildNodes() -> [Node] { childNodes }

  public func attr(_ key: String) throws -> String {
    attributes[key.lowercased()] ?? ""
  }

  public func hasAttr(_ key: String) -> Bool {
    attributes[key.lowercased()] != nil
  }

  @discardableResult
  public func attr(_ key: String, _ value: String) throws -> Node {
    attributes[key.lowercased()] = value
    return self
  }

  func appendChild(_ node: Node) {
    node.parentNode = self
    childNodes.append(node)
  }

  /// Removes this node from its parent.
  public func remove() {
    guard let parent = parentNode,
      let index = parent.childNodes.firstIndex(where: { $0 === self })
    else { return }
    parent.childNodes.remove(at: index)
    parentNode = nil
  }

  /// Inserts parsed `html` as siblings directly after this node.
  @discardableResult
  public func after(_ html: String) throws -> Node {
    guard let parent = parentNode,
      let index = parent.childNodes.firstIndex(where: { $0 === self })
    else { return self }
    let inserted = HTMLParser.parseFragment(html)
    for node in inserted { node.parentNode = parent }
    parent.childNodes.insert(contentsOf: inserted, at: index + 1)
    return self
  }

  /// Outer HTML, matching SwiftSoup's `description`.
  public var description: String { outerHTML() }

  func outerHTML() -> String { childNodes.map { $0.outerHTML() }.joined() }

  func textContent() -> String { childNodes.map { $0.textContent() }.joined() }

  /// Depth-first walk in document order, this node included.
  func walk(_ visit: (Node) -> Void) {
    visit(self)
    for child in childNodes { child.walk(visit) }
  }
}

public final class TextNode: Node {
  /// Stored exactly as it appeared in the source, entities and all, because
  /// HTMLString unescapes it itself.
  public var text: String

  init(text: String) {
    self.text = text
    super.init()
  }

  public override func nodeName() -> String { "#text" }
  public override var description: String { text }
  override func outerHTML() -> String { text }
  override func textContent() -> String { text }
}

public final class Comment: Node {
  let data: String

  init(data: String) {
    self.data = data
    super.init()
  }

  public override func nodeName() -> String { "#comment" }
  override func outerHTML() -> String { "<!--\(data)-->" }
  override func textContent() -> String { "" }
}

public class Element: Node {
  public let tagName: String

  init(tagName: String, attributes: [String: String] = [:]) {
    self.tagName = tagName.lowercased()
    super.init()
    self.attributes = attributes
  }

  public override func nodeName() -> String { tagName }

  public func tagNameNormal() -> String { tagName }

  public var classNames: Set<String> {
    Set((attributes["class"] ?? "").split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).map(String.init))
  }

  public func hasClass(_ name: String) -> Bool { classNames.contains(name) }

  public func text() -> String {
    textContent()
  }

  public func html() throws -> String {
    childNodes.map { $0.outerHTML() }.joined()
  }

  public func select(_ query: String) throws -> Elements {
    let selector = try Selector(query)
    var matches: [Element] = []
    walk { node in
      guard let element = node as? Element, !(element is Document) else { return }
      if selector.matches(element) { matches.append(element) }
    }
    return Elements(matches)
  }

  override func outerHTML() -> String {
    let attrs = attributes
      .sorted { $0.key < $1.key }
      .map { " \($0.key)=\"\(Entities.escape($0.value))\"" }
      .joined()
    if HTMLParser.voidElements.contains(tagName) {
      return "<\(tagName)\(attrs)>"
    }
    let inner = childNodes.map { $0.outerHTML() }.joined()
    return "<\(tagName)\(attrs)>\(inner)</\(tagName)>"
  }
}

public final class Document: Element {
  private var settings = OutputSettings()

  init() { super.init(tagName: "#document") }

  public override func nodeName() -> String { "#document" }

  @discardableResult
  public func outputSettings(_ settings: OutputSettings) -> Document {
    self.settings = settings
    return self
  }

  public func outputSettings() -> OutputSettings { settings }

  override func outerHTML() -> String {
    childNodes.map { $0.outerHTML() }.joined()
  }
}

// MARK: - Element collections

public final class Elements {
  private let elements: [Element]

  init(_ elements: [Element]) { self.elements = elements }

  public func array() -> [Element] { elements }
  public var count: Int { elements.count }
  public var isEmpty: Bool { elements.isEmpty }
  public func first() -> Element? { elements.first }
  public func last() -> Element? { elements.last }

  @discardableResult
  public func remove() throws -> Elements {
    // Remove deepest-last so removing a parent does not strand its children.
    for element in elements.reversed() { element.remove() }
    return self
  }

  @discardableResult
  public func after(_ html: String) throws -> Elements {
    for element in elements.reversed() { try element.after(html) }
    return self
  }

  public func text() -> String {
    elements.map { $0.text() }.joined(separator: " ")
  }
}

// MARK: - Selectors

/// Supports the forms HTMLString asks for: `p`, `br`, `p.quote-inline`
/// and `p:not(.quote-inline)`.
struct Selector {
  private let tag: String?
  private let requiredClasses: [String]
  private let excludedClasses: [String]

  init(_ query: String) throws {
    var rest = query.trimmingCharacters(in: .whitespaces)
    guard !rest.isEmpty else { throw SwiftSoupError.parseFailure("empty selector") }

    var excluded: [String] = []
    while let notRange = rest.range(of: ":not(") {
      guard let close = rest[notRange.upperBound...].firstIndex(of: ")") else {
        throw SwiftSoupError.parseFailure("unbalanced :not() in \(query)")
      }
      let inner = String(rest[notRange.upperBound..<close])
      excluded.append(contentsOf: inner.split(separator: ".").map(String.init))
      rest.removeSubrange(notRange.lowerBound...close)
    }
    excludedClasses = excluded

    let parts = rest.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
    let name = parts.first ?? ""
    tag = (name.isEmpty || name == "*") ? nil : name.lowercased()
    requiredClasses = parts.dropFirst().filter { !$0.isEmpty }
  }

  func matches(_ element: Element) -> Bool {
    if let tag, element.tagName != tag { return false }
    let classes = element.classNames
    for required in requiredClasses where !classes.contains(required) { return false }
    for excludedClass in excludedClasses where classes.contains(excludedClass) { return false }
    return true
  }
}

// MARK: - Parser

enum HTMLParser {
  static let voidElements: Set<String> = [
    "area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param",
    "source", "track", "wbr",
  ]

  /// Elements that auto-close when a same-or-related tag opens.
  private static let autoClosing: [String: Set<String>] = [
    "li": ["li"],
    "p": ["p", "ul", "ol", "blockquote", "div", "pre", "table"],
  ]

  static func parseFragment(_ html: String) -> [Node] {
    let root = Element(tagName: "#fragment")
    parse(html, into: root)
    let children = root.childNodes
    for child in children { child.parentNode = nil }
    return children
  }

  static func parseDocument(_ html: String) -> Document {
    let document = Document()
    parse(html, into: document)
    return document
  }

  private static func parse(_ html: String, into root: Element) {
    var stack: [Element] = [root]
    var index = html.startIndex
    var pendingText = ""

    func flushText() {
      guard !pendingText.isEmpty else { return }
      stack.last?.appendChild(TextNode(text: pendingText))
      pendingText = ""
    }

    while index < html.endIndex {
      let character = html[index]
      guard character == "<" else {
        pendingText.append(character)
        index = html.index(after: index)
        continue
      }

      let afterAngle = html.index(after: index)
      guard afterAngle < html.endIndex else {
        pendingText.append(character)
        break
      }

      // Comment or doctype
      if html[afterAngle] == "!" {
        flushText()
        if html[afterAngle...].hasPrefix("!--") {
          let contentStart = html.index(afterAngle, offsetBy: 3)
          if let end = html.range(of: "-->", range: contentStart..<html.endIndex) {
            stack.last?.appendChild(Comment(data: String(html[contentStart..<end.lowerBound])))
            index = end.upperBound
          } else {
            index = html.endIndex
          }
        } else if let close = html[afterAngle...].firstIndex(of: ">") {
          index = html.index(after: close)
        } else {
          index = html.endIndex
        }
        continue
      }

      guard let close = html[afterAngle...].firstIndex(of: ">") else {
        pendingText.append(character)
        index = afterAngle
        continue
      }

      let raw = String(html[afterAngle..<close])
      index = html.index(after: close)

      if raw.hasPrefix("/") {
        // Closing tag: unwind to the nearest matching open element.
        let name = raw.dropFirst().trimmingCharacters(in: .whitespaces).lowercased()
        flushText()
        if let position = stack.lastIndex(where: { $0.tagName == name }), position > 0 {
          stack.removeSubrange(position...)
        }
        continue
      }

      flushText()
      let (name, attributes, selfClosing) = parseTag(raw)
      guard !name.isEmpty else { continue }

      if let closes = autoClosing[name], let top = stack.last, closes.contains(top.tagName),
        stack.count > 1
      {
        stack.removeLast()
      }

      let element = Element(tagName: name, attributes: attributes)
      stack.last?.appendChild(element)
      if !selfClosing && !voidElements.contains(name) {
        stack.append(element)
      }
    }
    flushText()
  }

  private static func parseTag(_ raw: String) -> (String, [String: String], Bool) {
    var body = raw
    var selfClosing = false
    if body.hasSuffix("/") {
      selfClosing = true
      body.removeLast()
    }

    var scanner = Substring(body)
    func skipWhitespace() {
      while let first = scanner.first, first == " " || first == "\n" || first == "\t" || first == "\r" {
        scanner = scanner.dropFirst()
      }
    }

    skipWhitespace()
    let name = String(scanner.prefix(while: { !" \n\t\r/".contains($0) })).lowercased()
    scanner = scanner.dropFirst(name.count)

    var attributes: [String: String] = [:]
    while true {
      skipWhitespace()
      guard !scanner.isEmpty else { break }
      let key = String(scanner.prefix(while: { !" \n\t\r=/".contains($0) })).lowercased()
      scanner = scanner.dropFirst(key.count)
      guard !key.isEmpty else {
        scanner = scanner.dropFirst()
        continue
      }
      skipWhitespace()
      guard scanner.first == "=" else {
        attributes[key] = ""
        continue
      }
      scanner = scanner.dropFirst()
      skipWhitespace()
      var value = ""
      if let quote = scanner.first, quote == "\"" || quote == "'" {
        scanner = scanner.dropFirst()
        value = String(scanner.prefix(while: { $0 != quote }))
        scanner = scanner.dropFirst(value.count)
        if !scanner.isEmpty { scanner = scanner.dropFirst() }
      } else {
        value = String(scanner.prefix(while: { !" \n\t\r".contains($0) }))
        scanner = scanner.dropFirst(value.count)
      }
      attributes[key] = (try? Entities.unescape(value)) ?? value
    }
    return (name, attributes, selfClosing)
  }
}

// MARK: - Module entry points

public func parse(_ html: String) throws -> Document {
  HTMLParser.parseDocument(html)
}

public func parse(_ html: String, _ baseUri: String) throws -> Document {
  HTMLParser.parseDocument(html)
}

public func parseBodyFragment(_ html: String) throws -> Document {
  HTMLParser.parseDocument(html)
}

/// Strips everything the whitelist does not allow. With `Whitelist.none()`
/// that leaves the document's text, which is what HTMLString wants.
public func clean(
  _ html: String, _ baseUri: String = "", _ whitelist: Whitelist,
  _ outputSettings: OutputSettings = OutputSettings()
) throws -> String? {
  let document = HTMLParser.parseDocument(html)
  guard !whitelist.allowedTags.isEmpty else {
    // Text nodes keep their source escaping, matching SwiftSoup's output.
    return document.textContent()
  }
  func render(_ node: Node) -> String {
    if let text = node as? TextNode { return text.text }
    guard let element = node as? Element else { return "" }
    let inner = element.childNodes.map(render).joined()
    guard whitelist.allowedTags.contains(element.tagName) else { return inner }
    if HTMLParser.voidElements.contains(element.tagName) { return "<\(element.tagName)>" }
    return "<\(element.tagName)>\(inner)</\(element.tagName)>"
  }
  return document.childNodes.map(render).joined()
}
