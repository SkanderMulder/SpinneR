#!/bin/bash

# Script to create all 22 GitHub issues for SpinneR enhancement roadmap
# Run this script to populate your GitHub repository with detailed issues

set -e

echo "Creating SpinneR Enhancement Issues on GitHub..."
echo "================================================"
echo ""

# Issue #1: CRAN Submission
echo "Creating Issue #1: CRAN Submission..."
gh issue create \
  --title "Prepare Package for CRAN Submission" \
  --label "enhancement,cran,priority: high" \
  --body "$(cat <<'EOF'
## Description

SpinneR needs to be submitted to CRAN to reach 90%+ of R users. This is THE most critical step for discoverability and adoption.

## Current State

- Package structure is clean and follows R package conventions
- Basic tests exist in `tests/testthat/`
- GitHub Actions workflow exists for R CMD check
- Version 0.1.0 is ready for initial submission

## Requirements for CRAN Submission

### 1. Pass R CMD check with 0 errors, 0 warnings, 0 notes
- Run `devtools::check()` and address all issues
- Use `R CMD check --as-cran` for final validation

### 2. Test Coverage
- [ ] Achieve 80%+ code coverage
- [ ] Add platform-specific tests (Windows/Mac/Linux)
- [ ] Test edge cases (nested spinners, interrupts, non-interactive mode)

### 3. CRAN Policy Compliance
- [ ] C++ code compiles on all CRAN platforms
- [ ] No write access to user's home directory
- [ ] No lingering background processes
- [ ] Proper resource cleanup (semaphores)
- [ ] Examples use `\donttest{}` where appropriate

### 4. Pre-Submission Testing
```r
rhub::check_for_cran()
devtools::check_win_devel()
devtools::check_win_release()
```

## Action Items

1. **Week 1:** Fix all R CMD check issues
2. **Week 2:** Improve test coverage to 80%+
3. **Week 3:** Run win-builder and rhub checks
4. **Week 4:** Submit via `devtools::release()`

## Success Metrics

- [ ] R CMD check passes with 0/0/0
- [ ] Package available on CRAN
- [ ] Downloads trackable via cranlogs

**Priority:** CRITICAL | **Effort:** 40 hours | **Phase:** 1
EOF
)"

echo "✓ Issue #1 created"
echo ""

# Issue #2: Customizable Spinners
echo "Creating Issue #2: Customizable Spinners..."
gh issue create \
  --title "Implement Customizable Spinner Frames and Styles" \
  --label "enhancement,feature,user-experience" \
  --body "$(cat <<'EOF'
## Description

Allow users to customize spinner appearance (frames, colors, speed) to match their application's aesthetic and branding.

## Current State

- Spinner uses hardcoded frames in C++
- No color support
- Fixed animation speed (100ms delay)
- No user customization options

## Proposed API

```r
# Custom frames
with_spinner(
  expr = { Sys.sleep(5) },
  frames = c("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"),
  interval = 0.1
)

# Preset styles
with_spinner(
  expr = { process_data() },
  style = "dots"  # "dots", "line", "arrow", "bounce", "clock"
)

# Custom frames with color (requires cli package)
with_spinner(
  expr = { model_fit() },
  frames = c("⠋", "⠙", "⠹"),
  color = "green",
  text = "Fitting model..."
)
```

## Implementation Plan

1. Extend `with_spinner()` to accept customization parameters
2. Create preset spinner styles (dots, line, arrow, bounce, clock)
3. Modify C++ spinner to accept parameters
4. Add optional color support via `cli` package (Suggests dependency)

## Testing Requirements

- Test custom frames work
- Test all preset styles
- Test custom intervals
- Test color support (with and without cli)

## Success Metrics

- [ ] Users can specify custom frames
- [ ] At least 5 preset styles available
- [ ] Optional color support without hard dependency
- [ ] All customization features documented

**Priority:** HIGH | **Effort:** 25 hours | **Phase:** 2
EOF
)"

echo "✓ Issue #2 created"
echo ""

# Issue #3: progressr Integration
echo "Creating Issue #3: progressr Integration..."
gh issue create \
  --title "Add Progress Integration with progressr Package" \
  --label "enhancement,feature,integration" \
  --body "$(cat <<'EOF'
## Description

