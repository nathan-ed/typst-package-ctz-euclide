#import "/src/lib.typ": *

#set page(width: 16cm, height: 22cm, margin: 1cm)

= Quick: Conics and Projectiles

#ctz-canvas({
  ctz-init()
  ctz-def-points(O: (0, 0), F: (2, 0), A: (-2, -3), B: (-2, 3))

  ctz-def-ellipse("E1", "O", 3, 2, angle: 25deg)
  ctz-draw("E1", stroke: blue + 1pt)

  ctz-def-line("d1", "A", "B")
  ctz-draw("d1", stroke: gray + 0.6pt)
  ctz-def-parabola("P1", "F", "d1", extent: 3.5, steps: 140)
  ctz-draw("P1", stroke: red + 1pt)

  ctz-draw("O", fill: black)
  ctz-draw("F", fill: black)
  ctz-draw-labels("O", "F", O: "below", F: "below")
})

#ctz-canvas({
  ctz-init()
  ctz-draw-axes(xmin: -1, xmax: 8, ymin: -1, ymax: 6, stroke: gray + 0.5pt)

  ctz-def-projectile(
    "T1",
    (0, 0),
    (4, 6),
    y-floor: 0,
    vectors: true,
    vector-count: 6,
    vector-scale: 0.08,
  )
  ctz-draw("T1", stroke: blue + 1pt)
})
