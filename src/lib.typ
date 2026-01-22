// ctz-euclide/src/lib.typ
// Main entry point for ctz-euclide Typst package
//
// A port of the LaTeX tkz-euclide package for Euclidean geometry
// Uses cetz as the drawing backend

#import "@preview/cetz:0.4.2" as cetz

#import "util.typ"
#import "point.typ"
#import "intersection.typ"
#import "triangle.typ"
#import "transform.typ"
#import "draw.typ"
#import "drawing.typ"
#import "circle.typ"

/// Package version
#let _version = (0, 1, 0)

// Re-export cetz canvas for convenience
#let _canvas = cetz.canvas

/// Internal key for storing points in shared-state
#let _points-key = "tkz-points"

/// Get all stored points from context
#let _get-points(ctx) = {
  ctx.shared-state.at(_points-key, default: (:))
}

/// Store points in context
#let _set-points(ctx, points) = {
  ctx.shared-state.insert(_points-key, points)
  ctx
}

/// Custom coordinate resolver - accepts both "A" and "ctz:A" syntax
#let _ctz-coordinate-resolver(ctx, c) = {
  if type(c) == str {
    let points = _get-points(ctx)
    // Try with "ctz:" prefix first
    if c.starts-with("ctz:") {
      let name = c.slice(4)
      if name in points {
        return points.at(name)
      }
    }
    // Try direct name lookup (e.g., "A" instead of "ctz:A")
    if c in points {
      return points.at(c)
    }
  }
  c
}

/// Initialize ctz-euclide in a cetz canvas
/// Must be called at the start of canvas body
#let _init() = {
  cetz.draw.set-ctx(ctx => {
    // Initialize shared state for point storage
    if _points-key not in ctx.shared-state {
      ctx.shared-state.insert(_points-key, (:))
    }
    // Register coordinate resolver if not already done
    if type(ctx.resolve-coordinate) != array {
      ctx.resolve-coordinate = ()
    }
    if _ctz-coordinate-resolver not in ctx.resolve-coordinate {
      ctx.resolve-coordinate.push(_ctz-coordinate-resolver)
    }
    ctx
  })
}

/// Resolve a point reference to coordinates (internal helper)
#let _resolve-point(ctx, p) = {
  if type(p) == str {
    // Check if it's a tkz point name
    let points = _get-points(ctx)
    if p in points {
      return points.at(p)
    }
    // Try to strip "ctz:" prefix
    if p.starts-with("ctz:") {
      let name = p.slice(4)
      if name in points {
        return points.at(name)
      }
    }
    // Fall back to cetz coordinate resolution
    let (_, _pt) = cetz.coordinate.resolve(ctx, p)
    return _pt
  } else if type(p) == array {
    if p.len() >= 2 and p.len() <= 3 and p.all(x => type(x) in (int, float)) {
      return if p.len() == 2 { (p.at(0), p.at(1), 0) } else { p }
    }
    let (_, _pt) = cetz.coordinate.resolve(ctx, p)
    return _pt
  } else if type(p) == dictionary {
    let (_, _pt) = cetz.coordinate.resolve(ctx, p)
    return _pt
  }
  panic("Cannot resolve point: " + repr(p))
}

/// Helper to convert point name to ctz: coordinate
#let _pt(name) = "ctz:" + name

/// Define multiple points at once
#let _pts(..points) = {
  let pairs = if points.named() != (:) {
    points.named().pairs()
  } else {
    let pos = points.pos()
    assert(calc.rem(pos.len(), 2) == 0,
      message: "ctz-pts requires name-coordinate pairs")
    range(0, pos.len(), step: 2).map(i => (pos.at(i), pos.at(i + 1)))
  }

  (ctx => {
    for (name, coord) in pairs {
      let _pt = if type(coord) == array and coord.len() >= 2 and coord.len() <= 3 and coord.all(x => type(x) in (int, float, length)) {
        let resolve-num(v) = if type(v) == length { v / 1cm } else { v }
        let x = resolve-num(coord.at(0))
        let y = resolve-num(coord.at(1))
        let z = if coord.len() > 2 { resolve-num(coord.at(2)) } else { 0 }
        (x, y, z)
      } else {
        let (ctx2, resolved) = cetz.coordinate.resolve(ctx, coord)
        ctx = ctx2
        resolved
      }

      let stored = _get-points(ctx)
      stored.insert(name, _pt)
      ctx = _set-points(ctx, stored)
    }
    (ctx: ctx)
  },)
}

