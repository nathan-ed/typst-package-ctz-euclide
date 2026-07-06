// Function Reference
#import "../helpers.typ": *

= Function Reference

== Point Definition
- `ctz-def-points(A: (x, y), ...)` — Define named points
- `ctz-def-line(name, a, b)` — Named line from two points
- `ctz-def-circle(name, center, radius|through)` — Named circle
- `ctz-def-polygon(name, a, b, c, ...)` — Named polygon
- `ctz-def-midpoint(name, a, b)` — Midpoint of segment
- `ctz-def-linear(name, a, b, k)` — Point at ratio k along line
- `ctz-def-regular-polygon([name,] names, center, first)` — Regular n-gon vertices (optionally register polygon name)
- `ctz-def-point-on-circle(name, center, radius, angle)` — Point on circle at angle
- `ctz-def-equilateral(name, a, b)` — Third vertex of equilateral triangle
- `ctz-def-golden(name, a, b, inside: true)` — Golden ratio point (`inside: false` for the external section)
- `ctz-def-square(nc, nd, a, b)` — Third and fourth vertices of square ABCD
- `ctz-def-barycentric(name, a, b, c, wa, wb, wc)` — Barycentric combination point
- `ctz-def-symmetry(name, source, center)` — Central symmetry image
- `ctz-def-tangent-from(n1, n2, point, center, radius)` — Tangent points from external point to circle
- `ctz-def-radical-axis(n1, n2, circle1, circle2)` — Two points on the radical axis of two circles
- `ctz-pt(name)` / `ctz-pts(..)` — Aliases: point-name coordinate helper / `ctz-def-points`

== Line Constructions
- `ctz-def-perp(n1, n2, line, through)` — Perpendicular through point
- `ctz-def-para(n1, n2, line, through)` — Parallel through point
- `ctz-def-bisect(n1, n2, a, vertex, c)` — Angle bisector
- `ctz-def-mediator(n1, n2, a, b)` — Perpendicular bisector

== Intersections
- `ctz-def-ll(name, line1, line2)` — Line-line intersection
- `ctz-def-lc(names, line, circle)` — Line-circle intersections
- `ctz-def-cc(names, circle1, circle2)` — Circle-circle intersections

== Triangle Centers
- `ctz-def-centroid`, `ctz-def-circumcenter`, `ctz-def-incenter`, `ctz-def-orthocenter`
- `ctz-def-euler`, `ctz-def-lemoine`, `ctz-def-nagel`, `ctz-def-gergonne`, `ctz-def-spieker`
- `ctz-def-feuerbach`, `ctz-def-mittenpunkt`, `ctz-def-excenter`

== Special Triangles
- `ctz-def-medial-triangle(na, nb, nc, a, b, c)` — Medial triangle
- `ctz-def-orthic-triangle(na, nb, nc, a, b, c)` — Orthic triangle
- `ctz-def-intouch-triangle(na, nb, nc, a, b, c)` — Intouch triangle
- `ctz-def-thales-triangle(na, nb, nc, center, radius, ...)` — Right triangle via Thales' theorem

== Transformations
- `ctz-def-rotation(name, source, center, angle)` — Rotation (works on all object types)
- `ctz-def-reflect(name, source, line-a, line-b)` — Reflection
- `ctz-def-translate(name, source, vector)` — Translation
- `ctz-def-homothety(name, source, center, factor)` — Homothety
- `ctz-def-project(name, source, line-a, line-b)` — Projection
- `ctz-def-inversion(name, source, center, radius)` — Inversion (works on points, lines, circles, polygons)
- `ctz-duplicate(target, source, points: auto)` — Duplicate any geometric object