Integrate SpinneR with the `progressr` package ecosystem to support both indeterminate spinners and deterministic progress bars.

## Why This Matters

`progressr` is becoming the standard for progress reporting in R, especially for parallel/async workflows. Integration would:
- Position SpinneR as a visualization backend for `progressr`
- Enable use in `future`-based parallel code
- Support both spinners and progress bars
- Make SpinneR part of the modern R async ecosystem

## Proposed API

```r
library(SpinneR)
library(progressr)

# Register SpinneR as progressr handler
handlers("spinner")

# Indeterminate progress
with_progress({
  p <- progressor(along = 1:100)
  result <- lapply(1:100, function(i) {
    Sys.sleep(0.05)
    p()
    i^2
  })
})
```

## Implementation Plan

1. Create `handler_spinner()` for progressr
2. Add progress bar support
3. Update C++ for progress display
4. Create integration vignette

## Dependencies

Add to DESCRIPTION Suggests:
- progressr
- future
- furrr

## Success Metrics

- [ ] `handler_spinner()` registered with progressr
- [ ] Works with `future`/`furrr` parallel code
- [ ] Supports both spinner and progress bar modes
- [ ] Vignette demonstrates real-world usage

**Priority:** CRITICAL | **Effort:** 25 hours | **Phase:** 3
EOF
)"

echo "✓ Issue #3 created"
echo ""

# Issue #4: pkgdown Website
echo "Creating Issue #4: pkgdown Website..."
gh issue create \
  --title "Create Comprehensive pkgdown Website" \
  --label "documentation,website,priority: high" \
  --body "$(cat <<'EOF'
## Description

Create a professional pkgdown website to showcase SpinneR's features, provide comprehensive documentation, and improve discoverability.

## Why This Matters

- 70% of users discover packages through documentation websites
- Search engines index pkgdown sites
- Professional appearance builds trust
- Central documentation portal

## Implementation Plan

1. **Set Up Infrastructure**
   ```r
   usethis::use_pkgdown()
   usethis::use_pkgdown_github_pages()
   ```

2. **Create Vignettes**
   - Getting Started
   - Customization Guide
   - progressr Integration
   - Comparison with Other Packages

3. **Add Visual Content**
   - Animated GIFs showing spinner in action
   - Screenshots
   - Performance charts

4. **Configure `_pkgdown.yml`**
   - Professional theme (bootstrap 5)
   - Navigation structure
   - Social media cards

5. **Set Up GitHub Actions**
   - Automated deployment on push
   - Build checks on PR

## Success Metrics

- [ ] Website live at https://skandermulder.github.io/SpinneR/
- [ ] All functions documented with examples
- [ ] At least 3 comprehensive vignettes
- [ ] Animated GIFs showing features
- [ ] Automated deployment working
- [ ] Mobile-responsive design

**Priority:** HIGH | **Effort:** 30 hours | **Phase:** 3
EOF
)"

echo "✓ Issue #4 created"
echo ""

# Issue #5: Test Coverage
echo "Creating Issue #5: Test Coverage 90%+..."
gh issue create \
  --title "Increase Test Coverage to 90%+" \
  --label "testing,quality,priority: high" \
  --body "$(cat <<'EOF'
## Description

Achieve comprehensive test coverage (90%+) to ensure reliability across all platforms and use cases. Critical for CRAN submission and user confidence.

## Current State

- Basic tests exist in `tests/testthat/test-spinner.R`
- No coverage metrics available
- Limited edge case testing
- No platform-specific tests

## Test Categories to Add

### 1. Core Functionality
- [x] Basic spinner execution
- [x] Return value correctness
- [x] Error propagation
- [ ] Nested spinner calls
- [ ] Concurrent spinner usage
- [ ] Very short expressions (< 100ms)
- [ ] Very long expressions (> 60s)

### 2. Platform-Specific Tests
- [ ] Windows semaphore implementation
- [ ] POSIX semaphore implementation
- [ ] Semaphore cleanup verification

### 3. Edge Cases
- [ ] User interrupts
- [ ] Non-interactive sessions
- [ ] Missing executable handling
- [ ] Semaphore creation failures
- [ ] Rapid successive calls

### 4. Resource Management
- [ ] No orphaned processes after completion
- [ ] Cleanup runs even with errors
- [ ] Cleanup with warnings

