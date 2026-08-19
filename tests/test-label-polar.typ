// Polar label placement (issue #6): "135deg" or "200deg+0.6" as a string, and
// (angle: 135deg, dist: 0.4) as parameters. 0° is to the right, angles turn
// counter-clockwise.
//
// Part 1 asserts the parser numerically: a wrong angle convention, a wrong
// default distance or a wrong anchor fails the compile.
// Part 2 draws the eight directions so the page can be eyeballed.
#import "../src/lib.typ": *

#set page(width: 11cm, height: auto, margin: 0.7cm)

#let close(a, b, msg) = assert(
  calc.abs(a - b) < 1e-9,
  message: msg + " : " + repr(a) + " vs " + repr(b),
)

#{
  let parse = _drawing._parse-polar-pos
  let d = _drawing._polar-default-dist

  // 0° points right, 90° up: the trigonometric convention, not screen coords
  let right = parse("0deg", d)
  close(right.offset.at(0), d, "0deg dx")
  close(right.offset.at(1), 0, "0deg dy")
  assert(right.pos == "right", message: "0deg anchor: " + right.pos)

  let up = parse("90deg", d)
  close(up.offset.at(0), 0, "90deg dx")
  close(up.offset.at(1), d, "90deg dy")
  assert(up.pos == "above", message: "90deg anchor: " + up.pos)

  let left = parse("180deg", d)
  close(left.offset.at(0), -d, "180deg dx")
  assert(left.pos == "left", message: "180deg anchor: " + left.pos)

  let down = parse("270deg", d)
  close(down.offset.at(1), -d, "270deg dy")
  assert(down.pos == "below", message: "270deg anchor: " + down.pos)

  // explicit distance
  let far = parse("90deg+1.5", d)
  close(far.offset.at(1), 1.5, "90deg+1.5 dy")

  // diagonals take the composite anchor
  assert(parse("45deg", d).pos == "above right", message: "45deg anchor")
  assert(parse("135deg", d).pos == "above left", message: "135deg anchor")
  assert(parse("225deg", d).pos == "below left", message: "225deg anchor")
  assert(parse("315deg", d).pos == "below right", message: "315deg anchor")

  // negative and beyond-360 angles normalise
  assert(parse("-90deg", d).pos == "below", message: "-90deg anchor")
  assert(parse("450deg", d).pos == "above", message: "450deg anchor")

  // polar placement pins the label: the collision engine must not move it
  assert(parse("90deg", d).enforced, message: "polar must be enforced")

  // what is not polar must be refused, so the compass parser still gets it
  for bad in ("above", "above+1.2 left+0.5", "90", "deg", "90degx", "") {
    assert(parse(bad, d) == none, message: "should not parse as polar: " + repr(bad))
  }
}

== String form and parameter form land in the same place

Top row written as strings, bottom row as parameters.

#ctz-canvas(length: 1.2cm, {
  import cetz.draw: *
  ctz-init()
  ctz-def-points(
    A: (0, 0), B: (2.4, 0), C: (4.8, 0),
    D: (0, -1.6), E: (2.4, -1.6), F: (4.8, -1.6),
  )
  ctz-draw-points("A", "B", "C", "D", "E", "F")
  // string form, then parameter form: both must land in the same place
  ctz-draw-labels(A: "45deg+0.5", B: "135deg+0.5", C: "225deg+0.5")
  ctz-draw-labels(
    D: (angle: 45deg, dist: 0.5),
    E: (angle: 135deg, dist: 0.5),
    F: (angle: 225, dist: 0.5),
  )
})
