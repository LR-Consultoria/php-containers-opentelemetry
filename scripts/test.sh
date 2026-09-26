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
REGISTRY="${REGISTRY:-ghcr.io/lr-consultoria}"
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
  version       PHP version (8.2, 8.3, 8.4, 8.5)
  variant       Image variant (frankenphp)
  tag_suffix    Optional tag suffix (default: alpine)

Examples:
  $0 8.3 frankenphp

Environment Variables:
  REGISTRY      Docker registry (default: ghcr.io/lr-consultoria)

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
    8.2|8.3|8.4|8.5) ;;
    *) echo "Error: Invalid PHP version '$PHP_VERSION'"; exit 1 ;;
esac

case $VARIANT in
    frankenphp) ;;
    *) echo "Error: Invalid variant '$VARIANT'"; exit 1 ;;
esac

# Set image names
IMAGE_NAME="php-$VARIANT"

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
if docker image inspect "$FULL_IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Image found locally${NC}"
else
    echo -e "${YELLOW}⚠️  Image not found locally, attempting to pull...${NC}"
    if docker pull "$FULL_IMAGE_NAME"; then
        echo -e "${GREEN}✅ Image pulled successfully${NC}"
    else
        echo -e "${RED}❌ Failed to pull image${NC}"
        docker images
        exit 1
    fi
fi

# Test 2: PHP version check (required)
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

# Test 3: OpenTelemetry extension (required)
echo -e "${YELLOW}Test 3: Checking OpenTelemetry extension...${NC}"
if docker run --rm "$FULL_IMAGE_NAME" php -m | grep -qi "^opentelemetry$"; then
    echo -e "${GREEN}✅ OpenTelemetry extension loaded${NC}"
else
    echo -e "${RED}❌ OpenTelemetry extension not found${NC}"
    docker run --rm "$FULL_IMAGE_NAME" php -m | sort
    exit 1
fi

# Test 4: gRPC extension (required)
echo -e "${YELLOW}Test 4: Checking gRPC extension...${NC}"
if docker run --rm "$FULL_IMAGE_NAME" php -m | grep -qi "^grpc$"; then
    echo -e "${GREEN}✅ gRPC extension loaded${NC}"
else
    echo -e "${RED}❌ gRPC extension not found${NC}"
    docker run --rm "$FULL_IMAGE_NAME" php -m | sort
    exit 1
fi

# Test 5: FrankenPHP binary (required)
echo -e "${YELLOW}Test 5: Checking FrankenPHP binary...${NC}"
if docker run --rm "$FULL_IMAGE_NAME" frankenphp version | grep -q "FrankenPHP"; then
    echo -e "${GREEN}✅ FrankenPHP available${NC}"
else
    echo -e "${RED}❌ FrankenPHP not available${NC}"
    exit 1
fi

# Test 6: Essential PHP extensions (required)
echo -e "${YELLOW}Test 6: Checking essential PHP extensions...${NC}"
# Only extensions guaranteed by the base image (dunglas/frankenphp) or installed
# by our Dockerfile. Everything else must be added by the consuming app.
REQUIRED_EXTENSIONS=("json" "mbstring" "pdo" "openssl" "tokenizer" "xml" "ctype" "curl")
MISSING_EXTENSIONS=()
INSTALLED_EXTENSIONS=$(docker run --rm "$FULL_IMAGE_NAME" php -m)

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if ! echo "$INSTALLED_EXTENSIONS" | grep -qi "^$ext$"; then
        MISSING_EXTENSIONS+=("$ext")
    fi
done

if [ ${#MISSING_EXTENSIONS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All essential extensions present${NC}"
else
    echo -e "${RED}❌ Missing extensions: ${MISSING_EXTENSIONS[*]}${NC}"
    echo "$INSTALLED_EXTENSIONS" | sort
    exit 1
fi

# Test 7: Composer availability (informational)
echo -e "${YELLOW}Test 7: Checking Composer...${NC}"
if docker run --rm "$FULL_IMAGE_NAME" which composer >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Composer available${NC}"
else
    echo -e "${YELLOW}⚠️  Composer not found (continuing anyway)${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Tests completed for $FULL_IMAGE_NAME!${NC}"
echo -e "${BLUE}Image is ready for use.${NC}"
