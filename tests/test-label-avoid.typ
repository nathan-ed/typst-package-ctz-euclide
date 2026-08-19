// Tests for the collision-avoiding label placement engine.
// Compile from the package root:  typst compile --root . tests/test-label-avoid.typ

#import "../src/lib.typ": *

#set page(width: 18cm, height: auto, margin: 1cm)

#let assert-close(got, want, eps: 1e-6, msg: "") = {
  assert(
    calc.abs(got - want) < eps,
    message: msg + ": expected " + repr(want) + ", got " + repr(got),
  )
}

= Label collision avoidance

== Part 1 — numeric assertions

#{
  // --- anchor-candidate-rect: all 8 anchors, w=2, h=1, pad=0.25 -----------
  // padded size: W=2.5, H=1.5, at coord (10, 20)
  let cases = (
    ("above",       (10 - 1.25, 20,       10 + 1.25, 20 + 1.5)),
    ("below",       (10 - 1.25, 20 - 1.5, 10 + 1.25, 20)),
    ("right",       (10,        20 - 0.75, 10 + 2.5, 20 + 0.75)),
    ("left",        (10 - 2.5,  20 - 0.75, 10,       20 + 0.75)),
    ("above right", (10,        20,        10 + 2.5, 20 + 1.5)),
    ("above left",  (10 - 2.5,  20,        10,       20 + 1.5)),
    ("below right", (10,        20 - 1.5,  10 + 2.5, 20)),
    ("below left",  (10 - 2.5,  20 - 1.5,  10,       20)),
  )
  for (pos, want) in cases {
    let got = _drawing.anchor-candidate-rect(pos, (10, 20), 2, 1, 0.25)
    for i in range(4) {
      assert-close(got.at(i), want.at(i), msg: "rect " + pos + " [" + str(i) + "]")
    }
  }

  // --- candidate list: order, length, uniqueness ---------------------------
  // 8 anchors x 3 rings + 16 float directions x 3 rings
  let cands = _drawing._candidate-list("above", 3)
  assert(cands.len() == 72, message: "72 candidates expected, got " + str(cands.len()))
  assert(cands.at(0).pos == "above" and cands.at(0).ring == 0,
    message: "preferred anchor first, got " + repr(cands.at(0)))
  assert(cands.map(c => (c.pos, c.angle, c.ring)).dedup().len() == 72, message: "candidates must be unique")
  // float candidates are more expensive than staying near the request but
  // cheaper than the far rings / big flips of the anchor grid
  let first-float = cands.position(c => c.pos == "center")
  assert(cands.at(first-float).cost >= 3.4, message: "floats start at cost 3.4")
  // staying on the requested side (farther ring) beats switching anchors
  let idx-of(pos, ring) = cands.position(x => x.pos == pos and x.ring == ring)
  assert(idx-of("above", 1) < idx-of("above left", 0), message: "preferred@r1 before neighbor@r0")
  // but a 45° neighbor at ring 0 beats a 90° switch at ring 0
  assert(idx-of("above left", 0) < idx-of("left", 0), message: "45° before 90°")
  assert(idx-of("above", 1) < idx-of("left", 1), message: "preferred@r1 before 90°@r1")
  // anchor switches are expensive: every ring on the requested anchor is
  // exhausted before even the 45° neighbors at ring 0
  assert(idx-of("above", 2) < idx-of("above left", 0), message: "preferred@r2 before 45° switch")
  // the OPPOSITE side keeps the label centered on the same axis and beats
  // perpendicular and diagonal flips (crowded rows alternate above/below)
  assert(idx-of("above left", 0) < idx-of("below", 0), message: "45° lean before opposite")
  assert(idx-of("below", 0) < idx-of("left", 0), message: "opposite before 90°")
  assert(idx-of("below", 0) < idx-of("below left", 0), message: "opposite before 135°")

  // --- precise position parser ----------------------------------------------
  let pp = _drawing._parse-precise-pos("above+1.2 left+0.5")
  assert(pp.pos == "above left" and pp.enforced, message: "precise compound: " + repr(pp))
  assert-close(pp.offset.at(0), -0.5, msg: "precise dx")
  assert-close(pp.offset.at(1), 1.2, msg: "precise dy")
  let pp2 = _drawing._parse-precise-pos("top+.8")
  assert(pp2.pos == "above" and pp2.enforced, message: "top alias: " + repr(pp2))
  assert-close(pp2.offset.at(1), 0.8, msg: "top alias dy")
  let pp3 = _drawing._parse-precise-pos("left-0.5")   // negative flips
  assert(pp3.pos == "right" and pp3.enforced, message: "negative flip: " + repr(pp3))
  assert-close(pp3.offset.at(0), 0.5, msg: "negative flip dx")
  let pp4 = _drawing._parse-precise-pos("above left") // plain names: suggestion
  assert(pp4.pos == "above left" and not pp4.enforced, message: "plain compound: " + repr(pp4))
  assert(_drawing._parse-precise-pos("auto") == none, message: "auto is not a direction")
  assert(_drawing._parse-precise-pos("above+x") == none, message: "bad amount rejected")

  // --- segment chord --------------------------------------------------------
  // horizontal segment through a unit rect
  let rect = (0, 0, 1, 1)
  assert-close(_drawing._segment-rect-chord(rect, (-1, 0.5), (2, 0.5)), 1, msg: "full chord")
  assert-close(_drawing._segment-rect-chord(rect, (-1, 2), (2, 2)), 0, msg: "miss above")
  assert-close(_drawing._segment-rect-chord(rect, (0.5, 0.5), (2, 0.5)), 0.5, msg: "endpoint inside")

  // --- circle ring depth -----------------------------------------------------
  // rect fully inside a big circle: touches no stroke → 0
  assert-close(_drawing._rect-circle-ring-depth((-0.5, -0.5, 0.5, 0.5), (0, 0), 5, 0.1), 0,
    msg: "rect inside big circle")
  // rect far outside: 0
  assert-close(_drawing._rect-circle-ring-depth((10, 10, 11, 11), (0, 0), 5, 0.1), 0,
    msg: "rect outside circle")
  // rect straddling the ring: > 0
  assert(_drawing._rect-circle-ring-depth((4.5, -0.5, 5.5, 0.5), (0, 0), 5, 0.1) > 0,
    message: "rect straddling ring must collide")

  // --- rect-point distance ---------------------------------------------------
  assert-close(_drawing._rect-point-dist((0, 0, 1, 1), (0.5, 0.5)), 0, msg: "point inside")
  assert-close(_drawing._rect-point-dist((0, 0, 1, 1), (2, 1)), 1, msg: "point right of rect")

  // --- find-label-placement: blocked preferred anchor -----------------------
  // Point at origin on a horizontal line; a label rect already sits exactly
  // where "above" (and its rings) would land → engine must pick a clean spot:
  // the opposite side ("below"), which keeps the label centered on the point.
  let sizes = ((scale: 1.0, w: 0.4, h: 0.25),)
  let cfg = (pad: 0.1, ring-step: 0.15, rings: 3, weights: (label: 4, point: 2, segment: 1, circle: 1), margin: 0.02)
  let obstacles = (
    segments: (((-5, 0), (5, 0)),),           // horizontal line through the point
    circles: (),
    points: (),
    labels: ((-0.15, 0.0, 0.15, 1.5),),       // tall narrow blocker over "above"
  )
  let res = _drawing.find-label-placement("above", (0, 0), sizes, obstacles, cfg)
  assert(res.score == 0, message: "expected clean placement, got score " + str(res.score))
  assert(res.pos != "above", message: "blocked anchor must not be used")
  assert(res.pos == "below", message: "opposite side expected, got " + res.pos)
  assert(res.scale == 1.0, message: "no shrink needed")

  // deterministic: same inputs → same result
  let res2 = _drawing.find-label-placement("above", (0, 0), sizes, obstacles, cfg)
  assert(repr(res) == repr(res2), message: "placement must be deterministic")

  // --- find-label-placement: fully boxed-in point ---------------------------
  // Four fat point disks around the origin leave no clean spot within reach:
  // engine must terminate and return the least-bad full-size candidate.
  let boxed = (
    segments: (
      ((-3, 1.2), (3, 1.2)), ((-3, -1.2), (3, -1.2)),
      ((-1.2, -3), (-1.2, 3)), ((1.2, -3), (1.2, 3)),
    ),
    circles: (),
    // a large disk right on the point makes every candidate collide
    points: ((0, 0, 3),),
    labels: (),
  )
  let sizes3 = (
    (scale: 1.0, w: 0.8, h: 0.4),
    (scale: 0.85, w: 0.68, h: 0.34),
    (scale: 0.7, w: 0.56, h: 0.28),
  )
  let res3 = _drawing.find-label-placement("above", (0, 0), sizes3, boxed, cfg)
  assert(res3.score > 0, message: "impossible layout must report score > 0")
  assert(res3.scale == 1.0, message: "fallback must be full size")

  // --- shrink path: tight slot that only fits the small size ----------------
  // Two horizontal lines 0.5 apart; full-size padded label is 0.45 tall + gap
  // rings; the 0.7-scale one fits between them above the point.
  let slot = (
    segments: (((-5, 0), (5, 0)), ((-5, 0.5), (5, 0.5)),
               ((-5, -0.4), (5, -0.4)), ((-0.4, -3), (-0.4, 3)), ((0.4, -3), (0.4, 3))),
    circles: (), points: (), labels: (),
  )
  let sizes4 = (
    (scale: 1.0, w: 0.9, h: 0.5),
    (scale: 0.7, w: 0.63, h: 0.28),
  )
  let cfg4 = (pad: 0.05, ring-step: 0.05, rings: 2, weights: cfg.weights, margin: 0.01)
  let res4 = _drawing.find-label-placement("above", (0, 0), sizes4, slot, cfg4)
  assert(res4.score == 0 and res4.scale == 0.7,
    message: "expected shrunk clean fit, got scale " + str(res4.scale) + " score " + str(res4.score))

