#import "/src/lib.typ": *

#set page(width: 16cm, height: 24cm, margin: 1cm)

= Test: New Polymorphic API Features

== Test 1: Polymorphic ctz-draw()

#ctz-canvas({
  ctz-init()

  ctz-def-points(O: (0, 0), A: (2, 0), B: (0, 2))
  ctz-def-circle("c1", "O", radius: 1.5)
  ctz-def-line("l1", "O", "A")
  ctz-def-polygon("tri", "O", "A", "B")

  // Draw using polymorphic function
  ctz-draw("c1", stroke: blue)
  ctz-draw("l1", stroke: red)
  ctz-draw("tri", stroke: green)
  ctz-draw("O", fill: black)
  ctz-draw("A", fill: black)
  ctz-draw("B", fill: black)

  ctz-draw-labels("O", "A", "B")
})

== Test 2: Polymorphic ctz-def-rotation()

#ctz-canvas({
  ctz-init()
  ctz-def-points(O: (0, 0), A: (2, 0))

  // Rotate circle
  ctz-def-circle("c1", (1, 0), radius: 0.5)
  ctz-def-rotation("c2", "c1", "O", 90)
  ctz-draw("c1", stroke: blue)
  ctz-draw("c2", stroke: red)

  // Rotate line
  ctz-def-line("l1", (0, 0), (2, 0))
  ctz-def-rotation("l2", "l1", (1, 0), 45)
  ctz-draw("l1", stroke: blue)
  ctz-draw("l2", stroke: red)

  ctz-draw("O")
  ctz-draw("A")
  ctz-draw-labels("O", "A")
})

== Test 3: ctz-duplicate()

#ctz-canvas({
  ctz-init()

  // Duplicate circle
  ctz-def-circle("c1", (0, 0), radius: 1)
  ctz-duplicate("c2", "c1")
  ctz-draw("c1", stroke: blue)

  // Duplicate polygon with explicit names
  ctz-def-regular-polygon("hex1", ("A","B","C","D","E","F"), (3,0), (4,0), n: 6)
  ctz-duplicate("hex2", "hex1", points: ("A2","B2","C2","D2","E2","F2"))
  ctz-draw("hex1", stroke: blue)
  ctz-draw("A")
  ctz-draw("B")
  ctz-draw("C")
  ctz-draw("D")
  ctz-draw("E")
  ctz-draw("F")
  ctz-draw-labels("A", "B", "C", "D", "E", "F")
})

== Test 4: ctz-def-thales-triangle()

#ctz-canvas({
  ctz-init()

  ctz-def-points(O: (0, 0))
  ctz-def-thales-triangle("A", "B", "C", "O", 2, base-angle: 30, orientation: "left")
  ctz-def-circle("circ", "O", radius: 2)

  ctz-draw("circ", stroke: gray + 0.5pt)
  ctz-draw-path("A--B--C--A", stroke: black + 1pt, points: false, labels: false)
  ctz-draw-mark-right-angle("A", "C", "B", color: red)
  ctz-draw("A")
  ctz-draw("B")
  ctz-draw("C")
  ctz-draw("O")
  ctz-draw-labels("A", "B", "C", "O")
})
