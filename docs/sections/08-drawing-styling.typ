// Drawing & Styling
#import "../helpers.typ": *

= Drawing & Styling

== Global Style Configuration

The package provides configurable style variables that control the default appearance of points, crosses, and marks. These are defined in `draw.typ` and can be overridden.

=== Style Variables

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  stroke: 0.5pt + luma(80%),
  inset: 6pt,
  [*Variable*], [*Default*], [*Description*],
  [`default-point-stroke-width`], [`0.9pt`], [Stroke width for point markers (crosses, plus signs)],
  [`default-mark-stroke-width`], [`1pt`], [Stroke width for tick marks on segments and arcs],
  [`default-point-size`], [`0.07`], [Point size in canvas units (for `ctz-draw` points)],
  [`default-point-size-pt`], [`2pt`], [Point size in pt (for path markers like crosses)],
  [`default-point-size-small-pt`], [`1.5pt`], [Smaller point size in pt (for dots, circles, squares)],
  [`default-point-color`], [`black`], [Default color for points],
  [`default-line-color`], [`black`], [Default color for lines and segments],
  [`default-mark-color`], [`black`], [Default color for construction marks],
  [`default-point-shape`], [`"cross"`], [Default point shape (cross, dot, circle, plus, square, diamond, triangle)],
)

=== Customizing Styles

To customize the default appearance, modify the variables in `src/draw.typ` at the top of the file:

```typst
// In src/draw.typ - modify these values:
#let default-point-stroke-width = 1.2pt   // thicker crosses
#let default-mark-stroke-width = 1.5pt    // thicker tick marks
#let default-point-size = 0.1             // larger points
#let default-point-size-pt = 3pt          // larger path markers
#let default-point-color = blue           // blue points
#let default-line-color = gray            // gray lines
#let default-mark-color = red             // red tick marks
#let default-point-shape = "dot"          // use dots instead of crosses
```

All drawing functions throughout the package reference these variables, so changing them once affects all drawings consistently.

The public API also exports these as `ctz-default-point-stroke-width`, `ctz-default-point-color`, etc., for inspection.

== Automatic Label Placement (Collision Avoidance)

Labels are placed *as close as possible to the requested anchor* while
avoiding everything that has already been drawn: segments, circles, point
markers, and other labels. This is *on by default*.

The engine works per label, deterministically:

+ Measure the label and build its bounding box (including the standard 5pt
  gap around the text). In tight clusters — another point closer than the
  label could ever be — the gap is reduced to 60% so the label hugs its
  point instead of floating; points in open space keep the airy gap.
+ Try candidate positions in order of visual "closeness" to your request:
  the requested anchor first (pushed slightly farther out if needed), then a
  45° lean, then the *opposite* side — flipping above ↔ below keeps the
  label centered on the same axis, so a crowded row naturally alternates
  its labels above and below the line. Perpendicular and diagonal flips
  come last. When the anchor grid finds nothing nearby, *free-floating*
  candidates at 16 fine directions around the point take over — they can
  nestle a label into a tilted wedge (e.g. between two medians crossing at
  a centroid). *Every* full-size position is tried before the font is
  shrunk (85%, then 70%) — shrinking is a last resort.
+ A candidate is accepted when its *text* is clear of everything: thin
  geometry may run through the label's padding (a close, slightly grazed
  label reads better than one exiled to the first perfectly clear spot).
  If nothing is acceptable, the least-bad candidate is used (never an
  unbounded search).
+ If any label of a figure must shrink, *all* labels of that figure are
  re-placed at the same (smallest needed) scale — mixed sizes look
  accidental. The scale also applies to labels drawn later in the canvas.
+ *Group tidiness:* if even one label had to travel far from its point
  (staggered rows, big anchor flips) or still collides, the figure is
  overcrowded for its label size. The engine then retries the whole figure
  at a uniform smaller scale and keeps the largest scale where the layout is
  *calm* — every label at its requested anchor, nothing colliding. One
  quiet row of slightly smaller labels reads better than full-size chaos;
  if no scale is calm, the full-size layout is kept.

