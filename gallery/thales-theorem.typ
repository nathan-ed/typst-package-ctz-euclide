#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#canvas({
  import cetz.draw: *

  init()
  style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

  // Circle with diameter
  pts("O", (0, 0), "A", (-3, 0), "B", (3, 0))

  // Point on circle
  point-on-circle("C", "O", 3, 110)

  // Draw circle
  circle("O", radius: 3, stroke: gray + 0.8pt)

  // Draw diameter
  line("A", "B", stroke: blue + 1.2pt)

  // Draw triangle (angle at C is right angle by Thales' theorem)
  line("A", "C", "B", "A", stroke: black + 1.2pt)

  // Mark the right angle at C
  mark-right-angle("A", "C", "B", size: 0.4)

  // Draw altitude from C to AB
  project("H", "C", "A", "B")
  line("C", "H", stroke: (paint: green, thickness: 0.8pt, dash: "dashed"))

  // Mark points
  points("A", "B", "C", "O", "H")

  // Labels
  labels("A", "B", "C", "O", "H",
    A: "left", B: "right", C: "above", O: "below", H: "below")
})
