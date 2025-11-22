# Constants for spinner timing
SPINNER_START_DELAY <- 0.1  # Delay after starting spinner process (seconds)
SPINNER_STOP_DELAY <- 0.1   # Delay after stopping spinner process (seconds)

#' Get path to compiled executable
#' @param name Name of the executable (without extension)
#' @returns Full path to executable
#' @noRd
get_exec_path <- function(name) {
  if (Sys.info()["sysname"] == "Windows") {
    name <- paste0(name, ".exe")
  }
  path <- system.file(file.path("exec", name), package = "SpinneR")

  # Return empty string if not found (system.file returns "" for not found)
  return(path)
}

spinner_semaphore_name <- "/spinner_semaphore"

#' Start the spinner background process
#' @returns TRUE if successful, FALSE otherwise
#' @noRd
start_spinner <- function() {
  spinner_path <- get_exec_path("spinner")

  # Validate executable exists
  if (spinner_path == "" || !file.exists(spinner_path)) {
    warning(
      "Spinner executable not found. ",
      "Please reinstall the SpinneR package."
    )
    return(FALSE)
  }

  # Start spinner process
  result <- tryCatch({
    if (Sys.info()["sysname"] == "Windows") {
      status <- system2(
        spinner_path,
        wait = FALSE,
        stdout = FALSE,
        stderr = FALSE
      )
    } else {
      status <- system2(
        "sh",
        args = c("-c", shQuote(paste0(spinner_path, " &"))),
        wait = FALSE,
        stdout = FALSE,
        stderr = FALSE
      )
    }

    # Give spinner time to initialize
    Sys.sleep(SPINNER_START_DELAY)
    TRUE
  }, error = function(e) {
    warning("Failed to start spinner: ", e$message)
    FALSE
  })

  invisible(result)
}

#' Stop the spinner background process
#' @noRd
stop_spinner <- function() {
  sem_post_helper_path <- get_exec_path("sem_post_helper")

  # Only attempt to stop if helper exists
  if (sem_post_helper_path == "" || !file.exists(sem_post_helper_path)) {
    return(invisible(NULL))
  }

  # Send stop signal to spinner
  tryCatch({
    system2(sem_post_helper_path, stdout = FALSE, stderr = FALSE, wait = TRUE)
  }, error = function(e) {
    # Silently handle errors during cleanup
    NULL
  })

  invisible(NULL)
}

#' Run an expression with a CLI spinner
#'
#' This function evaluates an R expression while displaying a non-blocking,
#' asynchronous spinner in the CLI. The spinner runs in a background process
#' and communicates with the main R process via semaphores.
#'
#' In non-interactive sessions, the spinner is automatically disabled and the
#' expression is evaluated directly.
#'
#' @param expr The R expression to evaluate.
#' @returns The result of the evaluated expression.
#' @export
#' @examplesIf interactive()
#' with_spinner({
#'   Sys.sleep(2) # Simulate a long-running task
#'   "Task complete!"
#' })
with_spinner <- function(expr) {
  # Skip spinner in non-interactive sessions (batch mode, Rscript, etc.)
  if (!interactive()) {
    return(force(expr))
  }

  # Attempt to start spinner
  spinner_started <- start_spinner()

  # Always ensure spinner cleanup, even if it didn't start successfully
  on.exit({
    if (spinner_started) {
      stop_spinner()
      Sys.sleep(SPINNER_STOP_DELAY)
    }
  }, add = TRUE)

  # Evaluate expression and return result
  result <- force(expr)
  return(result)
}