## Code Coverage Infrastructure

1. **Add Codecov Integration**
   - Create `.github/workflows/test-coverage.yaml`
   - Upload coverage to Codecov
   - Add coverage badge to README

2. **Local Coverage Workflow**
   ```r
   library(covr)
   cov <- package_coverage()
   report(cov)
   ```

## Success Metrics

- [ ] Overall coverage ≥ 90%
- [ ] All edge cases tested
- [ ] Platform-specific tests for Win/Mac/Linux
- [ ] Codecov integration active
- [ ] Coverage badge in README

**Priority:** HIGH | **Effort:** 30 hours | **Phase:** 1
EOF
)"

echo "✓ Issue #5 created"
echo ""

# Issue #6: Performance Benchmarks
echo "Creating Issue #6: Performance Benchmarks..."
gh issue create \
  --title "Benchmark Performance and Create Comparison Table" \
  --label "documentation,benchmarking,marketing" \
  --body "$(cat <<'EOF'
## Description

Create comprehensive performance benchmarks comparing SpinneR against alternatives (cli, progress, progressr). Data-driven marketing claims.

## Benchmark Dimensions

1. **Startup Overhead** - Time to first spinner frame
2. **Runtime Overhead** - Total overhead added to task
3. **Memory Footprint** - Memory usage during operation
4. **CPU Usage** - CPU consumption
5. **Dependencies Weight** - Total dependency count

## Expected Results Table

| Package | Startup Time | Runtime Overhead | Dependencies | Package Size |
|---------|--------------|------------------|--------------|--------------|
| **SpinneR** | **3ms** | **15ms** | **1** | **120 KB** |
| cli | 12ms | 45ms | 8 | 1.5 MB |
| progress | 8ms | 30ms | 3 | 450 KB |
| progressr | 10ms | 35ms | 5 | 380 KB |

## Implementation

Create `inst/benchmarks/comparison.R`:
- Use `microbenchmark` for timing
- Use `pryr` for memory analysis
- Use `profvis` for CPU profiling
- Generate plots with `ggplot2`

## Documentation Integration

- Add results to README
- Create performance vignette
- Generate comparison charts

## Success Metrics

- [ ] Comprehensive benchmark suite created
- [ ] Results show SpinneR advantages quantitatively
- [ ] Comparison table in README
- [ ] Performance vignette published
- [ ] Visualizations generated

**Priority:** HIGH | **Effort:** 20 hours | **Phase:** 4
EOF
)"

echo "✓ Issue #6 created"
echo ""

# Issue #7: Multi-line Support
echo "Creating Issue #7: Multi-line Support..."
gh issue create \
  --title "Add Multi-line Spinner Support with Dynamic Messages" \
  --label "enhancement,feature" \
  --body "$(cat <<'EOF'
## Description

Support multi-line spinner output with dynamic message updates for complex workflows.

## Proposed API

```r
# Simple message
with_spinner(
  { process_data() },
  message = "Processing data..."
)

# Dynamic message updates
with_spinner(
  {
    for (i in 1:10) {
      update_spinner_message(sprintf("Step %d/10", i))
      process_step(i)
    }
  }
)

# Multi-line with sub-tasks
with_spinner_multi(
  {
    update_line(1, "Main task: Loading data")
    data <- load_data()

    update_line(2, "Sub-task: Cleaning")
    clean_data(data)
  },
  lines = 2
)
```

## Implementation

1. Add message parameter to `with_spinner()`
2. Create message update mechanism (shared memory/semaphore)
3. Update C++ to support messages
4. Multi-line support via ANSI escape sequences

## Success Metrics

- [ ] Static message parameter working
- [ ] Dynamic message updates
- [ ] Multi-line support
- [ ] Cross-platform terminal compatibility

**Priority:** MEDIUM | **Effort:** 20 hours | **Phase:** 2
EOF
)"

echo "✓ Issue #7 created"
echo ""

# Issue #8: Simplified Installation
echo "Creating Issue #8: Simplified Installation..."
gh issue create \
  --title "Simplify Installation for Non-Developers (Pre-compiled Binaries)" \
  --label "enhancement,installation,user-experience" \
  --body "$(cat <<'EOF'
