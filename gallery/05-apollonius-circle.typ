#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#canvas(length: 0.95cm, {
  import cetz.draw: *

  init()
  style(point: (shape: "dot", size: 0.08, fill: black))

  pts(A: (-3, 0), B: (3, 0))

  // For k = 2, construct Apollonius circle
  // Locus of points P such that PA/PB = 2

  // External division point
  let k = 2
  pts(E: (-5, 0))

  // Internal division point
  pts(I: (-1, 0))

  // Center is midpoint of E and I
  midpoint("O", "E", "I")

  // Circle through E and I
  circle("O", "E", stroke: purple.darken(10%) + 1.3pt)

  // Show some points on the circle
  rotation("P1", "E", "O", 60)
  rotation("P2", "E", "O", 120)
  rotation("P3", "E", "O", -60)
  rotation("P4", "E", "O", -120)

  // Draw radii from P1 to A and B
  line("P1", "A", stroke: blue + 0.8pt)
  line("P1", "B", stroke: red + 0.8pt)

  // Base points
  line("A", "B", stroke: black + 1pt)

  points("A", "B", "O", "E", "I", "P1", "P2", "P3", "P4")
  labels(
    "A",
    "B",
    "E",
    "I",
    "P1",
    A: "below",
    B: "below",
    E: "below left",
    I: "below",
    P1: (pos: "above", offset: (0, 0.15)),
  )
  labels("O", O: (pos: "below", offset: (0, -0.15)))
})
