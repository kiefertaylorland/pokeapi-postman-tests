#!/bin/bash

# ========================================
# Pokemon API Test Suite Runner
# ========================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for better UX
ROCKET="🚀"
CHECK="✅"
CROSS="❌"
GEAR="⚙️"
REPORT="📊"
CLOCK="⏱️"
POKEMON="⚡"
FOLDER="📁"

echo -e "${BLUE}${ROCKET} Pokemon API Test Suite Runner${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}${CROSS} Error: package.json not found. Please run this script from the project root.${NC}"
    exit 1
fi

if [ ! -d "collections" ]; then
    echo -e "${RED}${CROSS} Error: collections directory not found. Please ensure your Postman collections are in the collections/ folder.${NC}"
    exit 1
fi

# Function to print section headers
print_section() {
    echo ""
    echo -e "${PURPLE}${1}${NC}"
    echo -e "${PURPLE}$(echo "$1" | sed 's/./─/g')${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies
install_dependencies() {
    print_section "${GEAR} Installing Dependencies"
    
    if ! command_exists npm; then
        echo -e "${RED}${CROSS} npm not found. Please install Node.js first.${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}Installing Newman and reporters...${NC}"
    npm install newman newman-reporter-htmlextra --save-dev
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${CHECK} Dependencies installed successfully${NC}"
    else
        echo -e "${RED}${CROSS} Failed to install dependencies${NC}"
        exit 1
    fi
}

# Function to check API health
check_api_health() {
    print_section "${POKEMON} Checking PokeAPI Health"
    
    echo -e "${CYAN}Testing PokeAPI connectivity...${NC}"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 https://pokeapi.co/api/v2/pokemon/1 2>/dev/null)
    
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}${CHECK} PokeAPI is healthy (Status: $response)${NC}"
        
        # Test response time
        response_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time 10 https://pokeapi.co/api/v2/pokemon/1 2>/dev/null)
        response_time_ms=$(echo "$response_time * 1000" | bc -l | cut -d. -f1)
        echo -e "${GREEN}${CLOCK} Response time: ${response_time_ms}ms${NC}"
        
        if [ "$response_time_ms" -gt 1000 ]; then
            echo -e "${YELLOW}⚠️  Warning: API response time is slow (>${response_time_ms}ms)${NC}"
        fi
    else
        echo -e "${RED}${CROSS} PokeAPI health check failed (Status: $response)${NC}"
        echo -e "${YELLOW}⚠️  Continuing with tests, but API might be unavailable${NC}"
    fi
}

# Function to validate collection files
validate_collections() {
    print_section "${FOLDER} Validating Collection Files"
    
    collection_file="collections/pokemon-api-tests.postman_collection.json"
    environment_file="collections/pokemon-environments.postman_environment.json"
    
    if [ -f "$collection_file" ]; then
        echo -e "${GREEN}${CHECK} Collection file found: $collection_file${NC}"
        
        # Basic JSON validation
        if python3 -m json.tool "$collection_file" > /dev/null 2>&1; then
            echo -e "${GREEN}${CHECK} Collection file is valid JSON${NC}"
        else
            echo -e "${RED}${CROSS} Collection file contains invalid JSON${NC}"
            exit 1
        fi
    else
        echo -e "${RED}${CROSS} Collection file not found: $collection_file${NC}"
        echo -e "${YELLOW}Please export your Postman collection to this location${NC}"
        exit 1
    fi
    
    if [ -f "$environment_file" ]; then
        echo -e "${GREEN}${CHECK} Environment file found: $environment_file${NC}"
        
        # Basic JSON validation
        if python3 -m json.tool "$environment_file" > /dev/null 2>&1; then
            echo -e "${GREEN}${CHECK} Environment file is valid JSON${NC}"
        else
            echo -e "${RED}${CROSS} Environment file contains invalid JSON${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  Environment file not found: $environment_file${NC}"
        echo -e "${YELLOW}Tests will run with default settings${NC}"
    fi
}

