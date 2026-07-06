// Regression tests for the 2026-07 review fixes.
// Compile from the package root:  typst compile --root . tests/test-regressions.typ
//
// Part 1 asserts numerically (a bug makes the compile FAIL).
// Part 2 renders visual cases; compare against tests/test-regressions-*.png.

#import "../src/lib.typ": *

#set page(width: 18cm, height: auto, margin: 1cm)

#let assert-close(got, want, eps: 1e-6, msg: "") = {
  assert(
    calc.abs(got - want) < eps,
    message: msg + ": expected " + repr(want) + ", got " + repr(got),
  )
}
#let assert-pt(got, want, eps: 1e-6, msg: "") = {
  assert-close(got.at(0), want.at(0), eps: eps, msg: msg + " (x)")
  assert-close(got.at(1), want.at(1), eps: eps, msg: msg + " (y)")
}

= Regression tests

== Part 1 — numeric assertions

#{
  // --- atan2 argument order (systemic fix) ---------------------------------
  // slope-angle of a horizontal segment is 0°, vertical is 90°
  assert-close((ctz-algorithms.slope-angle)((0, 0), (1, 0)), 0, msg: "slope horizontal")
  assert-close((ctz-algorithms.slope-angle)((0, 0), (0, 1)), 90, msg: "slope vertical")
  assert-close((ctz-algorithms.slope-angle)((0, 0), (1, 1)), 45, msg: "slope diagonal")

  // _direction-angle (drives auto label placement): to the right = 0°
  assert-close(_drawing._direction-angle((0, 0), (1, 0)), 0, msg: "direction-angle right")
  assert-close(_drawing._direction-angle((0, 0), (0, 1)), 90, msg: "direction-angle up")

  // auto label position for a point on a horizontal line avoids the line
  let pos = _drawing.compute-auto-label-position((0, 180))
  assert(pos in ("above", "below"), message: "auto label on horizontal line got " + pos)

  // --- tangent points from external point ----------------------------------
  // From P(4,0) to unit circle at O: contact points (1/4, ±√15/4)
  let tg = (ctz-algorithms.tangent-from)((4, 0, 0), (0, 0, 0), 1)
  assert(tg.len() == 2, message: "two tangent points expected")
  assert-close(tg.at(0).at(0), 0.25, msg: "tangent point x")
  assert-close(tg.at(1).at(0), 0.25, msg: "tangent point x")
  assert-close(calc.abs(tg.at(0).at(1)), calc.sqrt(15) / 4, msg: "tangent point |y|")
  assert-close(tg.at(0).at(1) + tg.at(1).at(1), 0, msg: "tangent points symmetric")

  // --- excenter: case-insensitive vertex, correct default ------------------
  // 3-4-5 triangle A(0,0) B(4,0) C(0,3): excenter opposite A is (6, 6)
  let A = (0, 0, 0)
  let B = (4, 0, 0)
  let C = (0, 3, 0)
  assert-pt((ctz-algorithms.excenter)(A, B, C, vertex: "a"), (6, 6), msg: "excenter a")
  assert-pt((ctz-algorithms.excenter)(A, B, C, vertex: "A"), (6, 6), msg: "excenter A (uppercase)")

  // --- golden ratio point: inside and outside ------------------------------
  let phi = (1 + calc.sqrt(5)) / 2
  assert-pt(
    (ctz-algorithms.golden-ratio-point)((0, 0, 0), (1, 0, 0)),
    (1 / phi, 0),
    msg: "golden inside",
  )
  assert-pt(
    (ctz-algorithms.golden-ratio-point)((0, 0, 0), (1, 0, 0), inside: false),
    (phi, 0),
    msg: "golden outside",
  )

  // --- intersections --------------------------------------------------------
  let ll = (ctz-algorithms.line-line)((0, 0, 0), (2, 2, 0), (0, 2, 0), (2, 0, 0))
  assert-pt(ll, (1, 1), msg: "line-line")
  let lc = (ctz-algorithms.line-circle)((-2, 0, 0), (2, 0, 0), (0, 0, 0), 1)
  assert(lc.len() == 2, message: "line-circle two points")
  // externally tangent circles meet in exactly one point
  let cc = (ctz-algorithms.circle-circle)((0, 0, 0), 1, (2, 0, 0), 1, epsilon: 1e-6)
  assert(cc.len() == 1, message: "tangent circles: expected 1 point, got " + str(cc.len()))
  assert-pt(cc.at(0), (1, 0), eps: 1e-3, msg: "tangency point")

  // --- ellipse projection preserves the ray direction ----------------------
  // Project (2,2) onto ellipse rx=2, ry=1 along the ray from center:
  // result must lie on the ellipse AND on the ray y = x
  let proj = _conic.ellipse-project-point-raw((0, 0, 0), 2, 1, (2, 2, 0))
  let on-ellipse = calc.abs(
    proj.at(0) * proj.at(0) / 4 + proj.at(1) * proj.at(1) - 1,
  )
  assert(on-ellipse < 1e-6, message: "projection lies on ellipse")
  assert-close(proj.at(1) - proj.at(0), 0, msg: "projection keeps ray direction")
  assert(proj.at(0) > 0, message: "projection on the correct side")

  // --- feuerbach sanity (3-4-5: incenter (1,1), r=1; N=(1.25,0.75), R9=1.25)
  let F = (ctz-algorithms.feuerbach)(A, B, C)
  let I = (ctz-algorithms.incenter)(A, B, C)
  assert-close((ctz-algorithms.dist)(F, I), 1, msg: "feuerbach on incircle")

  // --- grid steps: no float-accumulation dropout ---------------------------
  assert(_drawing._step-values(0, 1, 0.1).len() == 11, message: "0..1 step 0.1 has 11 values")
  assert(_drawing._step-values(-5, 5, 1).len() == 11, message: "-5..5 step 1 has 11 values")

  // --- label rendering ------------------------------------------------------
  // greek names become symbols; odd names must not panic inside eval
  assert(repr(_drawing._math-label("alpha")) == repr($alpha$), message: "alpha renders as α")
  let _ = _drawing._math-label("Omega12")
  let _ = _drawing._math-label("P'")
  let _ = _drawing._math-label("not a name!")

  // --- version consistency --------------------------------------------------
  let toml-version = toml("../typst.toml").package.version
  assert(
    ctz-version.map(str).join(".") == toml-version,
    message: "ctz-version " + repr(ctz-version) + " != typst.toml " + toml-version,
  )
  // the bundled cetz must match the ecosystem version (issue #1)
  assert(cetz.version == version(0, 5, 2), message: "cetz version drifted")
}
All numeric assertions passed.

