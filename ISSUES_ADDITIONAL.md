# SpinneR Additional Enhancement Issues

Quick-win features and smaller enhancements to boost usability and adoption.

---

## Issue #13: Add Success/Failure Indicators on Completion

**Labels:** `enhancement`, `user-experience`, `quick-win`

**Category:** Feature Enhancement

### Description

Automatically display a success (✓) or failure (✗) indicator when the spinner completes, based on whether the expression succeeded or threw an error.

### Current State

Spinner just disappears when done, providing no visual confirmation of success/failure.

### Proposed API

```r
# Automatic success indicator
result <- with_spinner(
  { process_data() },
  show_result = TRUE  # Default: FALSE for backward compatibility
)
# Output: ✓ Done (0.5s)

# Automatic failure indicator
tryCatch(
  with_spinner(
    { stop("Error!") },
    show_result = TRUE
  ),
  error = function(e) NULL
)
# Output: ✗ Failed (0.2s)

# Custom success/failure messages
with_spinner(
  { process_data() },
  success_message = "Processing complete!",
  failure_message = "Processing failed!",
  show_result = TRUE
)
```

### Implementation

```r
# R/spinner.R
with_spinner <- function(expr,
                         show_result = FALSE,
                         success_symbol = "\u2713",  # ✓
                         failure_symbol = "\u2717",  # ✗
                         success_message = "Done",
                         failure_message = "Failed",
                         show_timing = TRUE,
                         ...) {
  if (!interactive()) {
    return(force(expr))
  }

  spinner_started <- start_spinner(...)
  start_time <- Sys.time()

  on.exit({
    if (spinner_started) {
      stop_spinner()

      if (show_result) {
        elapsed <- difftime(Sys.time(), start_time, units = "secs")

        if (exists("spinner_error")) {
          # Failed
          symbol <- cli::col_red(failure_symbol)
          msg <- failure_message
        } else {
          # Success
          symbol <- cli::col_green(success_symbol)
          msg <- success_message
        }

        if (show_timing) {
          cat(sprintf("%s %s (%.1fs)\n", symbol, msg, elapsed))
        } else {
          cat(sprintf("%s %s\n", symbol, msg))
        }
      }
    }
  }, add = TRUE)

  # Evaluate with error tracking
  result <- tryCatch(
    {
      force(expr)
    },
    error = function(e) {
      spinner_error <<- e
      stop(e)
    }
  )

  result
}
```

### Success Metrics

- [ ] Configurable success/failure indicators
- [ ] Optional timing display
- [ ] Backward compatible (default: no result indicator)
- [ ] Color support via cli
- [ ] Tests for success and failure cases

---

## Issue #14: Add Spinner Pause/Resume Functionality

**Labels:** `enhancement`, `feature`

**Category:** Feature Enhancement

### Description

Allow users to pause and resume spinners programmatically. Useful for long-running tasks with intermediate user interactions.

### Use Cases

```r
# Pause for user input
with_spinner({
  data <- load_data()

  pause_spinner()
  user_choice <- readline("Continue processing? (y/n): ")
  resume_spinner()

  if (user_choice == "y") {
    process_data(data)
  }
})

# Pause during print statements
with_spinner({
  for (i in 1:10) {
    process_step(i)

    if (i %% 3 == 0) {
      pause_spinner()
      cat(sprintf("Checkpoint: %d/10 complete\n", i))
      resume_spinner()
    }
  }
})
```

### Implementation

Use semaphore signaling to pause/resume the C++ spinner process.

### Success Metrics

- [ ] `pause_spinner()` and `resume_spinner()` functions
- [ ] Nested pause/resume support
- [ ] Tests for pause/resume behavior

---

## Issue #15: Create RStudio Addins for Common Tasks

**Labels:** `enhancement`, `rstudio`, `user-experience`

**Category:** Developer Experience

### Description

Create RStudio addins for common SpinneR operations, making it easier to wrap code in spinners via GUI.

### Proposed Addins

