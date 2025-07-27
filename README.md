# 🔬 PokeAPI Postman Test Suite

A comprehensive, production-ready API test suite for the [PokeAPI](https://pokeapi.co/) built with **Postman** and **Newman**. This project demonstrates professional QA engineering practices through systematic testing of REST API endpoints.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🎯 Project Overview

This test suite focuses on **quality over quantity** with comprehensive coverage of core Pokemon API endpoints:

- **Single Pokemon Lookup** (`/pokemon/{id}`) - Individual Pokemon data retrieval
- **Pokemon Listing** (`/pokemon?limit=X&offset=Y`) - Paginated Pokemon collections  
- **Type Relationships** (`/type/{id}`) - Pokemon type information and relationships

### 🧪 Test Categories

Each endpoint includes four essential test categories:

1. **✅ Happy Path Tests** - Valid requests returning 200 responses
2. **🔄 Edge Case Tests** - Boundary values and limits testing
3. **❌ Negative Tests** - Invalid inputs and error handling
4. **📋 Schema Validation** - Response structure verification

## 🚀 Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) (v14 or higher)
- [Postman](https://www.postman.com/downloads/) (optional, for collection editing)

### Installation & Execution

```bash
# Clone the repository
git clone https://github.com/yourusername/pokeapi-postman-tests.git
cd pokeapi-postman-tests

# Install dependencies
npm run install-deps

# Run all tests
npm test

# View detailed HTML report
open reports/test-report.html
```

### Alternative Execution Methods

```bash
# Verbose output with detailed logs
npm run test:verbose

# CI-friendly JUnit output
npm run test:ci
```

## 🏗️ Project Structure

```markdown
pokeapi-postman-tests/
├── collections/
│   ├── pokemon-api-tests.postman_collection.json     # Main test collection
│   └── pokemon-environments.postman_environment.json # Environment variables
├── reports/
│   ├── test-report.html                             # Generated HTML report
│   └── junit.xml                                    # CI-friendly test results
├── scripts/
│   ├── run-tests.sh                                 # Bash execution script
│   └── generate-report.js                           # Custom report generator
├── package.json                                     # Dependencies and scripts
└── README.md                                        # This file
```

## 🎓 Learning Outcomes

This project demonstrates mastery of:

### Technical Skills

- **API Testing Fundamentals**: HTTP methods, status codes, response validation
- **Test Automation**: Collection design, environment management, CI integration
- **Performance Testing**: Response time monitoring, threshold validation
- **Schema Validation**: JSON structure verification, data type checking

### QA Engineering Practices

- **Test Strategy**: Comprehensive coverage planning, risk-based testing
- **Test Design Patterns**: Reusable assertions, modular test structure
- **Reporting**: Professional test reports, actionable failure analysis
- **Documentation**: Clear setup instructions, comprehensive project documentation
- **Version Control**: Proper Git practices, collaborative development

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-test`)
3. Commit your changes (`git commit -m 'Add amazing test'`)
4. Push to the branch (`git push origin feature/amazing-test`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) file for details.

## 🙏 Acknowledgments

- [PokeAPI](https://pokeapi.co/) for providing an excellent, stable REST API for testing
- [Postman](https://www.postman.com/) for comprehensive API testing tools
- [Newman](https://github.com/postmanlabs/newman) for command-line test execution

---

**Ready to explore Pokemon through the lens of API testing? Clone this repo and start your testing journey!** 🚀
