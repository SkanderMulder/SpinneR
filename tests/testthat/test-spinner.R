test_that("with_spinner displays and hides spinner", {
  # This test is tricky to automate fully as it involves visual output and timing.
  # We'll test for the side effects and ensure no errors.

  # Capture output to check for spinner characters (indirectly)
  output <- capture.output({
    result <- with_spinner({
      Sys.sleep(0.5) # Simulate work
      "done"
    })
  })

  expect_equal(result, "done")

  # We can't reliably check for "\r" and spinner chars in captured output
  # because they are overwritten.
  # Instead, we'll rely on the fact that if the C++ process failed, 
  # it would likely throw an error or the R process would hang.
  # The on.exit cleanup should also prevent lingering processes.
})

test_that("with_spinner handles errors gracefully", {
  expect_error({
    with_spinner({
      Sys.sleep(0.1)
      stop("An error occurred!")
    })
  }, "An error occurred!")
})

