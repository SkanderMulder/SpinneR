# SpinneR 0.1.0

## Major Improvements

* Improved code quality and adherence to R package best practices

### New Features

* Added automatic detection of non-interactive sessions - spinner is now disabled in batch mode, Rscript, and non-interactive environments
* Added comprehensive input validation and error handling
* Improved error messages with helpful context

### Bug Fixes

* Fixed missing error checking in C++ semaphore operations
* Fixed potential resource leaks by improving cleanup logic
* Added proper validation of executable paths before attempting to start spinner

### Code Quality Improvements

* Replaced magic numbers with named constants (`SPINNER_START_DELAY`, `SPINNER_STOP_DELAY`)
* Added extensive code documentation for internal functions
* Improved error handling with `tryCatch` blocks throughout
* Added comprehensive test suite with multiple edge cases

### Package Infrastructure

* Added `tests/testthat.R` entry point for proper test execution
* Updated `DESCRIPTION` with URL and BugReports fields
* Added `.gitignore` for better version control
* Added `cleanup` script for package build artifacts
* Added `NEWS.md` for version tracking
* Improved DESCRIPTION with proper dependencies and system requirements

### Testing

* Expanded test coverage significantly with new test cases:
  - Return value correctness tests
  - Error handling and recovery tests
  - Multiple consecutive calls tests
  - Different return type tests (NULL, lists, vectors)
  - Warning propagation tests

### C++ Improvements

* Added proper error checking for `sem_post()` calls
* Added error checking for `sem_close()` calls
* Improved error messages with `strerror()` for better debugging

### Documentation

* Enhanced function documentation with parameter and return value details
* Added notes about non-interactive session behavior
* Improved internal code comments

---

# SpinneR 0.0.1 (Initial Release)

* Initial release with basic spinner functionality
* Cross-platform support for Windows, macOS, and Linux
* Asynchronous spinner using C++ background processes
* Semaphore-based IPC for clean resource management
