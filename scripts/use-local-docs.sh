#!/bin/bash
# Switch docs/gallery to use local package (tests remain with direct imports)

set -e

echo "Updating docs to use @local/ctz-euclide:0.1.0..."

# Update main lib imports in docs
find docs -name "*.typ" -type f -exec sed -i 's|#import "/src/lib.typ": \*|#import "@local/ctz-euclide:0.1.0": *|g' {} \;

# Update submodule imports (conic, drawing)
# Package format: @local/ctz-euclide:0.1.0/conic (NO .typ extension!)
find docs -name "*.typ" -type f -exec sed -i 's|import "/src/conic.typ"|import "@local/ctz-euclide:0.1.0/conic"|g' {} \;
find docs -name "*.typ" -type f -exec sed -i 's|import "/src/drawing.typ"|import "@local/ctz-euclide:0.1.0/drawing"|g' {} \;

# Update helpers.typ path in sections
find docs/sections -name "*.typ" -type f -exec sed -i 's|#import "/docs/helpers.typ"|#import "../helpers.typ"|g' {} \;

echo "Done! Docs updated to use local package."
echo ""
echo "Test compilation:"
echo "  typst compile docs/manual.typ docs/manual.pdf"
