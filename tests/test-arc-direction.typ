// An arc named by two points is the direct one, counter-clockwise from start
// to end, the same arc the angle form of the call draws.
//
// Reported on issue #4 after the first fix: with C at 150 deg and D at 250
// deg, calc.atan2 answers -110 for D, so cetz swept the long way round
// clockwise and the arc landed on top of an unrelated one.
//
// p1: by angles, the reference. p2: the same two arcs named by points; the two
// pages must match.
#import "../src/lib.typ": *

#set page(width: 6cm, height: 6cm, margin: 0.4cm)

#ctz-canvas(length: 1cm, {
  import cetz.draw: *
  ctz-init()
  ctz-def-points(O: (0, 0))
  ctz-draw-circle-r("O", 2)
  ctz-draw-arc-r((0, 0), 2, 0deg, 100deg, stroke: green)
  ctz-draw-arc-r((0, 0), 2, 150deg, 250deg, stroke: red)
})
#pagebreak()
#ctz-canvas(length: 1cm, {
  import cetz.draw: *
  ctz-init()
  ctz-def-points(O: (0, 0), R: (2, 0))
  ctz-def-rotation("A", "R", "O", 0)
  ctz-def-rotation("B", "R", "O", 100)
  ctz-def-rotation("C", "R", "O", 150)
  ctz-def-rotation("D", "R", "O", 250)
  ctz-draw-circle-through("O", "R")
  ctz-draw-arc("O", "A", "B", stroke: green)
  ctz-draw-arc("O", "C", "D", stroke: red)
})