// --- association rule: label always closer to its own point ---------------
  // Point at origin, neighbor at (0.6, 0). A blocker forces the label off
  // "above"; whatever the engine picks, the label center must remain closer
  // to (0,0) than to the neighbor.
  let assoc-obstacles = (
    segments: (((-5, 0), (5, 0)),),
    circles: (),
    points: ((0.6, 0, 0.05),),
    labels: ((-0.6, 0.05, 0.6, 0.6),),   // wide blocker over "above"
  )
  let res5 = _drawing.find-label-placement("above", (0, 0),
    ((scale: 1.0, w: 0.5, h: 0.25),), assoc-obstacles, cfg)
  let cx = (res5.rect.at(0) + res5.rect.at(2)) / 2
  let cy = (res5.rect.at(1) + res5.rect.at(3)) / 2
  let d-own = calc.sqrt(cx * cx + cy * cy)
  let d-other = calc.sqrt((cx - 0.6) * (cx - 0.6) + cy * cy)
  assert(d-own < d-other,
    message: "label must be closer to its own point: own " + str(d-own) + " vs other " + str(d-other))

  // HARD constraint: even in an impossible layout (fallback path), the
  // returned placement must satisfy the association rule whenever any
  // association-valid candidate exists.
  let impossible = (
    segments: (((-3, 0.55), (3, 0.55)), ((-3, -0.55), (3, -0.55)),
               ((-0.55, -3), (-0.55, 3)), ((0.55, -3), (0.55, 3)),
               ((-3, 0), (3, 3)), ((0, -3), (3, 0))),
    circles: (),
    points: ((0.5, 0, 0.05),),   // neighbor to the right
    labels: (),
  )
  let res6 = _drawing.find-label-placement("above", (0, 0),
    ((scale: 1.0, w: 0.8, h: 0.4),), impossible, cfg)
  assert(res6.score > 0, message: "impossible layout must report score > 0")
  let c6x = (res6.rect.at(0) + res6.rect.at(2)) / 2
  let c6y = (res6.rect.at(1) + res6.rect.at(3)) / 2
  let d6-own = calc.sqrt(c6x * c6x + c6y * c6y)
  let d6-other = calc.sqrt((c6x - 0.5) * (c6x - 0.5) + c6y * c6y)
  assert(d6-own < d6-other,
    message: "fallback must also respect association: own " + str(d6-own) + " vs other " + str(d6-other))
}
All numeric assertions passed.

