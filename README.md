
<!-- README.md is generated from README.Rmd. Please edit that file -->

# squeal

<!-- badges: start -->
<!-- badges: end -->

`squeal` makes working with the DPH SQL servers a breeze. There are
basic functions for the most common tasks and domain-specific wrappers
that make working with `DPH_ODP`, various facts and dimensions easier,
faster to program and safer to execute.

## Installation

You can install the development version of sql like so:

``` r
# remotes::install(
# https://github.com/asenetcky-r-pkgs/squeal.git
# git = "external")
```

``` r
library(squeal)
```

## Basics

`squeal` has the basics but with checks built in to ensure developers
can be as safe as reasonably expected.

``` r

conn <- dbplyr::simulate_mssql()
database <- "fake_database"
schema <- "fake_schema"
table <- "fake_table"

important_data <-
  dplyr::tibble(
    col1 = 1:10,
    col2 = 1:10,
    col3 = 1:10
  )

# Survey a table
# Grab basic information about the table from the comfort of your IDE
survey_table(
  conn,
  database,
  schema,
  table
)

# Create a table
create_table(
  important_data,
  conn,
  database,
  schema,
  table
)


# Read a table
read_table(
  conn,
  database,
  schema,
  table,
  lazy = FALSE # set TRUE for lazily-evaluated tables!
)

# Append to a table
append_table(
  important_data,
  conn,
  database,
  schema,
  table
)

# Truncate a table
truncate_table(
  conn,
  database,
  schema,
  table
)

# Drop a table
nuke_table(
  conn,
  database,
  schema,
  table
)
```
