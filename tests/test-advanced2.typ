#import "/src/lib.typ": *
#import "/src/conic.typ" as conic

#set page(width: 20cm, height: 20cm, margin: 1cm)

= Parabola with Tangents from Circle Points

#ctz-canvas({
  ctz-init()

  let F = (0, 0)
  let p = 2.0
  let theta = 0deg

  // Parabola from focus, p, angle
  ctz-draw-parabola-focus(F, p, angle: theta, extent: 6, stroke: (paint: black, thickness: 1.2pt))

  ctz-draw(points: (F,))
  ctz-draw-text(F.at(0) + 0.3, F.at(1) + 0.3, [$F$])

  let (D1, D2, V) = conic.parabola-directrix-raw(F, p, angle: theta)

  // Circle centered at C = V + 2*(V-F)
  let C = (V.at(0) + 2 * (V.at(0) - F.at(0)), V.at(1) + 2 * (V.at(1) - F.at(1)))
  let r = 0.8
  ctz-draw(circle-r: (C, r), stroke: (paint: black, thickness: 0.8pt))

  for i in (0, 90, 180, 270) {
    let ang = (i + 30) * 1deg
    let M = (C.at(0) + r * calc.cos(ang), C.at(1) + r * calc.sin(ang))
    ctz-draw(points: (M,))
    let label = [$M_#(i/90)$]
    let ux = M.at(0) - C.at(0)
    let uy = M.at(1) - C.at(1)
    let len = calc.sqrt(ux*ux + uy*uy)
    let ux2 = if len > 0 { ux/len } else { 0 }
    let uy2 = if len > 0 { uy/len } else { 0 }
    ctz-draw-text(M.at(0) + 0.2 * ux2, M.at(1) + 0.2 * uy2, label)

    let tangents = conic.parabola-tangents-from-point-raw(F, D1, D2, M, length: 5)
    for t in tangents {
      let (p1, p2, tp) = t
      ctz-draw(line: (p1, p2), stroke: (paint: red, thickness: 0.8pt))
      ctz-draw(points: (tp,), style: (shape: "dot", size: 3pt, fill: blue))
    }
  }
})
