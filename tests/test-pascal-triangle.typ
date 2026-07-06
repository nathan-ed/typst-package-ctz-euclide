// Test: Pascal's Triangle using ctz-euclide declarative helpers
#import "@preview/cetz:0.5.2" as cetz
#import "../src/lib.typ" as euclide
#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.8cm)

// === Configuration ===
#let rows = 8
#let h-spacing = 1.48
#let v-spacing = 1.13

// === Colors ===
#let colors = (
  label: rgb("#5B9BD5"),
  diagonal: rgb("#D0D8E0"),
  highlight-green: rgb("#70AD47"),
  highlight-red: rgb("#FFC0CB"),
  annotation: rgb("#C00000"),
)

// === Drawing using ctz-euclide helpers ===
#cetz.canvas({
  import cetz.draw: *

  // --- Pascal's Triangle Values (using helper) ---
  draw-pascal-values(
    cetz.draw,
    rows,
    h-spacing: h-spacing,
    v-spacing: v-spacing,
    text-size: 12pt,
  )

  // --- Row Labels (using helper) ---
  draw-row-labels(
    cetz.draw,
    rows,
    h-spacing: h-spacing,
    v-spacing: v-spacing,
    offset: -1.5,
    text-size: 11pt,
    text-color: colors.label,
    format: n => $n = #n$,
  )

  // --- Diagonal Labels (using helper) ---
  draw-diagonal-labels(
    cetz.draw,
    rows,
    h-spacing: h-spacing,
    v-spacing: v-spacing,
    offset: (0.5, 0.5),
    text-size: 9pt,
    text-color: colors.diagonal.darken(20%),
    angle: 45deg,
    format: k => $arrow.l k = #k$,
  )

  // --- Highlights (using helpers) ---
  // Get positions using pascal-pos
  let pos-5-3 = triangular-pos(5, 3, h-spacing: h-spacing, v-spacing: v-spacing)
  let pos-4-2 = triangular-pos(4, 2, h-spacing: h-spacing, v-spacing: v-spacing)
  let pos-4-3 = triangular-pos(4, 3, h-spacing: h-spacing, v-spacing: v-spacing)

  // Filled highlight for (5, 3)
  highlight-fill(cetz.draw, pos-5-3, radius: 0.35, fill: colors.highlight-red)
  // Redraw the number on top
  content(pos-5-3, text(size: 12pt, str(binomial(5, 3))))

  // Outline highlights for (4, 2) and (4, 3)
  highlight-many(
    cetz.draw,
    (pos-4-2, pos-4-3),
    radius: 0.35,
    stroke: colors.highlight-green + 1.5pt,
  )

  // --- Addition Indicator (using helper) ---
  draw-addition-indicator(
    cetz.draw,
    pos-4-2,
    pos-4-3,
    pos-5-3,
    color: colors.highlight-green,
  )

  // --- Binomial Annotation (using helper) ---
  let annotation-pos = (5.2, -2.9 * v-spacing)

  smooth-arrow(
    cetz.draw,
    (pos-5-3.at(0) + 0.45, pos-5-3.at(1)),
    (annotation-pos.at(0) - 0.8, annotation-pos.at(1) - 0.45),
    waypoints: (
      (pos-5-3.at(0) + 1.05, pos-5-3.at(1) - 0.5),
      (pos-5-3.at(0) + 1.85, pos-5-3.at(1) - 0.1),
    ),
    stroke: colors.annotation + 1pt,
    mark: (end: ">", fill: colors.annotation),
  )

  content(annotation-pos, text(size: 13pt, fill: colors.annotation, $ binom(5, 3) = 10 $))
})
