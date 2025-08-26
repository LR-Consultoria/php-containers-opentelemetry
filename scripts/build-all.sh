#!/bin/bash

# Build all PHP Docker images
# Usage: ./scripts/build-all.sh [tag_suffix]

set -e

# Configuration
PHP_VERSIONS=("8.2" "8.3" "8.4")
VARIANTS=("base" "swoole" "nginx" "frankenphp")
TAG_SUFFIX=${1:-alpine}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPT="$SCRIPT_DIR/build.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_BUILDS=$((${#PHP_VERSIONS[@]} * ${#VARIANTS[@]}))
CURRENT_BUILD=0
FAILED_BUILDS=()
SUCCESS_BUILDS=()

echo -e "${BLUE}🐳 Building all PHP Docker images${NC}"
echo -e "${BLUE}Total builds: $TOTAL_BUILDS${NC}"
echo ""

# Check if build script exists
if [ ! -f "$BUILD_SCRIPT" ]; then
    echo -e "${RED}❌ Build script not found at: $BUILD_SCRIPT${NC}"
    exit 1
fi

# Make build script executable
chmod +x "$BUILD_SCRIPT"

# Build all combinations
for version in "${PHP_VERSIONS[@]}"; do
    for variant in "${VARIANTS[@]}"; do
        CURRENT_BUILD=$((CURRENT_BUILD + 1))
        IMAGE_NAME="php-$variant"
        if [ "$variant" = "base" ]; then
            IMAGE_NAME="php-base"
        fi
        
        echo -e "${YELLOW}📦 Building $CURRENT_BUILD/$TOTAL_BUILDS: $IMAGE_NAME:$version-$TAG_SUFFIX${NC}"
        echo "----------------------------------------"
        
        # Run build script
        if "$BUILD_SCRIPT" "$version" "$variant" "$TAG_SUFFIX"; then
            SUCCESS_BUILDS+=("$IMAGE_NAME:$version-$TAG_SUFFIX")
            echo -e "${GREEN}✅ Success: $IMAGE_NAME:$version-$TAG_SUFFIX${NC}"
        else
            FAILED_BUILDS+=("$IMAGE_NAME:$version-$TAG_SUFFIX")
            echo -e "${RED}❌ Failed: $IMAGE_NAME:$version-$TAG_SUFFIX${NC}"
        fi
        
        echo ""
        echo "========================================"
        echo ""
    done
done

# Summary
echo -e "${BLUE}📊 Build Summary${NC}"
echo "========================================"
echo -e "${GREEN}✅ Successful builds: ${#SUCCESS_BUILDS[@]}${NC}"
if [ ${#SUCCESS_BUILDS[@]} -gt 0 ]; then
    for build in "${SUCCESS_BUILDS[@]}"; do
        echo -e "   ${GREEN}• $build${NC}"
    done
fi

echo ""
echo -e "${RED}❌ Failed builds: ${#FAILED_BUILDS[@]}${NC}"
if [ ${#FAILED_BUILDS[@]} -gt 0 ]; then
    for build in "${FAILED_BUILDS[@]}"; do
        echo -e "   ${RED}• $build${NC}"
    done
fi

echo ""
if [ ${#FAILED_BUILDS[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All builds completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some builds failed. Check the output above for details.${NC}"
    exit 1
fi
