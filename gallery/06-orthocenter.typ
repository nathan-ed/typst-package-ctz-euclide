#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#canvas(length: 0.85cm, {
  import cetz.draw: *

  init()
  style(point: (shape: "cross", size: 0.1, stroke: black + 1.2pt))

  pts(A: (0, 0), B: (8, 0), C: (2.5, 5.5))

  // Set clip region
  set-clip(-1.5, -1.5, 9.5, 7)

  // Triangle
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  // Extended altitudes (clipped)
  perp("Ha1", "Ha2", ("B", "C"), "A")
  perp("Hb1", "Hb2", ("A", "C"), "B")
  perp("Hc1", "Hc2", ("A", "B"), "C")

  tkz-line("A", "Ha1", add: (1, 1.5), stroke: blue + 1pt)
  tkz-line("B", "Hb1", add: (1, 1.5), stroke: red + 1pt)
  tkz-line("C", "Hc1", add: (1, 2.5), stroke: green.darken(20%) + 1pt)

  // Orthocenter
  orthocenter("H", "A", "B", "C")

  // Feet of altitudes
  project("Ha", "A", "B", "C")
  project("Hb", "B", "A", "C")
  project("Hc", "C", "A", "B")

  // Right angle marks
  mark-right-angle("A", "Ha", "B", size: 0.3)
  mark-right-angle("B", "Hb", "C", size: 0.3)
  mark-right-angle("C", "Hc", "A", size: 0.3)

  points("A", "B", "C", "H", "Ha", "Hb", "Hc")
  labels(
    "A",
    "B",
    "C",
    "H",
    A: "below left",
    B: "below right",
    C: "above",
    H: (pos: "below right", offset: (0.1, -0.05)),
  )
})
