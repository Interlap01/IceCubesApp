# PreviewScreens

Preview-only SwiftUI screens for [mobai](https://mobai.run) — a phone-sized
viewport that renders SwiftUI on Linux with no device, simulator or Xcode.

Nothing here is part of any Xcode target; the app never compiles these files.

## Why a separate directory

The preview engine compiles every Swift file under its project root. Pointed at
the repo root it tries to build the whole app — `Packages/*`, UIKit, SwiftData,
RevenueCat — none of which exist on Linux. So this directory is its own mobai
project (`PreviewScreens/.mobai/config.json`) and only the screens in it are
compiled.

That means a screen here is a standalone copy of the app's UI, not the app's
own code. Keep it close to the original and note which file it mirrors.

## Running

```bash
mobai-cloud preview run --detach -C PreviewScreens   # start once
mobai-cloud preview inspect -C PreviewScreens --json # semantic tree
mobai-cloud preview tap --label Retry -C PreviewScreens
mobai-cloud preview screenshot --out /tmp/shot.png -C PreviewScreens
mobai-cloud preview reload -C PreviewScreens         # after an edit
mobai-cloud preview stop -C PreviewScreens
```

`--entry <ViewName>` picks the screen when more than one is present.

## First-time setup on a fresh machine

```bash
~/.mobai/bin/mobai-cloud setup --agent claude --framework swiftui
# install what it reports missing (Swift 6.3.3 via swiftly, then:)
mobai-cloud login --email you@example.com          # sends a 6 digit code
mobai-cloud login --email you@example.com --code 123456
mobai-cloud engines install swiftui
```

On Linux the engine's macro plugin (`OpenSwiftUIMacros-tool`) is not linked
against the Swift runtime, so `@Entry` and friends fail with *"produced
malformed response"*. Put the toolchain libraries on the loader path once:

```bash
TC=$(dirname $(dirname $(readlink -f $(which swiftc))))/lib
printf '%s\n%s\n%s\n' "$TC/swift/linux" "$TC/swift/host" "$TC" \
  | sudo tee /etc/ld.so.conf.d/swiftly.conf && sudo ldconfig
```

## Limits

SF Symbols do not exist on Linux and render as a dot. Fonts, native gestures
and real rendering fidelity need a simulator or device — see the
`previewing-mobile-apps` skill for what the preview can and cannot answer.