When the engine is active, labels without an explicit position are fully
automatic (`labels: true` picks each label's side from the local geometry).
`"auto"` also works per label, so you can mix automatic, suggested and
pinned labels in one call:

```typst
ctz-draw(points: ("A", "B", "C"), labels: (
  A: "auto",                 // engine picks the side from the geometry
  B: "left",                 // suggestion — may be adjusted
  C: "below+0.4 right+0.3",  // pinned exactly (see below)
))
```

Labels never overlap the *stroke* of a circle but may sit inside it, and a
label placed by the engine is registered so later labels avoid it too.

*Association guarantee:* an automatically placed label is always strictly
closer to its own point than to any other drawn point (`assoc-factor`,
default 1.0; raise it to demand a clear margin) — candidates that would
visually attach to a neighbor are rejected outright, in the fallback too.

*Important:* the engine only sees geometry drawn *before* the label —
draw your labels last (all examples in this manual already do).

=== Turning it off and on

```typst
ctz-label-avoid(false)   // global off: labels go exactly where asked
ctz-label-avoid(true)    // back on with defaults
```

Per label, `avoid: false` pins the label exactly where requested:

```typst
ctz-draw(points: ("A", "B", "M"), labels: (
  A: "below left",
  M: (pos: "below", avoid: false),  // exact position, no dodging
  B: "below right",
))
```

`ctz-label-avoid(...)` can be called mid-canvas; it affects all labels drawn
after it.

=== Precise manual placement

A plain position name (`"above"`) is a *suggestion* — the engine may move
the label to keep it readable. To place a label *exactly*, add numeric
offsets (canvas units) to direction tokens; such a label is pinned as
written and the engine ignores it:

```typst
ctz-draw(points: ("A", "B", "M"), labels: (
  A: "above+1.2 left+0.5",   // 1.2 up, 0.5 left of A — exactly there
  B: "top+0.8",              // top/bottom/up/down are aliases
  M: "below+0.3 right+0.2",
))
```

The direction tokens also set the text anchor (`"above+1.2 left+0.5"`
anchors like `"above left"`, so the text extends away from the point), and
the standard 5pt text gap still applies — `"above+0"` is exactly a pinned
`"above"`. A negative amount flips the direction (`"left-0.5"` moves right).
The equivalent dictionary form is
`(pos: "above left", offset: (-0.5, 1.2), avoid: false)`.

=== Configuration

Pass a dictionary to `ctz-label-avoid` (or set
`ctz-style(label: (avoid: (...)))`) to tune the engine. All distance options
accept Typst lengths (canvas-scale independent) or plain numbers (canvas
units).

#table(
  columns: (auto, auto, 1fr),
  inset: 6pt,
  stroke: 0.5pt + luma(80%),
  [*Option*], [*Default*], [*Meaning*],
  [`ring-step`], [`4pt`], [Extra distance per push-out retry],
  [`rings`], [`5`], [Number of distances tried per anchor],
  [`allow-shrink`], [`true`], [`false`: never reduce the font size — overcrowded figures stagger their labels at full size instead],
  [`shrink`], [`(0.85, 0.7)`], [Font scales tried when full size does not fit calmly],
  [`assoc-factor`], [`1.0`], [A label must be this factor closer to its own point than to any other (1.0 = strictly closer)],
  [`margin`], [`1.5pt`], [Clearance kept around points and circle strokes],
)

```typst
ctz-label-avoid((allow-shrink: false))   // full-size labels, whatever happens
ctz-label-avoid((rings: 8))              // search farther out
```

Angle labels (`ctz-draw-angle`) participate too: they slide outward along the
angle bisector until clear, and register their footprint so point labels flow
around them.

== Main Levée (Hand-Drawn Style)

The package supports a "main levée" (hand-drawn/sketchy) style that adds slight perturbations to lines and shapes, giving them a natural, hand-drawn appearance.

=== Main Levée Variables

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  stroke: 0.5pt + luma(80%),
  inset: 6pt,
  [*Variable*], [*Default*], [*Description*],
  [`default-main-levee`], [`false`], [Enable hand-drawn style globally],
  [`default-main-levee-roughness`], [`1.0`], [Roughness amount (0 = smooth, 1-2 = typical)],
  [`default-main-levee-seed`], [`42`], [Seed for reproducible randomness],
)

=== Using Sketchy Mode with `ctz-draw`

The simplest way to use hand-drawn style is to add `sketchy: true` to any `ctz-draw()` call. This works with segments, circles, polylines, ellipses, arcs, and more.

