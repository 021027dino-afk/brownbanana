#!/usr/bin/env python3
"""Search the Opus 5.5 video prompt collection.

  search.py [keyword ...] [--category motion|explainer|3d|interactive] [--tag canvas] [--limit N] [--full]
  search.py --show <slug>
  search.py --stats
"""
import argparse, json, os, sys
from collections import Counter

DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data", "videos.json")


def load():
    with open(DATA, encoding="utf-8") as f:
        return json.load(f)


def show(v, full):
    tags = ", ".join(v["tech_tags"]) or "-"
    partial = " (partial prompt)" if v["prompt_partial"] else ""
    print(f"## {v['slug']} | {v.get('title') or '(untitled)'}")
    print(f"category: {v['category']} | tags: {tags} | by @{v['author']}{partial}")
    print(f"original: {v['post_url']}")
    p = v["prompt"].strip()
    if not full and len(p) > 300:
        p = p[:300].rstrip() + " ..."
    print(p)
    print()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("keywords", nargs="*")
    ap.add_argument("--category")
    ap.add_argument("--tag", action="append", default=[])
    ap.add_argument("--limit", type=int, default=10)
    ap.add_argument("--full", action="store_true")
    ap.add_argument("--show")
    ap.add_argument("--stats", action="store_true")
    a = ap.parse_args()
    data = load()

    if a.stats:
        print("total", len(data))
        print("categories", dict(Counter(v["category"] for v in data)))
        print("tags", dict(Counter(t for v in data for t in v["tech_tags"]).most_common()))
        return
    if a.show:
        for v in data:
            if v["slug"] == a.show:
                show(v, True)
                return
        sys.exit(f"no entry with slug {a.show}")

    kws = [k.lower() for k in a.keywords]
    hits = []
    for v in data:
        if a.category and v["category"] != a.category:
            continue
        if any(t not in v["tech_tags"] for t in a.tag):
            continue
        hay = f"{v.get('title') or ''} {v['prompt']}".lower()
        score = sum(hay.count(k) for k in kws)
        if kws and not all(k in hay for k in kws):
            continue
        # prefer complete prompts
        hits.append((score, not v["prompt_partial"], v))
    hits.sort(key=lambda h: (h[0], h[1]), reverse=True)
    print(f"{len(hits)} matches, showing {min(len(hits), a.limit)}\n")
    for _, _, v in hits[: a.limit]:
        show(v, a.full)


if __name__ == "__main__":
    main()
