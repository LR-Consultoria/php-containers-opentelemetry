#!/bin/bash

# Build script for PHP Docker images
# Usage: ./scripts/build.sh <version> <variant> [tag_suffix]

set -e

# Default values
PHP_VERSION=""
VARIANT=""
TAG_SUFFIX=""
REGISTRY="ghcr.io/lrconsultoria"
BUILD_ARGS=""

# Help function
show_help() {
    cat << EOF
Usage: $0 <version> <variant> [tag_suffix]

Build Docker images for PHP projects.

Arguments:
  version       PHP version (8.2, 8.3, 8.4)
  variant       Image variant (fpm, swoole, nginx, frankenphp)
  tag_suffix    Optional tag suffix (default: alpine)

Examples:
  $0 8.3 fpm
  $0 8.3 swoole
  $0 8.3 nginx dev
  $0 8.4 frankenphp latest

Environment Variables:
  REGISTRY      Docker registry (default: ghcr.io/lrconsultoria)
  NO_CACHE      Set to 1 to disable build cache
  PUSH          Set to 1 to push image after build
  BUILDX        Set to 1 to use docker buildx for multi-platform builds

EOF
}

# Parse arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments"
    show_help
    exit 1
fi

PHP_VERSION=$1
VARIANT=$2
TAG_SUFFIX=${3:-alpine}

# Validate PHP version
case $PHP_VERSION in
    8.2|8.3|8.4)
        ;;
    *)
        echo "Error: Invalid PHP version '$PHP_VERSION'. Supported: 8.2, 8.3, 8.4"
        exit 1
        ;;
esac

# Validate variant
case $VARIANT in
    fpm|swoole|nginx|frankenphp)
        ;;
    *)
        echo "Error: Invalid variant '$VARIANT'. Supported: fpm, swoole, nginx, frankenphp"
        exit 1
        ;;
esac

# Set image names
if [ "$VARIANT" = "fpm" ]; then
    IMAGE_NAME="php-fpm"
else
    IMAGE_NAME="php-$VARIANT"
fi

TAG="$PHP_VERSION-$TAG_SUFFIX"
FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"

# Set dockerfile path
DOCKERFILE_PATH="$VARIANT/Dockerfile"

# Check if Dockerfile exists
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "Error: Dockerfile not found at $DOCKERFILE_PATH"
    exit 1
fi

# Build arguments
if [ "$NO_CACHE" = "1" ]; then
    BUILD_ARGS="$BUILD_ARGS --no-cache"
fi

if [ "$BUILDX" = "1" ]; then
    BUILD_ARGS="$BUILD_ARGS --platform linux/amd64,linux/arm64"
    BUILDER_CMD="docker buildx build"
else
    BUILDER_CMD="docker build"
fi

# Build command with PHP version argument
BUILD_CMD="$BUILDER_CMD $BUILD_ARGS --build-arg PHP_VERSION=$PHP_VERSION -t $FULL_IMAGE_NAME -f $DOCKERFILE_PATH ."

echo "Building image: $FULL_IMAGE_NAME"
echo "Command: $BUILD_CMD"
echo ""

# Execute build
eval $BUILD_CMD

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully built: $FULL_IMAGE_NAME"
    
    # Push if requested
    if [ "$PUSH" = "1" ]; then
        echo "🚀 Pushing image to registry..."
        if [ "$BUILDX" = "1" ]; then
            # Buildx already pushes with --push flag
            echo "Image pushed via buildx"
        else
            docker push "$FULL_IMAGE_NAME"
            echo "✅ Successfully pushed: $FULL_IMAGE_NAME"
        fi
    fi
    
    # Show image info
    if [ "$BUILDX" != "1" ]; then
        echo ""
        echo "📊 Image information:"
        docker images "$FULL_IMAGE_NAME" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
    fi
else
    echo "❌ Build failed for: $FULL_IMAGE_NAME"
    exit 1
fi
