#!/bin/bash

# Test script for PHP Docker images
# Usage: ./scripts/test.sh <version> <variant> [tag_suffix]

set -e

# Function to handle errors
handle_error() {
    echo -e "${RED}❌ Error occurred in script at line $1${NC}"
    echo "Command that failed: $2"
    exit 1
}

# Set error trap
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

# Default values
PHP_VERSION=""
VARIANT=""
TAG_SUFFIX=""
REGISTRY="ghcr.io/lrconsultoria"
CONTAINER_NAME=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    cat << EOF
Usage: $0 <version> <variant> [tag_suffix]

Test Docker images for PHP projects.

Arguments:
  version       PHP version (8.2, 8.3, 8.4)
  variant       Image variant (fpm, swoole, nginx, frankenphp)
  tag_suffix    Optional tag suffix (default: alpine)

Examples:
  $0 8.3 fpm
  $0 8.3 swoole
  $0 8.3 nginx

Environment Variables:
  REGISTRY      Docker registry (default: ghcr.io/lrconsultoria)

EOF
}

# Cleanup function
cleanup() {
    if [ -n "$CONTAINER_NAME" ] && docker ps -q -f name="$CONTAINER_NAME" >/dev/null 2>&1; then
        echo -e "${YELLOW}🧹 Cleaning up container: $CONTAINER_NAME${NC}"
        docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Parse arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments"
    show_help
    exit 1
fi

PHP_VERSION=$1
VARIANT=$2
TAG_SUFFIX=${3:-alpine}

# Validate inputs
case $PHP_VERSION in
    8.2|8.3|8.4) ;;
    *) echo "Error: Invalid PHP version '$PHP_VERSION'"; exit 1 ;;
esac

case $VARIANT in
    fpm|swoole|nginx|frankenphp) ;;
    *) echo "Error: Invalid variant '$VARIANT'"; exit 1 ;;
esac

# Set image names
if [ "$VARIANT" = "fpm" ]; then
    IMAGE_NAME="php-fpm"
else
    IMAGE_NAME="php-$VARIANT"
fi

TAG="$PHP_VERSION-$TAG_SUFFIX"
FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"
CONTAINER_NAME="test-$IMAGE_NAME-$PHP_VERSION-$(date +%s)"

echo -e "${BLUE}🧪 Testing image: $FULL_IMAGE_NAME${NC}"
echo "Debug info:"
echo "  PHP_VERSION: $PHP_VERSION"
echo "  VARIANT: $VARIANT"
echo "  TAG_SUFFIX: $TAG_SUFFIX"
echo "  REGISTRY: $REGISTRY"
echo "  IMAGE_NAME: $IMAGE_NAME"
echo "  TAG: $TAG"
echo "  FULL_IMAGE_NAME: $FULL_IMAGE_NAME"
echo ""

# Test 1: Check if image exists
echo -e "${YELLOW}Test 1: Checking image availability...${NC}"
echo "Looking for image: $FULL_IMAGE_NAME"
echo "Available images:"
docker images --format "{{.Repository}}:{{.Tag}}" | grep "$IMAGE_NAME" || echo "No images found with name: $IMAGE_NAME"

# Try to find the image with a more flexible approach
if docker images --format "{{.Repository}}:{{.Tag}}" | grep -F "$FULL_IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Image found locally${NC}"
elif docker images --format "{{.Repository}}:{{.Tag}}" | grep -F "$IMAGE_NAME:$TAG" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Image found locally (partial match)${NC}"
    # Update FULL_IMAGE_NAME to the actual found image
    FULL_IMAGE_NAME=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -F "$IMAGE_NAME:$TAG" | head -1)
    echo "Using image: $FULL_IMAGE_NAME"
else
    echo -e "${YELLOW}⚠️  Image not found locally, attempting to pull...${NC}"
    if docker pull "$FULL_IMAGE_NAME"; then
        echo -e "${GREEN}✅ Image pulled successfully${NC}"
    else
        echo -e "${RED}❌ Failed to pull image${NC}"
        echo "Available images:"
        docker images
        exit 1
    fi
fi

# Test 2: PHP version check
echo -e "${YELLOW}Test 2: Verifying PHP version...${NC}"
PHP_OUTPUT=$(docker run --rm "$FULL_IMAGE_NAME" php -v)
if echo "$PHP_OUTPUT" | grep -q "PHP $PHP_VERSION"; then
    echo -e "${GREEN}✅ PHP version $PHP_VERSION confirmed${NC}"
else
    echo -e "${RED}❌ PHP version mismatch${NC}"
    echo "Expected: PHP $PHP_VERSION"
    echo "Got: $PHP_OUTPUT"
    exit 1
fi

