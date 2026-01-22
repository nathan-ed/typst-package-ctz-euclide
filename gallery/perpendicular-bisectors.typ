#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.3cm)

#canvas({
  import cetz.draw: *

  init()
  style(point: (shape: "dot", size: 0.08, fill: black))

  // Define triangle
  pts("A", (0, 0), "B", (6, 0), "C", (2.5, 5))

  // Set clipping region
  set-clip(-1, -1, 7, 6)

  // Calculate midpoints
  midpoint("Mab", "A", "B")
  midpoint("Mbc", "B", "C")
  midpoint("Mca", "C", "A")

  // Calculate circumcenter (intersection of perpendicular bisectors)
  circumcenter("O", "A", "B", "C")

  // Create perpendicular bisector lines
  mediator("Pab1", "Pab2", "A", "B")
  mediator("Pbc1", "Pbc2", "B", "C")
  mediator("Pca1", "Pca2", "C", "A")

  // Draw triangle
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  // Draw perpendicular bisectors (clipped)
  seg("Pab1", "Pab2", stroke: blue + 0.8pt)
  seg("Pbc1", "Pbc2", stroke: red + 0.8pt)
  seg("Pca1", "Pca2", stroke: green + 0.8pt)

  // Draw circumcircle
  circumcircle("A", "B", "C", stroke: purple + 1.2pt)

  // Draw segments from circumcenter to vertices
  line("O", "A", stroke: gray + 0.4pt)
  line("O", "B", stroke: gray + 0.4pt)
  line("O", "C", stroke: gray + 0.4pt)

  // Mark right angles at midpoints
  mark-right-angle("A", "Mab", "O", size: 0.3)
  mark-right-angle("B", "Mbc", "O", size: 0.3)
  mark-right-angle("C", "Mca", "O", size: 0.3)

  // Mark points
  points("A", "B", "C", "O", "Mab", "Mbc", "Mca")

  // Labels
  labels("A", "B", "C", "O",
    A: "below left", B: "below right", C: "above", O: "below")
})