==== Sketchy Segments

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (4, 0), "C", (4, 2))

    // Normal segment for comparison
    ctz-draw(segment: ("A", "B"), stroke: gray)

    // Sketchy segments with different roughness
    ctz-draw(segment: ("B", "C"), stroke: blue, sketchy: true)
    ctz-draw(segment: ("C", "A"), stroke: red, sketchy: true, roughness: 1.5)

    ctz-draw(points: ("A", "B", "C"), labels: (A: "left", B: "below", C: "right"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (4, 0), "C", (4, 2))
    ctz-draw(segment: ("A", "B"), stroke: gray)
    ctz-draw(segment: ("B", "C"), stroke: blue, sketchy: true)
    ctz-draw(segment: ("C", "A"), stroke: red, sketchy: true, roughness: 1.5)
    ctz-draw(points: ("A", "B", "C"), labels: (A: "left", B: "below", C: "right"))
  },
  length: 0.6cm,
)

==== Sketchy Circles

#example(
  [```typst
  #ctz-canvas(length: 0.5cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("O", (0, 0), "P", (1.5, 0), "O2", (5, 0), "P2", (6.5, 0))

    // Normal circle
    ctz-draw(circle-through: ("O", "P"), stroke: gray)

    // Sketchy circle
    ctz-draw(circle-through: ("O2", "P2"), stroke: blue, sketchy: true)

    ctz-draw(points: ("O", "O2"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("O", (0, 0), "P", (1.5, 0), "O2", (5, 0), "P2", (6.5, 0))
    ctz-draw(circle-through: ("O", "P"), stroke: gray)
    ctz-draw(circle-through: ("O2", "P2"), stroke: blue, sketchy: true)
    ctz-draw(points: ("O", "O2"))
  },
  length: 0.5cm,
)

==== Sketchy Polylines (Triangles)

#example(
  [```typst
  #ctz-canvas(length: 0.5cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (3, 0), "C", (1.5, 2.5))
    ctz-def-points("A2", (5, 0), "B2", (8, 0), "C2", (6.5, 2.5))

    // Normal triangle
    ctz-draw(line: ("A", "B", "C", "A"), stroke: gray)

    // Sketchy triangle
    ctz-draw(line: ("A2", "B2", "C2", "A2"), stroke: blue, sketchy: true)

    ctz-draw(points: ("A", "B", "C", "A2", "B2", "C2"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (3, 0), "C", (1.5, 2.5))
    ctz-def-points("A2", (5, 0), "B2", (8, 0), "C2", (6.5, 2.5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: gray)
    ctz-draw(line: ("A2", "B2", "C2", "A2"), stroke: blue, sketchy: true)
    ctz-draw(points: ("A", "B", "C", "A2", "B2", "C2"))
  },
  length: 0.5cm,
)

==== Sketchy Ellipse

#example(
  [```typst
  #ctz-canvas(length: 0.5cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("O", (0, 0))

    ctz-draw(ellipse: ("O", 2.5, 1.5, 20deg), stroke: purple, sketchy: true)
    ctz-draw(points: ("O",))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("O", (0, 0))
    ctz-draw(ellipse: ("O", 2.5, 1.5, 20deg), stroke: purple, sketchy: true)
    ctz-draw(points: ("O",))
  },
  length: 0.5cm,
)

==== Sketchy Circumcircle and Incircle

#example(
  [```typst
  #ctz-canvas(length: 0.5cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (4, 0), "C", (1.5, 2.5))

    ctz-draw(line: ("A", "B", "C", "A"), stroke: gray, sketchy: true)
    ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue, sketchy: true)
    ctz-draw(incircle: ("A", "B", "C"), stroke: red, sketchy: true)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (4, 0), "C", (1.5, 2.5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: gray, sketchy: true)
    ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue, sketchy: true)
    ctz-draw(incircle: ("A", "B", "C"), stroke: red, sketchy: true)
    ctz-draw(points: ("A", "B", "C"), labels: (A: "below left", B: "below right", C: "above"))
  },
  length: 0.5cm,
)

==== Sketchy Path

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (2, 0), "C", (3, 1.5), "D", (1, 2))

    ctz-draw(path: "A--B--C--D--A", stroke: maroon, sketchy: true, roughness: 0.8)
    ctz-draw(points: ("A", "B", "C", "D"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("A", (0, 0), "B", (2, 0), "C", (3, 1.5), "D", (1, 2))
    ctz-draw(path: "A--B--C--D--A", stroke: maroon, sketchy: true, roughness: 0.8)
    ctz-draw(points: ("A", "B", "C", "D"))
  },
  length: 0.6cm,
)

=== Sketchy Parameters

The following parameters control the hand-drawn appearance:

- `sketchy: true` — Enable hand-drawn style
- `roughness: 1.0` — Controls wobbliness (0 = smooth, 1-2 = typical hand-drawn)
- `seed: 42` — Seed for reproducible randomness (same seed = same wobbles)

=== Roughness Comparison

The `roughness` parameter controls how "wobbly" the lines are:

#example(
  [```typst
  #ctz-canvas(length: 0.4cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("O1", (-4, 0), "P1", (-2.5, 0))
    ctz-def-points("O2", (0, 0), "P2", (1.5, 0))
    ctz-def-points("O3", (4, 0), "P3", (5.5, 0))

    // roughness = 0.5 (subtle)
    ctz-draw(circle-through: ("O1", "P1"), stroke: blue, sketchy: true, roughness: 0.5)
    content((-4, -2.5), [roughness: 0.5])

    // roughness = 1.0 (default)
    ctz-draw(circle-through: ("O2", "P2"), stroke: red, sketchy: true, roughness: 1.0)
    content((0, -2.5), [roughness: 1.0])

    // roughness = 2.0 (very sketchy)
    ctz-draw(circle-through: ("O3", "P3"), stroke: green, sketchy: true, roughness: 2.0)
    content((4, -2.5), [roughness: 2.0])
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points("O1", (-4, 0), "P1", (-2.5, 0))
    ctz-def-points("O2", (0, 0), "P2", (1.5, 0))
    ctz-def-points("O3", (4, 0), "P3", (5.5, 0))
    ctz-draw(circle-through: ("O1", "P1"), stroke: blue, sketchy: true, roughness: 0.5)
    content((-4, -2.5), [roughness: 0.5])
    ctz-draw(circle-through: ("O2", "P2"), stroke: red, sketchy: true, roughness: 1.0)
    content((0, -2.5), [roughness: 1.0])
    ctz-draw(circle-through: ("O3", "P3"), stroke: green, sketchy: true, roughness: 2.0)
    content((4, -2.5), [roughness: 2.0])
  },
  length: 0.4cm,
)

=== Supported Constructs

The `sketchy: true` parameter works with:

#table(
  columns: (auto, auto),
  align: (left, left),
  stroke: 0.5pt + luma(80%),
  inset: 6pt,
  [*Construct*], [*Example*],
  [`segment:`], [`ctz-draw(segment: ("A", "B"), sketchy: true)`],
  [`line:`], [`ctz-draw(line: ("A", "B", "C"), sketchy: true)`],
  [`path:`], [`ctz-draw(path: "A--B--C", sketchy: true)`],
  [`circle-through:`], [`ctz-draw(circle-through: ("O", "P"), sketchy: true)`],
  [`circle-r:`], [`ctz-draw(circle-r: ("O", 2), sketchy: true)`],
  [`circle-diameter:`], [`ctz-draw(circle-diameter: ("A", "B"), sketchy: true)`],
  [`circumcircle:`], [`ctz-draw(circumcircle: ("A", "B", "C"), sketchy: true)`],
  [`incircle:`], [`ctz-draw(incircle: ("A", "B", "C"), sketchy: true)`],
  [`ellipse:`], [`ctz-draw(ellipse: ("O", 2, 1.5), sketchy: true)`],
  [`arc:`], [`ctz-draw(arc: (center: "O", start: "A", end: "B"), sketchy: true)`],
  [`arc-r:`], [`ctz-draw(arc-r: ("O", 2, 0, 90), sketchy: true)`],
  [`semicircle:`], [`ctz-draw(semicircle: ("A", "B"), sketchy: true)`],
  [Named objects], [`ctz-draw("myCircle", sketchy: true)`],
)

=== Low-Level Sketchy Functions

For more control, you can also use the dedicated sketchy functions directly:

```typst
ctz-sketchy-line((0, 0), (4, 0), stroke: blue, roughness: 1.0)
ctz-sketchy-circle((0, 0), 2, stroke: red, roughness: 1.2)
ctz-sketchy-polygon((0, 0), (3, 0), (1.5, 2.5), stroke: green)
ctz-sketchy-ellipse((0, 0), 2, 1.5, angle: 20deg, stroke: purple)
ctz-sketchy-rect((-2, -1), (2, 1), stroke: orange)
ctz-sketchy-arc((0, 0), 2, 0deg, 90deg, stroke: teal)
```

== Points — `ctz-draw-points`

Draw points at named locations:

```typst
ctz-draw(points: ("A", "B", "C"))
```

== Unified Drawing — `ctz-draw`

The `ctz-draw()` function provides a unified interface for drawing both *named objects* and *unnamed constructs*.

=== Drawing Named Objects

Use `ctz-draw()` to draw any object type without remembering type-specific commands. It automatically detects whether the object is a point, line, circle, polygon, or conic (ellipse/parabola/projectile).

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-circle("c1", (0, 0), radius: 1.5)
    ctz-def-line("l1", (-2, 0), (2, 0))
    ctz-def-polygon("tri", "A", "B", "C")
    ctz-def-points(A: (1, 2), B: (2, 0), C: (0, 1))

    ctz-draw("c1", stroke: blue, fill: none)
    ctz-draw("l1", stroke: red + 1.5pt)
    ctz-draw("tri", stroke: green)
    ctz-draw("A")
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-circle("c1", (0, 0), radius: 1.5)
    ctz-def-line("l1", (-2, 0), (2, 0))
    ctz-def-polygon("tri", "A", "B", "C")
    ctz-def-points(A: (1, 2), B: (2, 0), C: (0, 1))
    ctz-draw("c1", stroke: blue, fill: none)
    ctz-draw("l1", stroke: red + 1.5pt)
    ctz-draw("tri", stroke: green)
    ctz-draw("A")
  },
  length: 0.75cm,
)

=== Drawing Unnamed Constructs

You can also use `ctz-draw()` to draw geometric objects directly without defining them first using named parameters.

*Define vs Draw*: Most `ctz-draw()` type parameters have a corresponding `ctz-def-*` function. Use `ctz-def-*` when you need to reuse the object (for intersections, transformations, etc.). Use the draw shorthand for one-off drawing. See the summary table at the end of this section.

==== Points with Labels

Draw multiple points at once, optionally with labels:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (2, 0), C: (2, 2), D: (0, 2))

    // Draw points with custom label positions
    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (2, 0), C: (2, 2), D: (0, 2))
    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  },
  length: 0.75cm,
)

Use `labels: true` for default label positioning, or omit the `labels` parameter to draw points without labels.

==== Paths and Polylines

Draw paths using the `path:` parameter for CeTZ-style path syntax, or `line:` for polylines through points:

```typst
ctz-draw(path: "A--B--C--A", stroke: black)  // Close the path by repeating first point
ctz-draw(line: ("A", "B", "C", "D"), stroke: red)  // Open polyline
```

==== Circles

Draw circles without naming them:

```typst
// Circle through two points (center and point on circumference)
ctz-draw(circle-through: ("O", "A"), stroke: blue)

// Circle by center and radius
ctz-draw(circle-r: ((0, 0), 1.5), stroke: green)

// Circle by diameter endpoints
ctz-draw(circle-diameter: ("A", "B"), stroke: purple)

// Circumcircle of triangle
ctz-draw(circumcircle: ("A", "B", "C"), stroke: red)

// Incircle of triangle
ctz-draw(incircle: ("A", "B", "C"), stroke: teal)
```

==== Conics (Ellipses, Parabolas, Projectiles)

Draw conics without naming them:

```typst
// Ellipse by center, radii, and rotation angle
ctz-draw(ellipse: ((0, 0), 3, 2, 20deg), stroke: black)

// Parabola by focus + directrix (line or two points)
ctz-draw(parabola: ((0, 0), ((-2, -3), (-2, 3)), 4), stroke: black)

// Projectile by origin + velocity (optional gravity, vectors, etc.)
ctz-draw(projectile: (origin: (0, 0), velocity: (4, 6), y-floor: 0, vectors: true), stroke: blue)
```

==== Arcs and Semicircles

```typst
// Arc by center and two points
ctz-draw(arc: (center: "O", start: "A", end: "B"), stroke: orange)

// Arc by center, radius, and angles (in degrees)
ctz-draw(arc-r: ((0, 0), 2, 0, 90), stroke: black)

// Semicircle by diameter endpoints
ctz-draw(semicircle: ("A", "B"), stroke: blue, fill: blue.lighten(80%))
```

==== Line Segments

```typst
ctz-draw(segment: ("A", "B"), stroke: maroon + 1.5pt)
```

=== Complete Example

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))

    // Named circle
    ctz-def-circle("myCircle", (1.5, 1), radius: 2.5)
    ctz-draw("myCircle", stroke: gray + 0.5pt)

    // Unnamed constructs
    ctz-draw(path: "A--B--C--A", stroke: black)
    ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
    ctz-draw(incircle: ("A", "B", "C"), stroke: red)
    ctz-draw(points: ("A", "B", "C"), labels: true)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
    ctz-def-circle("myCircle", (1.5, 1), radius: 2.5)
    ctz-draw("myCircle", stroke: gray + 0.5pt)
    ctz-draw(path: "A--B--C--A", stroke: black)
    ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
    ctz-draw(incircle: ("A", "B", "C"), stroke: red)
    ctz-draw(points: ("A", "B", "C"), labels: true)
  },
  length: 0.6cm,
)

== Labels — `ctz-draw-labels`

Add labels to points with positioning:

```typst
ctz-draw-labels("A", "B", "C",
  A: "below left",
  B: "below right",
  C: "above")
```

Positions: `"above"`, `"below"`, `"left"`, `"right"`, `"above left"`, etc.

Custom offset:
```typst
ctz-draw-labels("O", O: (pos: "below", offset: (0, -0.15)))
```

More placement controls (position, offset, distance):
```typst
ctz-draw-labels("A", "B", "C",
  A: (pos: "above", dist: 0.25),
  B: (pos: "right", offset: (0.1, 0)),
  C: (pos: "below left", offset: (-0.05, -0.05)))
```

== Labels & Points — Unified API (Recommended)

The modern approach combines point drawing and labeling in a single call:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  },
  length: 0.75cm,
)

This unified API replaces separate `ctz-draw-points()` and `ctz-draw-labels()` calls. The old API remains supported for backward compatibility.

You can also label points that were drawn earlier:
```typst
ctz-draw(points: ("A", "B"))  // Draw points without labels
// ... other drawing commands ...
ctz-draw(labels: (A: "below", B: "above"))  // Add labels later
```

== Segments — `ctz-draw-segment`

Draw a segment with optional arrow or bar tips and a dimension label:

```typst
ctz-draw-segment("A", "B", arrows: "|-|", dim: $5$, dim-pos: "above")
```

Supported `arrows`: `--` (none), `->`, `<-`, `<->`, `|-|`, `|->`, `<-|`.

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (6, 1.5))

    ctz-draw-segment("A", "B", arrows: "|-|", dim: $5$, dim-pos: "above")
    ctz-draw-segment("B", "C", arrows: "->", dim: $v$, dim-pos: "below")
    ctz-draw(points: ("A", "B", "C"), labels: (A: "below", B: "below", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (6, 1.5))

    ctz-draw-segment("A", "B", arrows: "|-|", dim: $5$, dim-pos: "above")
    ctz-draw-segment("B", "C", arrows: "->", dim: $v$, dim-pos: "below")
    ctz-draw(points: ("A", "B", "C"), labels: (A: "below", B: "below", C: "above"))
  },
  length: 0.8cm,
)

Mark equal-length segments with ticks:

```typst
ctz-draw-mark-segment("A", "B", mark: 1)
ctz-draw-mark-segment("C", "D", mark: 2)
```

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (4, 2.5), D: (0, 2.5))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black)

    // Opposite sides equal
    ctz-draw-mark-segment("A", "B", mark: 1)
    ctz-draw-mark-segment("C", "D", mark: 1)
    ctz-draw-mark-segment("B", "C", mark: 2)
    ctz-draw-mark-segment("D", "A", mark: 2)

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (4, 2.5), D: (0, 2.5))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black)

    // Opposite sides equal
    ctz-draw-mark-segment("A", "B", mark: 1)
    ctz-draw-mark-segment("C", "D", mark: 1)
    ctz-draw-mark-segment("B", "C", mark: 2)
    ctz-draw-mark-segment("D", "A", mark: 2)

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  },
  length: 0.8cm,
)

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0), A: (3, 0))
    ctz-def-regular-polygon("Hex", ("A", "B", "C", "D", "E", "F"), "O", "A")

    ctz-draw-regular-polygon(("A", "B", "C", "D", "E", "F"),
      stroke: black, mark: 1)

    // Mark all sides with the same tick
    // (use mark-opts to customize size/position)

    ctz-draw(points: ("A", "B", "C", "D", "E", "F"), labels: (
      A: "right",
      B: "above right",
      C: "above left",
      D: "left",
      E: "below",
      F: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0), A: (3, 0))
    ctz-def-regular-polygon("Hex", ("A", "B", "C", "D", "E", "F"), "O", "A")

    ctz-draw-regular-polygon(("A", "B", "C", "D", "E", "F"),
      stroke: black, mark: 1)

    // Mark all sides with the same tick
    // (use mark-opts to customize size/position)

    ctz-draw(points: ("A", "B", "C", "D", "E", "F"), labels: (
      A: "right",
      B: "above right",
      C: "above left",
      D: "left",
      E: "below",
      F: "below"
    ))
  },
  length: 0.7cm,
)

== Segment Measurements — `ctz-draw-measure-segment`

Draw an offset measurement line with dotted fences and a centered label.
The line breaks around the label and uses open arrowheads by default.

```typst
ctz-draw-measure-segment("A", "B", label: $5$, offset: 0.3, side: "left")
```

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 1.2))
    ctz-draw-segment("A", "B", stroke: black + 1pt)

    // Minimal measurement example
    ctz-draw-measure-segment("A", "B", label: $ell$, offset: 0.45, side: "left",
      fence-dash: "dotted")

    ctz-draw(points: ("A", "B"), labels: (
      A: "below",
      B: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 1.2))
    ctz-draw-segment("A", "B", stroke: black + 1pt)

    // Minimal measurement example
    ctz-draw-measure-segment("A", "B", label: $ell$, offset: 0.45, side: "left",
      fence-dash: "dotted")

    ctz-draw(points: ("A", "B"), labels: (
      A: "below",
      B: "below"
    ))
  },
  length: 0.8cm,
)

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (5, 3), D: (0, 3))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black + 1pt)

    // Rectangle measurements (width and height)
    ctz-draw-measure-segment("A", "B", label: $w$, offset: 0.45, side: "below")
    ctz-draw-measure-segment("C", "B", label: $h$, offset: -0.45, side: "right")

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (5, 3), D: (0, 3))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black + 1pt)

    // Rectangle measurements (width and height)
    ctz-draw-measure-segment("A", "B", label: $w$, offset: 0.45, side: "below")
    ctz-draw-measure-segment("C", "B", label: $h$, offset: -0.45, side: "right")

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  },
  length: 0.8cm,
)

== Paths — `ctz-draw-path`

Draw polylines with per-segment tips using a TikZ-like string:

```typst
ctz-draw-path("A--B->C|-|D", stroke: black)
```

Supported connectors: `--`, `->`, `<-`, `<->`, `|-|`, `|->`, `<-|`.

By default, `ctz-draw-path` draws points as crosses for normal segments and hides
points that touch a bar connector (`|-|`, `|->`, `<-|`). Labels default to `below`.
You can override per-point placements or point styles in the path with `{...}`, or via
`label-overrides`.

Default behavior, label are placed below

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    // Default labels below, default point styles
    ctz-draw-path("A--B->C|-|D", stroke: black)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    // Default labels below, default point styles
    ctz-draw-path("A--B->C|-|D", stroke: black)
  },
  length: 0.8cm,
)


#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below}--B{below}->C{above}|-|D{below}", stroke: black)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below}--B{below}->C{above}|-|D{below}", stroke: black)
  },
  length: 0.8cm,
)

Override placements using `label-overrides`:

```typst
ctz-draw-path("A--B->C|-|D",
  label-overrides: (A: "left", C: "above right"))
```

Customize point appearance or disable points/labels:

```typst
ctz-draw-path("A--B->C|-|D",
  point-style: "circle",
  point-color: red,
  label-pos: "above")
```

```typst
ctz-draw-path("A--B->C|-|D",
  points: false,
  labels: false)
```

Per-point overrides inside the path:

```typst
ctz-draw-path("A{below, style: circle}--B{below}->C{above, style: none}|-|D{below}",
  stroke: black)
```

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below, style: circle}--B{below}->C{above}|-|D{below}",
      stroke: black)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below, style: circle}--B{below}->C{above}|-|D{below}",
      stroke: black)
  },
  length: 0.8cm,
)


== Global Styling — `ctz-style`

Set default styles for points and labels:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.1, fill: red))

    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2.5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"))

    ctz-style(point: (shape: "cross", size: 0.15, stroke: blue + 1.5pt))
    ctz-def-centroid("G", "A", "B", "C")
    ctz-draw(points: ("G"))

    ctz-draw(points: ("G"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      G: "right"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.1, fill: red))
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2.5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"))
    ctz-style(point: (shape: "cross", size: 0.15, stroke: blue + 1.5pt))
    ctz-def-centroid("G", "A", "B", "C")
    ctz-draw(points: ("G"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      G: "right"
    ))
  },
)

Point shapes: `"dot"`, `"cross"`, `"circle"`, `"square"`

== Angle Marking — `ctz-draw-angle`

Mark and label angles:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    ctz-draw-angle("A", "B", "C",
      label: $alpha$,
      radius: 0.7,
      fill: blue.lighten(70%),
      stroke: blue)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-angle("A", "B", "C", label: $alpha$, radius: 0.7, fill: blue.lighten(70%), stroke: blue)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  },
)

== Right Angle Mark — `ctz-draw-mark-right-angle`

Mark a right angle with a small square:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (0, 3))
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("A", "C"), stroke: black)

    ctz-draw-mark-right-angle("B", "A", "C", size: 0.4)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "right",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (0, 3))
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("A", "C"), stroke: black)
    ctz-draw-mark-right-angle("B", "A", "C", size: 0.4)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "right",
      C: "above"
    ))
  },
)

#pagebreak()

== Summary: Draw and Define Correspondence

The table below shows which `ctz-draw()` type parameters have corresponding `ctz-def-*` functions. Use `ctz-def-*` when you need to reference the object later (for intersections, transformations, etc.).

=== Geometric Objects (Have Define Functions)

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  stroke: 0.5pt + luma(80%),
  inset: 6pt,
  [*Draw Shorthand*], [*Define Function*], [*Object Type*],
  [`points: (...)`], [`ctz-def-points(...)`], [Points],
  [`line: (...)`], [`ctz-def-line(name, a, b)`], [Line/Polyline],
  [`circle-r: (center, r)`], [`ctz-def-circle(name, center, radius: r)`], [Circle],
  [`circle-through: (center, pt)`], [`ctz-def-circle(name, center, through: pt)`], [Circle],
  [`circle-diameter: (a, b)`], [`ctz-def-circle-diameter(name, a, b)`], [Circle],
  [`circumcircle: (a, b, c)`], [`ctz-def-circumcircle(name, a, b, c)`], [Circle],
  [`incircle: (a, b, c)`], [`ctz-def-incircle(name, a, b, c)`], [Circle],
  [—], [`ctz-def-excircle(name, a, b, c, vertex: v)`], [Circle],
  [—], [`ctz-def-euler-circle(name, a, b, c)`], [Circle],
  [—], [`ctz-def-spieker-circle(name, a, b, c)`], [Circle],
  [—], [`ctz-def-apollonius-circle(name, a, b, k)`], [Circle],
  [`ellipse: (center, rx, ry, angle)`], [`ctz-def-ellipse(name, center, rx, ry, angle: 0deg)`], [Conic],
  [—], [`ctz-def-ellipse-foci(n1, n2, center, rx, ry, angle)`], [Points (foci)],
  [—], [`ctz-def-ellipse-tangent(name, center, rx, ry, t, ...)`], [Line (tangent)],
  [—], [`ctz-def-ellipse-tangents-from(n1, n2, center, rx, ry, pt, ...)`], [Lines (tangents)],
  [`parabola: (focus, directrix, extent)`], [`ctz-def-parabola(name, focus, directrix, ...)`], [Conic],
  [—], [`ctz-def-parabola-focus(name, focus, p, angle, ...)`], [Conic],
  [—], [`ctz-def-parabola-tangent(name, focus, directrix, t, ...)`], [Line (tangent)],
  [—], [`ctz-def-parabola-tangents-from(n1, n2, focus, dir, pt, ...)`], [Lines (tangents)],
  [`projectile: (...)`], [`ctz-def-projectile(name, origin, velocity, ...)`], [Conic],
)

=== Drawing Primitives (No Define Functions)

These are purely visual elements that don't need to be stored for later geometric operations:

#table(
  columns: (auto, auto),
  align: (left, left),
  stroke: 0.5pt + luma(80%),
  inset: 6pt,
  [*Draw Function/Parameter*], [*Purpose*],
  [`arc:`, `arc-r:`, `semicircle:`], [Partial circles (drawing only)],
  [`segment:`], [Line segment (use `ctz-def-line` if needed)],
  [`path:`], [CeTZ-style path syntax],
  [`labels:`], [Point labels],
  [`ctz-draw-angle`, `ctz-draw-fill-angle`], [Angle arcs and fills],
  [`ctz-draw-mark-segment`, `ctz-draw-mark-right-angle`], [Geometric marks],
  [`ctz-draw-grid`, `ctz-draw-axes`], [Coordinate system decoration],
)

