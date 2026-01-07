#!/bin/sh
# Script to replace hardcoded API URLs in built JavaScript files
# This runs after the build to fix any hardcoded HTTP URLs

echo "Fixing API URLs in built files..."

# Find all JavaScript files in the dist directory
find /usr/share/nginx/html -type f -name "*.js" | while read file; do
    # Replace HTTP port 8080 URLs with HTTPS port 443 (or relative path)
    sed -i 's|http://www\.trackmyexpenses\.in:8080|https://www.trackmyexpenses.in|g' "$file"
    sed -i 's|http://139\.59\.85\.102:8080|https://www.trackmyexpenses.in|g' "$file"
    sed -i 's|http://localhost:8080|/api|g' "$file"
    
    # Also replace any hardcoded HTTP URLs to HTTPS
    sed -i 's|http://www\.trackmyexpenses\.in/api|https://www.trackmyexpenses.in/api|g' "$file"
    sed -i 's|http://139\.59\.85\.102/api|https://www.trackmyexpenses.in/api|g' "$file"
done

echo "API URLs fixed!"