# Function to create reports directory
setup_reports() {
    print_section "${FOLDER} Setting Up Reports Directory"
    
    if [ ! -d "reports" ]; then
        mkdir -p reports
        echo -e "${GREEN}${CHECK} Created reports directory${NC}"
    else
        echo -e "${CYAN}Reports directory already exists${NC}"
    fi
    
    # Clean up old reports
    if [ -f "reports/test-report.html" ]; then
        mv "reports/test-report.html" "reports/test-report-$(date +%Y%m%d-%H%M%S).html"
        echo -e "${CYAN}Archived previous HTML report${NC}"
    fi
    
    if [ -f "reports/junit.xml" ]; then
        mv "reports/junit.xml" "reports/junit-$(date +%Y%m%d-%H%M%S).xml"
        echo -e "${CYAN}Archived previous JUnit report${NC}"
    fi
}

# Function to run tests
run_tests() {
    local test_type=$1
    local description=$2
    
    print_section "${POKEMON} Running $description"
    
    collection_file="collections/pokemon-api-tests.postman_collection.json"
    environment_file="collections/pokemon-environments.postman_environment.json"
    
    # Base newman command
    newman_cmd="newman run $collection_file"
    
    # Add environment if exists
    if [ -f "$environment_file" ]; then
        newman_cmd="$newman_cmd -e $environment_file"
    fi
    
    # Configure based on test type
    case $test_type in
        "standard")
            newman_cmd="$newman_cmd --reporters cli,htmlextra --reporter-htmlextra-export reports/test-report.html --reporter-htmlextra-title 'Pokemon API Test Results'"
            ;;
        "verbose")
            newman_cmd="$newman_cmd --reporters cli,htmlextra --reporter-htmlextra-export reports/test-report-verbose.html --verbose"
            ;;
        "ci")
            newman_cmd="$newman_cmd --reporters cli,junit --reporter-junit-export reports/junit.xml"
            ;;
        "data-driven")
            if [ -f "data/pokemon-test-data.csv" ]; then
                newman_cmd="$newman_cmd -d data/pokemon-test-data.csv --reporters cli,htmlextra --reporter-htmlextra-export reports/test-report-datadriven.html"
            else
                echo -e "${YELLOW}⚠️  CSV data file not found, running standard tests instead${NC}"
                newman_cmd="$newman_cmd --reporters cli,htmlextra --reporter-htmlextra-export reports/test-report.html"
            fi
            ;;
        *)
            echo -e "${RED}${CROSS} Unknown test type: $test_type${NC}"
            return 1
            ;;
    esac
    
    echo -e "${CYAN}Executing: $newman_cmd${NC}"
    echo ""
    
    # Run the tests
    eval $newman_cmd
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo -e "${GREEN}${CHECK} Tests completed successfully!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}${CROSS} Tests failed with exit code: $exit_code${NC}"
        return $exit_code
    fi
}

# Function to display results
display_results() {
    print_section "${REPORT} Test Results Summary"
    
    if [ -f "reports/test-report.html" ]; then
        echo -e "${GREEN}${CHECK} HTML Report: reports/test-report.html${NC}"
        
        # Try to open the report automatically
        if command_exists open; then
            echo -e "${CYAN}Opening HTML report...${NC}"
            open reports/test-report.html
        elif command_exists xdg-open; then
            echo -e "${CYAN}Opening HTML report...${NC}"
            xdg-open reports/test-report.html
        else
            echo -e "${YELLOW}${REPORT} Open reports/test-report.html in your browser to view detailed results${NC}"
        fi
    fi
    
    if [ -f "reports/junit.xml" ]; then
        echo -e "${GREEN}${CHECK} JUnit Report: reports/junit.xml${NC}"
    fi
    
    # Count report files
    report_count=$(ls -1 reports/ 2>/dev/null | wc -l)
    echo -e "${CYAN}Total report files: $report_count${NC}"
}

