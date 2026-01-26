// ctz-euclide/src/conic.typ
// Conic sections and projectile helpers

#import "util.typ"

/// Normalize a 2D vector
#let _unit2(v) = {
  let len = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))
  if len < util.eps {
    return (0, 0)
  }
  (v.at(0) / len, v.at(1) / len)
}

/// Perpendicular 2D vector
#let _perp2(v) = (-v.at(1), v.at(0))

/// Dot product (2D)
#let _dot2(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)

/// Rotate a 2D vector by angle
#let _rotate2(v, angle) = {
  let ang = if type(angle) == type(0deg) { angle } else { angle * 1deg }
  let c = calc.cos(ang)
  let s = calc.sin(ang)
  (v.at(0) * c - v.at(1) * s, v.at(0) * s + v.at(1) * c)
}

/// Point on ellipse for parameter angle t
#let ellipse-point-raw(center, rx, ry, angle: 0deg, t: 0deg) = {
  let tt = if type(t) == type(0deg) { t } else { t * 1deg }
  let x = rx * calc.cos(tt)
  let y = ry * calc.sin(tt)
  let rot = _rotate2((x, y), angle)
  (center.at(0) + rot.at(0), center.at(1) + rot.at(1), center.at(2, default: 0))
}

/// Foci of an ellipse
/// Returns (F1, F2)
#let ellipse-foci-raw(center, rx, ry, angle: 0deg) = {
  let a = if rx >= ry { rx } else { ry }
  let b = if rx >= ry { ry } else { rx }
  let c = calc.sqrt(calc.max(0, a * a - b * b))
  let local1 = if rx >= ry { (c, 0) } else { (0, c) }
  let local2 = if rx >= ry { (-c, 0) } else { (0, -c) }
  let rot1 = _rotate2(local1, angle)
  let rot2 = _rotate2(local2, angle)
  (
    (center.at(0) + rot1.at(0), center.at(1) + rot1.at(1), center.at(2, default: 0)),
    (center.at(0) + rot2.at(0), center.at(1) + rot2.at(1), center.at(2, default: 0)),
  )
}

/// Point on ellipse for a direction from center
/// If from-center is true, theta is the ray direction angle
#let ellipse-angpoint-raw(center, rx, ry, angle: 0deg, theta: 0deg, from-center: false) = {
  if not from-center {
    return ellipse-point-raw(center, rx, ry, angle: angle, t: theta)
  }
  let th = if type(theta) == type(0deg) { theta } else { theta * 1deg }
  let dir = (calc.cos(th), calc.sin(th))
  let local = _rotate2(dir, -angle)
  let denom = (local.at(0) * local.at(0)) / (rx * rx) + (local.at(1) * local.at(1)) / (ry * ry)
  if denom <= util.eps { return center }
  let s = 1 / calc.sqrt(denom)
  let local-pt = (local.at(0) * s, local.at(1) * s)
  let world = _rotate2(local-pt, angle)
  (center.at(0) + world.at(0), center.at(1) + world.at(1), center.at(2, default: 0))
}

/// Relative point on ellipse (0..1 maps to 0..360deg)
#let ellipse-relpoint-raw(center, rx, ry, t, angle: 0deg) = {
  let tt = t * 360deg
  ellipse-point-raw(center, rx, ry, angle: angle, t: tt)
}

/// Tangent line at ellipse parameter t
/// Returns (p1, p2, pt)
#let ellipse-tangent-raw(center, rx, ry, angle: 0deg, t: 0deg, length: auto) = {
  let pt = ellipse-point-raw(center, rx, ry, angle: angle, t: t)
  let tt = if type(t) == type(0deg) { t } else { t * 1deg }
  let dir = (-rx * calc.sin(tt), ry * calc.cos(tt))
  let dir-rot = _rotate2(dir, angle)
  let udir = _unit2(dir-rot)
  let len = if length == auto { calc.max(rx, ry) } else { length }
  let p1 = (pt.at(0) - udir.at(0) * len, pt.at(1) - udir.at(1) * len, pt.at(2))
  let p2 = (pt.at(0) + udir.at(0) * len, pt.at(1) + udir.at(1) * len, pt.at(2))
  (p1, p2, pt)
}

/// Sample points on an ellipse
/// - center: (x, y, z)
/// - rx, ry: radii
/// - angle: rotation angle (deg)
/// - steps: number of segments
#let ellipse-points-raw(center, rx, ry, angle: 0deg, steps: 120) = {
  let pts = ()
  let rot = if type(angle) == type(0deg) { angle } else { angle * 1deg }
  for i in range(0, steps + 1) {
    let t = i * 360deg / steps
    let x = rx * calc.cos(t)
    let y = ry * calc.sin(t)
    let p = (center.at(0) + x, center.at(1) + y, center.at(2, default: 0))
    if rot != 0deg {
      p = util.rotate-point(p, center, rot)
    }
    pts.push(p)
  }
  pts
}