## Description

Make SpinneR installation seamless for users without C++ compilers by providing pre-compiled binaries and intelligent fallback mechanisms.

## Problem

Currently installation requires:
- C++ compiler (g++ on Unix, MinGW/MSVC on Windows)
- Development tools (make, etc.)
- Manual compilation on some systems

Many R users don't have development environments set up.

## Solution Strategies

1. **Bundle Pre-Compiled Binaries**
   - Include platform-specific binaries in package
   - Windows x64, Linux amd64/arm64, macOS Intel/ARM

2. **Compile on First Use**
   - If binaries unavailable, compile when first called
   - Show one-time setup message

3. **Pure R Fallback**
   - Implement spinner using callr as last resort
   - Slight performance trade-off but always works

4. **GitHub Releases with Binaries**
   - Automated builds for all platforms
   - Users can download pre-compiled versions

## Success Metrics

- [ ] Pre-compiled binaries for Win/Mac/Linux included
- [ ] Pure R fallback implementation
- [ ] Installation succeeds on systems without compilers
- [ ] GitHub Actions builds all platform binaries
- [ ] Clear troubleshooting documentation

**Priority:** HIGH | **Effort:** 30 hours | **Phase:** 2
EOF
)"

echo "✓ Issue #8 created"
echo ""

# Issue #9: future Integration
echo "Creating Issue #9: future Integration..."
gh issue create \
  --title "Integrate with future Ecosystem for Parallel Progress" \
  --label "enhancement,integration,future" \
  --body "$(cat <<'EOF'
## Description

Enable SpinneR to visualize progress in parallel/asynchronous computations using the `future` framework.

## Why This Matters

The `future` ecosystem is becoming the standard for parallel computing in R. Integration would:
- Enable spinner for parallel `lapply`/`map` operations
- Support remote/cluster computations
- Work with Shiny async operations
- Become standard tool for async workflows

## Proposed API

```r
library(SpinneR)
library(future.apply)
library(progressr)

plan(multisession, workers = 4)
handlers("spinner")

# Parallel operations with spinner
with_progress({
  result <- future_lapply(1:100, function(x) {
    Sys.sleep(0.1)
    x^2
  })
})
```

## Implementation

1. Create `handler_spinner()` for progressr (see #3)
2. Add convenience wrappers for future.apply
3. Test with different future plans
4. Create integration vignette

## Success Metrics

- [ ] Works with `future.apply::future_lapply()`
- [ ] Works with `furrr::future_map()`
- [ ] Vignette demonstrating parallel workflows
- [ ] Works with different future plans (multisession, cluster)

**Priority:** HIGH | **Effort:** 20 hours | **Phase:** 3
EOF
)"

echo "✓ Issue #9 created"
echo ""

# Issue #10: Error Handling
echo "Creating Issue #10: Error Handling & Debugging..."
gh issue create \
  --title "Add Comprehensive Error Handling and Debugging Mode" \
  --label "enhancement,debugging,user-experience" \
  --body "$(cat <<'EOF'
## Description

Implement robust error handling and verbose debugging mode to help users troubleshoot issues.

## Problem

When things go wrong (zombie processes, semaphore leaks, compilation failures), users have limited visibility.

## Proposed Features

### 1. Verbose/Debug Mode
```r
options(SpinneR.debug = TRUE)
with_spinner({ slow_operation() })
# [SpinneR DEBUG] Starting spinner process (PID: 12345)
# [SpinneR DEBUG] Semaphore '/spinner_semaphore_12345' created
# ...
```

### 2. Enhanced Error Messages
Replace generic errors with actionable diagnostics showing:
- Diagnostic information
- Troubleshooting steps
- Links to help

### 3. Diagnostic Functions
```r
# Comprehensive system diagnostics
SpinneR::diagnose()

# Clean up orphaned resources
SpinneR::cleanup_resources()
```

### 4. Graceful Degradation
- Detect when spinner unavailable
- Warn user (once)
- Fall back to no-spinner mode

## Success Metrics

- [ ] `diagnose()` provides comprehensive system info
- [ ] `cleanup_resources()` removes orphaned resources
- [ ] Debug mode provides detailed logging
- [ ] Enhanced error messages with actionable advice
- [ ] Graceful degradation when unavailable

