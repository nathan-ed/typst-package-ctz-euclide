#import "../src/lib.typ": *
#import "/src/conic.typ" as conic

#set page(width: 18cm, height: 14cm, margin: 1cm)

= Advanced Example 4

#ctz-canvas(length: 1cm, clip-canvas: (-4, -4, 12, 12), {
  ctz-init()

  let F = (0, 0)
  let p = 0.35
  let theta = 25deg

  ctz-draw-parabola-focus(F, p, angle: theta, extent: 4, stroke: (paint: black, thickness: 1pt))

  let (D1, D2, V) = conic.parabola-directrix-raw(F, p, angle: theta)

  // Circle positioned to be tangent to the parabola (touching at one point only)
  // With wider parabola (larger p), adjust position for tangency
  // TODO: No automatic tangency function available - adjusting manually
  let C = (V.at(0) + 10 * (V.at(0) - F.at(0)), V.at(1) + 10 * (V.at(1) - F.at(1)))
  let r = 1.4
  ctz-draw(circle-r: (C, r), stroke: (paint: black, thickness: 0.6pt))

  // Spread M points to avoid congestion - cluster on left side
  let M1 = (C.at(0) + r * calc.cos(150deg), C.at(1) + r * calc.sin(150deg))
  let M2 = (C.at(0) + r * calc.cos(210deg), C.at(1) + r * calc.sin(210deg))
  let M3 = (C.at(0) + r * calc.cos(250deg), C.at(1) + r * calc.sin(250deg))

  // Tangents and intersection points
  for M in (M1, M2, M3) {
    let tangents = conic.parabola-tangents-from-point-raw(F, D1, D2, M, length: 1.5)
    for t in tangents {
      let (p1, p2, tp) = t
      ctz-draw(line: (p1, p2), stroke: (paint: red, thickness: 0.8pt))
      ctz-draw(points: (tp,), style: (shape: "dot", size: 1pt, fill: blue))
    }
  }

  // Register points for labels with explicit positioning
  ctz-def-points(C: C, M1: M1, M2: M2, M3: M3)
  ctz-draw(points: ("C", "M1", "M2", "M3"), labels: (
    C: (pos: "below", offset: (0, 0)),
    M1: (pos: "above left", offset: (-0.2, 0.15)),
    M2: (pos: "above left", offset: (-0.5, 0)),
    M3: (pos: "below right", offset: (0.2, -0.15)),
  ))
})
