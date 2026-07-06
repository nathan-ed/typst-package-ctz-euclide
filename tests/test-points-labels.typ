#import "../src/lib.typ": *

#set page(width: 16cm, height: 20cm, margin: 1cm)

= Test: Points and Labels with ctz-draw()

== Test 1: Draw multiple points

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (2, 0), C: (2, 2), D: (0, 2))

  ctz-draw(points: ("A", "B", "C", "D"))
})

== Test 2: Draw points with default labels

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (2, 0), C: (2, 2), D: (0, 2))

  ctz-draw(points: ("A", "B", "C", "D"), labels: true)
})

== Test 3: Draw points with custom label positions

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0), C: (3, 2), D: (0, 2))

  ctz-draw(points: ("A", "B", "C", "D"), labels: (
    A: "below left",
    B: "below right",
    C: "above right",
    D: "above left"
  ))
})

== Test 4: Combined usage with other constructs

#ctz-canvas({
  ctz-init()
  ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))

  ctz-draw(path: "A--B--C--A", stroke: black)
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
  ctz-draw(points: ("A", "B", "C"), labels: true)
})
