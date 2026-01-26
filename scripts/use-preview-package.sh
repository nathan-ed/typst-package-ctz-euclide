#!/bin/bash
# Switch to using @preview package (for deployment/publishing)

set -e

echo "Updating imports to use @preview/ctz-euclide:0.1.0..."

# Update to @preview
find docs tests -name "*.typ" -type f -exec sed -i 's|@local/ctz-euclide:0.1.0|@preview/ctz-euclide:0.1.0|g' {} \;

echo "Done! All imports updated to use @preview package."
echo ""
echo "NOTE: Make sure the package is published to @preview before using these files!"
