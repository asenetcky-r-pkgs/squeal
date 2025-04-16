test_that("survey_table errors on fake table", {
  conn <- dbplyr::simulate_mssql()
  database <- "fake"
  schema <- "fake"
  table <- "fake"

  expect_error(
    survey_table(
      conn,
      database,
      schema,
      "NOTHINGISREAL"
    )
  )
})


test_that("read_table errors on fake table", {
  conn <- dbplyr::simulate_mssql()
  database <- "fake"
  schema <- "fake"
  table <- "fake"

  # fake table
  expect_error(
    read_table(
      conn,
      database,
      schema,
      "NOTHINGISREAL"
    )
  )
})
