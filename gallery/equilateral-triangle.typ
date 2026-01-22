#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#canvas({
  import cetz.draw: *

  init()
  style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

  // Base of equilateral triangle
  pts("A", (0, 0), "B", (5, 0))

  // Construct equilateral triangle
  equilateral("C", "A", "B")

  // Draw triangle
  line("A", "B", "C", "A", stroke: blue + 1.5pt)

  // Mark 60 angles
  angle("A", "B", "C", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  angle("B", "C", "A", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  angle("C", "A", "B", label: $60°$, radius: 0.8, stroke: orange + 0.8pt)

  // Draw circles at vertices
  circle("A", radius: 0.3, stroke: green + 1pt)
  circle("B", radius: 0.3, stroke: green + 1pt)
  circle("C", radius: 0.3, stroke: orange + 1pt)

  // Find center (all centers coincide in equilateral triangle)
  centroid("G", "A", "B", "C")

  // Draw altitudes/medians
  midpoint("Ma", "B", "C")
  midpoint("Mb", "A", "C")
  midpoint("Mc", "A", "B")

  line("A", "Ma", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  line("B", "Mb", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  line("C", "Mc", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))

  // Mark center
  style(point: (shape: "dot", size: 0.1, fill: red))
  points("G")

  // Mark vertices
  style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))
  points("A", "B", "C")

  // Labels
  labels("A", "B", "C", "G",
    A: "below left", B: "below right", C: "above", G: "right")
})