/// Line-line intersection
#let _ll(name, line1, line2, ray: true) = {
  (ctx => {
    let p1 = _resolve-point(ctx, line1.at(0))
    let p2 = _resolve-point(ctx, line1.at(1))
    let p3 = _resolve-point(ctx, line2.at(0))
    let p4 = _resolve-point(ctx, line2.at(1))

    let result = intersection.line-line-raw(p1, p2, p3, p4, ray: ray)
    assert(result != none, message: "Lines are parallel, no intersection found")

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Parse circle specification
#let _parse-circle(ctx, circle-spec) = {
  if type(circle-spec) == dictionary {
    let center = _resolve-point(ctx, circle-spec.center)
    let radius = if "radius" in circle-spec {
      if type(circle-spec.radius) == length { circle-spec.radius / 1cm } else { circle-spec.radius }
    } else if "through" in circle-spec {
      let _pt = _resolve-point(ctx, circle-spec.through)
      util.dist(center, _pt)
    } else {
      panic("Circle needs radius or through point")
    }
    (center, radius)
  } else if type(circle-spec) == array and circle-spec.len() == 2 {
    let center = _resolve-point(ctx, circle-spec.at(0))
    let _pt = _resolve-point(ctx, circle-spec.at(1))
    (center, util.dist(center, _pt))
  } else {
    panic("Invalid circle specification: " + repr(circle-spec))
  }
}

/// Line-circle intersection
#let _lc(result-names, line, circle-spec, near: none) = {
  (ctx => {
    let la = _resolve-point(ctx, line.at(0))
    let lb = _resolve-point(ctx, line.at(1))
    let (center, radius) = _parse-circle(ctx, circle-spec)

    let results = intersection.line-circle-raw(la, lb, center, radius)

    if near != none and results.len() > 1 {
      let near-pt = _resolve-point(ctx, near)
      results = results.sorted(key: _pt => util.dist-sq(near-pt, _pt))
    }

    let names = if type(result-names) == str { (result-names,) } else { result-names }
    let points = _get-points(ctx)
    for (i, _pt-name) in names.enumerate() {
      if i < results.len() {
        points.insert(_pt-name, results.at(i))
      }
    }
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Circle-circle intersection
#let _cc(result-names, circle1, circle2) = {
  (ctx => {
    let (c0, r0) = _parse-circle(ctx, circle1)
    let (c1, r1) = _parse-circle(ctx, circle2)

    let results = intersection.circle-circle-raw(c0, r0, c1, r1)

    let names = if type(result-names) == str { (result-names,) } else { result-names }
    let points = _get-points(ctx)
    for (i, _pt-name) in names.enumerate() {
      if i < results.len() {
        points.insert(_pt-name, results.at(i))
      }
    }
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Triangle centroid
#let _centroid(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.centroid-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle circumcenter
#let _circumcenter(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.circumcenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle incenter
#let _incenter(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.incenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle orthocenter
#let _orthocenter(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.orthocenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// ADDITIONAL TRIANGLE CENTERS
// =============================================================================

/// Nine-point (Euler) circle center
#let _euler(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.euler-center-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Lemoine point (symmedian point)
#let _lemoine(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.lemoine-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Nagel point
#let _nagel(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.nagel-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Gergonne point
#let _gergonne(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.gergonne-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Spieker center
#let _spieker(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.spieker-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Feuerbach point
#let _feuerbach(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.feuerbach-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Mittenpunkt
#let _mittenpunkt(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.mittenpunkt-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Excenter (opposite to specified vertex)
#let _excenter(name, a, b, c, vertex: "a") = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.excenter-raw(pa, pb, pc, vertex: vertex)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// SPECIAL TRIANGLES
// =============================================================================

/// Define medial triangle vertices
#let _medial(name-a, name-b, name-c, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let (ma, mb, mc) = triangle.medial-triangle-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name-a, ma)
    points.insert(name-b, mb)
    points.insert(name-c, mc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define orthic triangle vertices
#let _orthic(name-a, name-b, name-c, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let (ha, hb, hc) = triangle.orthic-triangle-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name-a, ha)
    points.insert(name-b, hb)
    points.insert(name-c, hc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define intouch triangle vertices
#let _intouch(name-a, name-b, name-c, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let (ta, tb, tc) = triangle.intouch-triangle-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name-a, ta)
    points.insert(name-b, tb)
    points.insert(name-c, tc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// POINT CONSTRUCTIONS
// =============================================================================

/// Define midpoint of segment AB
#let _midpoint(name, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let mid = util.midpoint(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, mid)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define equilateral triangle third point
#let _equilateral(name, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = util.equilateral-point(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, pc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define square third and fourth points
#let _square(name-c, name-d, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let (pc, pd) = util.square-points(pa, pb)
    let points = _get-points(ctx)
    points.insert(name-c, pc)
    points.insert(name-d, pd)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define golden ratio point
#let _golden(name, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = util.golden-ratio-point(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, pc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define barycentric point
#let _barycentric(name, a, b, c, wa, wb, wc) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let result = util.barycentric-point(pa, pb, pc, wa, wb, wc)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point on circle at angle
#let _point-on-circle(name, center, radius, angle-deg) = {
  (ctx => {
    let c = _resolve-point(ctx, center)
    let r = if type(radius) == length { radius / 1cm } else { radius }
    let result = util.point-on-circle(c, r, angle-deg)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define regular polygon vertices
#let _regular-polygon(names, center, first-vertex) = {
  (ctx => {
    let c = _resolve-point(ctx, center)
    let fv = _resolve-point(ctx, first-vertex)
    let n = names.len()
    let vertices = util.regular-polygon-vertices(c, fv, n)
    let points = _get-points(ctx)
    for (i, name) in names.enumerate() {
      points.insert(name, vertices.at(i))
    }
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define linear combination point: P = A + k*(B-A)
#let _linear(name, a, b, k) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let result = util.linear-point(pa, pb, k)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define central symmetry point
#let _symmetry(name, source, center) = {
  (ctx => {
    let p = _resolve-point(ctx, source)
    let c = _resolve-point(ctx, center)
    let result = util.central-symmetry(p, c)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define circle inversion point
#let _inversion(name, source, center, radius) = {
  (ctx => {
    let p = _resolve-point(ctx, source)
    let c = _resolve-point(ctx, center)
    let r = if type(radius) == length { radius / 1cm } else { radius }
    let result = util.circle-inversion(p, c, r)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// TANGENT DEFINITIONS
// =============================================================================

/// Define tangent points from external point to circle
#let _tangent-from(name1, name2, external-point, center, radius) = {
  (ctx => {
    let p = _resolve-point(ctx, external-point)
    let c = _resolve-point(ctx, center)
    let r = if type(radius) == length { radius / 1cm } else { radius }
    let tangents = circle.tangent-from-point-raw(p, c, r)
    let points = _get-points(ctx)
    if tangents.len() >= 1 { points.insert(name1, tangents.at(0)) }
    if tangents.len() >= 2 { points.insert(name2, tangents.at(1)) }
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define tangent line at point on circle
#let _tangent-at(name1, name2, point-on-circle, center) = {
  (ctx => {
    let p = _resolve-point(ctx, point-on-circle)
    let c = _resolve-point(ctx, center)
    let (t1, t2) = circle.tangent-at-point-raw(p, c)
    let points = _get-points(ctx)
    points.insert(name1, t1)
    points.insert(name2, t2)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define radical axis of two circles
#let _radical-axis(name1, name2, center1, radius1, center2, radius2) = {
  (ctx => {
    let c1 = _resolve-point(ctx, center1)
    let c2 = _resolve-point(ctx, center2)
    let r1 = if type(radius1) == length { radius1 / 1cm } else { radius1 }
    let r2 = if type(radius2) == length { radius2 / 1cm } else { radius2 }
    let result = circle.radical-axis-raw(c1, r1, c2, r2)
    if result != none {
      let (p1, p2) = result
      let points = _get-points(ctx)
      points.insert(name1, p1)
      points.insert(name2, p2)
      ctx = _set-points(ctx, points)
    }
    (ctx: ctx)
  },)
}

/// Define point by rotation around a center
#let _rotation(name, source, center, angle-deg) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let ctr = _resolve-point(ctx, center)
    let result = transform.rotation-raw(src, ctr, angle-deg)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by reflection across a line
#let _reflect(name, source, line-a, line-b) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let la = _resolve-point(ctx, line-a)
    let lb = _resolve-point(ctx, line-b)
    let result = transform.reflection-raw(src, la, lb)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by translation
#let _translate(name, source, vector) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let vec = if type(vector) == array {
      (vector.at(0), vector.at(1), 0)
    } else {
      let v1 = _resolve-point(ctx, vector.at(0))
      let v2 = _resolve-point(ctx, vector.at(1))
      (v2.at(0) - v1.at(0), v2.at(1) - v1.at(1), 0)
    }
    let result = transform.translation-raw(src, vec)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by homothety (scaling from center)
#let _homothety(name, source, center, factor) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let ctr = _resolve-point(ctx, center)
    let result = transform.homothety-raw(src, ctr, factor)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by projection onto line
#let _project(name, source, line-a, line-b) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let la = _resolve-point(ctx, line-a)
    let lb = _resolve-point(ctx, line-b)
    let result = transform.projection-raw(src, la, lb)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Global point style state key
#let _point-style-key = "tkz-point-style"

/// Set up default point style
#let _set-up-point(style-spec) = {
  cetz.draw.set-ctx(ctx => {
    ctx.shared-state.insert(_point-style-key, style-spec)
    ctx
  })
}

/// Get current point style
#let _get-point-style(ctx) = {
  ctx.shared-state.at(_point-style-key, default: draw.default-point-style)
}

/// Define a line by geometric construction (perpendicular, parallel, bisector, etc.)
#let _def-line(name1, name2, construction) = {
  (ctx => {
    let result = if construction.type == "perpendicular" {
      // Perpendicular to line through point
      let la = _resolve-point(ctx, construction.line.at(0))
      let lb = _resolve-point(ctx, construction.line.at(1))
      let through = _resolve-point(ctx, construction.through)
      let foot = util.project-point-on-line(through, la, lb)
      // Line from through point, perpendicular to la-lb
      let dx = lb.at(0) - la.at(0)
      let dy = lb.at(1) - la.at(1)
      // Perpendicular direction
      let p1 = (through.at(0) - dy, through.at(1) + dx, 0)
      let p2 = (through.at(0) + dy, through.at(1) - dx, 0)
      (p1, p2)
    } else if construction.type == "parallel" {
      // Parallel to line through point
      let la = _resolve-point(ctx, construction.line.at(0))
      let lb = _resolve-point(ctx, construction.line.at(1))
      let through = _resolve-point(ctx, construction.through)
      let dx = lb.at(0) - la.at(0)
      let dy = lb.at(1) - la.at(1)
      let p1 = (through.at(0) - dx, through.at(1) - dy, 0)
      let p2 = (through.at(0) + dx, through.at(1) + dy, 0)
      (p1, p2)
    } else if construction.type == "bisector" {
      // Angle bisector: vertex is middle point
      let pa = _resolve-point(ctx, construction.points.at(0))
      let vertex = _resolve-point(ctx, construction.points.at(1))
      let pc = _resolve-point(ctx, construction.points.at(2))
      let bisector-pt = util.angle-bisector-point(pa, vertex, pc)

      // Extend the bisector both ways so it is visible across the figure
      let dir-x = bisector-pt.at(0) - vertex.at(0)
      let dir-y = bisector-pt.at(1) - vertex.at(1)
      let dir-len = calc.sqrt(dir-x * dir-x + dir-y * dir-y)
      let dir = if util.approx-zero(dir-len) { (1, 0) } else { (dir-x / dir-len, dir-y / dir-len) }

      let span = calc.max(util.dist(vertex, pa), util.dist(vertex, pc), 1) * 2.5
      let p1 = (vertex.at(0) - dir.at(0) * span, vertex.at(1) - dir.at(1) * span, vertex.at(2, default: 0))
      let p2 = (vertex.at(0) + dir.at(0) * span, vertex.at(1) + dir.at(1) * span, vertex.at(2, default: 0))
      (p1, p2)
    } else if construction.type == "mediator" {
      // Perpendicular bisector of segment
      let pa = _resolve-point(ctx, construction.segment.at(0))
      let pb = _resolve-point(ctx, construction.segment.at(1))
      let (p1, p2, mid) = util.perpendicular-bisector(pa, pb)
      (p1, p2)
    } else {
      panic("Unknown line construction type: " + construction.type)
    }

    let points = _get-points(ctx)
    points.insert(name1, result.at(0))
    points.insert(name2, result.at(1))
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// Line construction helpers
#let _perp(name1, name2, line, through) = _def-line(name1, name2, (type: "perpendicular", line: line, through: through))
#let _para(name1, name2, line, through) = _def-line(name1, name2, (type: "parallel", line: line, through: through))
#let _bisect(name1, name2, a, vertex, c) = _def-line(name1, name2, (type: "bisector", points: (a, vertex, c)))
#let _mediator(name1, name2, a, b) = _def-line(name1, name2, (type: "mediator", segment: (a, b)))

// =============================================================================
// DRAWING FUNCTIONS
// =============================================================================

/// Draw a polyline (direct CeTZ wrapper)
#let _draw-line(..args) = cetz.draw.line(..args)

/// Set point/label styling
#let _style(..style-args) = drawing.set-style(cetz.draw, ..style-args)

/// Draw points
#let _points(..names) = drawing.draw-points-styled(cetz.draw, _pt, ..names)

/// Draw labels
#let _labels(..args) = drawing.label-points-styled(cetz.draw, _pt, ..args)

/// Draw angle
#let _angle(vertex, a, b, ..opts) = drawing.mark-angle(cetz.draw, cetz.angle, _pt(vertex), _pt(a), _pt(b), ..opts)

/// Draw polygon
#let _polygon(..args) = drawing.draw-polygon(cetz.draw, _pt, ..args)

/// Fill polygon
#let _fill-polygon(..args) = drawing.fill-polygon(cetz.draw, _pt, ..args)

/// Draw segment
#let _segment(a, b, ..opts) = drawing.draw-segment(cetz.draw, _pt, a, b, ..opts)

/// Draw line with extension
#let _line-add(a, b, ..opts) = drawing.draw-line-add(cetz.draw, _pt, a, b, ..opts)

/// Draw arc through points
#let _arc(center, start, end, ..opts) = drawing.draw-arc-through(cetz.draw, _pt, center, start, end, ..opts)

/// Draw arc with radius
#let _arc-r(center, radius, start-angle, end-angle, ..opts) = drawing.draw-arc-r(cetz.draw, center, radius, start-angle, end-angle, ..opts)

/// Draw circle with radius
#let _circle-r(center, radius, ..opts) = drawing.draw-circle-r(cetz.draw, center, radius, ..opts)

/// Draw circle through point
#let _circle-through(center, through, ..opts) = drawing.draw-circle-through(cetz.draw, _pt, center, through, ..opts)

/// Draw circle with diameter
#let _circle-diameter(a, b, ..opts) = drawing.draw-circle-diameter(cetz.draw, _pt, a, b, ..opts)

/// Draw circumcircle
#let _circumcircle(a, b, c, ..opts) = drawing.draw-circumcircle(cetz.draw, _pt, a, b, c, ..opts)

/// Draw incircle
#let _incircle(a, b, c, ..opts) = drawing.draw-incircle(cetz.draw, _pt, a, b, c, ..opts)

/// Draw semicircle
#let _semicircle(a, b, ..opts) = drawing.draw-semicircle(cetz.draw, _pt, a, b, ..opts)

/// Draw sector
#let _sector(center, start, end, ..opts) = drawing.draw-sector(cetz.draw, _pt, center, start, end, ..opts)

/// Mark segment
#let _mark-segment(a, b, ..opts) = drawing.mark-segment(cetz.draw, _pt, a, b, ..opts)

/// Mark right angle
#let _mark-right-angle(a, vertex, c, ..opts) = drawing.mark-right-angle(cetz.draw, _pt, a, vertex, c, ..opts)

/// Fill angle
#let _fill-angle(vertex, a, c, ..opts) = drawing.fill-angle(cetz.draw, cetz.angle, _pt, vertex, a, c, ..opts)

/// Label segment
#let _label-segment(a, b, ..opts) = drawing.label-segment(cetz.draw, _pt, a, b, ..opts)

/// Label angle
#let _label-angle(vertex, a, c, ..opts) = drawing.label-angle-at(cetz.draw, _pt, vertex, a, c, ..opts)

// =============================================================================
// CALCULATIONS (return values via context)
// =============================================================================

#let _calc-length(a, b) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  (ctx: ctx, value: util.dist(pa, pb))
},)

#let _calc-angle(a, b, c) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  let pc = _resolve-point(ctx, c)
  (ctx: ctx, value: util.angle-at-vertex(pa, pb, pc))
},)

#let _calc-area(a, b, c) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  let pc = _resolve-point(ctx, c)
  (ctx: ctx, value: util.triangle-area(pa, pb, pc))
},)

#let _calc-slope(a, b) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  (ctx: ctx, value: util.slope-angle(pa, pb))
},)

#let _calc-ratio(a, b, c) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  let pc = _resolve-point(ctx, c)
  (ctx: ctx, value: util.ratio(pa, pb, pc))
},)

// =============================================================================
// GRID AND AXES
// =============================================================================

#let _grid(..opts) = drawing.draw-grid(cetz.draw, ..opts)
#let _axes(..opts) = drawing.draw-axes(cetz.draw, ..opts)
#let _axis-x(..opts) = drawing.draw-axis-x(cetz.draw, ..opts)
#let _axis-y(..opts) = drawing.draw-axis-y(cetz.draw, ..opts)
#let _hline(y, ..opts) = drawing.draw-hline(cetz.draw, y, ..opts)
#let _vline(x, ..opts) = drawing.draw-vline(cetz.draw, x, ..opts)
#let _draw-text(x, y, content, ..opts) = drawing.draw-text(cetz.draw, x, y, content, ..opts)

// =============================================================================
// CLIPPING
// =============================================================================

/// Set global clip region
#let _set-clip(xmin, ymin, xmax, ymax) = drawing.set-clip-region(cetz.draw, xmin, ymin, xmax, ymax)

/// Clear global clip region
#let _clear-clip() = drawing.clear-clip-region(cetz.draw)

/// Show clip boundary
#let _show-clip(stroke: gray + 0.5pt) = drawing.draw-global-clip-boundary(cetz.draw, stroke: stroke)

/// Draw line with global clip
#let _tkz-line(a, b, add: (10, 10), stroke: black) = drawing.draw-line-global-clip(cetz.draw, _pt, a, b, add: add, stroke: stroke)

/// Draw segment with global clip
#let _seg(a, b, stroke: black) = drawing.draw-segment-global-clip(cetz.draw, _pt, a, b, stroke: stroke)

/// Draw clipped line (manual bounds)
#let _clipped-line(p1, p2, xmin, ymin, xmax, ymax, stroke: black) = drawing.draw-clipped-line(cetz.draw, p1, p2, xmin, ymin, xmax, ymax, stroke: stroke)

/// Draw clipped line with extension (manual bounds)
#let _clipped-line-add(a, b, xmin, ymin, xmax, ymax, add: (10, 10), stroke: black) = drawing.draw-clipped-line-add(cetz.draw, _pt, a, b, xmin, ymin, xmax, ymax, add: add, stroke: stroke)

/// Draw clip boundary
#let _clip-boundary(xmin, ymin, xmax, ymax, stroke: black + 0.5pt) = drawing.draw-clip-boundary(cetz.draw, xmin, ymin, xmax, ymax, stroke: stroke)

/// Raw clipping algorithm
#let _clip-line-to-rect = drawing.clip-line-to-rect

// =============================================================================
// RAW ALGORITHMS (no context needed)
// =============================================================================

#let _algorithms = (
  // Intersections
  line-line: intersection.line-line-raw,
  line-circle: intersection.line-circle-raw,
  circle-circle: intersection.circle-circle-raw,
  // Triangle centers
  centroid: triangle.centroid-raw,
  circumcenter: triangle.circumcenter-raw,
  incenter: triangle.incenter-raw,
  orthocenter: triangle.orthocenter-raw,
  inradius: triangle.inradius-raw,
  circumradius: triangle.circumradius-raw,
  euler-center: triangle.euler-center-raw,
  euler-radius: triangle.euler-radius-raw,
  lemoine: triangle.lemoine-raw,
  nagel: triangle.nagel-raw,
  gergonne: triangle.gergonne-raw,
  spieker: triangle.spieker-raw,
  feuerbach: triangle.feuerbach-raw,
  mittenpunkt: triangle.mittenpunkt-raw,
  excenter: triangle.excenter-raw,
  exradius: triangle.exradius-raw,
  // Special triangles
  medial-triangle: triangle.medial-triangle-raw,
  orthic-triangle: triangle.orthic-triangle-raw,
  intouch-triangle: triangle.intouch-triangle-raw,
  excentral-triangle: triangle.excentral-triangle-raw,
  tangential-triangle: triangle.tangential-triangle-raw,
  // Transformations
  rotation: transform.rotation-raw,
  reflection: transform.reflection-raw,
  translation: transform.translation-raw,
  homothety: transform.homothety-raw,
  projection: transform.projection-raw,
  point-on-circle: transform.point-on-circle-raw,
  // Circle definitions
  circle-through: circle.circle-through-raw,
  circle-diameter: circle.circle-diameter-raw,
  circle-circum: circle.circle-circum-raw,
  circle-in: circle.circle-in-raw,
  circle-ex: circle.circle-ex-raw,
  circle-euler: circle.circle-euler-raw,
  tangent-from: circle.tangent-from-point-raw,
  tangent-at: circle.tangent-at-point-raw,
  radical-axis: circle.radical-axis-raw,
  apollonius: circle.apollonius-circle-raw,
  // Utility calculations
  midpoint: util.midpoint,
  dist: util.dist,
  angle-at-vertex: util.angle-at-vertex,
  slope-angle: util.slope-angle,
  triangle-area: util.triangle-area,
  polygon-area: util.polygon-area,
  equilateral-point: util.equilateral-point,
  square-points: util.square-points,
  golden-ratio-point: util.golden-ratio-point,
  barycentric-point: util.barycentric-point,
  regular-polygon-vertices: util.regular-polygon-vertices,
  central-symmetry: util.central-symmetry,
  circle-inversion: util.circle-inversion,
)

// Re-export utility functions
#let _midpoint-raw = util.midpoint
#let _dist = util.dist
#let _angle-to = util.angle-to
#let _project-point-on-line = util.project-point-on-line
#let _rotate-point = util.rotate-point

// =============================================================================
// PUBLIC API (ctz- prefix)
// =============================================================================

/// Package version
#let ctz-version = _version

/// CeTZ canvas alias
#let ctz-canvas = _canvas

/// Initialize ctz-euclide (call at start of canvas body)
#let ctz-init() = _init()

/// Helper to convert point name to ctz: coordinate
#let ctz-pt(name) = _pt(name)

// Point definitions
#let ctz-def-points(..points) = _pts(..points)
#let ctz-pts(..points) = ctz-def-points(..points)

// Intersections
#let ctz-def-ll(name, l1, l2, ray: true) = _ll(name, l1, l2, ray: ray)
#let ctz-def-lc(result-names, line, circle-spec, near: none) = _lc(result-names, line, circle-spec, near: near)
#let ctz-def-cc(result-names, circle1, circle2) = _cc(result-names, circle1, circle2)

// Triangle centers
#let ctz-def-centroid(name, a, b, c) = _centroid(name, a, b, c)
#let ctz-def-circumcenter(name, a, b, c) = _circumcenter(name, a, b, c)
#let ctz-def-incenter(name, a, b, c) = _incenter(name, a, b, c)
#let ctz-def-orthocenter(name, a, b, c) = _orthocenter(name, a, b, c)
#let ctz-def-euler(name, a, b, c) = _euler(name, a, b, c)
#let ctz-def-lemoine(name, a, b, c) = _lemoine(name, a, b, c)
#let ctz-def-nagel(name, a, b, c) = _nagel(name, a, b, c)
#let ctz-def-gergonne(name, a, b, c) = _gergonne(name, a, b, c)
#let ctz-def-spieker(name, a, b, c) = _spieker(name, a, b, c)
#let ctz-def-feuerbach(name, a, b, c) = _feuerbach(name, a, b, c)
#let ctz-def-mittenpunkt(name, a, b, c) = _mittenpunkt(name, a, b, c)
#let ctz-def-excenter(name, a, b, c, vertex: "A") = _excenter(name, a, b, c, vertex: vertex)

// Special triangles
#let ctz-def-medial-triangle(name-a, name-b, name-c, a, b, c) = _medial(name-a, name-b, name-c, a, b, c)
#let ctz-def-orthic-triangle(name-a, name-b, name-c, a, b, c) = _orthic(name-a, name-b, name-c, a, b, c)
#let ctz-def-intouch-triangle(name-a, name-b, name-c, a, b, c) = _intouch(name-a, name-b, name-c, a, b, c)

// Point constructions
#let ctz-def-midpoint(name, a, b) = _midpoint(name, a, b)
#let ctz-def-equilateral(name, a, b) = _equilateral(name, a, b)
#let ctz-def-square(name-c, name-d, a, b) = _square(name-c, name-d, a, b)
#let ctz-def-golden(name, a, b, inside: true) = _golden(name, a, b, inside: inside)
#let ctz-def-barycentric(name, a, b, c, x, y, z) = _barycentric(name, a, b, c, x, y, z)
#let ctz-def-point-on-circle(name, center, radius, angle-deg) = _point-on-circle(name, center, radius, angle-deg)
#let ctz-def-regular-polygon(names, center, vertex) = _regular-polygon(names, center, vertex)
#let ctz-def-linear(name, a, b, k) = _linear(name, a, b, k)
#let ctz-def-symmetry(name, source, center) = _symmetry(name, source, center)
#let ctz-def-inversion(name, source, center, radius) = _inversion(name, source, center, radius)
#let ctz-def-tangent-from(name1, name2, point, center, radius) = _tangent-from(name1, name2, point, center, radius)
#let ctz-def-tangent-at(name1, name2, point-on-circle, center) = _tangent-at(name1, name2, point-on-circle, center)
#let ctz-def-radical-axis(name1, name2, circle1, circle2) = _radical-axis(name1, name2, circle1, circle2)

// Transformations
#let ctz-def-rotation(name, source, center, angle-deg) = _rotation(name, source, center, angle-deg)
#let ctz-def-reflect(name, source, p1, p2) = _reflect(name, source, p1, p2)
#let ctz-def-translate(name, source, vector) = _translate(name, source, vector)
#let ctz-def-homothety(name, source, center, k) = _homothety(name, source, center, k)
#let ctz-def-project(name, source, p1, p2) = _project(name, source, p1, p2)

// Line construction helpers
#let ctz-def-perp(name1, name2, line, through) = _perp(name1, name2, line, through)
#let ctz-def-para(name1, name2, line, through) = _para(name1, name2, line, through)
#let ctz-def-bisect(name1, name2, a, vertex, c) = _bisect(name1, name2, a, vertex, c)
#let ctz-def-mediator(name1, name2, a, b) = _mediator(name1, name2, a, b)

// Drawing functions
#let ctz-style(..style-args) = _style(..style-args)
#let ctz-draw-line(..args) = _draw-line(..args)
#let ctz-draw-points(..names) = _points(..names)
#let ctz-points(..names) = ctz-draw-points(..names)
#let ctz-draw-labels(..args) = _labels(..args)
#let ctz-draw-angle(vertex, a, b, ..opts) = _angle(vertex, a, b, ..opts)
#let ctz-draw-polygon(..args) = _polygon(..args)
#let ctz-draw-fill-polygon(..args) = _fill-polygon(..args)
#let ctz-draw-segment(a, b, ..opts) = _segment(a, b, ..opts)
#let ctz-draw-line-add(a, b, ..opts) = _line-add(a, b, ..opts)
#let ctz-draw-arc(center, start, end, ..opts) = _arc(center, start, end, ..opts)
#let ctz-draw-arc-r(center, radius, start-angle, end-angle, ..opts) = _arc-r(center, radius, start-angle, end-angle, ..opts)
#let ctz-draw-circle-r(center, radius, ..opts) = _circle-r(center, radius, ..opts)
#let ctz-draw-circle-through(center, through, ..opts) = _circle-through(center, through, ..opts)
#let ctz-draw-circle-diameter(a, b, ..opts) = _circle-diameter(a, b, ..opts)
#let ctz-draw-circumcircle(a, b, c, ..opts) = _circumcircle(a, b, c, ..opts)
#let ctz-draw-incircle(a, b, c, ..opts) = _incircle(a, b, c, ..opts)
#let ctz-draw-semicircle(a, b, ..opts) = _semicircle(a, b, ..opts)
#let ctz-draw-sector(center, start, end, ..opts) = _sector(center, start, end, ..opts)
#let ctz-draw-mark-segment(a, b, ..opts) = _mark-segment(a, b, ..opts)
#let ctz-draw-mark-right-angle(a, vertex, c, ..opts) = _mark-right-angle(a, vertex, c, ..opts)
#let ctz-draw-fill-angle(vertex, a, c, ..opts) = _fill-angle(vertex, a, c, ..opts)
#let ctz-draw-label-segment(a, b, ..opts) = _label-segment(a, b, ..opts)
#let ctz-draw-label-angle(vertex, a, c, ..opts) = _label-angle(vertex, a, c, ..opts)

// Calculations (return values via context)
#let ctz-calc-length(a, b) = _calc-length(a, b)
#let ctz-calc-angle(a, b, c) = _calc-angle(a, b, c)
#let ctz-calc-area(a, b, c) = _calc-area(a, b, c)
#let ctz-calc-slope(a, b) = _calc-slope(a, b)
#let ctz-calc-ratio(a, b, c) = _calc-ratio(a, b, c)

// Grid and axes
#let ctz-draw-grid(..opts) = _grid(..opts)
#let ctz-draw-axes(..opts) = _axes(..opts)
#let ctz-draw-axis-x(..opts) = _axis-x(..opts)
#let ctz-draw-axis-y(..opts) = _axis-y(..opts)
#let ctz-draw-hline(y, ..opts) = _hline(y, ..opts)
#let ctz-draw-vline(x, ..opts) = _vline(x, ..opts)
#let ctz-draw-text(x, y, content, ..opts) = _draw-text(x, y, content, ..opts)

// Clipping
#let ctz-set-clip(xmin, ymin, xmax, ymax) = _set-clip(xmin, ymin, xmax, ymax)
#let ctz-clear-clip() = _clear-clip()
#let ctz-show-clip(stroke: gray + 0.5pt) = _show-clip(stroke: stroke)
#let ctz-draw-line-global-clip(a, b, add: (10, 10), stroke: black) = _tkz-line(a, b, add: add, stroke: stroke)
#let ctz-draw-seg-global-clip(a, b, stroke: black) = _seg(a, b, stroke: stroke)
#let ctz-draw-clipped-line(p1, p2, xmin, ymin, xmax, ymax, stroke: black) = _clipped-line(p1, p2, xmin, ymin, xmax, ymax, stroke: stroke)
#let ctz-draw-clipped-line-add(a, b, xmin, ymin, xmax, ymax, add: (10, 10), stroke: black) = _clipped-line-add(a, b, xmin, ymin, xmax, ymax, add: add, stroke: stroke)
#let ctz-draw-clip-boundary(xmin, ymin, xmax, ymax, stroke: black + 0.5pt) = _clip-boundary(xmin, ymin, xmax, ymax, stroke: stroke)
#let ctz-clip-line-to-rect = _clip-line-to-rect

// Raw algorithms (no context needed)
#let ctz-algorithms = _algorithms

// Utility re-exports
#let ctz-midpoint-raw = _midpoint-raw
#let ctz-dist = _dist
#let ctz-angle-to = _angle-to
#let ctz-project-point-on-line = _project-point-on-line
#let ctz-rotate-point = _rotate-point
