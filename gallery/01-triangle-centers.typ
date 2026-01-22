#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#canvas(length: 0.95cm, {
  import cetz.draw: *

  init()
  style(point: (shape: "dot", size: 0.07, fill: black))

  pts(A: (0, 0), B: (7, 0.5), C: (2.5, 5))
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  centroid("G", "A", "B", "C")
  circumcenter("O", "A", "B", "C")
  incenter("I", "A", "B", "C")
  orthocenter("H", "A", "B", "C")

  // Euler line
  line("H", "O", stroke: (
    paint: red.darken(20%),
    dash: "dashed",
    thickness: 1.2pt,
  ))

  // Circumcircle
  circle("O", "A", stroke: blue + 1pt)

  // Incircle
  incircle("A", "B", "C", stroke: green.darken(20%) + 1pt)

  // Medians
  midpoint("Ma", "B", "C")
  midpoint("Mb", "A", "C")
  midpoint("Mc", "A", "B")
  line("A", "Ma", stroke: gray + 0.7pt)
  line("B", "Mb", stroke: gray + 0.7pt)
  line("C", "Mc", stroke: gray + 0.7pt)

  points("A", "B", "C", "G", "O", "I", "H")
  labels(
    "A",
    "B",
    "C",
    "G",
    "O",
    "I",
    "H",
    A: "below left",
    B: "below right",
    C: "above",
    G: (pos: "right", offset: (0.15, 0)),
    O: (pos: "right", offset: (0.15, 0)),
    I: (pos: "above left", offset: (-0.1, 0.1)),
    H: (pos: "left", offset: (-0.15, 0)),
  )
})
