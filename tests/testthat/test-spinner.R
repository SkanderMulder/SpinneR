test_that("with_spinner returns correct result", {
  # Test that the result of the expression is returned correctly
  result <- with_spinner({
    Sys.sleep(0.2)
    42
  })
  expect_equal(result, 42)

  # Test with a more complex expression
  result2 <- with_spinner({
    x <- 10
    y <- 20
    x + y
  })
  expect_equal(result2, 30)
})

test_that("with_spinner handles errors gracefully", {
  # Test that errors in the expression are propagated
  expect_error({
    with_spinner({
      Sys.sleep(0.1)
      stop("An error occurred!")
    })
  }, "An error occurred!")

  # Ensure spinner cleanup happens even on error
  # (If cleanup fails, subsequent calls would fail)
  result <- with_spinner({
    Sys.sleep(0.1)
    "success after error"
  })
  expect_equal(result, "success after error")
})

test_that("with_spinner works with different return types", {
  # Test with NULL return
  result <- with_spinner({
    Sys.sleep(0.1)
    NULL
  })
  expect_null(result)

  # Test with list return
  result <- with_spinner({
    list(a = 1, b = 2)
  })
  expect_equal(result, list(a = 1, b = 2))

  # Test with vector return
  result <- with_spinner({
    c(1, 2, 3, 4, 5)
  })
  expect_equal(result, c(1, 2, 3, 4, 5))
})

test_that("with_spinner handles warnings", {
  # Test that warnings in the expression are still shown
  expect_warning({
    result <- with_spinner({
      warning("A warning occurred")
      "done"
    })
  }, "A warning occurred")
})

test_that("with_spinner can be called multiple times", {
  # Test that consecutive calls work correctly
  result1 <- with_spinner({ Sys.sleep(0.1); "first" })
  result2 <- with_spinner({ Sys.sleep(0.1); "second" })
  result3 <- with_spinner({ Sys.sleep(0.1); "third" })

  expect_equal(result1, "first")
  expect_equal(result2, "second")
  expect_equal(result3, "third")
})

test_that("with_spinner handles empty expressions", {
  # Test with an expression that returns nothing (invisible NULL)
  result <- with_spinner({
    x <- 5  # Assignment returns invisibly
  })
  # The result should be 5 (the value assigned)
  expect_equal(result, 5)
})

