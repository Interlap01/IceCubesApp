#!/usr/bin/env python3
"""Build the neutral-timeline fixtures.

The status list is derived from a real /api/v1/trends/statuses response so the
fixture keeps every field Models.Status decodes; only the human-visible parts
(accounts, text, counts, attachments) are replaced with invented sample data.
"""

import json
import os
import struct
import subprocess
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
FIX = os.path.join(HERE, "fixtures")
AVATARS = os.path.join(FIX, "avatars")
ASSET_BASE = "http://127.0.0.1:8099"

PEOPLE = [
    ("ada", "Ada Fern", "AF", "#4C6EF5", "#364FC7"),
    ("rowan", "Rowan Vale", "RV", "#F28C28", "#C25E0A"),
    ("mira", "Mira Okonkwo", "MO", "#12B886", "#087F5B"),
    ("tomas", "Tomas Lind", "TL", "#7950F2", "#5F3DC4"),
    ("priya", "Priya Raman", "PR", "#E64980", "#A61E4D"),
    ("weekly", "Devs Weekly", "DW", "#495057", "#212529"),
]

POSTS = [
    dict(
        who="ada",
        html="<p>Spent the morning on a tiny Swift package that turns a folder of "
        "markdown into a tidy static site. 120 lines, no dependencies. Sometimes "
        "the boring solution is the whole solution.</p>",
        replies=4, reblogs=31, favs=88, age_hours=2, tags=[], media=None,
    ),
    dict(
        who="rowan",
        html="<p>The sourdough finally behaved itself. Twelve hours cold ferment, a "
        "much wetter dough than I am used to, and an oven spring I would frame if "
        "I could. \U0001f35e</p>",
        replies=9, reblogs=12, favs=140, age_hours=1, tags=[], media="loaf",
    ),
    dict(
        who="mira",
        html="<p>Reminder that a smooth scroll is mostly about not doing work per "
        "frame, and only rarely about doing the same work faster.</p>",
        replies=6, reblogs=54, favs=201, age_hours=3, tags=[], media=None,
    ),
    dict(
        who="priya",
        html="<p>Refactored a 900 line view into six small ones today. Same pixels, "
        "a tenth of the thinking required to change any of them. "
        '<a href="https://mastodon.social/tags/SwiftUI" class="mention hashtag" '
        'rel="tag">#<span>SwiftUI</span></a></p>',
        replies=3, reblogs=44, favs=163, age_hours=5,
        tags=[{"name": "SwiftUI", "url": "https://mastodon.social/tags/SwiftUI"}],
        media=None,
    ),
    dict(
        who="tomas",
        html="<p>Walked the coastal path before sunrise. Two seals, one very "
        "committed heron, and a thermos of coffee that lasted exactly as long as "
        "it needed to.</p>",
        replies=2, reblogs=8, favs=67, age_hours=7, tags=[], media=None,
    ),
    dict(
        who="weekly",
        html="<p>New issue out: designing APIs that are hard to misuse, a short "
        "history of the retain cycle, and why your build is slow. "
        '<a href="https://mastodon.social/tags/dev" class="mention hashtag" '
        'rel="tag">#<span>dev</span></a></p>',
        replies=1, reblogs=22, favs=74, age_hours=9,
        tags=[{"name": "dev", "url": "https://mastodon.social/tags/dev"}],
        media=None,
    ),
]

AVATAR_SIZE = 240

# librsvg ignores dominant-baseline and alignment-baseline (verified against
# 2.58.0: renders with and without them are byte-identical), so `y` is always
# the text baseline and the monogram cannot be centred declaratively. The
# baseline is therefore placed by measuring the rendered ink and correcting,
# which also sidesteps depending on any particular font's cap-height metrics.
AVATAR_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}">
  <defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{light}"/><stop offset="1" stop-color="{dark}"/>
  </linearGradient></defs>
  <rect width="{size}" height="{size}" fill="url(#g)"/>
  <text x="{x:.2f}" y="{y:.2f}" font-family="DejaVu Sans" font-size="104"
        font-weight="bold" fill="#FFFFFF" fill-opacity="0.92"
        text-anchor="middle">{initials}</text>
