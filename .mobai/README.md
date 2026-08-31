# Previewing Ice Cubes without a simulator

`mobai-cloud` compiles one SwiftUI screen and the code it reaches, then renders
it into a phone-sized viewport on Linux — no Xcode, no simulator. It is fast
enough for UI iteration; it is not a substitute for a device when the question
is native rendering fidelity, real gestures, media playback or performance.

## Running one

```bash
. "$HOME/.local/share/swiftly/env.sh"          # Swift 6.3.3, which the engine requires
mobai-cloud preview run --detach --entry .mobai/screens/TimelinePreview.swift --json
mobai-cloud preview inspect --json             # the screen as a semantic tree
mobai-cloud preview screenshot --out /tmp/shot.png --json
mobai-cloud mock appearance dark --json        # same screen, other theme, no restart
mobai-cloud preview stop --json
```

After editing app source, `mobai-cloud preview reload --json` recompiles behind
the same port. SwiftUI reloads reset state, so re-drive to the screen after one.

## Why the entries live here

The engine renders a single screen, so nothing runs the environment injection
`IceCubesApp` does at launch: a screen reading `@Environment(Theme.self)` traps
at startup with "No Observable of type Theme found". `.mobai/screens/` holds
small wrappers that play the role of that root and inject what a screen reads.

They sit under `.mobai/` deliberately. `IceCubesApp/` is an Xcode
*synchronized* group, so any `.swift` file added under it joins the shipped
app target — but Xcode skips dot-directories, so nothing here ever ships.

The cost of that isolation: the engine only compiles the entry's own directory
from the app target, so a wrapper here can reach any **package** type
(`StatusKit`, `Env`, `DesignSystem`, …) but not a type defined in the app
target itself, such as the Settings screens. Package screens cover most of the
app's UI. Where a package's own initializer is `internal`, prefer the public
entry point next to it — `StatusRowExternalView` rather than `StatusRowView`.

## Adapters

`Packages/` depends on libraries that cannot run here — some because they need
hardware or Apple frameworks the engine cannot compile, some because they are
third-party code the engine has no catalog entry for. `.mobai/adapters/` holds
hand-written stand-ins that present the same API and implement it with what
the preview does have:

| adapter | stands in for | fidelity |
|---|---|---|
| `SwiftSoup.swift` | HTML parsing in `Models/HTMLString.swift` | **real** — a parser covering parse/clean/select/entity-unescape, so post bodies render as themselves |
| `CryptoKit.swift` | Apple CryptoKit | **real** — re-exports swift-crypto, which ships with the engine; also declares `SecRandomCopyBytes` |
| `os.swift` | `OSAllocatedUnfairLock` | **real** — NSLock, same semantics |
| `KeychainSwift.swift` | the iOS keychain | in-memory, shared per process: what is written reads back for one session |
| `OSLog.swift` | `Logger` | writes to stderr |
| `UserNotifications.swift` | notification delivery | authorization granted; nothing is delivered |
| `Nuke.swift` / `NukeUI.swift` | remote image loading | **placeholder** — no image backend, so `LazyImage` draws a neutral fill and hands the app a settled, empty state. Layout is real; pixels are not |
| `EmojiText.swift` | markdown + custom emoji | markdown is real; `:shortcode:` stays as text |
| `Gifu.swift` | animated GIFs | a still `UIImageView` |
| `AVKit.swift`, `CoreHaptics.swift` | playback, haptics | state reads back; nothing plays or vibrates |

`AVKit.swift`, `CoreHaptics.swift` and `UserNotifications.swift` began as
engine-generated stand-ins and were repaired by hand — the generated versions
declared `<Self>` generic parameters Swift rejects, get-only properties the app
assigns to, and delegate methods in a form the app does not implement.

The engine keeps mocks **per entry directory**, so they need copying to
wherever the entry lives:

```bash
./.mobai/sync-adapters.sh .mobai/screens/TimelinePreview.swift
```

Those per-entry copies are generated and git-ignored; `.mobai/adapters/` is the
source of truth. When the engine writes a fresh stand-in that you then fix,
copy it back into `.mobai/adapters/` so the fix survives.

## Known rough edge

The engine prunes `Env/PreviewEnv.swift` as unreachable for some entries while
keeping the `#Preview` blocks in `StatusRowView` and `AccountsListView` that
call its `withPreviewsEnv()`, and the build then fails on a symbol neither side
owns. It does not affect `.mobai/screens/TimelinePreview.swift`. If you hit it
on another entry, declare a no-op `withPreviewsEnv()` in that entry's copy of
`EmojiText.swift` (which `StatusRowView` imports) — but not in
`.mobai/adapters/`, or entries that *do* keep `PreviewEnv.swift` fail with an
ambiguous-use error instead.