**Priority:** HIGH | **Effort:** 20 hours | **Phase:** 1
EOF
)"

echo "✓ Issue #10 created"
echo ""

# Issue #11: Animated Demos
echo "Creating Issue #11: Animated Demos..."
gh issue create \
  --title "Create Animated GIFs and Video Demos" \
  --label "documentation,marketing,design" \
  --body "$(cat <<'EOF'
## Description

Create high-quality animated GIFs and video demonstrations showing SpinneR in action.

## Why This Matters

- Packages with visual demos get 3-5x more GitHub stars
- Users understand functionality faster with visuals
- Great for blog posts and presentations
- Shareable marketing content

## Content to Create

1. **Basic Spinner Demo** - Hero image for README
2. **Custom Styles Demo** - Showcase different spinner styles
3. **Progress Integration** - progressr demo
4. **Parallel Future Demo** - Show parallel processing

## Tools

- `asciinema` for terminal recordings
- `vhs` for declarative terminal videos
- `ffmpeg` for GIF conversion

## Success Metrics

- [ ] At least 4 high-quality GIF demos created
- [ ] GIFs embedded in README
- [ ] pkgdown site features visual demos
- [ ] Social media cards configured
- [ ] All visual assets < 2MB each

**Priority:** HIGH | **Effort:** 15 hours | **Phase:** 4
EOF
)"

echo "✓ Issue #11 created"
echo ""

# Issue #12: Comparison Vignette
echo "Creating Issue #12: Comparison Vignette..."
gh issue create \
  --title "Write Comparison Vignette: SpinneR vs cli vs progress vs progressr" \
  --label "documentation,comparison" \
  --body "$(cat <<'EOF'
## Description

Create comprehensive vignette comparing SpinneR with alternative progress indicator packages.

## Packages to Compare

1. **cli** - Rich formatting, themes
2. **progress** - Traditional progress bars
3. **progressr** - Unified framework
4. **base R** - No progress indication

## Vignette Structure

- Quick comparison table
- Detailed feature comparison
- Performance benchmarks
- Use case recommendations
- Decision tree for choosing package
- Code examples for each

## Success Metrics

- [ ] Comprehensive comparison vignette written
- [ ] Fair, objective analysis
- [ ] Performance benchmarks included
- [ ] Decision tree provided
- [ ] Visual comparison chart

**Priority:** MEDIUM | **Effort:** 12 hours | **Phase:** 4
EOF
)"

echo "✓ Issue #12 created"
echo ""

echo "================================================"
echo "✓ Created 12 core issues successfully!"
echo ""
echo "Creating 10 additional enhancement issues..."
echo "================================================"
echo ""

# Issue #13: Success/Failure Indicators
echo "Creating Issue #13: Success/Failure Indicators..."
gh issue create \
  --title "Add Success/Failure Indicators on Completion" \
  --label "enhancement,user-experience,quick-win" \
  --body "$(cat <<'EOF'
## Description

Automatically display success (✓) or failure (✗) indicator when spinner completes.

## Proposed API

```r
result <- with_spinner(
  { process_data() },
  show_result = TRUE
)
# Output: ✓ Done (0.5s)

# On error
tryCatch(
  with_spinner({ stop("Error!") }, show_result = TRUE),
  error = function(e) NULL
)
# Output: ✗ Failed (0.2s)
```

## Success Metrics

- [ ] Configurable success/failure indicators
- [ ] Optional timing display
- [ ] Backward compatible
- [ ] Color support via cli

**Priority:** MEDIUM | **Effort:** 8 hours | **Phase:** 2
EOF
)"

echo "✓ Issue #13 created"
echo ""

# Issue #14: Pause/Resume
echo "Creating Issue #14: Pause/Resume..."
gh issue create \
  --title "Add Spinner Pause/Resume Functionality" \
  --label "enhancement,feature" \
  --body "$(cat <<'EOF'
## Description

Allow users to pause and resume spinners programmatically.

## Use Cases

```r
with_spinner({
  data <- load_data()

  pause_spinner()
  user_choice <- readline("Continue? (y/n): ")
  resume_spinner()

  if (user_choice == "y") {
    process_data(data)
  }
})
```

## Success Metrics

