#!/usr/bin/env bash
# Copies the tracked preview adapters into an entry's mock directory.
#
# The engine keeps mocks per entry directory: previewing
# <dir>/Screen.swift reads them from <dir>/.mobai/preview/swiftui/mocks.
# The hand-written ones live in .mobai/adapters so they are written once and
# tracked; this puts them where the engine will look for a given entry.
#
#   ./.mobai/sync-adapters.sh .mobai/screens/TimelinePreview.swift
set -euo pipefail

entry="${1:?usage: sync-adapters.sh <entry .swift path, relative to the project root>}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mocks="$root/$(dirname "$entry")/.mobai/preview/swiftui/mocks"

mkdir -p "$mocks"
cp "$root"/.mobai/adapters/*.swift "$mocks"/
echo "synced $(ls -1 "$root"/.mobai/adapters/*.swift | wc -l) adapters -> $mocks"
