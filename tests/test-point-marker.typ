// The default point marker is a small circle (issue #6): a cross gets messy
// where several lines run close to the point, and the circle is what
// tkz-euclide and textbooks draw. The other shapes stay reachable.
#import "../src/lib.typ": *
#import "../src/draw.typ" as pkg-draw
#import "../src/drawing.typ" as pkg-drawing

#set page(width: 11cm, height: auto, margin: 0.5cm)

#{
  // the default itself
  assert(
    pkg-draw.default-point-shape == "circle",
    message: "default point shape is " + repr(pkg-draw.default-point-shape),
  )
  // the global style picks it up
  assert(
    pkg-drawing.default-global-style.point.shape == "circle",
    message: "global style shape is " + repr(pkg-drawing.default-global-style.point.shape),
  )
}

== Default, then the shapes asked for explicitly

#let fig(body) = ctz-canvas(length: 0.7cm, {
  import cetz.draw: *
  ctz-init()
  body
  ctz-def-points(A: (0, 0), B: (2.4, 0), C: (0.8, 1.6))
  ctz-draw-line("A", "B", "C", "A")
  ctz-draw-points("A", "B", "C")
})

#grid(
  columns: 4,
  column-gutter: 1em,
  align: bottom,
  [default], [cross], [dot], [square],
  fig({}),
  fig(ctz-style(point: (shape: "cross"))),
  fig(ctz-style(point: (shape: "dot"))),
  fig(ctz-style(point: (shape: "square"))),
)
