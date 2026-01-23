#import "@preview/ctz-euclide:0.1.0": *

#set page(width: 18cm, height: 26cm, margin: 1cm)

= Test: Fully Polymorphic ctz-draw()

== Test 1: Named Objects (Existing)

#ctz-canvas({
  ctz-init()

  ctz-def-points(O: (0, 0), A: (2, 0))
  ctz-def-circle("C1", "O", radius: 1.5)
  ctz-def-line("L1", "O", "A")
  ctz-def-polygon("tri", "O", "A", (1, 1.5))

  ctz-draw("C1", stroke: blue)
  ctz-draw("L1", stroke: red)
  ctz-draw("tri", stroke: green)
  ctz-draw("O")
  ctz-draw("A")
  ctz-draw-labels("O", "A")
})

== Test 2: Path (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (2, 0), C: (1, 1.5))

  ctz-draw(path: "A--B--C--A", stroke: black + 1pt)
  ctz-draw-points("A", "B", "C")
  ctz-draw-labels("A", "B", "C")
})

== Test 3: Polyline (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (2, 0), C: (2, 1.5), D: (0, 1.5))

  ctz-draw(line: ("A", "B", "C", "D", "A"), stroke: blue + 1pt)
  ctz-draw-points("A", "B", "C", "D")
  ctz-draw-labels("A", "B", "C", "D")
})

== Test 4: Circle Through Points (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(O: (0, 0), A: (2, 0))

  ctz-draw(circle-through: ("O", "A"), stroke: purple)
  ctz-draw-points("O", "A")
  ctz-draw-labels("O", "A")
})

== Test 5: Circle by Radius (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(O: (0, 0))

  ctz-draw(circle-r: ((0, 0), 1.5), stroke: green)
  ctz-draw("O")
  ctz-draw-labels("O")
})

== Test 6: Circumcircle (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))

  ctz-draw(path: "A--B--C--A", stroke: black)
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
  ctz-draw-points("A", "B", "C")
  ctz-draw-labels("A", "B", "C")
})

== Test 7: Incircle (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))

  ctz-draw(path: "A--B--C--A", stroke: black)
  ctz-draw(incircle: ("A", "B", "C"), stroke: red)
  ctz-draw-points("A", "B", "C")
  ctz-draw-labels("A", "B", "C")
})

== Test 8: Arc Through Points (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(O: (0, 0), A: (2, 0), B: (0, 2))

  ctz-draw(arc: (center: "O", start: "A", end: "B"), stroke: orange + 1pt)
  ctz-draw-points("O", "A", "B")
  ctz-draw-labels("O", "A", "B")
})

== Test 9: Semicircle (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0))

  ctz-draw(semicircle: ("A", "B"), stroke: teal, fill: teal.lighten(80%))
  ctz-draw-points("A", "B")
  ctz-draw-labels("A", "B")
})

== Test 10: Segment (New)

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 2))

  ctz-draw(segment: ("A", "B"), stroke: maroon + 1.5pt)
  ctz-draw-points("A", "B")
  ctz-draw-labels("A", "B")
})

== Test 11: Multiple Points (New) - Simplified

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (1, 0), C: (2, 0))

  // Use existing points function for now
  ctz-draw-points("A", "B", "C")
  ctz-draw-labels("A", "B", "C")
})

== Test 12: Mixed Usage

#ctz-canvas({
  ctz-init()

  ctz-def-points(O: (0, 0), A: (2, 0), B: (1, 1.5), C: (-1, 1))
  ctz-def-circle("myCircle", "O", radius: 2.5)

  // Named object
  ctz-draw("myCircle", stroke: gray + 0.5pt)

  // Unnamed constructs
  ctz-draw(path: "A--B--C--A", stroke: blue + 1pt)
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: red)
  ctz-draw(incircle: ("A", "B", "C"), stroke: green)

  ctz-draw-points("O", "A", "B", "C")
  ctz-draw-labels("O", "A", "B", "C")
})