1. **Wrap Selection in Spinner**
   - Select code in RStudio
   - Run addin
   - Code wrapped in `with_spinner({ ... })`

2. **Insert Spinner Template**
   - Insert spinner code template at cursor

3. **Diagnose SpinneR**
   - Run `SpinneR::diagnose()` in console

4. **Cleanup Resources**
   - Run `SpinneR::cleanup_resources()` from menu

### Implementation

Create `inst/rstudio/addins.dcf`:

```dcf
Name: Wrap in Spinner
Description: Wrap selected code in with_spinner()
Binding: wrap_selection_in_spinner
Interactive: false

Name: Insert Spinner Template
Description: Insert spinner code template
Binding: insert_spinner_template
Interactive: false

Name: Diagnose SpinneR
Description: Run SpinneR diagnostics
Binding: run_diagnose
Interactive: false

Name: Cleanup Resources
Description: Clean up orphaned spinner resources
Binding: cleanup_resources_addin
Interactive: false
```

Create `R/addins.R`:

```r
#' Wrap selected code in spinner
#' @keywords internal
wrap_selection_in_spinner <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$text

  if (nchar(selection) == 0) {
    rstudioapi::showDialog(
      "No Selection",
      "Please select code to wrap in spinner."
    )
    return(invisible(NULL))
  }

  # Wrap in spinner
  wrapped <- sprintf("with_spinner({\n%s\n})", selection)

  # Replace selection
  rstudioapi::modifyRange(
    context$selection[[1]]$range,
    wrapped
  )
}

#' Insert spinner template
#' @keywords internal
insert_spinner_template <- function() {
  template <- 'with_spinner({\n  # Your code here\n  Sys.sleep(2)\n  "Done!"\n})'

  rstudioapi::insertText(template)
}

#' Run diagnostics addin
#' @keywords internal
run_diagnose <- function() {
  diagnose()
}

#' Cleanup resources addin
#' @keywords internal
cleanup_resources_addin <- function() {
  result <- rstudioapi::showQuestion(
    "Cleanup Resources",
    "This will remove orphaned spinner processes and semaphores. Continue?",
    "Yes",
    "No"
  )

  if (result) {
    cleanup_resources()
    rstudioapi::showDialog(
      "Cleanup Complete",
      "SpinneR resources have been cleaned up."
    )
  }
}
```

### Success Metrics

- [ ] 4 RStudio addins created
- [ ] Addins work in RStudio IDE
- [ ] Documented in README and vignette

---

## Issue #16: Support Spinner in Rmarkdown/Quarto Documents

**Labels:** `enhancement`, `rmarkdown`, `documentation`

**Category:** Feature Enhancement

### Description

Enable spinners in R Markdown and Quarto documents, with smart detection for knitting vs interactive sessions.

### Current Behavior

Spinners don't work well in Rmd because:
- `interactive()` returns FALSE during knitting
- Terminal output not visible in rendered documents
- Need alternative representation

### Proposed Solution

1. **During interactive execution:** Show spinner normally
2. **During knitting:** Show progress via knitr hooks

```r
# Auto-detect and adapt
with_spinner({
  long_computation()
})

# In interactive mode: Shows spinner
# During knitting: Shows "Processing..." message
# In rendered doc: Shows "[Computation completed in 2.3s]"
```

### Implementation

```r
# R/rmarkdown.R

#' Check if running in knitr
#' @noRd
in_knitr <- function() {
  isTRUE(getOption("knitr.in.progress"))
}

#' Spinner for Rmarkdown/Quarto
#'
#' @param expr Expression to evaluate
#' @param knitr_message Message to show during knitting
#' @export
with_spinner_rmd <- function(expr, knitr_message = "Processing...") {
  if (in_knitr()) {
    # Show message for knitting
    knitr::knit_print(knitr_message)

    start_time <- Sys.time()
    result <- force(expr)
    elapsed <- difftime(Sys.time(), start_time, units = "secs")

    knitr::knit_print(
      sprintf("[Completed in %.1fs]", elapsed)
    )

    return(result)
  } else {
    # Regular spinner for interactive
    with_spinner(expr)
  }
}
```

