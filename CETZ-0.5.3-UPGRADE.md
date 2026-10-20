# ctz-euclide: CeTZ 0.5.3 upgrade, progress tracker

Source: investigation of 2026-10-19. On hold until CeTZ 0.5.3 is on Typst Universe.
Status legend: [ ] todo · [~] in progress · [x] done · [-] dropped (with reason)

## 0. Blockers (check before starting)
- [ ] CeTZ 0.5.3 is published on Typst Universe. On 2026-10-19 it was not: the
      tag `v0.5.3` exists on GitHub (2026-10-16) but `packages/preview/cetz` in
      `typst/packages` stops at 0.5.2. A package importing `@preview/cetz:0.5.3`
      cannot be submitted to Universe or installed by users until then.
- [ ] Accept dropping Typst 0.14: CeTZ 0.5.3 declares `compiler = "0.15.0"`, so
      `typst.toml` must move to `compiler = "0.15.0"` (Typst 0.15.1 is out).

## 1. What CeTZ 0.5.3 brings
- `draw.clip(clipping-region, body, mode: "inside" | "outside", ...)`: new in
  0.5.3 (absent from 0.5.2, not listed in CHANGES.md). Clips the strokes and
  fills of any path drawables (lines, circles, arcs, polygons, filled shapes)
  by any closed region (rectangle, circle, polygon, several closed paths).
  Source: `src/draw/clip.typ` in the cetz repo.
- Mark `inset:` style no longer applied twice (#1099).
- `make-ctx` creates a canvas context without a canvas.
- `hobby` and `boolean` accept two-component vectors.
- Line elements get named anchors for their points (`pt-0`, `pt-1`, ...).
- Already available since 0.5.1 (usable today with 0.5.2): `boolean` path
  operations (union / intersection / difference).

## 2. Compatibility check (done 2026-10-19, nothing committed)
- [x] Typst 0.15.1 + CeTZ 0.5.2: every test and check script passes.
- [x] Typst 0.15.1 + CeTZ 0.5.3: every test passes except the deliberate guard
      `tests/test-regressions.typ:115`
      (`assert(cetz.version == version(0, 5, 2), ...)`), to update with the bump.
- [x] Snapshots, CeTZ 0.5.2 vs 0.5.3 on Typst 0.15.1: 22 pages differ, all by
      sub-pixel moves of labels and strokes. No visible change.
- [x] Snapshots, Typst 0.14.2 vs 0.15.1 (CeTZ 0.5.2): 50 of 102 pages differ.
      In the pages inspected this is text rendering (glyph metrics), not the figures.
- [x] Prototype: `clip(rect(...), { circle; arc; filled polygon })` and
      `clip(circle(...), { hatching lines })` render correctly with 0.5.3.

## 3. Plan
### 3a. Bump
- [ ] `@preview/cetz:0.5.2` → `0.5.3` in every file importing it:
      src/lib.typ, src/drawing.typ, src/drawing/{labels,annotations,primitives,
      grids,polygons,state,clipping}.typ, tests/test-pascal-triangle.typ.
- [ ] `typst.toml`: `compiler = "0.15.0"`.
- [ ] `tests/test-regressions.typ:115`: expect `version(0, 5, 3)`.
- [ ] Snapshot before/after (tests/snapshot.sh, tests/compare-snapshots.sh)
      and check the diffs are the sub-pixel moves listed in §2.

### 3b. Clip every shape to the canvas
Today `ctz-canvas(clip-canvas: ...)` clips only lines and segments
(Cohen-Sutherland in `src/drawing/clipping.typ`, used by `src/drawing.typ:1016`
and `:1448` and by `src/drawing/labels.typ:268`). The manual says so:
"Circles, arcs, and other shapes are not clipped yet"
(`docs/sections/11-clipping.typ`; README "Canvas Clipping").
- [ ] Wrap the canvas body in `cetz.draw.clip(rect(clip-region), body)` when
      `clip-canvas` is set, so circles, arcs, sectors, polygons, fills and
      hatches are clipped too.
- [ ] Decide what stays outside the clip: point labels and marks near the edge
      (tkz-euclide clips only the drawing, not the labels). Probably draw labels
      after the clipped body.
- [ ] Keep `clip-line-to-rect` for label placement (labels.typ), which needs
      the clipped geometry as numbers, not as drawables.
- [ ] Remove the per-line Cohen-Sutherland clipping in drawing.typ if the
      canvas clip makes it redundant. Check that `ctz-draw-line-add` with large
      `add:` still renders identically.

### 3c. New clip helpers (tkz-euclide parity)
- [ ] `ctz-clip-circle(center, radius-or-point, body)` ~ `\tkzClipCircle`.
- [ ] `ctz-clip-polygon(points..., body)` ~ `\tkzClipPolygon`.
- [ ] `mode: "outside"` (~ `\tkzClipOutCircle` / `\tkzClipOutPolygon`).
- [ ] Optional: `ctz-clip-sector`.

### 3d. Tests and docs
- [ ] Pixel test: a circle larger than the canvas leaves no ink outside the clip
      rectangle (same style as the existing check-*.sh scripts).
- [ ] Tests for each clip helper, inside and outside.
- [ ] Update `docs/sections/11-clipping.typ` (drop "not clipped yet", add the
      helpers with live examples), README "Canvas Clipping", and the changelog.
- [ ] Regenerate gallery and manual; bump the package version.

## 4. Reproducing the setup offline
packages.typst.org was unreachable from the environment used for this
investigation. CeTZ was installed from GitHub instead:
- `git clone --depth 1 --branch v0.5.3 https://github.com/cetz-package/cetz`
  into `~/.cache/typst/packages/preview/cetz/0.5.3`.
- The wasm plugin is not in git; build it:
  `cd cetz-core && cargo build --release --target wasm32-unknown-unknown` then
  copy `target/wasm32-unknown-unknown/release/cetz_core.wasm` to `cetz-core/`.
- Dependency: `@preview/oxifmt:1.0.0` (github.com/PgBiel/typst-oxifmt, tag v1.0.0).