/// Sample points on a parabola defined by focus and directrix line
/// - focus: (x, y, z)
/// - directrix-a, directrix-b: two points on the directrix
/// - extent: half-width along directrix direction
/// - steps: number of segments
#let parabola-points-focus-directrix-raw(focus, directrix-a, directrix-b, extent: auto, steps: 120) = {
  let foot = util.project-point-on-line(focus, directrix-a, directrix-b)
  let d = util.dist(focus, foot)
  if d < util.eps {
    return ()
  }

  let u = _unit2((focus.at(0) - foot.at(0), focus.at(1) - foot.at(1)))
  let v = _perp2(u)
  let ext = if extent == auto { d * 3 } else { extent }

  let pts = ()
  for i in range(0, steps + 1) {
    let t = -ext + (2 * ext) * i / steps
    let x = (t * t + d * d) / (2 * d)
    let px = foot.at(0) + u.at(0) * x + v.at(0) * t
    let py = foot.at(1) + u.at(1) * x + v.at(1) * t
    pts.push((px, py, focus.at(2, default: 0)))
  }
  pts
}

/// Parabola points from focus, p, angle (Asymptote-like)
/// p: distance from vertex to focus
/// angle: opening direction
#let parabola-points-from-focus-raw(focus, p, angle: 0deg, extent: auto, steps: 120) = {
  let ang = if type(angle) == type(0deg) { angle } else { angle * 1deg }
  let ax = (calc.cos(ang), calc.sin(ang))
  let perp = (-ax.at(1), ax.at(0))

  // Vertex and directrix (distance p behind focus, then another p to directrix)
  let V = (focus.at(0) - p * ax.at(0), focus.at(1) - p * ax.at(1))
  let D0 = (focus.at(0) - 2 * p * ax.at(0), focus.at(1) - 2 * p * ax.at(1))
  let D1 = (D0.at(0) - 10 * perp.at(0), D0.at(1) - 10 * perp.at(1))
  let D2 = (D0.at(0) + 10 * perp.at(0), D0.at(1) + 10 * perp.at(1))

  parabola-points-focus-directrix-raw(focus, D1, D2, extent: extent, steps: steps)
}

/// Directrix endpoints and vertex for a parabola (focus, p, angle)
/// Returns (D1, D2, V)
#let parabola-directrix-raw(focus, p, angle: 0deg) = {
  let ang = if type(angle) == type(0deg) { angle } else { angle * 1deg }
  let ax = (calc.cos(ang), calc.sin(ang))
  let perp = (-ax.at(1), ax.at(0))
  let V = (focus.at(0) - p * ax.at(0), focus.at(1) - p * ax.at(1))
  let D0 = (focus.at(0) - 2 * p * ax.at(0), focus.at(1) - 2 * p * ax.at(1))
  let D1 = (D0.at(0) - 10 * perp.at(0), D0.at(1) - 10 * perp.at(1))
  let D2 = (D0.at(0) + 10 * perp.at(0), D0.at(1) + 10 * perp.at(1))
  (D1, D2, V)
}

/// Internal parabola frame (foot, u, v, d)
#let _parabola-frame-raw(focus, directrix-a, directrix-b) = {
  let foot = util.project-point-on-line(focus, directrix-a, directrix-b)
  let d = util.dist(focus, foot)
  if d < util.eps {
    return none
  }
  let u = _unit2((focus.at(0) - foot.at(0), focus.at(1) - foot.at(1)))
  let v = _perp2(u)
  (foot, u, v, d)
}

/// Point on parabola (focus/directrix) for parameter t (along directrix direction)
#let parabola-point-raw(focus, directrix-a, directrix-b, t) = {
  let frame = _parabola-frame-raw(focus, directrix-a, directrix-b)
  if frame == none { return none }
  let (foot, u, v, d) = frame
  let x = (t * t + d * d) / (2 * d)
  let px = foot.at(0) + u.at(0) * x + v.at(0) * t
  let py = foot.at(1) + u.at(1) * x + v.at(1) * t
  (px, py, focus.at(2, default: 0))
}