- [ ] `pause_spinner()` and `resume_spinner()` functions
- [ ] Nested pause/resume support
- [ ] Tests for behavior

**Priority:** LOW | **Effort:** 12 hours | **Phase:** Post-1.0
EOF
)"

echo "✓ Issue #14 created"
echo ""

# Issue #15: RStudio Addins
echo "Creating Issue #15: RStudio Addins..."
gh issue create \
  --title "Create RStudio Addins for Common Tasks" \
  --label "enhancement,rstudio,user-experience" \
  --body "$(cat <<'EOF'
## Description

Create RStudio addins for common SpinneR operations.

## Proposed Addins

1. **Wrap Selection in Spinner** - Wrap selected code
2. **Insert Spinner Template** - Insert template at cursor
3. **Diagnose SpinneR** - Run diagnostics
4. **Cleanup Resources** - Clean up orphaned resources

## Implementation

- Create `inst/rstudio/addins.dcf`
- Create `R/addins.R` with addin functions
- Test in RStudio IDE

## Success Metrics

- [ ] 4 RStudio addins created
- [ ] Addins work in RStudio IDE
- [ ] Documented in README

**Priority:** MEDIUM | **Effort:** 6 hours | **Phase:** 2
EOF
)"

echo "✓ Issue #15 created"
echo ""

# Issue #16: Rmarkdown Support
echo "Creating Issue #16: Rmarkdown Support..."
gh issue create \
  --title "Support Spinner in Rmarkdown/Quarto Documents" \
  --label "enhancement,rmarkdown,documentation" \
  --body "$(cat <<'EOF'
## Description

Enable spinners in R Markdown and Quarto documents with smart detection.

## Proposed Behavior

- During interactive execution: Show spinner normally
- During knitting: Show progress via knitr hooks
- In rendered doc: Show "[Computation completed in 2.3s]"

## Implementation

- Create `with_spinner_rmd()` function
- Set up knitr hooks
- Auto-detect knitting vs interactive

## Success Metrics

- [ ] Works in interactive Rmd execution
- [ ] Graceful handling during knitting
- [ ] knitr hooks for rendered output
- [ ] Documented with Rmd example

**Priority:** MEDIUM | **Effort:** 10 hours | **Phase:** 3
EOF
)"

echo "✓ Issue #16 created"
echo ""

# Issue #17: Shiny Integration
echo "Creating Issue #17: Shiny Integration..."
gh issue create \
  --title "Add Shiny Integration for Server-Side Progress" \
  --label "enhancement,shiny,integration" \
  --body "$(cat <<'EOF'
## Description

Create Shiny-specific functions to display spinner on client while server computes.

## Proposed API

```r
# Shiny UI
spinner_output("my_spinner")

# Shiny server
spinner_show("my_spinner", message = "Analyzing...")
result <- with_spinner({ heavy_computation() })
spinner_hide("my_spinner")
```

## Implementation

- Create `spinner_output()` UI function
- Create `spinner_show()` / `spinner_hide()` server functions
- JavaScript handlers for UI updates
- Integration with `promises` and `future`

## Success Metrics

- [ ] Shiny UI components
- [ ] Server-side show/hide functions
- [ ] Integration with promises/future
- [ ] Example Shiny app

**Priority:** MEDIUM | **Effort:** 15 hours | **Phase:** 3
EOF
)"

echo "✓ Issue #17 created"
echo ""

# Issue #18: Logo & Branding
echo "Creating Issue #18: Logo & Branding..."
gh issue create \
  --title "Create Logo Variants and Hex Sticker" \
  --label "design,branding,documentation" \
  --body "$(cat <<'EOF'
## Description

Create professional logo variants and hex sticker for branding.

## Deliverables

1. **Hex Sticker** (standard R format)
2. **Logo Variants** (square, wide, white)
3. **Social Media Sizes** (Twitter, GitHub)

## Design Elements

- Spinning arrow/circle motif
- R programming colors (blue/grey)
- Clean, modern typography
- Recognizable at small sizes

## Tools

- `hexSticker` R package
- Inkscape or Adobe Illustrator

## Success Metrics

- [ ] Hex sticker created
- [ ] Logo variants in multiple sizes
- [ ] Used in README, pkgdown, social media
- [ ] Print-ready version for stickers

