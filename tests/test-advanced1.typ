#import "../src/lib.typ": *

#set page(width: 16cm, height: 18cm, margin: 1cm)

= Advanced Example 3

#ctz-canvas({
  ctz-init()

  let a = 3
  let b = 2
  let O = (0, 0)

  let blue-stroke = (paint: blue, thickness: 0.8pt)
  let green-stroke = (paint: green, thickness: 0.8pt)
  let red-stroke = (paint: red, thickness: 0.8pt)

  let unit(v) = {
    let len = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))
    (v.at(0) / len, v.at(1) / len)
  }

  // Axes
  ctz-draw(line: ((-5, 0), (5, 0)), stroke: (paint: black, thickness: 0.6pt))
  ctz-draw(line: ((0, -5), (0, 5)), stroke: (paint: black, thickness: 0.6pt))

  // Circles and ellipse
  ctz-draw(circle-r: (O, a), stroke: blue-stroke)
  ctz-draw(circle-r: (O, b), stroke: green-stroke)
  ctz-draw(ellipse: (O, b, a, 0deg), stroke: red-stroke)

  // Key points
  let H = (a / 2, 0)
  let Hp = (0, -b / 2)
  let M = (a / 2, a * calc.sqrt(3) / 2)
  let N = (-b * calc.sqrt(3) / 2, -b / 2)
  let Mp = (b / a * M.at(0), M.at(1))
  let Np = (N.at(0), a / b * N.at(1))

  // Dashed construction segments
  ctz-draw(line: (H, M), stroke: (paint: black, thickness: 0.6pt, dash: "dashed"))
  ctz-draw(line: (Hp, Np), stroke: (paint: black, thickness: 0.6pt, dash: "dashed"))

  // Radii
  ctz-draw(line: (O, M), stroke: blue-stroke)
  ctz-draw(line: (O, N), stroke: green-stroke)

  // Tangent at M on C
  let tM = unit((-M.at(1), M.at(0)))
  let TM1 = (M.at(0) - 4 * tM.at(0), M.at(1) - 4 * tM.at(1))
  let TM2 = (M.at(0) + 4 * tM.at(0), M.at(1) + 4 * tM.at(1))
  ctz-draw(line: (TM1, TM2), stroke: blue-stroke)

  // Tangent at N on Cp
  let tN = unit((-N.at(1), N.at(0)))
  let TN1 = (N.at(0) - 4 * tN.at(0), N.at(1) - 4 * tN.at(1))
  let TN2 = (N.at(0) + 4 * tN.at(0), N.at(1) + 4 * tN.at(1))
  ctz-draw(line: (TN1, TN2), stroke: green-stroke)

  // Intersections with axes
  let P = (2 * a, 0)
  let Pp = (0, -2 * b)

  // Perpendicular marks
  ctz-def-points(TM1: TM1, TN1: TN1, M: M, N: N, O: O)
  ctz-draw-mark-right-angle("TM1", "M", "O", color: blue)
  ctz-draw-mark-right-angle("TN1", "N", "O", color: green)

  // Tangents through Mp and Np from P and P'
  let uMp = unit((Mp.at(0) - P.at(0), Mp.at(1) - P.at(1)))
  let uNp = unit((Np.at(0) - Pp.at(0), Np.at(1) - Pp.at(1)))

  let A1 = (Mp.at(0) - 2 * uMp.at(0), Mp.at(1) - 2 * uMp.at(1))
  let A2 = (Mp.at(0) + 2 * uMp.at(0), Mp.at(1) + 2 * uMp.at(1))
  let B1 = (Np.at(0) - 2 * uNp.at(0), Np.at(1) - 2 * uNp.at(1))
  let B2 = (Np.at(0) + 2 * uNp.at(0), Np.at(1) + 2 * uNp.at(1))

  ctz-draw(line: (A1, A2), stroke: red-stroke, mark: (end: ">", start: ">"))
  ctz-draw(line: (B1, B2), stroke: red-stroke, mark: (end: ">", start: ">"))

  // Register and label points using auto placement
  ctz-def-points(O: O, H: H, Hp: Hp, M: M, Mp: Mp, N: N, Np: Np, P: P, Pp: Pp)
  ctz-draw(points: ("O", "H", "Hp", "M", "Mp", "N", "Np", "P", "Pp"), labels: (
    O: "auto",
    H: "auto",
    Hp: "auto",
    M: "auto",
    Mp: "auto",
    N: "auto",
    Np: "auto",
    P: "auto",
    Pp: "auto",
  ))
})
