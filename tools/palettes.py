"""Single source of truth for every theme. tools/build.py turns these into the
tmux, starship, fzf, leaf, nvim and Windows Terminal files.

Key meanings
  bg / bg_dark / surface / surface_high   page, panel (status bars, floats), selected tab, borders
  fg / fg_heading / fg_muted / comment    text, headings, secondary text, comments + line numbers
  selection                               visual selection background
  blue cyan purple green yellow red orange  text colours (all >= 4.5:1 on bg, bg_dark and surface)
  accent / on_accent                      strong fill colour and the text that sits on it
  search_bg / search_fg / search_hl_bg    current search match, text on it, other matches
  mode_fg                                 tmux copy-mode text
  tint_green / tint_red / mark_bg / strong  leaf status tints, ==mark==, bold text
  h1..h4                                  markdown headings
  ansi                                    the 16 terminal colours (+ cursor)
"""

THEMES = {
    # ── the original dark theme ─────────────────────────────────────────────
    "apple-classic-dark": dict(
        kind="dark", syntax="base16-eighties.dark",
        bg="#2c2b2b", bg_dark="#222121", surface="#373b41", surface_high="#424040",
        fg="#c5c8c6", fg_heading="#f0c674", fg_muted="#969896", comment="#707880",
        selection="#373b41",
        blue="#81a2be", cyan="#8abeb7", purple="#b294bb", green="#b5bd68",
        yellow="#f0c674", red="#cc6666", orange="#de935f",
        accent="#81a2be", on_accent="#222121",
        search_bg="#f0c674", search_fg="#2c2b2b", search_hl_bg="#424040",
        mode_fg="#f0c674",
        tint_green="#33372a", tint_red="#3d2b2b", mark_bg="#5c4f2a", strong="#ffffff",
        h1="#f0c674", h2="#b5bd68", h3="#81a2be", h4="#b294bb",
        ansi=dict(
            black="#222121", red="#cc6666", green="#b5bd68", yellow="#f0c674",
            blue="#81a2be", purple="#b294bb", cyan="#8abeb7", white="#c5c8c6",
            brightBlack="#707880", brightRed="#de8484", brightGreen="#c8d07f",
            brightYellow="#f5d28e", brightBlue="#9ab8d1", brightPurple="#c5aacd",
            brightCyan="#a1d1ca", brightWhite="#eaebea", cursor="#c5c8c6",
        ),
    ),

    # ── light, built around the Windows PowerShell navy (#012456) ───────────
    "powershell-light": dict(
        kind="light", syntax="InspiredGitHub",
        bg="#F4F8FD", bg_dark="#E5EDF8", surface="#D5E2F4", surface_high="#8FA8CB",
        fg="#0B1B33", fg_heading="#012456", fg_muted="#3A4F74", comment="#48607F",
        selection="#BCD3F2",
        blue="#0B55B3", cyan="#00616F", purple="#6A2C9B", green="#176B2B",
        yellow="#7A4A00", red="#A81D17", orange="#A03F00",
        accent="#012456", on_accent="#FFFFFF",
        search_bg="#FFE08A", search_fg="#0B1B33", search_hl_bg="#FFF1BD",
        mode_fg="#0B1B33",
        tint_green="#D8EFDC", tint_red="#F7DAD8", mark_bg="#FFE9A8", strong="#000F2B",
        h1="#012456", h2="#0B55B3", h3="#00616F", h4="#6A2C9B",
        ansi=dict(
            black="#0B1B33", red="#A81D17", green="#176B2B", yellow="#7A4A00",
            blue="#0B55B3", purple="#6A2C9B", cyan="#00616F", white="#3A4F74",
            brightBlack="#4F6589", brightRed="#B8231C", brightGreen="#1B7A32",
            brightYellow="#8A5400", brightBlue="#0F62C9", brightPurple="#7A38AE",
            brightCyan="#006C7C", brightWhite="#0B1B33", cursor="#012456",
        ),
        selectionBackground="#BCD3F2",
    ),

    # ── light, macOS Sequoia: white, system blue accent, multi-colour syntax ─
    "sequoia-light": dict(
        kind="light", syntax="InspiredGitHub",
        bg="#FFFFFF", bg_dark="#F5F5F7", surface="#E5E5EA", surface_high="#A1A1A6",
        fg="#1D1D1F", fg_heading="#1D1D1F", fg_muted="#515154", comment="#636366",
        selection="#B3D7FF",
        blue="#0A5CC8", cyan="#00677C", purple="#7E2DAA", green="#1B7332",
        yellow="#7F5300", red="#C9091C", orange="#AE3A00",
        accent="#0A5CC8", on_accent="#FFFFFF",
        search_bg="#FFE066", search_fg="#1D1D1F", search_hl_bg="#FFF2B3",
        mode_fg="#1D1D1F",
        tint_green="#DDF3E2", tint_red="#FADCDF", mark_bg="#FFEA99", strong="#000000",
        h1="#0A5CC8", h2="#7E2DAA", h3="#1B7332", h4="#AE3A00",
        ansi=dict(
            black="#1D1D1F", red="#C9091C", green="#1B7332", yellow="#7F5300",
            blue="#0A5CC8", purple="#7E2DAA", cyan="#00677C", white="#515154",
            brightBlack="#636366", brightRed="#D70015", brightGreen="#1F7D37",
            brightYellow="#8A5A00", brightBlue="#1566D6", brightPurple="#8E3CBA",
            brightCyan="#00728A", brightWhite="#1D1D1F", cursor="#0A5CC8",
        ),
        selectionBackground="#B3D7FF",
    ),
}

TEXT_KEYS = ["fg", "fg_heading", "fg_muted", "comment", "blue", "cyan", "purple",
             "green", "yellow", "red", "orange"]