# Function to run performance benchmark
run_performance_benchmark() {
    print_section "${CLOCK} Performance Benchmark"
    
    echo -e "${CYAN}Running quick performance check...${NC}"
    
    collection_file="collections/pokemon-api-tests.postman_collection.json"
    environment_file="collections/pokemon-environments.postman_environment.json"
    
    # Set stricter performance thresholds for benchmark
    temp_env=$(mktemp)
    if [ -f "$environment_file" ]; then
        # Create temporary environment with stricter performance threshold
        sed 's/"value": "500"/"value": "300"/g' "$environment_file" > "$temp_env"
        newman_cmd="newman run $collection_file -e $temp_env --reporters cli --bail"
    else
        newman_cmd="newman run $collection_file --reporters cli --bail"
    fi
    
    echo -e "${CYAN}Running with 300ms performance threshold...${NC}"
    
    start_time=$(date +%s)
    eval $newman_cmd > /dev/null 2>&1
    end_time=$(date +%s)
    
    runtime=$((end_time - start_time))
    
    # Clean up temp file
    [ -f "$temp_env" ] && rm "$temp_env"
    
    echo -e "${GREEN}${CLOCK} Benchmark completed in ${runtime}s${NC}"
    
    if [ $runtime -lt 30 ]; then
        echo -e "${GREEN}${CHECK} Excellent performance! (< 30s)${NC}"
    elif [ $runtime -lt 60 ]; then
        echo -e "${YELLOW}⚠️  Good performance (30-60s)${NC}"
    else
        echo -e "${RED}⚠️  Performance could be improved (> 60s)${NC}"
    fi
}

# Main execution function
main() {
    local test_type=${1:-"standard"}
    local skip_health_check=${2:-false}
    local skip_benchmark=${3:-false}
    
    echo -e "${CYAN}Test Type: $test_type${NC}"
    echo -e "${CYAN}Timestamp: $(date)${NC}"
    echo ""
    
    # Step 1: Install dependencies
    install_dependencies
    
    # Step 2: Check API health (unless skipped)
    if [ "$skip_health_check" != "true" ]; then
        check_api_health
    fi
    
    # Step 3: Validate collections
    validate_collections
    
    # Step 4: Setup reports
    setup_reports
    
    # Step 5: Run tests based on type
    case $test_type in
        "all")
            echo -e "${BLUE}Running comprehensive test suite...${NC}"
            run_tests "standard" "Standard Tests" && \
            run_tests "data-driven" "Data-Driven Tests" && \
            run_tests "ci" "CI Tests"
            ;;
        "quick")
            run_tests "ci" "Quick Tests (CI Mode)"
            ;;
        "benchmark")
            run_performance_benchmark
            return $?
            ;;
        *)
            run_tests "$test_type" "Tests ($test_type mode)"
            ;;
    esac
    
    local test_exit_code=$?
    
    # Step 6: Display results
    if [ $test_exit_code -eq 0 ]; then
        display_results
        
        # Step 7: Optional performance benchmark
        if [ "$skip_benchmark" != "true" ] && [ "$test_type" = "standard" ]; then
            echo ""
            read -p "Run performance benchmark? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                run_performance_benchmark
            fi
        fi
        
        echo ""
        echo -e "${GREEN}${ROCKET} All tests completed successfully!${NC}"
        echo -e "${GREEN}Happy testing! ${POKEMON}${NC}"
    else
        echo ""
        echo -e "${RED}${CROSS} Test execution failed.${NC}"
        echo -e "${YELLOW}Check the output above for details.${NC}"
        exit $test_exit_code
    fi
}

# Help function
show_help() {
    echo "Pokemon API Test Suite Runner"
    echo ""
    echo "Usage: $0 [TEST_TYPE] [OPTIONS]"
    echo ""
    echo "TEST_TYPES:"
    echo "  standard     - Run standard test suite with HTML report (default)"
    echo "  verbose      - Run with verbose output and detailed logging"
    echo "  ci           - Run in CI mode with JUnit output"
    echo "  data-driven  - Run data-driven tests using CSV file"
    echo "  quick        - Run quick tests suitable for development"
    echo "  all          - Run all test types"
    echo "  benchmark    - Run performance benchmark only"
    echo ""
    echo "OPTIONS:"
    echo "  --skip-health    Skip API health check"
    echo "  --skip-benchmark Skip performance benchmark prompt"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run standard tests"
    echo "  $0 verbose            # Run with verbose output"
    echo "  $0 ci --skip-health   # Run CI tests without health check"
    echo "  $0 all                # Run comprehensive test suite"
    echo ""
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    *)
        # Parse options
        skip_health="false"
        skip_benchmark="false"
        
        for arg in "$@"; do
            case $arg in
                --skip-health)
                    skip_health="true"
                    ;;
                --skip-benchmark)
                    skip_benchmark="true"
                    ;;
            esac
        done
        
        main "${1:-standard}" "$skip_health" "$skip_benchmark"
        ;;
esac