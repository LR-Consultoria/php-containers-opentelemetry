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
echo -e "${BLUE}📦 Available Variants: fpm, swoole, nginx, frankenphp${NC}"
echo ""

echo -e "${YELLOW}🏗 Build Command Examples:${NC}"
echo ""

echo -e "${GREEN}1. Traditional approach (using our scripts):${NC}"
echo "   ./scripts/build.sh 8.3 fpm alpine"
echo "   ./scripts/build.sh 8.4 swoole alpine"
echo ""

echo -e "${GREEN}2. Direct Docker commands (using build args):${NC}"
echo "   docker build --build-arg PHP_VERSION=8.3 -t my-php-fpm:8.3 -f fpm/Dockerfile ."
echo "   docker build --build-arg PHP_VERSION=8.2 -t my-php-swoole:8.2 -f swoole/Dockerfile ."
echo "   docker build --build-arg PHP_VERSION=8.4 -t my-php-nginx:8.4 -f nginx/Dockerfile ."
echo ""

echo -e "${GREEN}3. Multi-platform builds:${NC}"
echo "   docker buildx build --platform linux/amd64,linux/arm64 \\"
echo "     --build-arg PHP_VERSION=8.3 \\"
echo "     -t my-php-fpm:8.3 \\"
echo "     -f fpm/Dockerfile ."
echo ""

echo -e "${GREEN}4. Docker Compose with build args:${NC}"
cat << 'EOF'
   services:
     app:
       build:
         context: .
         dockerfile: fpm/Dockerfile
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
echo "   fpm/Dockerfile     (was fpm/Dockerfile.8.2, Dockerfile.8.3, Dockerfile.8.4)"
echo "   swoole/Dockerfile   (was swoole/Dockerfile.8.2, Dockerfile.8.3, Dockerfile.8.4)"
echo "   nginx/Dockerfile    (was nginx/Dockerfile.8.2, Dockerfile.8.3, Dockerfile.8.4)"
echo "   frankenphp/Dockerfile  (was franken/Dockerfile.8.2, Dockerfile.8.3, Dockerfile.8.4)"
echo ""

echo -e "${BLUE}🚀 Try it yourself:${NC}"
echo "   make build VERSION=8.3 VARIANT=fpm"
echo "   make test VERSION=8.3 VARIANT=fpm"
echo ""

echo -e "${GREEN}✨ Refactoring completed successfully!${NC}"