</svg>
"""

LOAF_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="800">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#F5E7D0"/><stop offset="1" stop-color="#E4C79B"/>
    </linearGradient>
    <linearGradient id="crust" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#D79A4E"/><stop offset="1" stop-color="#9C5F22"/>
    </linearGradient>
  </defs>
  <rect width="1200" height="800" fill="url(#sky)"/>
  <ellipse cx="600" cy="620" rx="430" ry="60" fill="#C8A574" fill-opacity="0.55"/>
  <ellipse cx="600" cy="430" rx="400" ry="230" fill="url(#crust)"/>
  <path d="M260 400 q340 -150 680 0" stroke="#F3D7A8" stroke-width="26"
        fill="none" stroke-linecap="round" stroke-opacity="0.75"/>
  <path d="M330 470 q270 -110 540 0" stroke="#7A4515" stroke-width="16"
        fill="none" stroke-linecap="round" stroke-opacity="0.45"/>
  <text x="600" y="730" font-family="DejaVu Sans" font-size="40" fill="#7A5A32"
        text-anchor="middle">sample image \u00b7 preview fixture</text>
</svg>
"""


def render(svg_text, out_path, width):
  proc = subprocess.run(
      ["rsvg-convert", "-w", str(width), "-o", out_path],
      input=svg_text.encode("utf-8"), capture_output=True)
  if proc.returncode != 0:
    sys.exit("rsvg-convert failed for %s: %s" % (out_path, proc.stderr.decode()))


