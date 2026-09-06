// Preview supplement compiled into StatusKit's preview copy.
//
// The editor's Transferable types (Editor/Components/UTTypeSupported.swift)
// declare `static var transferRepresentation: some TransferRepresentation`.
// The engine cannot compile those bodies in a preview, so it demotes each one
// to a trap that returns `Never` - and `Never` did not conform to
// TransferRepresentation, so the opaque return type had nothing to bind to and
// the whole module failed to compile.
//
// SwiftUI solves the same problem for `View` by making `Never` a View. This
// does that for TransferRepresentation: the demoted bodies now typecheck, and
// because nothing in a preview ever performs a transfer, no trap is ever
// reached. Dragging a file into the composer is simply not simulated.

import MobAIPreviewControls

extension Never: TransferRepresentation {
  public typealias Body = Never

  public var body: Never { fatalError("no transfers in a preview") }
}