/// Tangent at parameter t on parabola
/// Returns (p1, p2, pt)
#let parabola-tangent-raw(focus, directrix-a, directrix-b, t, length: auto) = {
  let frame = _parabola-frame-raw(focus, directrix-a, directrix-b)
  if frame == none { return none }
  let (foot, u, v, d) = frame
  let pt = parabola-point-raw(focus, directrix-a, directrix-b, t)
  let dir = (u.at(0) * (t / d) + v.at(0), u.at(1) * (t / d) + v.at(1))
  let udir = _unit2(dir)
  let len = if length == auto { d * 2 } else { length }
  let p1 = (pt.at(0) - udir.at(0) * len, pt.at(1) - udir.at(1) * len, pt.at(2))
  let p2 = (pt.at(0) + udir.at(0) * len, pt.at(1) + udir.at(1) * len, pt.at(2))
  (p1, p2, pt)
}

/// Tangents from an external point to the parabola (focus/directrix)
/// Returns ( (p1, p2, tpt), ... )
#let parabola-tangents-from-point-raw(focus, directrix-a, directrix-b, external, length: auto) = {
  let frame = _parabola-frame-raw(focus, directrix-a, directrix-b)
  if frame == none { return () }
  let (foot, u, v, d) = frame

  let rel = (external.at(0) - foot.at(0), external.at(1) - foot.at(1))
  let x0 = _dot2(rel, u)
  let y0 = _dot2(rel, v)

  let A = (-2 * x0 + d)
  let B = 2 * y0
  let C = -d

  let slopes = ()
  if calc.abs(A) < util.eps {
    if calc.abs(B) < util.eps {
      slopes = ()
    } else {
      slopes = (-C / B,)
    }
  } else {
    let disc = B * B - 4 * A * C
    if disc >= 0 {
      let root = calc.sqrt(disc)
      slopes = ((-B + root) / (2 * A), (-B - root) / (2 * A))
    }
  }

  let results = ()
  for m in slopes {
    let b = y0 - m * x0
    let tpt = if calc.abs(m) < util.eps and calc.abs(b) < util.eps {
      // Vertex tangent
      let x = d / 2
      let y = 0
      let px = foot.at(0) + u.at(0) * x + v.at(0) * y
      let py = foot.at(1) + u.at(1) * x + v.at(1) * y
      (px, py, external.at(2, default: 0))
    } else {
      let x = (d - m * b) / (m * m)
      let y = m * x + b
      let px = foot.at(0) + u.at(0) * x + v.at(0) * y
      let py = foot.at(1) + u.at(1) * x + v.at(1) * y
      (px, py, external.at(2, default: 0))
    }

    // Direction from external point to tangent point
    let dir = (tpt.at(0) - external.at(0), tpt.at(1) - external.at(1))
    let udir = _unit2(dir)
    let len = if length == auto { d * 2 } else { length }

    // Line passes through both external and tpt, extend in both directions
    let p1 = (external.at(0) - udir.at(0) * len, external.at(1) - udir.at(1) * len, external.at(2, default: 0))
    let p2 = (tpt.at(0) + udir.at(0) * len, tpt.at(1) + udir.at(1) * len, tpt.at(2, default: 0))

    results.push((p1, p2, tpt))
  }

  results
}

/// Compute time range for projectile
#let projectile-time-max-raw(origin, velocity, gravity, t-max: auto, y-floor: none) = {
  if t-max != auto {
    return t-max
  }

  let y0 = origin.at(1)
  let vy = velocity.at(1)
  let g = gravity

  if y-floor != none and g != 0 {
    let a = 0.5 * g
    let b = -vy
    let c = y-floor - y0
    let disc = b * b - 4 * a * c
    if disc >= 0 {
      let root = calc.sqrt(disc)
      let t1 = (-b + root) / (2 * a)
      let t2 = (-b - root) / (2 * a)
      let t = calc.max(t1, t2)
      if t > 0 {
        return t
      }
    }
  }

  if g != 0 and vy > 0 {
    return 2 * vy / g
  }

  1
}

/// Projectile position at time t
#let projectile-position-raw(origin, velocity, gravity, t) = {
  (
    origin.at(0) + velocity.at(0) * t,
    origin.at(1) + velocity.at(1) * t - 0.5 * gravity * t * t,
    origin.at(2, default: 0),
  )
}

/// Projectile velocity at time t
#let projectile-velocity-raw(velocity, gravity, t) = {
  (
    velocity.at(0),
    velocity.at(1) - gravity * t,
    0,
  )
}

/// Sample points on a projectile trajectory
#let projectile-points-raw(origin, velocity, gravity, t-max, steps: 80, y-floor: none) = {
  let t-end = projectile-time-max-raw(origin, velocity, gravity, t-max: t-max, y-floor: y-floor)
  let pts = ()
  for i in range(0, steps + 1) {
    let t = t-end * i / steps
    pts.push(projectile-position-raw(origin, velocity, gravity, t))
  }
  (pts, t-end)
}
