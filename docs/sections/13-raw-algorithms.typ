// Raw Algorithms
#import "../helpers.typ": *

= Raw Algorithms

For direct computation without the point registry, use the `raw` dictionary:

```typst
// Direct centroid calculation
let center = raw.ctz-def-centroid((0,0,0), (3,0,0), (1.5,2.5,0))

// Distance between points
let d = raw.dist((0,0,0), (3,4,0))  // Returns 5

// Line-line intersection
let pt = raw.line-line((0,0,0), (1,1,0), (0,1,0), (1,0,0), ray: true)
```

Available raw functions:
- *Intersections*: `line-line`, `line-circle`, `circle-circle`
- *Triangle centers*: `ctz-def-centroid`, `ctz-def-circumcenter`, `ctz-def-incenter`, `ctz-def-orthocenter`, `euler-center`, `ctz-def-lemoine`, etc.
- *Transformations*: `ctz-def-rotation`, `reflection`, `translation`, `ctz-def-homothety`, `projection`, `ctz-def-inversion`
- *Utilities*: `ctz-def-midpoint`, `dist`, `angle-at-vertex`, `triangle-area`, etc.

#pagebreak()



== Measurements — `ctz-calc-*`

These return values through the canvas context (use them inside a canvas via
`ctz-algorithms` for direct numeric work instead):

- `ctz-calc-length(a, b)` — distance between two named points
- `ctz-calc-angle(a, b, c)` — angle at vertex `b`, in degrees
- `ctz-calc-area(a, b, c)` — triangle area
- `ctz-calc-slope(a, b)` — slope angle of the line ab, in degrees
- `ctz-calc-ratio(a, b, c)` — ratio AB/AC

For direct computation on raw coordinates, prefer the `ctz-algorithms`
dictionary (call entries with the parenthesized form):

```typst
#let d = (ctz-algorithms.dist)((0, 0, 0), (3, 4, 0))   // 5
#let s = (ctz-algorithms.slope-angle)((0, 0), (1, 1))  // 45
#let I = (ctz-algorithms.incenter)(A, B, C)
```

== Axes and Guide Lines

- `ctz-draw-axes(xmin: .., xmax: .., ymin: .., ymax: .., ..)` — both axes with
  ticks, numeric labels and arrowheads
- `ctz-draw-axis-x(..)` / `ctz-draw-axis-y(..)` — one axis only
- `ctz-draw-hline(y, xmin: .., xmax: .., ..)` — horizontal guide line
- `ctz-draw-vline(x, ymin: .., ymax: .., ..)` — vertical guide line
- `ctz-draw-text(x, y, content, angle: 0deg, anchor: "center")` — free text