== Part 2 — visual cases

=== Five crowded points all requesting "above" (too tight for one side → alternate above/below, full size)
#ctz-canvas({
  ctz-init()
  ctz-def-points(P1: (0, 0), P2: (0.45, 0), P3: (0.9, 0), P4: (1.35, 0), P5: (1.8, 0))
  ctz-draw-segment("P1", "P5")
  ctz-draw(points: ("P1", "P2", "P3", "P4", "P5"),
    labels: (P1: "above", P2: "above", P3: "above", P4: "above", P5: "above"))
})

=== Same figure fully automatic (endpoints go outward, middle row stays calm)
#ctz-canvas({
  ctz-init()
  ctz-def-points(P1: (0, 0), P2: (0.45, 0), P3: (0.9, 0), P4: (1.35, 0), P5: (1.8, 0))
  ctz-draw-segment("P1", "P5")
  ctz-draw(points: ("P1", "P2", "P3", "P4", "P5"), labels: true)
})

=== Moderate crowding stays at full size (no shrink unless nothing calm fits)
#ctz-canvas({
  ctz-init()
  ctz-def-points(Q1: (0, 0), Q2: (0.8, 0), Q3: (1.6, 0), Q4: (2.4, 0))
  ctz-draw-segment("Q1", "Q4")
  ctz-draw(points: ("Q1", "Q2", "Q3", "Q4"),
    labels: (Q1: "above", Q2: "above", Q3: "above", Q4: "above"))
})