### Knitr Hook Integration

```r
# R/hooks.R

#' Set up knitr hooks for SpinneR
#' @export
setup_spinner_hooks <- function() {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    return(invisible(NULL))
  }

  # Hook to show spinner status in rendered output
  knitr::knit_hooks$set(
    spinner = function(before, options, envir) {
      if (before) {
        paste0("**Processing:**", options$spinner.message, "\n\n")
      } else {
        paste0("\n\n**✓ Complete**\n\n")
      }
    }
  )
}
```

Usage in Rmd:

````md
```{r, spinner=TRUE, spinner.message="Loading data"}
with_spinner_rmd({
  data <- read.csv("large_file.csv")
  process(data)
})
```
````

### Success Metrics

- [ ] Works in interactive Rmd execution
- [ ] Graceful handling during knitting
- [ ] knitr hooks for rendered output
- [ ] Documented with Rmd example vignette

---

## Issue #17: Add Shiny Integration for Server-Side Progress

**Labels:** `enhancement`, `shiny`, `integration`

**Category:** Ecosystem Integration

### Description

Create Shiny-specific functions to display spinner on the client while server computation runs.

### Proposed API

```r
# Shiny server
library(shiny)
library(SpinneR)

server <- function(input, output, session) {
  observeEvent(input$run_analysis, {
    # Show spinner in UI
    spinner_show("my_spinner", message = "Analyzing data...")

    # Run computation
    result <- with_spinner({
      heavy_computation(input$data)
    })

    # Update UI with result
    output$result <- renderPlot(result)

    # Hide spinner
    spinner_hide("my_spinner")
  })
}

# Shiny UI
ui <- fluidPage(
  actionButton("run_analysis", "Run Analysis"),
  spinner_output("my_spinner"),  # Spinner placeholder
  plotOutput("result")
)

shinyApp(ui, server)
```

### Integration with `promises` and `future`

```r
library(promises)
library(future)

server <- function(input, output, session) {
  observeEvent(input$run, {
    spinner_show("async_spinner")

    future({ heavy_computation() }) %...>% {
      output$result <- renderText(.)
    } %...>% {
      spinner_hide("async_spinner")
    }
  })
}
```

### Implementation

```r
# R/shiny.R

#' Create spinner output in Shiny UI
#' @export
spinner_output <- function(id, message = "Loading...") {
  shiny::tagList(
    shiny::tags$div(
      id = id,
      class = "spinner-container",
      style = "display: none;",
      shiny::tags$span(class = "spinner-icon"),
      shiny::tags$span(class = "spinner-message", message)
    )
  )
}

#' Show spinner in Shiny
#' @export
spinner_show <- function(id, message = NULL, session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(message)) {
    session$sendCustomMessage("spinner-update-message", list(id = id, message = message))
  }

  session$sendCustomMessage("spinner-show", list(id = id))
}

#' Hide spinner in Shiny
#' @export
spinner_hide <- function(id, session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("spinner-hide", list(id = id))
}
```

JavaScript handler (`inst/www/spinner.js`):

```javascript
Shiny.addCustomMessageHandler('spinner-show', function(data) {
  $('#' + data.id).show();
});

Shiny.addCustomMessageHandler('spinner-hide', function(data) {
  $('#' + data.id).hide();
});

Shiny.addCustomMessageHandler('spinner-update-message', function(data) {
  $('#' + data.id + ' .spinner-message').text(data.message);
});
```

### Success Metrics

- [ ] Shiny UI components for spinner
- [ ] Server-side show/hide functions
- [ ] Integration with `promises`/`future`
- [ ] Example Shiny app in vignettes

---

## Issue #18: Create Logo Variants and Hex Sticker

**Labels:** `design`, `branding`, `documentation`

**Category:** Documentation & Discoverability

### Description

Create professional logo variants and a hex sticker for branding, stickers, and social media.

