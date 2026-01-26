#!/bin/bash
# Switch back to direct src imports (for development)

set -e

echo "Restoring direct src imports for development..."

# Restore /src/lib.typ imports
find docs tests -name "*.typ" -type f -exec sed -i 's|#import "@local/ctz-euclide:0.1.0": \*|#import "/src/lib.typ": *|g' {} \;
find docs tests -name "*.typ" -type f -exec sed -i 's|#import "@preview/ctz-euclide:0.1.0": \*|#import "/src/lib.typ": *|g' {} \;
find docs tests -name "*.typ" -type f -exec sed -i 's|#import "@local/ctz-euclide:0.1.0" as euclide|#import "../src/lib.typ" as euclide|g' {} \;
find docs tests -name "*.typ" -type f -exec sed -i 's|#import "@preview/ctz-euclide:0.1.0" as euclide|#import "../src/lib.typ" as euclide|g' {} \;

# Restore /src/drawing.typ imports
find docs tests -name "*.typ" -type f -exec sed -i 's|import "@local/ctz-euclide:0.1.0/src/drawing.typ"|import "/src/drawing.typ"|g' {} \;
find docs tests -name "*.typ" -type f -exec sed -i 's|import "@preview/ctz-euclide:0.1.0/src/drawing.typ"|import "/src/drawing.typ"|g' {} \;

# Restore /src/conic.typ imports
find docs tests -name "*.typ" -type f -exec sed -i 's|import "@local/ctz-euclide:0.1.0/src/conic.typ"|import "/src/conic.typ"|g' {} \;
find docs tests -name "*.typ" -type f -exec sed -i 's|import "@preview/ctz-euclide:0.1.0/src/conic.typ"|import "/src/conic.typ"|g' {} \;

# Restore /docs/helpers.typ imports in sections
find docs/sections -name "*.typ" -type f -exec sed -i 's|#import "\.\./helpers.typ"|#import "/docs/helpers.typ"|g' {} \;

echo "Done! Restored direct src imports for development."
echo ""
echo "Test compilation with --root flag:"
echo "  typst compile --root . docs/manual.typ docs/manual.pdf"
echo "  typst compile --root . tests/test-pascal-triangle.typ"