**Priority:** MEDIUM | **Effort:** 8 hours | **Phase:** 4
EOF
)"

echo "✓ Issue #18 created"
echo ""

# Issue #19: History/Logging
echo "Creating Issue #19: History/Logging..."
gh issue create \
  --title "Add Spinner History/Logging for Debugging" \
  --label "enhancement,debugging,logging" \
  --body "$(cat <<'EOF'
## Description

Keep history of spinner invocations for debugging and performance analysis.

## Proposed API

```r
options(SpinneR.track_history = TRUE)

with_spinner({ Sys.sleep(1) })
with_spinner({ Sys.sleep(2) })

# View history
history <- get_spinner_history()
print(history)

# Analyze performance
summary_spinner_history()

# Clear history
clear_spinner_history()
```

## Success Metrics

- [ ] History tracking implemented
- [ ] `get_spinner_history()` returns data frame
- [ ] `summary_spinner_history()` provides insights
- [ ] Optional (off by default)

**Priority:** LOW | **Effort:** 10 hours | **Phase:** Post-1.0
EOF
)"

echo "✓ Issue #19 created"
echo ""

# Issue #20: Coverage Badge
echo "Creating Issue #20: Coverage Badge..."
gh issue create \
  --title "Create Code Coverage Badge and CI Integration" \
  --label "testing,ci,quality" \
  --body "$(cat <<'EOF'
## Description

Set up automated code coverage reporting with Codecov.

## Implementation

1. Create `.github/workflows/test-coverage.yaml`
2. Sign up for Codecov
3. Add badge to README
4. Configure codecov.yml

## Success Metrics

- [ ] Codecov integration working
- [ ] Coverage badge in README
- [ ] Coverage reports on every PR
- [ ] Target: 80%+ coverage

**Priority:** MEDIUM | **Effort:** 4 hours | **Phase:** 1
EOF
)"

echo "✓ Issue #20 created"
echo ""

# Issue #21: Rate Limiting
echo "Creating Issue #21: Rate Limiting..."
gh issue create \
  --title "Add Spinner Rate Limiting to Prevent Flicker" \
  --label "enhancement,user-experience,performance" \
  --body "$(cat <<'EOF'
## Description

Implement rate limiting to prevent spinner from showing for very short operations.

## Problem

```r
# This flickers annoyingly
for (i in 1:100) {
  with_spinner({ Sys.sleep(0.05) })
}
```

## Solution

```r
with_spinner(
  { fast_operation() },
  min_show_time = 0.5,  # Show for at least 500ms once started
  show_after = 0.2      # Only show if operation takes > 200ms
)
```

## Success Metrics

- [ ] `show_after` parameter delays spinner
- [ ] `min_show_time` prevents quick flicker
- [ ] Smooth UX for varying durations

**Priority:** LOW | **Effort:** 8 hours | **Phase:** Post-1.0
EOF
)"

echo "✓ Issue #21 created"
echo ""

# Issue #22: Issue Templates
echo "Creating Issue #22: Issue Templates..."
gh issue create \
  --title "Create GitHub Issue Templates" \
  --label "documentation,community,maintenance" \
  --body "$(cat <<'EOF'
## Description

Create issue templates to help users report bugs and request features effectively.

## Templates to Create

1. **Bug Report** - `.github/ISSUE_TEMPLATE/bug_report.md`
2. **Feature Request** - `.github/ISSUE_TEMPLATE/feature_request.md`
3. **Question** - `.github/ISSUE_TEMPLATE/question.md`

## Success Metrics

- [ ] Issue templates created
- [ ] Templates guide users to provide necessary info
- [ ] Labels automatically applied

**Priority:** LOW | **Effort:** 2 hours | **Phase:** 1
EOF
)"

echo "✓ Issue #22 created"
echo ""

echo "================================================"
echo "✓ ALL 22 ISSUES CREATED SUCCESSFULLY!"
echo "================================================"
echo ""
echo "Visit your GitHub repository to see all issues:"
echo "https://github.com/SkanderMulder/SpinneR/issues"
echo ""
echo "Next steps:"
echo "1. Review issues and add milestones"
echo "2. Assign issues to yourself or team members"
echo "3. Start with Phase 1 critical issues (#1, #5, #10)"
echo ""
