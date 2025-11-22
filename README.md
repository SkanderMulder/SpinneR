# SpinneR <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/skandermulder/SpinneR/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/skandermulder/SpinneR/actions/workflows/R-CMD-check.yml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

An asynchronous CLI spinner for R that displays non-blocking animations while evaluating expressions.

## Overview

SpinneR provides a simple `with_spinner()` function that displays a lightweight, asynchronous spinner in the terminal while executing long-running R code. The spinner runs in a separate background process using cross-platform semaphore-based IPC, ensuring minimal overhead and clean resource management.

## Features

- **Non-blocking**: Spinner runs asynchronously without interfering with R execution
- **Cross-platform**: Works on Linux, macOS, and Windows
- **Minimal dependencies**: Only requires the `tools` package (part of base R)
- **Smart detection**: Automatically disables in non-interactive sessions (batch mode, Rscript)
- **Clean resource management**: Automatically cleans up background processes and semaphores
- **Robust error handling**: Gracefully handles errors in user expressions while ensuring spinner cleanup

## Installation

```r
# Install from GitHub
# install.packages("remotes")
remotes::install_github("skandermulder/SpinneR")
```

## Usage

Basic usage with `with_spinner()`:

```r
library(SpinneR)

# Wrap any long-running expression
result <- with_spinner({
  Sys.sleep(5)  # Simulate a long computation
  "Task complete!"
})
```

The spinner will display while the expression evaluates and automatically stop when complete.

### Examples

**Data processing:**

```r
processed_data <- with_spinner({
  # Simulate intensive data processing
  data <- read.csv("large_file.csv")
  processed <- complex_transformation(data)
  processed
})
```

**API calls:**

```r
response <- with_spinner({
  # Make a slow API request
  httr::GET("https://api.example.com/slow-endpoint")
})
```

**Long computations:**

```r
model <- with_spinner({
  # Train a machine learning model
  lm(y ~ ., data = training_data)
})
```

## How It Works

SpinneR uses a lightweight architecture:

1. **C++ Background Process**: A minimal compiled executable displays the spinner animation
2. **Semaphore IPC**: POSIX semaphores (Linux/macOS) or Windows Semaphores handle cross-process communication
3. **R Wrapper**: The `with_spinner()` function manages the background process lifecycle
4. **Clean Shutdown**: Semaphore signals tell the spinner to stop, and `on.exit()` ensures proper cleanup

### Architecture

```
┌─────────────────┐
│   R Session     │
│                 │
│  with_spinner() │
│       │         │
│       ├─────────┼──► Start C++ spinner process
│       │         │
│  evaluate expr  │    ┌──────────────────┐
│       │         │    │ Spinner Process  │
│       │         │    │                  │
│       │         │    │  while(running)  │
│       │         │◄───┤    display "|/-\\"│
│       │         │    │                  │
│  on.exit() ─────┼───►│  sem_post()     │
│                 │    │  stop & cleanup  │
└─────────────────┘    └──────────────────┘
```

## Requirements

- R >= 3.5.0
- C++ compiler (for building from source)
  - Linux/macOS: `g++` with pthread support
  - Windows: MSVC or MinGW
- `tools` package (part of base R)

## Building from Source

The package automatically compiles C++ components during installation:

```r
# Clone repository
git clone https://github.com/skandermulder/SpinneR.git
cd SpinneR

# Build package
R CMD build .
R CMD INSTALL SpinneR_*.tar.gz
```

Manual compilation of C++ sources (for development):

```bash
# Linux/macOS
make

# Or directly:
g++ -o exec/spinner csource/spinner.cpp -pthread -lrt
g++ -o exec/sem_post_helper csource/sem_post_helper.cpp -pthread -lrt
```

## API Reference

### `with_spinner(expr)`

Evaluate an R expression while displaying an asynchronous CLI spinner.

**Parameters:**
- `expr`: An R expression to evaluate

**Returns:**
- The result of the evaluated expression

**Examples:**
```r
# Simple usage
with_spinner({ Sys.sleep(3) })

# Return value
result <- with_spinner({ 2 + 2 })  # result = 4

# Error handling
tryCatch(
  with_spinner({ stop("Error!") }),
  error = function(e) message("Caught: ", e$message)
)
```

## Development

### Running Tests

```r
# Run all tests
devtools::test()

# Or with testthat
testthat::test_dir("tests/testthat")
```

### Package Check

```r
devtools::check()
```

## Technical Details

### Cross-Platform Semaphore Implementation

**POSIX (Linux/macOS):**
- Uses `sem_open()`, `sem_post()`, `sem_getvalue()`
- Named semaphore: `/spinner_semaphore`
- Automatic cleanup with `sem_unlink()`

**Windows:**
- Uses `CreateSemaphore()`, `ReleaseSemaphore()`, `WaitForSingleObject()`
- Named semaphore for cross-process communication
- Handle-based cleanup with `CloseHandle()`

### Resource Management

The package ensures proper cleanup through:
1. `on.exit()` handlers in R to stop spinner and terminate process
2. Semaphore signaling for graceful shutdown
3. Automatic detection and handling of non-interactive sessions
4. Explicit semaphore unlinking on exit
5. Comprehensive error checking in both R and C++ code

## License

MIT License - see LICENSE file for details

## Author

Skander Tahar Mulder

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Acknowledgments

Inspired by CLI spinner libraries in other languages and the need for non-blocking progress indicators in R workflows.
