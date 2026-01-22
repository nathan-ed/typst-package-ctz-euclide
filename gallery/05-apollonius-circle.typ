#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 0.95cm, {
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.08, fill: black))

  ctz-def-points(A: (-3, 0), B: (3, 0))

  // For k = 2, construct Apollonius circle
  // Locus of points P such that PA/PB = 2

  // External division point
  let k = 2
  ctz-def-points(E: (-5, 0))

  // Internal division point
  ctz-def-points(I: (-1, 0))

  // Center is midpoint of E and I
  ctz-def-midpoint("O", "E", "I")

  // Circle through E and I
  ctz-draw-circle-through("O", "E", stroke: purple.darken(10%) + 1.3pt)

  // Show some points on the circle
  ctz-def-rotation("P1", "E", "O", 60)
  ctz-def-rotation("P2", "E", "O", 120)
  ctz-def-rotation("P3", "E", "O", -60)
  ctz-def-rotation("P4", "E", "O", -120)

  // Draw radii from P1 to A and B
  ctz-draw-line("P1", "A", stroke: blue + 0.8pt)
  ctz-draw-line("P1", "B", stroke: red + 0.8pt)

  // Base points
  ctz-draw-line("A", "B", stroke: black + 1pt)

  ctz-draw-points("A", "B", "O", "E", "I", "P1", "P2", "P3", "P4")
  ctz-draw-labels(
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
  ctz-draw-labels("O", O: (pos: "below", offset: (0, -0.15)))
})
