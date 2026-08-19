// Issue #5: giving a position already names the point, so the point list must
// be optional. Page 1 uses positions only, page 2 the explicit list; the two
// must render identically.
#import "../src/lib.typ": *

#set page(width: 9cm, height: 5cm, margin: 0.5cm)

#let fig(labels-call) = ctz-canvas(length: 0.7cm, {
  import cetz.draw: *
  ctz-init()
  ctz-def-points(A: (0, 0), B: (4, 0), C: (2, 3))
  ctz-draw-line("A", "B", "C", "A")
  ctz-draw-points("A", "B", "C")
  labels-call
})

#fig(ctz-draw-labels(A: "below left", B: "below right", C: "above"))
#pagebreak()
#fig(ctz-draw-labels("A", "B", "C", A: "below left", B: "below right", C: "above"))