== Drawing
- `ctz-draw(name, ...)` or `ctz-draw(points: ..., labels: ...)` — Draw any object type (polymorphic) or draw/label points using unified API
- `ctz-draw-points(names...)` — Draw points (legacy, prefer unified `ctz-draw()`)
- `ctz-draw-labels(names, placements)` — Label points (legacy, prefer unified `ctz-draw()`)
- `ctz-style(point: (...))` — Set styling
- `ctz-draw-angle(vertex, a, b, ...)` — Mark angle
- `ctz-draw-mark-right-angle(a, vertex, c, ...)` — Right angle mark
- `ctz-draw-segment(a, b, ...)` — Draw segment
- `ctz-draw-measure-segment(a, b, ...)` — Offset measurement with fences and label
- `ctz-draw-path(spec, ...)` — Draw path with per-segment tips
- `ctz-draw-polygon(points...)` — Draw polygon (triangle, quadrilateral, etc.)
- `ctz-draw-fill-polygon(points...)` — Fill polygon
- `ctz-draw-regular-polygon(names, ...)` — Draw regular polygon by vertex names
- `ctz-draw-fill-regular-polygon(names, ...)` — Fill regular polygon by vertex names
- `ctz-draw-circle(name, ...)` — Draw named circle
- `ctz-label-circle(name, label, ...)` — Label named circle
- `ctz-label-polygon(name, label, ...)` — Label named polygon
- `ctz-draw-circumcircle(a, b, c, ...)` — Circumscribed circle
- `ctz-draw-incircle(a, b, c, ...)` — Inscribed circle
- `ctz-draw-circle-r(center, radius, ...)` — Circle by center and radius
- `ctz-draw-circle-through(center, through, ...)` — Circle by center and a point on it
- `ctz-draw-circle-diameter(a, b, ...)` — Circle by diameter endpoints
- `ctz-draw-semicircle(a, b, above: true, ...)` — Semicircle on diameter AB
- `ctz-draw-arc(center, start, end, ...)` — Arc around a center between two points
- `ctz-draw-arc-r(center, radius, start-angle, end-angle, ...)` — Arc by radius and angles
- `ctz-draw-sector(center, start, end, fill: ..., ...)` — Circular sector
- `ctz-draw-ellipse(center, rx, ry, angle: ..., ...)` — Ellipse
- `ctz-draw-projectile(origin, velocity, ...)` — Projectile trajectory
- `ctz-draw-ellipse-tangent(center, rx, ry, t, ...)` — Tangent to ellipse at parameter t
- `ctz-draw-parabola-tangent(focus, directrix, t, ...)` — Tangent to parabola at parameter t
- `ctz-draw-parabola-tangents-from-point(focus, directrix, p, ...)` — Parabola tangents from a point
- `ctz-draw-label-segment(a, b, label: ..., ...)` — Text label on a segment
- `ctz-draw-label-angle(vertex, a, c, label: ..., ...)` — Text label inside an angle
- `ctz-draw-text(x, y, content, ...)` — Free text at coordinates
- `ctz-draw-hline(y, ...)` / `ctz-draw-vline(x, ...)` — Horizontal/vertical guide line
- `ctz-draw-axis-x(...)` / `ctz-draw-axis-y(...)` — Single axis with ticks and labels
- `ctz-points(..)` — Alias of `ctz-draw-points`
- `ctz-label-avoid(setting)` — Enable/disable/configure automatic label placement
- `ctz-main-levee(enabled: true, roughness: ..., seed: ...)` — Toggle hand-drawn mode globally

== Clipping
- `ctz-canvas(clip-canvas: ...)` — Set clip bounds for the canvas
- `ctz-set-clip(xmin, ymin, xmax, ymax)` / `ctz-clear-clip()` — Set/clear the global clip region
- `ctz-show-clip(...)` — Draw the clip boundary
- `ctz-draw-line-add(a, b, ...)` — Extended line (respects clip bounds)
- `ctz-draw-segment(a, b, ...)` — Segment (respects clip bounds)
- `ctz-draw-line-global-clip(a, b, ...)` / `ctz-draw-seg-global-clip(a, b, ...)` — Explicitly clipped line/segment
- `ctz-draw-clipped-line(p1, p2, bounds...)` / `ctz-draw-clipped-line-add(a, b, bounds..., add: ...)` — Clip to manual bounds
- `ctz-draw-clip-boundary(bounds..., ...)` — Draw a manual clip rectangle
- `ctz-clip-line-to-rect(x0, y0, x1, y1, bounds...)` — Raw Cohen–Sutherland clipping (returns endpoints or `none`)