=== Same five crowded points with ctz-label-avoid((allow-shrink: false)) (alternation needs no shrink anyway)
#ctz-canvas({
  ctz-init()
  ctz-label-avoid((allow-shrink: false))
  ctz-def-points(P1: (0, 0), P2: (0.45, 0), P3: (0.9, 0), P4: (1.35, 0), P5: (1.8, 0))
  ctz-draw-segment("P1", "P5")
  ctz-draw(points: ("P1", "P2", "P3", "P4", "P5"),
    labels: (P1: "above", P2: "above", P3: "above", P4: "above", P5: "above"))
})

=== Same figure with avoidance disabled via ctz-label-avoid(false) (labels overlap — for comparison)
#ctz-canvas({
  ctz-init()
  ctz-label-avoid(false)
  ctz-def-points(P1: (0, 0), P2: (0.45, 0), P3: (0.9, 0), P4: (1.35, 0), P5: (1.8, 0))
  ctz-draw-segment("P1", "P5")
  ctz-draw(points: ("P1", "P2", "P3", "P4", "P5"),
    labels: true)
})

=== Crowded triangle: circumcircle + incircle + medians, everything labeled
#ctz-canvas(length: 0.9cm, {
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.06))
  ctz-def-points(A: (0, 0), B: (6, 0.5), C: (2, 4.5))
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.2pt)
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue + 0.8pt)
  ctz-draw(incircle: ("A", "B", "C"), stroke: green + 0.8pt)
  ctz-def-centroid("G", "A", "B", "C")
  ctz-def-circumcenter("O", "A", "B", "C")
  ctz-def-incenter("I", "A", "B", "C")
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")
  ctz-draw(segment: ("A", "Ma"), stroke: gray + 0.6pt)
  ctz-draw(segment: ("B", "Mb"), stroke: gray + 0.6pt)
  ctz-draw(segment: ("C", "Mc"), stroke: gray + 0.6pt)
  ctz-draw(points: ("A", "B", "C", "G", "O", "I", "Ma", "Mb", "Mc"), labels: (
    A: "below left", B: "below right", C: "above",
    G: "above", O: "below", I: "left",
    Ma: "above right", Mb: "left", Mc: "below",
  ))
})

=== Same triangle, fully automatic (labels: true — no positions specified)
#ctz-canvas(length: 0.9cm, {
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.06))
  ctz-def-points(A: (0, 0), B: (6, 0.5), C: (2, 4.5))
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.2pt)
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue + 0.8pt)
  ctz-draw(incircle: ("A", "B", "C"), stroke: green + 0.8pt)
  ctz-def-centroid("G", "A", "B", "C")
  ctz-def-circumcenter("O", "A", "B", "C")
  ctz-def-incenter("I", "A", "B", "C")
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")
  ctz-draw(segment: ("A", "Ma"), stroke: gray + 0.6pt)
  ctz-draw(segment: ("B", "Mb"), stroke: gray + 0.6pt)
  ctz-draw(segment: ("C", "Mc"), stroke: gray + 0.6pt)
  ctz-draw(points: ("A", "B", "C", "G", "O", "I", "Ma", "Mb", "Mc"), labels: true)
})

