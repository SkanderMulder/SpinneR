#' @importFrom tools file_ext
#' @noRd
get_exec_path <- function(name) {
  if (Sys.info()["sysname"] == "Windows") {
    name <- paste0(name, ".exe")
  }
  system.file(file.path("exec", name), package = "SpinneR")
}

spinner_semaphore_name <- "/spinner_semaphore"

#' @noRd
start_spinner <- function() {
  spinner_path <- get_exec_path("spinner")
  if (Sys.info()["sysname"] == "Windows") {
    system2(spinner_path, wait = FALSE)
  } else {
    system2("sh", args = c("-c", shQuote(paste0(spinner_path, " &"))), wait = FALSE)
  }
  Sys.sleep(0.1)
  invisible(NULL)
}

#' @noRd
stop_spinner <- function() {
  sem_post_helper_path <- get_exec_path("sem_post_helper")
  system2(sem_post_helper_path, stdout = "", stderr = "", wait = TRUE)
}

#' Run an expression with a CLI spinner
#'
#' This function evaluates an R expression while displaying a non-blocking,
#' asynchronous spinner in the CLI. The spinner runs in a background process
#' and communicates with the main R process via semaphores.
#'
#' @param expr The R expression to evaluate.
#' @return The result of the evaluated expression.
#' @export
#' @examples
#' \dontrun{
#' with_spinner({
#'   Sys.sleep(3) # Simulate a long-running task
#'   "Task complete!"
#' })
#' }
with_spinner <- function(expr) {
  start_spinner()
  on.exit({
    stop_spinner()
    Sys.sleep(0.1)
  }, add = TRUE)

  result <- force(expr)
  return(result)
}
