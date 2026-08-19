// ctz-def-triangle-center names the centre instead of hiding it in the
// function name, and takes the vertices in one place (issue #6). The eleven
// historic ctz-def-<centre> functions keep working unchanged.
//
// The definition functions return a callback taking a canvas context, so the
// dispatch is checked by running that callback on a stub context and reading
// the point it stores. No rendering involved: a wrong wiring fails the compile.
#import "../src/lib.typ": *

#set page(width: 13cm, height: auto, margin: 0.6cm)

#let A = (0, 0, 0)
#let B = (7, 0, 0)
#let C = (0.6, 2.2, 0)
#let alg = ctz-algorithms

// Minimal context: the three vertices already stored, which is all the
// definition callbacks read.
#let stub = (
  shared-state: (
    "ctz-points": (A: A, B: B, C: C),
  ),
)

// Run a definition and return the point it stored under `name`.
#let run(def, name) = {
  let ctx = stub
  for step in def {
    ctx = (step(ctx)).ctx
  }
  ctx.shared-state.at("ctz-points").at(name)
}

#let same(p, q, msg) = assert(
  calc.abs(p.at(0) - q.at(0)) < 1e-9 and calc.abs(p.at(1) - q.at(1)) < 1e-9,
  message: msg + " : " + repr(p) + " vs " + repr(q),
)

#{
  let by-kind = (
    (("centroid", "median", "g", "G"), (alg.centroid)(A, B, C)),
    (("circum", "circumcenter", "circumcentre", "o", "O"), (alg.circumcenter)(A, B, C)),
    (("in", "incenter", "incentre", "i", "I"), (alg.incenter)(A, B, C)),
    (("ortho", "orthocenter", "orthocentre", "h"), (alg.orthocenter)(A, B, C)),
    (("nagel",), (alg.nagel)(A, B, C)),
    (("gergonne",), (alg.gergonne)(A, B, C)),
    (("spieker",), (alg.spieker)(A, B, C)),
    (("mittenpunkt",), (alg.mittenpunkt)(A, B, C)),
  )

  // The centres have to be distinct on this triangle, or the checks below
  // would pass on a wrong dispatch.
  for i in range(by-kind.len()) {
    for j in range(i + 1, by-kind.len()) {
      let p = by-kind.at(i).at(1)
      let q = by-kind.at(j).at(1)
      assert(
        calc.abs(p.at(0) - q.at(0)) > 0.05 or calc.abs(p.at(1) - q.at(1)) > 0.05,
        message: "fixture triangle too regular: " + by-kind.at(i).at(0).first()
          + " and " + by-kind.at(j).at(0).first() + " coincide",
      )
    }
  }

  // every kind and alias reaches its own algorithm
  for (kinds, want) in by-kind {
    for k in kinds {
      same(run(ctz-def-triangle-center(k, "X", "A,B,C"), "X"), want, "kind " + repr(k))
    }
  }

  // the three vertex spellings agree, and match the historic function
  let want = (alg.incenter)(A, B, C)
  same(run(ctz-def-triangle-center("in", "X", "A,B,C"), "X"), want, "vertices \"A,B,C\"")
  same(run(ctz-def-triangle-center("in", "X", ("A", "B", "C")), "X"), want, "vertices as array")
  same(run(ctz-def-triangle-center("in", "X", "A", "B", "C"), "X"), want, "vertices as three arguments")
  same(run(ctz-def-incenter("X", "A", "B", "C"), "X"), want, "ctz-def-incenter")

  // excenter honours vertex:, and defaults to A like the historic function
  same(
    run(ctz-def-triangle-center("ex", "X", "A,B,C", vertex: "B"), "X"),
    (alg.excenter)(A, B, C, vertex: "B"),
    "excenter vertex B",
  )
  same(
    run(ctz-def-triangle-center("ex", "X", "A,B,C"), "X"),
    run(ctz-def-excenter("X", "A", "B", "C"), "X"),
    "excenter default vertex",
  )
}

== Drawn both ways

Historic function as a black circle, `ctz-def-triangle-center` as a red cross.

#ctz-canvas(length: 0.9cm, {
  import cetz.draw: *
  ctz-init()
  ctz-def-points(A: (0, 0), B: (7, 0), C: (0.6, 2.2))
  ctz-draw-line("A", "B", "C", "A")
  ctz-def-centroid("G1", "A", "B", "C")
  ctz-def-circumcenter("O1", "A", "B", "C")
  ctz-def-incenter("I1", "A", "B", "C")
  ctz-def-orthocenter("H1", "A", "B", "C")
  ctz-draw-points("G1", "O1", "I1", "H1", shape: "circle", size: 0.13, color: black)
  ctz-def-triangle-center("centroid", "G2", "A,B,C")
  ctz-def-triangle-center("circum", "O2", ("A", "B", "C"))
  ctz-def-triangle-center("in", "I2", "A", "B", "C")
  ctz-def-triangle-center("ortho", "H2", "A,B,C")
  ctz-draw-points("G2", "O2", "I2", "H2", shape: "cross", size: 0.07, color: red)
})
