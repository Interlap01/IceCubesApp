#!/usr/bin/env python3
"""Build the neutral-timeline fixtures.

The status list is derived from a real /api/v1/trends/statuses response so the
fixture keeps every field Models.Status decodes; only the human-visible parts
(accounts, text, counts, attachments) are replaced with invented sample data.
"""

import json
import os
import subprocess
import sys

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

AVATAR_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="240" height="240">
  <defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{light}"/><stop offset="1" stop-color="{dark}"/>
  </linearGradient></defs>
  <rect width="240" height="240" fill="url(#g)"/>
  <text x="120" y="122" font-family="DejaVu Sans" font-size="104" font-weight="bold"
        fill="#FFFFFF" fill-opacity="0.92" text-anchor="middle"
        dominant-baseline="central">{initials}</text>
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
    acct["avatar"] = "%s/avatars/%s.png" % (ASSET_BASE, slug)
    acct["avatar_static"] = acct["avatar"]
    acct["header"] = "%s/avatars/%s.png" % (ASSET_BASE, slug)
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
    render(AVATAR_SVG.format(initials=initials, light=light, dark=dark),
           os.path.join(AVATARS, slug + ".png"), 240)
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
      s["media_attachments"] = [{
          "id": "7700%d" % i,
          "type": "image",
          "url": "%s/%s.png" % (ASSET_BASE, post["media"]),
          "preview_url": "%s/%s.png" % (ASSET_BASE, post["media"]),
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
