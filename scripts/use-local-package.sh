#!/bin/bash
# Switch to using local package installation instead of direct src imports

set -e

echo "Updating imports to use @local/ctz-euclide:0.1.0..."

# Update /src/lib.typ imports
find docs tests -name "*.typ" -type f -exec sed -i 's|#import "/src/lib.typ": \*|#import "@local/ctz-euclide:0.1.0": *|g' {} \;
find docs tests -name "*.typ" -type f -exec sed -i 's|#import "\.\./src/lib.typ" as euclide|#import "@local/ctz-euclide:0.1.0" as euclide|g' {} \;

# Update /src/drawing.typ imports
find docs tests -name "*.typ" -type f -exec sed -i 's|import "/src/drawing.typ"|import "@local/ctz-euclide:0.1.0/src/drawing.typ"|g' {} \;

# Update /src/conic.typ imports
find docs tests -name "*.typ" -type f -exec sed -i 's|import "/src/conic.typ"|import "@local/ctz-euclide:0.1.0/src/conic.typ"|g' {} \;

# Update /docs/helpers.typ imports in sections
find docs/sections -name "*.typ" -type f -exec sed -i 's|#import "/docs/helpers.typ"|#import "../helpers.typ"|g' {} \;

echo "Done! All imports updated to use local package."
echo ""
echo "Test compilation:"
echo "  typst compile docs/manual.typ docs/manual.pdf"
echo "  typst compile tests/test-pascal-triangle.typ"
