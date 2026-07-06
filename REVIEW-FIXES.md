# ctz-euclide review fixes — progress tracker

Source: full package review of 2026-07-06 (GitHub issues #1-#4 + internal audit).
Status legend: [ ] todo · [~] in progress · [x] done · [-] dropped (with reason)

## 1. Structural dedupe (prerequisite)
- [x] Remove duplicated definitions from `src/drawing.typ` that shadow
      `src/drawing/{primitives,labels,polygons,clipping}.typ`; import submodules instead.
      Single source of truth per function.

## 2. atan2 argument order (systemic)
- [x] Add `util.angle-of(dx, dy)` wrapper (Typst `calc.atan2` takes x first).
- [x] Sweep all swapped call sites:
      util.typ:347 (slope-angle) · circle.typ:94 (tangent-from) ·
      draw.typ:340-341, 415 · drawing.typ (compass, arc-mark, arc-through,
      semicircle, sector, right-angle german, label-segment sloped, _direction-angle) ·
      lib.typ sketchy arc/semicircle · drawing/primitives.typ · drawing/labels.typ ·
      drawing/polygons.typ · conic/ellipse.typ:109,128

## 3. Arc center semantics (issue #4)
- [x] cetz `arc(position, ...)` anchors at arc-start, not center → pass `anchor: "origin"`
      in: draw-arc-through, draw-arc-r, draw-semicircle, draw-sector, draw-compass,
      mark-right-angle (german).

## 4. cetz upgrade 0.4.2 → 0.5.2 (issue #1)
- [x] Bump all `@preview/cetz` imports in src/ to 0.5.2 (matches deploy-skill rule:
      deps at latest). Resolves version-shadowing conflict with cetz-plot users.
- [x] Verify shared-state / resolve-coordinate / angle / hide(bounds:) still work.

## 5. Crash & wrong-default bugs
- [x] `ctz-def-golden` crashes (`inside:` param not accepted by `_golden`).
- [x] `ctz-draw(name, sketchy: true)` crashes on named lines (`line-data.a` on tuple).
- [x] `ctz-draw(name, sketchy: true)` crashes on named polygons (`poly.vertices` on array).
- [x] `ctz-def-excenter` default `vertex: "A"` silently computes vertex "c"
      → case-insensitive normalization + assert in triangle.typ.

## 6. Label placement
- [x] `_direction-angle` mirrored (fixed by §2).
- [x] Delete dead collision-avoidance block in `label-points-styled`
      (pos reassigned before `if pos == "auto"` check; ctx mutation in get-ctx
      can't persist anyway).
- [x] Remove `k.len() <= 5` heuristic in labels-only path of `ctz-draw`.
- [x] `_math-label`: greek names (alpha → α), digits, primes; safe fallback
      (no eval panic on odd names).
- [x] Wire `ctz-style(angle: ...)` into `mark-angle` (currently ignored).
- [x] `ctz-draw(points: ..., shape/size/color: ...)` per-call style overrides
      (currently silently ignored).

## 7. Angle types (issue #2)
- [x] `angle-type: "interior" | "reflex" | "supplementary"` on mark-angle /
      ctz-draw-angle (+ label bisector flipped accordingly). Document that
      complementary needs an explicit perpendicular ray.

## 8. Misc correctness / hygiene
- [x] `_version` read from typst.toml (currently hardcoded (0,1,0) vs 0.1.5).
- [x] circle-circle tangency threshold `h-sq < eps*eps` → `h-sq < eps`.
- [x] Grid/axes float-accumulation loops → integer step loops.
- [x] `_translate` vector handling → use `_resolve-vector` (point-pair support).
- [x] Reduce wildcard leak: rename lib.typ module bindings to `_`-prefixed
      (util, draw, drawing, point, circle, triangle, transform, conic, intersection).
      Keep `cetz` exported (documented pattern `import cetz.draw: *`).
- [x] Remove duplicated comment lib.typ:3213-3214.
- [x] README typos ("is will try", "feedback look") + changelog entry.
- [x] Delete tests/*.py one-shot scripts + stray tests/LICENSE.

## 9. Tests
- [x] Point existing tests at local `../src/lib.typ` (they currently test the
      *published* package, not the working tree).
- [x] New `tests/test-regressions.typ` with visual/numeric checks for every fix:
      arc rendering (issue #4 repro), slope-angle, tangent-from, excenter default,
      semicircle-on-diameter, sector, compass, golden, sketchy named line/polygon,
      label auto-placement on a line, long-name labels, greek labels,
      ellipse projection, translate by point pair, grid tick count, version.
- [x] All tests compile clean.

## 10. Documentation (issue #3)
- [x] docs/helpers.typ → import local `../src/lib.typ`.
- [x] Fix duplicated `#import "@preview/ctz-euclide:0.1.0"` lines + stale version
      in section code listings.
- [x] Blank pages 47/60 (full-figure pagebreak layout).
- [x] Broken image scaling p.58 (tiny) / pp.61,63 (oversized).
- [x] Recompile manual, visually verify affected pages.

## 11. Gallery
- [x] Recompile gallery files against fixed source; regenerate PNGs.

## Extra fixes found while testing
- [x] tangent-from-point-raw used asin(r/d) instead of acos(r/d) for the
      central angle (was partially masked by the atan2 bug).
- [x] feuerbach-raw returned the incenter (distance R9-r from N instead of R9).
- [x] cetz 0.5.2 treats bare-string coordinates in line() as element names →
      _draw-line now resolves point names itself.
- [x] draw-semicircle above/below picked the wrong side depending on the
      argument order; now picks the actually-higher side.
- [x] Equilateral-triangle example (gallery + manual): replaced the confusing
      radius-0.3 circles drawn on the vertices with real compass construction
      arcs meeting at C (this was the "circle around the vertex" artifact).
- [x] Examples no longer use the private _pt() helper (plain point names work).
- [x] Removed docs/error.log; added scripts/build-gallery.sh.

## Notes / decisions
- cetz upgraded to 0.5.2 rather than renaming the exported `cetz` binding:
  the `import cetz.draw: *` pattern is documented API, and matching the current
  ecosystem version removes the conflict issue #1 describes.
- Version bump itself is left to /deploy (it owns typst.toml version).
- docs/helpers.typ and tests import the LOCAL source (../src/lib.typ) so they
  exercise the working tree; /deploy must switch helpers.typ back to the
  @preview import when releasing (comment at the top of helpers.typ says so).
- Compile tests/docs with --root (e.g. `typst compile --root . tests/x.typ`).

## 12. Label collision avoidance engine (2026-07-06, follow-up feature)
- [x] `draw-with-state` custom element (state.typ): the ONLY way shared-state
      mutations persist — plain get-ctx callbacks receive a copy (verified
      by probe compile; the earlier assumption that get-ctx persists was wrong,
      which is also why the old drawn-lines tracking never worked).
- [x] Registries: ctz-drawn-lines / ctz-drawn-circles / ctz-drawn-points /
      ctz-placed-labels, filled by all segment/circle/arc/point draw functions.
- [x] Pure engine in drawing/labels.typ: anchor-candidate-rect,
      _candidate-list (unified cost: 1.2·anchor-switch + ring +
      shrink-cost·shrink-step), score-label-rect (chord/ring/disk/overlap),
      find-label-placement (first zero-score wins, least-bad full-size fallback).
- [x] Integration in label-points-styled: on by default, per-label avoid: false,
      global ctz-label-avoid(bool|dict), zero-size guard, engine-off labels
      still registered.
- [x] Angle labels: bisector push-out (bounded 8 steps) + rect registration.
- [x] draw-segment dim labels registered.
- [x] Duplicate labels (same point + same content) skipped — path auto-labels
      followed by ctz-draw-labels used to double-draw.
- [x] tests/test-label-avoid.typ: ~30 numeric asserts + 10 visual cases.
- [x] Manual section 08 + README changelog.

## 13. Label engine refinements (user feedback rounds, 2026-07-06)
- [x] Label-vs-label collision uses TIGHT (near-text) rects — neighboring
      labels may share padding space, tidy rows stay aligned.
- [x] Association rule, HARD constraint with margin: label center must be
      closer to its own point than to any other by assoc-factor (1.15);
      violating candidates rejected from search AND fallback.
- [x] Strict size phases: ALL full-size candidates before any shrunk one
      (shrink = last resort, per original user spec).
- [x] Uniform group scale: if any label of a figure shrinks, the whole label
      group is re-placed at the common smallest scale (fixpoint passes);
      sticky for later label calls via shared-state "ctz-label-scale".
- [x] Fully automatic default: with the engine on, unspecified labels use
      pos "auto" (labels: true needs no positions at all).
- [x] rings default 3 → 5 and any-size least-bad fallback: hub points (e.g.
      centroid with three medians) find clean full-size wedges instead of
      touching a line.
