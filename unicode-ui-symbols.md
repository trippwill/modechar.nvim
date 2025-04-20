# Unicode Box Drawing & UI Symbols Reference

This document provides a reference for Unicode symbols commonly used in terminal UIs — including vertical bars, horizontal lines, corners, and block elements — especially helpful in Neovim, tmux, or statusline/fold UI design.

---

## 📏 Vertical Bars

| Symbol | Unicode | Name                                    | Description |
|--------|---------|-----------------------------------------|-------------|
| `│`    | U+2502  | Box Drawings Light Vertical             | Thin, clean line. Great for splits, indent guides, or minimal dividers. |
| `┃`    | U+2503  | Box Drawings Heavy Vertical             | Bold vertical bar. Good for active splits or emphasized separators. |
| `╎`    | U+254E  | Box Drawings Light Double Dash Vertical | Dashed light vertical. Decorative, good for soft separation. |
| `╏`    | U+254F  | Box Drawings Heavy Double Dash Vertical | Dashed heavy vertical. Slightly more prominent than ╎. |
| `║`    | U+2551  | Box Drawings Double Vertical            | Double-lined bar. Classic for bordered layouts or UI frames. |
| `❘`    | U+2758  | Light Vertical Bar                      | Very thin bar. Great for subtle UI cues or inline separators. |
| `❙`    | U+2759  | Medium Vertical Bar                     | Medium-width vertical. Balanced between subtle and visible. |
| `❚`    | U+275A  | Heavy Vertical Bar                      | Thick vertical block. High visual weight, good for dividers. |
| `ǀ`    | U+01C0  | Latin Letter Dental Click               | Looks like a plain vertical bar `|`. Useful when font compatibility is needed. |

---

## 📐 Horizontal Bars

| Symbol | Unicode | Name                                    | Description |
|--------|---------|-----------------------------------------|-------------|
| `─`    | U+2500  | Box Drawings Light Horizontal           | Thin horizontal line. Ideal for statuslines or borders. |
| `━`    | U+2501  | Box Drawings Heavy Horizontal           | Bold version of `─`. Great for strong visual breaks. |
| `╌`    | U+254C  | Box Drawings Light Double Dash Horizontal | Light dashed line. Decorative. |
| `╍`    | U+254D  | Box Drawings Heavy Double Dash Horizontal | Heavy dashed line. More prominent. |
| `═`    | U+2550  | Box Drawings Double Horizontal          | Double line. Good for classic TUI borders. |
| `┈`    | U+2508  | Light Quadruple Dash Horizontal         | Very fine dashed line. Stylish. |
| `┉`    | U+2509  | Heavy Quadruple Dash Horizontal         | Bold version of ┈. Decorative emphasis. |
| `﹘`    | U+FE58  | Small Em Dash                           | Minimalist dash. Font support may vary. |

---

## 🧱 Blocks & UI Indicators

| Symbol | Unicode | Name                         | Description |
|--------|---------|------------------------------|-------------|
| `▌`    | U+258C  | Left Half Block              | Left-aligned half-cell fill. Good for cursor bars. |
| `▍`    | U+258D  | Left Three Quarters Block    | Covers ~75% of the cell. Progress indicators. |
| `▎`    | U+258E  | Left One Quarter Block       | Subtle indicator bar. |
| `█`    | U+2588  | Full Block                   | Fully filled cell. Max emphasis. |
| `▶`    | U+25B6  | Black Right-Pointing Triangle | Commonly used for folds, playback, indicators. |

---

## 🔲 Corners & Junctions

| Symbol | Unicode | Name                         | Description |
|--------|---------|------------------------------|-------------|
| `┌`    | U+250C  | Box Drawings Light Down and Right | Top-left corner (light). |
| `┐`    | U+2510  | Box Drawings Light Down and Left  | Top-right corner (light). |
| `└`    | U+2514  | Box Drawings Light Up and Right   | Bottom-left corner (light). |
| `┘`    | U+2518  | Box Drawings Light Up and Left    | Bottom-right corner (light). |
| `╔`    | U+2554  | Box Drawings Double Down and Right | Top-left corner (double). |
| `╗`    | U+2557  | Box Drawings Double Down and Left  | Top-right corner (double). |
| `╚`    | U+255A  | Box Drawings Double Up and Right   | Bottom-left corner (double). |
| `╝`    | U+255D  | Box Drawings Double Up and Left    | Bottom-right corner (double). |
| `├`    | U+251C  | Box Drawings Light Vertical and Right | T-junction (left). |
| `┤`    | U+2524  | Box Drawings Light Vertical and Left  | T-junction (right). |
| `┬`    | U+252C  | Box Drawings Light Down and Horizontal | T-junction (top). |
| `┴`    | U+2534  | Box Drawings Light Up and Horizontal | T-junction (bottom). |
| `┼`    | U+253C  | Box Drawings Light Vertical and Horizontal | Cross-junction. |

---

## 🧠 Tips & Notes

- Use box drawing characters for consistent grid-aligned UI elements.
- Combine `│ ─ ┌ ┐ └ ┘` for simple boxes or outlines.
- Use `utf8.char(0xNNNN)` or `"\\u{NNNN}"` in Lua to embed Unicode symbols.
- Font support varies — Nerd Fonts, JetBrainsMono, MesloLGS NF, and FiraCode Nerd Font are recommended for clean alignment.

---

## 🧪 Example: Drawing a Box in Neovim

```lua
print("┌────────────┐")
print("│  Neovim UI │")
print("└────────────┘")
```

---

## 🔗 Resources

- [Unicode Box Drawing Block](https://www.unicode.org/charts/PDF/U2500.pdf)
- [Unicode Block Elements](https://www.unicode.org/charts/PDF/U2580.pdf)
- [Nerd Fonts](https://www.nerdfonts.com/)
- Try them live in Neovim with `utf8.char(0x2502)` or `:put ='\\u2502'`

Enjoy building beautiful and expressive terminal UIs!