=== Point on a line, label "below" blocked by a second line → flips to the open side above
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (-2, 0), B: (2, 0), M: (0, 0), A2: (-2, -0.45), B2: (2, -0.45))
  ctz-draw-segment("A", "B")
  ctz-draw-segment("A2", "B2")
  ctz-draw(points: ("M",), labels: (M: "below"))
})

=== Scale independence: same figure at length 0.5cm and 2cm
#grid(columns: 2, gutter: 1cm,
  ctz-canvas(length: 0.5cm, {
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), M: (2, 0))
    ctz-draw-segment("A", "B")
    ctz-draw(points: ("A", "B", "M"), labels: true)
  }),
  ctz-canvas(length: 2cm, {
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), M: (2, 0))
    ctz-draw-segment("A", "B")
    ctz-draw(points: ("A", "B", "M"), labels: true)
  }),
)

=== Labels avoid a circle stroke but are allowed inside the circle
#ctz-canvas({
  ctz-init()
  ctz-def-points(O: (0, 0), P: (2, 0))
  ctz-draw-circle-r((0, 0), 2, stroke: blue)
  ctz-draw(points: ("O", "P"), labels: (O: "above", P: "right"))
})

=== Angle label avoidance: $alpha$ slides past the Q marker; Q's label dodges both
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (2.5, 0), V: (0, 0), B: (2, 1.8), Q: (1.05, 0.45))
  ctz-draw-segment("V", "A")
  ctz-draw-segment("V", "B")
  ctz-draw(points: ("Q",))
  ctz-draw-angle("V", "A", "B", label: $alpha$, radius: 0.9)
  ctz-draw(labels: (Q: "left"))
})

=== Duplicate labels are skipped (path auto-labels + explicit ctz-draw-labels)
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
  ctz-draw(path: "A--B--C--A", stroke: black)
  ctz-draw-points("A", "B", "C")
  ctz-draw-labels("A", "B", "C")
})

=== Per-label granularity: M2 pinned exactly where asked (avoid: false), M1/M3 dodge
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (4, 0), M1: (1, 0), M2: (2, 0), M3: (3, 0))
  ctz-draw-segment("A", "B")
  ctz-draw(points: ("M1", "M2", "M3"), labels: (
    M1: "above",
    M2: (pos: "below", avoid: false),  // sits ON the line, exactly as requested
    M3: "above",
  ))
})

=== Precise placement: numeric offsets pin labels exactly (engine off for them)
`A: "above+1.2 left+0.5"`, `B: "top+0.8"`, `M: "below+0.3 right+0.2"` — offsets in canvas units on a 0.5 grid:
#ctz-canvas({
  ctz-init()
  ctz-draw-grid(xmin: -1.5, xmax: 5, ymin: -1, ymax: 2, xstep: 0.5, ystep: 0.5, stroke: luma(85%) + 0.4pt)
  ctz-def-points(A: (0, 0), B: (4, 0), M: (2, 0))
  ctz-draw-segment("A", "B")
  ctz-draw(points: ("A", "B", "M"), labels: (
    A: "above+1.2 left+0.5",
    B: "top+0.8",
    M: "below+0.3 right+0.2",
  ))
})

=== Per-label "auto" mixed with explicit and precise positions
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
  ctz-draw(line: ("A", "B", "C", "A"))
  ctz-draw(points: ("A", "B", "C"), labels: (
    A: "auto",                    // engine picks the side from the geometry
    B: "below+0.4 right+0.3",     // pinned exactly
    C: "auto",
  ))
})

=== Turning avoidance back on mid-canvas
#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (4, 0), P: (1.3, 0), Q: (2.7, 0))
  ctz-draw-segment("A", "B")
  ctz-label-avoid(false)
  ctz-draw(labels: (P: "below",))   // overlaps the line (avoidance off)
  ctz-label-avoid(true)
  ctz-draw(labels: (Q: "below",))   // dodges the line (avoidance on again)
})
