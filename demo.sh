#!/bin/bash

# Demo script to showcase the new build argument architecture
# This script demonstrates how flexible the new structure is

set -e

echo "🐳 PHP Docker Images - Build Arguments Demo"
echo "==========================================="
echo ""

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Available PHP Versions: 8.2, 8.3, 8.4${NC}"
echo -e "${BLUE}📦 Available Variants: swoole, frankenphp${NC}"
echo ""

echo -e "${YELLOW}🏗 Build Command Examples:${NC}"
echo ""

echo -e "${GREEN}1. Traditional approach (using our scripts):${NC}"
echo "   ./scripts/build.sh 8.3 swoole alpine"
echo "   ./scripts/build.sh 8.4 swoole alpine"
echo ""

echo -e "${GREEN}2. Direct Docker commands (using build args):${NC}"
echo "   docker build --build-arg PHP_VERSION=8.3 -t my-php-swoole:8.3 -f swoole/Dockerfile ."
echo "   docker build --build-arg PHP_VERSION=8.2 -t my-php-swoole:8.2 -f swoole/Dockerfile ."
echo "   docker build --build-arg PHP_VERSION=8.4 -t my-php-frankenphp:8.4 -f frankenphp/Dockerfile ."
echo ""

echo -e "${GREEN}3. Multi-platform builds:${NC}"
echo "   docker buildx build --platform linux/amd64,linux/arm64 \\"
echo "     --build-arg PHP_VERSION=8.3 \\"
echo "     -t my-php-swoole:8.3 \\"
echo "     -f swoole/Dockerfile ."
echo ""

echo -e "${GREEN}4. Docker Compose with build args:${NC}"
cat << 'EOF'
   services:
     app:
       build:
         context: .
         dockerfile: swoole/Dockerfile
         args:
           PHP_VERSION: 8.3
EOF
echo ""

echo -e "${YELLOW}🎯 Benefits of the new structure:${NC}"
echo "   ✅ Single Dockerfile per variant (was 3 files each)"
echo "   ✅ Easy to add new PHP versions"
echo "   ✅ Consistent build process"
echo "   ✅ Better cache utilization"
echo "   ✅ Simplified CI/CD pipelines"
echo ""

echo -e "${YELLOW}📁 New directory structure:${NC}"
echo "   swoole/Dockerfile     (unified Dockerfile)"
echo "   frankenphp/Dockerfile (unified Dockerfile)"
echo ""

echo -e "${BLUE}🚀 Try it yourself:${NC}"
echo "   make build VERSION=8.3 VARIANT=swoole"
echo "   make test VERSION=8.3 VARIANT=swoole"
echo ""

echo -e "${GREEN}✨ Refactoring completed successfully!${NC}"
