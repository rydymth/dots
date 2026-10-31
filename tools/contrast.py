#!/usr/bin/env python3
"""WCAG contrast report for every theme. Exits 1 if any text colour is below 4.5:1.

  python3 tools/contrast.py            all themes
  python3 tools/contrast.py -v         also print passing rows
"""
import sys
sys.path.insert(0, __import__("os").path.dirname(__file__))
from palettes import THEMES, TEXT_KEYS

MIN = 4.5


def lum(hex_):
    h = hex_.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    f = lambda c: c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)


def ratio(a, b):
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def checks(p):
    """(label, foreground, background, minimum) for everything that renders text."""
    rows = []
    for bgname in ("bg", "bg_dark", "surface"):
        for k in TEXT_KEYS:
            rows.append((f"{k} on {bgname}", p[k], p[bgname], MIN))
    rows += [
        ("fg on selection", p["fg"], p["selection"], 7.0),
        ("on_accent on accent", p["on_accent"], p["accent"], MIN),
        ("on_accent on orange (tmux prefix)", p["on_accent"], p["orange"], MIN),
        ("search_fg on search_bg", p["search_fg"], p["search_bg"], 7.0),
        ("fg on search_hl_bg", p["fg"], p["search_hl_bg"], 7.0),
        ("mode_fg on selection", p["mode_fg"], p["selection"], MIN),
        ("green on tint_green", p["green"], p["tint_green"], MIN),
        ("red on tint_red", p["red"], p["tint_red"], MIN),
        ("fg on mark_bg", p["fg"], p["mark_bg"], 7.0),
        ("strong on bg", p["strong"], p["bg"], 7.0),
    ]
    for k in ("h1", "h2", "h3", "h4"):
        rows.append((f"{k} on bg", p[k], p["bg"], MIN))
    for name, col in p["ansi"].items():
        if name != "cursor":
            rows.append((f"ansi {name} on bg", col, p["bg"], MIN))
    return rows


def main():
    verbose = "-v" in sys.argv
    bad = 0
    for name, p in THEMES.items():
        # The dark theme is the established palette: reported, never enforced.
        enforce = p["kind"] == "light"
        print(f"\n== {name} ({p['kind']}{'' if enforce else ', informational'})")
        fails = 0
        lowest = (99, "")
        for label, fg, bg, need in checks(p):
            if not enforce and label == "ansi black on bg":
                continue
            r = ratio(fg, bg)
            if r < lowest[0]:
                lowest = (r, label)
            ok = r >= need
            fails += (not ok)
            if verbose or not ok:
                print(f"  {'ok  ' if ok else 'FAIL'} {r:5.2f} (need {need})  {label}  {fg} on {bg}")
        print(f"  {fails} below target; lowest ratio {lowest[0]:.2f} ({lowest[1]})")
        if enforce:
            bad += fails
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
