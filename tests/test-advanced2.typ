#import "/src/lib.typ": *

#set page(width: 20cm, height: 22cm, margin: 1cm)

= Parabola with Tangents from Circle Points

#ctz-canvas({
  ctz-init()

  // Create parabola: focus F at origin, directrix at x = -4 (for p=2)
  ctz-def-points(F: (0, 0), A: (-4, -10), B: (-4, 10))
  ctz-def-parabola("p", "F", ("A", "B"), extent: 6, steps: 120)

  // Draw the parabola
  ctz-draw("p", stroke: (paint: black, thickness: 1.2pt))
  ctz-draw(points: ("F",))
  ctz-draw-labels("F", F: "right")

  // Circle: center C = V + 2*(V-F), tangent to parabola
  // For parabola with focus at origin and p=2, vertex V is at (-2, 0)
  // So C = (-2, 0) + 2*((-2,0) - (0,0)) = (-2, 0) + 2*(-2, 0) = (-6, 0)
  ctz-def-points(C: (-6, 0))
  ctz-draw(circle-r: ("C", 0.8), stroke: (paint: black, thickness: 0.8pt))

  // Four points on circle using point-on-circle (no manual cos/sin!)
  ctz-def-point-on-circle("M0", "C", 0.8, 30)
  ctz-def-point-on-circle("M1", "C", 0.8, 120)
  ctz-def-point-on-circle("M2", "C", 0.8, 210)
  ctz-def-point-on-circle("M3", "C", 0.8, 300)

  ctz-draw(points: ("M0", "M1", "M2", "M3"))
  ctz-draw-labels("M0", "M1", "M2", "M3",
    M0: "right", M1: "above", M2: "left", M3: "below")

  // Draw tangent lines from each M point to the parabola
  ctz-draw-parabola-tangents-from-point("F", ("A", "B"), "M0",
    stroke: (paint: red, thickness: 0.8pt), length: 5)
  ctz-draw-parabola-tangents-from-point("F", ("A", "B"), "M1",
    stroke: (paint: red, thickness: 0.8pt), length: 5)
  ctz-draw-parabola-tangents-from-point("F", ("A", "B"), "M2",
    stroke: (paint: red, thickness: 0.8pt), length: 5)
  ctz-draw-parabola-tangents-from-point("F", ("A", "B"), "M3",
    stroke: (paint: red, thickness: 0.8pt), length: 5)
})