### Deliverables

1. **Hex Sticker** (`man/figures/logo.png`)
   - Standard R hex sticker format
   - Spinning icon/animation theme
   - "SpinneR" text
   - R colors (blue/grey palette)

2. **Logo Variants**
   - `man/figures/logo-square.png` (512x512 for icons)
   - `man/figures/logo-wide.png` (for headers)
   - `man/figures/logo-white.png` (for dark backgrounds)

3. **Social Media Sizes**
   - Twitter/X card (1200x628)
   - GitHub social preview (1280x640)

### Design Elements

- Spinning arrow/circle motif
- R programming colors (blue: #276DC3, grey: #7A7A7A)
- Clean, modern typography
- Recognizable at small sizes

### Tools

- [hexSticker R package](https://github.com/GuangchuangYu/hexSticker)
- Inkscape or Adobe Illustrator
- Online hex sticker generator

### Example Code

```r
library(hexSticker)
library(ggplot2)

# Create spinning icon
spinner_icon <- ggplot() +
  geom_polygon(
    aes(x = cos(seq(0, 2*pi, length.out = 8)),
        y = sin(seq(0, 2*pi, length.out = 8))),
    fill = "#276DC3",
    color = "#7A7A7A",
    size = 2
  ) +
  theme_void()

# Generate hex sticker
sticker(
  spinner_icon,
  package = "SpinneR",
  p_size = 20,
  p_color = "#276DC3",
  s_x = 1,
  s_y = 0.75,
  s_width = 0.6,
  s_height = 0.6,
  h_fill = "#FFFFFF",
  h_color = "#276DC3",
  filename = "man/figures/logo.png"
)
```

### Success Metrics

- [ ] Hex sticker created
- [ ] Logo variants in multiple sizes
- [ ] Used in README, pkgdown, social media
- [ ] Print-ready version for physical stickers

---

## Issue #19: Add Spinner History/Logging for Debugging

**Labels:** `enhancement`, `debugging`, `logging`

**Category:** Developer Experience

### Description

Keep a history of spinner invocations for debugging and performance analysis.

### Proposed API

```r
# Enable spinner history
options(SpinneR.track_history = TRUE)

# Run some operations
with_spinner({ Sys.sleep(1) })
with_spinner({ Sys.sleep(2) })
with_spinner({ Sys.sleep(0.5) })

# View history
history <- get_spinner_history()
print(history)
#   id start_time          end_time            duration status
# 1  1 2024-01-15 10:00:00 2024-01-15 10:00:01     1.00 success
# 2  2 2024-01-15 10:00:02 2024-01-15 10:00:04     2.00 success
# 3  3 2024-01-15 10:00:05 2024-01-15 10:00:05.5   0.50 success

# Analyze performance
summary_spinner_history()
# Total spinners: 3
# Total time: 3.5s
# Average duration: 1.17s
# Success rate: 100%

# Clear history
clear_spinner_history()
```

### Implementation

```r
# R/history.R

spinner_history <- new.env(parent = emptyenv())
spinner_history$records <- list()
spinner_history$counter <- 0

#' Record spinner invocation
#' @noRd
record_spinner <- function(start_time, end_time, status, error = NULL) {
  if (!getOption("SpinneR.track_history", FALSE)) {
    return(invisible(NULL))
  }

  spinner_history$counter <- spinner_history$counter + 1

  record <- list(
    id = spinner_history$counter,
    start_time = start_time,
    end_time = end_time,
    duration = as.numeric(difftime(end_time, start_time, units = "secs")),
    status = status,
    error = error
  )

  spinner_history$records[[length(spinner_history$records) + 1]] <- record

  invisible(NULL)
}

#' Get spinner history
#' @export
get_spinner_history <- function() {
  if (length(spinner_history$records) == 0) {
    return(data.frame(
      id = integer(0),
      start_time = character(0),
      end_time = character(0),
      duration = numeric(0),
      status = character(0),
      error = character(0)
    ))
  }

  do.call(rbind, lapply(spinner_history$records, as.data.frame))
}

#' Summarize spinner history
#' @export
summary_spinner_history <- function() {
  history <- get_spinner_history()

  if (nrow(history) == 0) {
    cat("No spinner history recorded.\n")
    return(invisible(NULL))
  }

  cat("Spinner History Summary\n")
  cat("=======================\n\n")
  cat("Total spinners:", nrow(history), "\n")
  cat("Total time:", sprintf("%.2fs", sum(history$duration)), "\n")
  cat("Average duration:", sprintf("%.2fs", mean(history$duration)), "\n")
  cat("Min duration:", sprintf("%.2fs", min(history$duration)), "\n")
  cat("Max duration:", sprintf("%.2fs", max(history$duration)), "\n")
  cat("Success rate:", sprintf("%.1f%%",
    sum(history$status == "success") / nrow(history) * 100), "\n")

  if (any(history$status == "error")) {
    cat("\nErrors:\n")
    errors <- history[history$status == "error", ]
    for (i in 1:nrow(errors)) {
      cat(sprintf("  [%d] %s\n", errors$id[i], errors$error[i]))
    }
  }

  invisible(history)
}

#' Clear spinner history
#' @export
clear_spinner_history <- function() {
  spinner_history$records <- list()
  spinner_history$counter <- 0
  invisible(NULL)
}
```

### Integration into `with_spinner()`

```r
with_spinner <- function(expr, ...) {
  # ... existing code ...

  start_time <- Sys.time()
  status <- "success"
  error_msg <- NULL

  result <- tryCatch(
    {
      force(expr)
    },
    error = function(e) {
      status <<- "error"
      error_msg <<- e$message
      stop(e)
    }
  )

  end_time <- Sys.time()
  record_spinner(start_time, end_time, status, error_msg)

  result
}
```

### Success Metrics

- [ ] History tracking implemented
- [ ] `get_spinner_history()` returns data frame
- [ ] `summary_spinner_history()` provides insights
- [ ] Optional (off by default for privacy)
- [ ] Tests for history tracking

---

## Issue #20: Create Code Coverage Badge and CI Integration

**Labels:** `testing`, `ci`, `quality`

**Category:** Testing & Quality

### Description

Set up automated code coverage reporting with Codecov and add coverage badge to README.

### Implementation Steps

1. **Add Codecov GitHub Action**

Create `.github/workflows/test-coverage.yaml`:

```yaml
on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

name: test-coverage

jobs:
  test-coverage:
    runs-on: ubuntu-latest
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::covr
          needs: coverage

      - name: Test coverage
        run: covr::codecov(quiet = FALSE)
        shell: Rscript {0}
```

2. **Sign up for Codecov**

- Visit https://codecov.io/
- Connect GitHub repository
- Get upload token (if needed)

3. **Add Badge to README**

```md
[![Codecov](https://codecov.io/gh/skandermulder/SpinneR/branch/main/graph/badge.svg)](https://codecov.io/gh/skandermulder/SpinneR)
```

4. **Configure Codecov Settings**

Create `codecov.yml`:

```yaml
coverage:
  status:
    project:
      default:
        target: 80%  # Require 80% coverage
        threshold: 1%  # Allow 1% drop
    patch:
      default:
        target: 80%

comment:
  layout: "reach, diff, flags, files"
  behavior: default
  require_changes: false
```

### Success Metrics

- [ ] Codecov integration working
- [ ] Coverage badge in README
- [ ] Coverage reports on every PR
- [ ] Target: 80%+ coverage

---

## Issue #21: Add Spinner Rate Limiting to Prevent Flicker

**Labels:** `enhancement`, `user-experience`, `performance`

**Category:** Feature Enhancement

### Description

Implement rate limiting to prevent spinner from showing for very short operations (< 100ms), reducing UI flicker.

### Problem

```r
# This flickers annoyingly
for (i in 1:100) {
  with_spinner({ Sys.sleep(0.05) })  # Spinner shows/hides 100 times
}
```

### Solution

Add minimum display time and delay before showing:

```r
with_spinner(
  { fast_operation() },
  min_show_time = 0.5,  # Show for at least 500ms once started
  show_after = 0.2       # Only show if operation takes > 200ms
)
```

### Implementation

```r
# R/spinner.R
with_spinner <- function(expr,
                         min_show_time = 0.0,
                         show_after = 0.0,
                         ...) {
  if (!interactive()) {
    return(force(expr))
  }

  start_time <- Sys.time()
  spinner_started <- FALSE
  spinner_start_time <- NULL

  # Delay showing spinner
  if (show_after > 0) {
    # Evaluate in background, check if still running after delay
    # This requires more complex implementation with futures
  }

  # ... rest of implementation ...

  on.exit({
    if (spinner_started) {
      # Ensure minimum show time
      if (!is.null(spinner_start_time) && min_show_time > 0) {
        elapsed <- as.numeric(difftime(Sys.time(), spinner_start_time, units = "secs"))
        if (elapsed < min_show_time) {
          Sys.sleep(min_show_time - elapsed)
        }
      }

      stop_spinner()
    }
  })

  force(expr)
}
```

### Success Metrics

- [ ] `show_after` parameter delays spinner
- [ ] `min_show_time` prevents quick flicker
- [ ] Smooth UX for varying operation durations

---

## Issue #22: Create GitHub Issue Templates

**Labels:** `documentation`, `community`, `maintenance`

**Category:** Developer Experience

### Description

Create issue templates to help users report bugs and request features effectively.

### Templates to Create

1. **Bug Report** (`.github/ISSUE_TEMPLATE/bug_report.md`)
2. **Feature Request** (`.github/ISSUE_TEMPLATE/feature_request.md`)
3. **Question** (`.github/ISSUE_TEMPLATE/question.md`)

### Bug Report Template

```md
---
name: Bug Report
about: Report a bug or unexpected behavior
title: '[BUG] '
labels: 'bug'
assignees: ''
---

## Bug Description

A clear description of the bug.

## Reproducible Example

```r
library(SpinneR)

# Your code here
with_spinner({
  # ...
})
```

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## System Information

- SpinneR version: [e.g., 0.1.0]
- R version: [e.g., 4.3.1]
- OS: [e.g., Ubuntu 22.04, Windows 11, macOS 14]
- RStudio: [yes/no, version if applicable]

## Diagnostic Output

Please run and paste output of:

```r
SpinneR::diagnose()
```

## Additional Context

Any other relevant information.
```

### Feature Request Template

```md
---
name: Feature Request
about: Suggest a new feature
title: '[FEATURE] '
labels: 'enhancement'
assignees: ''
---

## Feature Description

Clear description of the feature you'd like.

## Use Case

Why is this feature needed? What problem does it solve?

## Proposed API

How should this feature work?

```r
# Example usage
with_spinner(
  { ... },
  new_parameter = value
)
```

## Alternatives Considered

Other approaches you've considered.

## Additional Context

Any other information or mockups.
```

### Success Metrics

- [ ] Issue templates created
- [ ] Templates guide users to provide necessary info
- [ ] Labels automatically applied

---

## Summary of Additional Issues

**Quick Wins (Issues #13-15):**
- Success/failure indicators
- Pause/resume functionality
- RStudio addins

**Ecosystem Integration (Issues #16-17):**
- Rmarkdown/Quarto support
- Shiny integration

**Branding/Marketing (Issues #18, #20):**
- Logo and hex sticker
- Code coverage badge

**Developer Experience (Issues #19, #21-22):**
- Spinner history/logging
- Rate limiting
- Issue templates

These 10 additional issues complement the core 12 issues, providing a comprehensive roadmap to making SpinneR THE spinner package for R.

**Total Issues:** 22 comprehensive, actionable issues
**Estimated Timeline:** 4-6 months for full implementation
**Expected Outcome:** Market-leading spinner package with CRAN presence