== Calculations & Raw Utilities
- `ctz-calc-length(a, b)` / `ctz-calc-angle(a, b, c)` / `ctz-calc-area(a, b, c)` /
  `ctz-calc-slope(a, b)` / `ctz-calc-ratio(a, b, c)` — Measurements returned via the canvas context
- `ctz-algorithms` — Dictionary of all raw (context-free) algorithms; call as `(ctz-algorithms.dist)(p, q)`
- `ctz-dist(a, b)` — Distance between raw coordinates
- `ctz-angle-to(a, b)` — Direction angle from a to b
- `ctz-midpoint-raw(a, b)` — Midpoint of raw coordinates
- `ctz-project-point-on-line(p, a, b)` — Foot of the perpendicular from p onto line ab
- `ctz-rotate-point(p, center, angle)` — Rotate a raw coordinate
- `ctz-version` — Package version as an (major, minor, patch) array

== Style Constants
Read-only defaults, overridable per canvas via `ctz-style(..)`:
`ctz-default-point-shape`, `ctz-default-point-size`, `ctz-default-point-size-pt`,
`ctz-default-point-size-small-pt`, `ctz-default-point-color`,
`ctz-default-point-stroke-width`, `ctz-default-line-color`,
`ctz-default-mark-color`, `ctz-default-mark-stroke-width`,
`ctz-default-main-levee`, `ctz-default-main-levee-roughness`,
`ctz-default-main-levee-seed`, `ctz-default-clip-canvas`.

== Advanced Ellipse Constructions
- `ctz-def-ellipse-project(name, center, rx, ry, point, ...)` — Project a point onto an ellipse
- `ctz-ellipse-tangency-geom(a, b)` / `ctz-draw-ellipse-tangency(a, b)` — Full ellipse/circles tangency construction
- `ctz-ellipse-tangent-from-point-towards(...)` / `ctz-draw-ellipse-tangent-from-point-towards(...)` — Directed tangent selection

== Grid Positioning
- `triangular-pos(row, col, ...)` — Position in triangular grid (Pascal layout)
- `grid-pos(row, col, ...)` — Position in rectangular grid
- `hex-pos(row, col, ...)` — Position in hexagonal grid
- `binomial(n, k)` — Binomial coefficient C(n,k)

== Grid Drawing
- `draw-triangular-grid(cetz-draw, rows, content-fn, ...)` — Draw triangular grid with custom content
- `draw-rectangular-grid(cetz-draw, rows, cols, content-fn, ...)` — Draw rectangular grid
- `draw-pascal-values(cetz-draw, rows, ...)` — Draw Pascal's triangle values
- `draw-row-labels(cetz-draw, rows, ...)` — Draw row labels
- `draw-diagonal-labels(cetz-draw, count, ...)` — Draw diagonal labels

== Annotations
- `highlight-fill(cetz-draw, pos, ...)` — Filled circle highlight
- `highlight-outline(cetz-draw, pos, ...)` — Outlined circle highlight
- `highlight-many(cetz-draw, positions, ...)` — Highlight multiple positions
- `curved-arrow(cetz-draw, from, to, ...)` — Curved annotation arrow
- `smooth-arrow(cetz-draw, from, to, waypoints, ...)` — Smooth spline arrow
- `draw-addition-indicator(cetz-draw, a, b, result, ...)` — Show addition relationship
- `draw-brace-h(cetz-draw, start, end, ...)` — Horizontal brace
- `draw-brace-v(cetz-draw, start, end, ...)` — Vertical brace

#pagebreak()
