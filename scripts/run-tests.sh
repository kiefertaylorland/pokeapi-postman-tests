#!/bin/bash

# Pokemon API Test Suite Runner
# Author: Your Name
# Description: Automated test execution script for Pokemon API test suite

set -e  # Exit on any error

echo "🚀 Pokemon API Test Suite"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 16+ to continue.${NC}"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed. Please install npm to continue.${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm run install-deps

echo ""
echo -e "${BLUE}🧪 Executing test suite...${NC}"
echo "⏱️  This may take 30-60 seconds depending on API response times"
echo ""

# Run the tests
if npm test; then
    echo ""
    echo -e "${GREEN}✅ All tests completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📄 Detailed HTML report generated at: reports/test-report.html${NC}"
    
    # Try to open the report automatically
    if command -v open &> /dev/null; then
        echo -e "${BLUE}🌐 Opening report in browser...${NC}"
        open reports/test-report.html
    elif command -v xdg-open &> /dev/null; then
        echo -e "${BLUE}🌐 Opening report in browser...${NC}"
        xdg-open reports/test-report.html
    else
        echo -e "${YELLOW}💡 Open reports/test-report.html in your browser to view detailed results${NC}"
    fi
else
    echo ""
    echo -e "${RED}❌ Some tests failed. Check the output above for details.${NC}"
    echo -e "${YELLOW}📄 Detailed report still available at: reports/test-report.html${NC}"
    exit 1
fi