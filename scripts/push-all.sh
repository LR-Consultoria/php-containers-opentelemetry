#!/bin/bash

# Push all built PHP Docker images to registry
# Usage: ./scripts/push-all.sh [tag_suffix]

set -e

# Configuration
PHP_VERSIONS=("8.2" "8.3" "8.4")
VARIANTS=("base" "swoole" "nginx" "franken")
TAG_SUFFIX=${1:-alpine}
REGISTRY=${REGISTRY:-ghcr.io/lrconsultoria}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_PUSHES=$((${#PHP_VERSIONS[@]} * ${#VARIANTS[@]}))
CURRENT_PUSH=0
FAILED_PUSHES=()
SUCCESS_PUSHES=()

echo -e "${BLUE}🚀 Pushing all PHP Docker images to $REGISTRY${NC}"
echo -e "${BLUE}Total pushes: $TOTAL_PUSHES${NC}"
echo ""

# Function to check if image exists locally
image_exists() {
    docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$1$"
}

# Push all combinations
for version in "${PHP_VERSIONS[@]}"; do
    for variant in "${VARIANTS[@]}"; do
        CURRENT_PUSH=$((CURRENT_PUSH + 1))
        
        # Set image names
        if [ "$variant" = "base" ]; then
            IMAGE_NAME="php-base"
        else
            IMAGE_NAME="php-$variant"
        fi
        
        TAG="$version-$TAG_SUFFIX"
        FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"
        
        echo -e "${YELLOW}📤 Pushing $CURRENT_PUSH/$TOTAL_PUSHES: $FULL_IMAGE_NAME${NC}"
        
        # Check if image exists locally
        if ! image_exists "$FULL_IMAGE_NAME"; then
            echo -e "${RED}❌ Image not found locally: $FULL_IMAGE_NAME${NC}"
            FAILED_PUSHES+=("$FULL_IMAGE_NAME")
            echo ""
            continue
        fi
        
        # Push image
        if docker push "$FULL_IMAGE_NAME"; then
            SUCCESS_PUSHES+=("$FULL_IMAGE_NAME")
            echo -e "${GREEN}✅ Success: $FULL_IMAGE_NAME${NC}"
        else
            FAILED_PUSHES+=("$FULL_IMAGE_NAME")
            echo -e "${RED}❌ Failed: $FULL_IMAGE_NAME${NC}"
        fi
        
        echo ""
        echo "========================================"
        echo ""
    done
done

# Summary
echo -e "${BLUE}📊 Push Summary${NC}"
echo "========================================"
echo -e "${GREEN}✅ Successful pushes: ${#SUCCESS_PUSHES[@]}${NC}"
if [ ${#SUCCESS_PUSHES[@]} -gt 0 ]; then
    for push in "${SUCCESS_PUSHES[@]}"; do
        echo -e "   ${GREEN}• $push${NC}"
    done
fi

echo ""
echo -e "${RED}❌ Failed pushes: ${#FAILED_PUSHES[@]}${NC}"
if [ ${#FAILED_PUSHES[@]} -gt 0 ]; then
    for push in "${FAILED_PUSHES[@]}"; do
        echo -e "   ${RED}• $push${NC}"
    done
fi

echo ""
if [ ${#FAILED_PUSHES[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All pushes completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some pushes failed. Check the output above for details.${NC}"
    exit 1
fi