== Part 2 — visual cases

=== Issue #4 repro: arc around A from B to C (red quarter circle joining B and C)
#ctz-canvas(length: 0.5cm, {
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.08))
  ctz-def-points(A: (0, 0), B: (5, 0), C: (0, 5))
  ctz-draw-line("C", "A", "B")
  ctz-draw(arc: (center: "A", start: "B", end: "C"), stroke: (paint: red, dash: "dashed"))
  ctz-draw(points: ("A", "B", "C"), labels: (A: "above left", B: "below right", C: "below left"))
})

=== Semicircles: red above AB, blue below; sector; compass arc; arc-r
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0), O: (5, 0), P: (6, 1), Q: (5, 2))
  ctz-draw-segment("A", "B")
  ctz-draw-semicircle("A", "B", stroke: red)
  ctz-draw-semicircle("A", "B", stroke: blue, above: false)
  ctz-draw-sector("O", "P", "Q", stroke: blue, fill: blue.lighten(80%))
  ctz-draw-arc-r((8, 0), 1, 0deg, 90deg, stroke: green)
  ctz-draw(points: ("A", "B", "O"), labels: true)
})

=== Angle types: interior α, supplementary β (flat side), reflex γ
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (2, 0), V: (0, 0), B: (1.5, 1.5))
  ctz-draw-line-add("A", "V", add: (0, 0.8), stroke: gray)
  ctz-draw-segment("V", "A")
  ctz-draw-segment("V", "B")
  ctz-draw-angle("V", "A", "B", label: $alpha$, radius: 0.5)
  ctz-draw-angle("V", "A", "B", label: $beta$, angle-type: "supplementary", radius: 0.8, stroke: blue)
  ctz-draw-angle("V", "A", "B", label: $gamma$, angle-type: "reflex", radius: 1.1, stroke: red)
  ctz-draw(points: ("A", "V", "B"), labels: (A: "below", V: "below left", B: "above"))
})

=== Global angle style via ctz-style (orange, radius 0.9) + right-angle marks
#ctz-canvas({
  ctz-init()
  ctz-style(angle: (radius: 0.9, stroke: orange + 1pt))
  ctz-def-points(A: (3, 0), V: (0, 0), B: (0, 2))
  ctz-draw-line("A", "V", "B")
  ctz-draw-angle("V", "A", "B", label: $theta$)
  ctz-draw-mark-right-angle("A", "V", "B", color: purple)
  ctz-draw-mark-right-angle("A", "V", "B", german: true, color: green, size: 0.55)
})

=== Sketchy named objects (used to crash): line d, polygon T, circle c
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (4, 0), C: (2, 2.5))
  ctz-def-line("d", "A", "B")
  ctz-def-polygon("T", "A", "B", "C")
  ctz-def-circle("c", "C", radius: 0.8)
  ctz-draw("d", sketchy: true, stroke: blue)
  ctz-draw("T", sketchy: true, stroke: red)
  ctz-draw("c", sketchy: true)
})

=== Labels: auto placement off the line (M), 6-char name (Omega1), greek (alpha)
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (4, 0), M: (2, 0), Omega1: (6, 0), alpha: (8, 0))
  ctz-def-line("ab", "A", "B")
  ctz-draw-line("A", "B")
  ctz-draw(points: ("A", "B", "M"), labels: (A: "auto", B: "auto", M: "auto"))
  ctz-draw(points: ("Omega1", "alpha"))
  ctz-draw(labels: (Omega1: "above", alpha: "above"))
})

=== Point style overrides on ctz-draw (red dots, big green squares)
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (1.5, 0), C: (3, 0), D: (4.5, 0))
  ctz-draw(points: ("A", "B"), shape: "dot", size: 0.09, color: red)
  ctz-draw(points: ("C", "D"), shape: "square", size: 0.12, color: green)
})

=== Translation by point pair (fixed) and by raw vector
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (1, 1), P: (3, 0))
  ctz-def-translate("P1", "P", ("A", "B"))  // P + (B - A) = (4, 1)
  ctz-def-translate("P2", "P", (0, -1))     // (3, -1)
  ctz-draw-segment("A", "B", arrows: "->")
  ctz-draw(points: ("P", "P1", "P2"), labels: true)
})

=== Grid with step 0.1 sub-grid: last line at 1.0 present on all four edges
#ctz-canvas(length: 3cm, {
  ctz-init()
  ctz-draw-grid(xmin: 0, xmax: 1, ymin: 0, ymax: 1, xstep: 0.5, ystep: 0.5,
    sub: true, sub-xstep: 0.1, sub-ystep: 0.1)
})