def read_png(path):
  """Decode an 8-bit non-interlaced RGB or RGBA PNG.

  rsvg-convert drops the alpha channel when the artwork is fully opaque, so
  both colour types turn up depending on the SVG.
  """
  with open(path, "rb") as fh:
    data = fh.read()
  if data[:8] != b"\x89PNG\r\n\x1a\n":
    sys.exit("%s is not a PNG" % path)
  pos, idat, hdr = 8, [], None
  while pos < len(data):
    length, kind = struct.unpack(">I4s", data[pos:pos + 8])
    body = data[pos + 8:pos + 8 + length]
    if kind == b"IHDR":
      hdr = struct.unpack(">IIBBBBB", body)
    elif kind == b"IDAT":
      idat.append(body)
    elif kind == b"IEND":
      break
    pos += 12 + length
  width, height, depth, colour, _comp, _filt, interlace = hdr
  channels = {2: 3, 6: 4}.get(colour)
  if depth != 8 or interlace != 0 or channels is None:
    sys.exit("%s: expected 8-bit non-interlaced RGB/RGBA, got %r" % (path, hdr))
  raw = zlib.decompress(b"".join(idat))
  stride, bpp = width * channels, channels
  out, prev = bytearray(), bytearray(stride)
  for y in range(height):
    start = y * (stride + 1)
    ftype = raw[start]
    line = bytearray(raw[start + 1:start + 1 + stride])
    for i in range(stride):
      a = line[i - bpp] if i >= bpp else 0
      b = prev[i]
      c = prev[i - bpp] if i >= bpp else 0
      if ftype == 1:
        line[i] = (line[i] + a) & 0xFF
      elif ftype == 2:
        line[i] = (line[i] + b) & 0xFF
      elif ftype == 3:
        line[i] = (line[i] + (a + b) // 2) & 0xFF
      elif ftype == 4:
        p = a + b - c
        pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
        line[i] = (line[i] + (a if pa <= pb and pa <= pc
                              else b if pb <= pc else c)) & 0xFF
      elif ftype != 0:
        sys.exit("%s: unknown PNG filter %d" % (path, ftype))
    out += line
    prev = line
  return width, height, channels, out


def ink_centre(path):
  """Centre of the near-white glyph ink; the gradient background never is."""
  width, height, channels, buf = read_png(path)
  minx, miny, maxx, maxy = width, height, -1, -1
  for y in range(height):
    row = y * width * channels
    for x in range(width):
      i = row + x * channels
      if buf[i] > 225 and buf[i + 1] > 225 and buf[i + 2] > 225:
        minx, maxx = min(minx, x), max(maxx, x)
        miny, maxy = min(miny, y), max(maxy, y)
  if maxy < 0:
    sys.exit("%s: no glyph ink found" % path)
  return (minx + maxx) / 2.0, (miny + maxy) / 2.0


def render_avatar(out_path, initials, light, dark):
  """Render, measure where the ink landed, then re-render centred on it.

  Centring on the ink rather than on the advance width is what makes a short
  monogram look centred in a circle; text-anchor alone leaves the side
  bearings in, which is a few pixels off for letter pairs like "AF".
  """
  mid = AVATAR_SIZE / 2.0
  x, y = mid, mid
  for _ in range(3):
    render(AVATAR_SVG.format(size=AVATAR_SIZE, initials=initials, light=light,
                             dark=dark, x=x, y=y), out_path, AVATAR_SIZE)
    cx, cy = ink_centre(out_path)
    dx, dy = mid - cx, mid - cy
    if abs(dx) < 0.5 and abs(dy) < 0.5:
      break
    x, y = x + dx, y + dy
  return x, y


def asset_url(rel_path):
  """Content-addressed asset URL.

  The image loader caches by URL, so a regenerated avatar served under the
  same name would keep rendering the old bytes until the cache is cleared.
  """
  with open(os.path.join(FIX, rel_path), "rb") as fh:
    token = "%08x" % (zlib.crc32(fh.read()) & 0xFFFFFFFF)
  return "%s/%s?v=%s" % (ASSET_BASE, rel_path, token)


def build_accounts(template):
  accounts = {}
  for slug, name, initials, light, dark in PEOPLE:
    acct = json.loads(json.dumps(template))
    acct["id"] = "90000" + str(len(accounts) + 1)
    acct["username"] = slug
    acct["acct"] = slug
    acct["display_name"] = name
    acct["note"] = "<p>Sample account used by the preview fixture.</p>"
    acct["url"] = "https://mastodon.social/@" + slug
    acct["uri"] = "https://mastodon.social/users/" + slug
    acct["avatar"] = asset_url("avatars/%s.png" % slug)
    acct["avatar_static"] = acct["avatar"]
    acct["header"] = acct["avatar"]
    acct["header_static"] = acct["header"]
    acct["bot"] = slug == "weekly"
    acct["locked"] = False
    acct["emojis"] = []
    acct["fields"] = []
    acct["followers_count"] = 1200 + 137 * len(accounts)
    acct["following_count"] = 180 + 11 * len(accounts)
    acct["statuses_count"] = 400 + 53 * len(accounts)
    accounts[slug] = acct
  return accounts


def main():
  os.makedirs(AVATARS, exist_ok=True)
  for slug, _name, initials, light, dark in PEOPLE:
    out = os.path.join(AVATARS, slug + ".png")
    render_avatar(out, initials, light, dark)
    cx, cy = ink_centre(out)
    print("  %-8s ink centre (%.1f, %.1f)" % (slug, cx, cy))
  render(LOAF_SVG, os.path.join(FIX, "loaf.png"), 1200)

  real = json.load(open(sys.argv[1]))
  status_template = real[0]
  accounts = build_accounts(status_template["account"])

  out = []
  for i, post in enumerate(POSTS):
    s = json.loads(json.dumps(status_template))
    s["id"] = "11000000000000%02d" % (len(POSTS) - i)
    s["account"] = accounts[post["who"]]
    s["content"] = post["html"]
    s["spoiler_text"] = ""
    s["created_at"] = "2026-09-17T%02d:20:00.000Z" % max(0, 8 - post["age_hours"])
    s["edited_at"] = None
    s["replies_count"] = post["replies"]
    s["reblogs_count"] = post["reblogs"]
    s["favourites_count"] = post["favs"]
    s["quotes_count"] = 0
    s["url"] = "https://mastodon.social/@%s/%s" % (post["who"], s["id"])
    s["uri"] = s["url"]
    s["language"] = "en"
    s["sensitive"] = False
    s["visibility"] = "public"
    s["mentions"] = []
    s["emojis"] = []
    s["tags"] = post["tags"]
    s["card"] = None
    s["poll"] = None
    s["reblog"] = None
    s["quote"] = None
    s["in_reply_to_id"] = None
    s["in_reply_to_account_id"] = None
    s["application"] = None
    s["media_attachments"] = []
    if post["media"]:
      media = asset_url("%s.png" % post["media"])
      s["media_attachments"] = [{
          "id": "7700%d" % i,
          "type": "image",
          "url": media,
          "preview_url": media,
          "remote_url": None,
          "preview_remote_url": None,
          "text_url": None,
          "description": "A round sourdough loaf, drawn as a sample image.",
          "blurhash": None,
          "meta": {
              "original": {"width": 1200, "height": 800, "size": "1200x800",
                           "aspect": 1.5},
              "small": {"width": 600, "height": 400, "size": "600x400",
                        "aspect": 1.5},
          },
      }]
    out.append(s)

  with open(os.path.join(FIX, "trends-statuses.json"), "w") as fh:
    json.dump(out, fh, indent=1, ensure_ascii=False)
  print("wrote %d statuses, %d avatars" % (len(out), len(PEOPLE)))


if __name__ == "__main__":
  main()
