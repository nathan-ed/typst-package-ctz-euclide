#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#canvas(length: 0.9cm, {
  import cetz.draw: *

  init()
  style(point: (
    shape: "circle",
    size: 0.06,
    stroke: black + 0.8pt,
    fill: white,
  ))

  pts(A: (0, 0), B: (7, 0), C: (2, 5))
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  // Midpoints of sides
  midpoint("Ma", "B", "C")
  midpoint("Mb", "A", "C")
  midpoint("Mc", "A", "B")

  // Feet of altitudes
  project("Ha", "A", "B", "C")
  project("Hb", "B", "A", "C")
  project("Hc", "C", "A", "B")

  // Orthocenter and midpoints to vertices
  orthocenter("H", "A", "B", "C")
  midpoint("MHa", "H", "A")
  midpoint("MHb", "H", "B")
  midpoint("MHc", "H", "C")

  // Nine-point circle
  euler("N", "A", "B", "C")
  circle("N", "Ma", stroke: purple.darken(10%) + 1.2pt)

  // Draw altitudes
  line("A", "Ha", stroke: blue.lighten(30%) + 0.7pt)
  line("B", "Hb", stroke: blue.lighten(30%) + 0.7pt)
  line("C", "Hc", stroke: blue.lighten(30%) + 0.7pt)

  points(
    "A",
    "B",
    "C",
    "N",
    "Ma",
    "Mb",
    "Mc",
    "Ha",
    "Hb",
    "Hc",
    "MHa",
    "MHb",
    "MHc",
    "H",
  )
  labels(
    "A",
    "B",
    "C",
    "N",
    A: "below left",
    B: "below right",
    C: "above",
    N: (pos: "below", offset: (0, -0.15)),
  )
})
