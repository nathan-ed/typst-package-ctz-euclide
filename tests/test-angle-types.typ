// The four angle types on the same 26.57° angle AOB.
// p1 interior, p2 complementary, p3 supplementary, p4 reflex.
// Each arc is red, so its extent can be measured on the render.
#import "../src/lib.typ": *

#set page(width: 6cm, height: 5cm, margin: 0.4cm)

#let fig(kind) = ctz-canvas(length: 0.8cm, {
  import cetz.draw: *
  ctz-init()
  ctz-def-points(O: (0, 0), A: (3, 0), B: (2, 1))
  ctz-draw-line("A", "O", "B")
  ctz-draw-angle("O", "A", "B", angle-type: kind, radius: 1, stroke: red)
})

#fig("interior")
#pagebreak()
#fig("complementary")
#pagebreak()
#fig("supplementary")
#pagebreak()
#fig("reflex")