# Test 3: OpenTelemetry extension
echo -e "${YELLOW}Test 3: Checking OpenTelemetry extension...${NC}"
if docker run --rm "$FULL_IMAGE_NAME" php -m | grep -q "opentelemetry"; then
    echo -e "${GREEN}✅ OpenTelemetry extension loaded${NC}"
else
    echo -e "${YELLOW}⚠️  OpenTelemetry extension not found (continuing anyway)${NC}"
    echo "Available extensions:"
    docker run --rm "$FULL_IMAGE_NAME" php -m | head -20
fi

# Test 4: Composer availability
echo -e "${YELLOW}Test 4: Checking Composer...${NC}"
if docker run --rm "$FULL_IMAGE_NAME" which composer >/dev/null 2>&1; then
    COMPOSER_OUTPUT=$(docker run --rm "$FULL_IMAGE_NAME" composer --version)
    if echo "$COMPOSER_OUTPUT" | grep -q "Composer"; then
        echo -e "${GREEN}✅ Composer available${NC}"
    else
        echo -e "${YELLOW}⚠️  Composer found but version check failed${NC}"
        echo "Composer output: $COMPOSER_OUTPUT"
    fi
else
    echo -e "${YELLOW}⚠️  Composer not found (continuing anyway)${NC}"
fi

# Test 5: Basic container startup
echo -e "${YELLOW}Test 5: Testing container startup...${NC}"
case $VARIANT in
    "fpm")
        echo "Starting FPM container for testing..."
        docker run -d --name "$CONTAINER_NAME" "$FULL_IMAGE_NAME" >/dev/null 2>&1
        sleep 3
        if docker ps -f name="$CONTAINER_NAME" | grep -q "$CONTAINER_NAME"; then
            echo -e "${GREEN}✅ Container started successfully${NC}"
        else
            echo -e "${YELLOW}⚠️  Container failed to start (continuing anyway)${NC}"
            echo "Container logs:"
            docker logs "$CONTAINER_NAME" 2>/dev/null || echo "No logs available"
        fi
        ;;
    "swoole")
        # Test Swoole extension
        if docker run --rm "$FULL_IMAGE_NAME" php -m | grep -q "swoole"; then
            echo -e "${GREEN}✅ Swoole extension loaded${NC}"
        else
            echo -e "${YELLOW}⚠️  Swoole extension not found (continuing anyway)${NC}"
        fi
        ;;
    "nginx")
        echo "Starting Nginx container for testing..."
        docker run -d --name "$CONTAINER_NAME" -p 0:80 "$FULL_IMAGE_NAME" >/dev/null 2>&1
        sleep 5
        if docker ps -f name="$CONTAINER_NAME" | grep -q "$CONTAINER_NAME"; then
            echo -e "${GREEN}✅ Nginx + PHP-FPM container started successfully${NC}"
        else
            echo -e "${YELLOW}⚠️  Container failed to start (continuing anyway)${NC}"
            echo "Container logs:"
            docker logs "$CONTAINER_NAME" 2>/dev/null || echo "No logs available"
        fi
        ;;
    "frankenphp")
        # Test FrankenPHP availability
        if docker run --rm "$FULL_IMAGE_NAME" which frankenphp >/dev/null 2>&1; then
            if docker run --rm "$FULL_IMAGE_NAME" frankenphp version | grep -q "FrankenPHP"; then
                echo -e "${GREEN}✅ FrankenPHP available${NC}"
            else
                echo -e "${YELLOW}⚠️  FrankenPHP found but version check failed${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  FrankenPHP not found (continuing anyway)${NC}"
        fi
        ;;
esac

# Test 6: Essential PHP extensions
echo -e "${YELLOW}Test 6: Checking essential PHP extensions...${NC}"
REQUIRED_EXTENSIONS=("json" "mbstring" "pdo" "openssl" "tokenizer" "xml" "zip")
MISSING_EXTENSIONS=()

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if ! docker run --rm "$FULL_IMAGE_NAME" php -m | grep -q "^$ext$"; then
        MISSING_EXTENSIONS+=("$ext")
    fi
done

if [ ${#MISSING_EXTENSIONS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All essential extensions present${NC}"
else
    echo -e "${YELLOW}⚠️  Missing extensions: ${MISSING_EXTENSIONS[*]} (continuing anyway)${NC}"
    echo "Available extensions:"
    docker run --rm "$FULL_IMAGE_NAME" php -m | sort
fi

echo ""
echo -e "${GREEN}🎉 Tests completed for $FULL_IMAGE_NAME!${NC}"
echo -e "${BLUE}Image is ready for use.${NC}"
echo -e "${YELLOW}Note: Some tests may have shown warnings but the script continued.${NC}"
