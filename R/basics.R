#' Append a SQL table
#'
#' `append_table` appends a dataframe to a SQL table.
#'
#' @param .data Dataframe to append to the SQL table.
#' @inheritParams read_table
#' @family basics
#'
#' @returns A scalar numeric.
#' @export
#'
#' @examples
#' \dontrun{
#' append_table(
#'   .data = my_dataframe,
#'   conn = my_connection,
#'   database = "my_database",
#'   schema = "my_schema",
#'   table = "my_table"
#' )
#' }
append_table <- function(
  .data,
  conn,
  database,
  schema,
  table
) {
  table_target <-
    check_connection(
      conn,
      database,
      schema,
      table
    )

  succor::assert_dataframe_with_data(.data)

  DBI::dbAppendTable(
    conn,
    name = table_target,
    value = .data
  )
}

#' Truncate a SQL table
#'
#' `truncate_table` removes all rows from a SQL table but leaves the table
#' structure and identity intact.
#'
#' @inheritParams read_table
#' @family basics
#'
#' @returns A scalar numeric that specifies the number of rows affected by the
#'   truncate command.
#' @export
#'
#' @examples
#' \dontrun{
#' truncate_table(
#'   conn = my_connection,
#'   database = "my_database",
#'   schema = "my_schema",
#'   table = "my_table"
#' )
#' }
truncate_table <- function(
  conn,
  database,
  schema,
  table
) {
  # validate user input
  check_connection(
    conn,
    database,
    schema,
    table
  )

  # truncate statement
  truncate_statement <- NULL
  truncate_statement <-
    paste(
      "truncate table",
      paste(
        # ident isn't strictly necessary but
        # I need to get rid of that check note
        dbplyr::ident(database),
        dbplyr::ident(schema),
        dbplyr::ident(table),
        sep = "."
      )
    ) |>
    dplyr::sql()

  # truncate command
  DBI::dbExecute(conn, statement = truncate_statement)
}


#' Survey information about a SQL table
#'
#' `survey_table` returns a tibble with information about the target SQL table.
#'
#' @inheritParams read_table
#' @family basics
#'
#' @return Tibble with information about the target table.
#' @export
#'
#' @examples
#' \dontrun{
#' survey_table(
#'   conn = my_connection,
#'   database = "my_database",
#'   schema = "my_schema",
#'   table = "my_table"
#' )
#' }
survey_table <- function(
  conn,
  database,
  schema,
  table
) {
  # set global bindings
  table_catalog <- table_schema <- table_name <- NULL

  # check user inputs
  check_connection(
    conn,
    database,
    schema,
    table
  )

  ## table snapshot statement
  snapshot_statement <-
    dplyr::sql(
      paste0("select * from ", database, ".information_schema.columns")
    )

  ## snapshot
  DBI::dbGetQuery(
    conn = conn,
    statement = snapshot_statement
  ) |>
    dplyr::as_tibble() |>
    succor::rename_with_stringr() |>
    dplyr::filter(
      stringr::str_to_lower(table_catalog) == stringr::str_to_lower(database) &
        stringr::str_to_lower(table_schema) == stringr::str_to_lower(schema) &
        stringr::str_to_lower(table_name) == stringr::str_to_lower(table)
    )
}

#' Read all data from a SQL Table
#'
#' Read all rows of data from a SQL table as either a dataframe
#' stored in memory or as a lazy tibble.
#'
#' @param conn A DBIConnection object, as returned by [`DBI::dbConnect()`].
#' @param database Name of database or catalog.
#' @param schema Name of schema.
#' @param table Name of table.
#' @param lazy Bool with default value `FALSE` indicating a tibble in memory
#'   will be returned to the user. `TRUE` specifies that a lazy tibble will be
#'   returned.
#'
#' @return Tibble or lazy tibble.
#' @family basics
#' @export
#'
#' @examples
#' \dontrun{
#' read_table(
#'   conn = my_connection,
#'   database = "my_database",
#'   schema = "my_schema",
#'   table = "my_table",
#'   lazy = FALSE
#' )
#' }
read_table <- function(
  conn,
  database,
  schema,
  table,
  lazy = FALSE
) {
  # table to read from SQL
  table_target <-
    check_connection(
      conn,
      database,
      schema,
      table
    )

  table_or_lazy(table_target, conn, lazy)
}


#' Create a new SQL table
#'
#' `create_table` creates a new SQL table from a dataframe.
#' It will not append a table if it already exists, nor
#' will it overwrite an existing table.  Users should
#' use `append_table`, `truncate_table` or `overwrite_table`
#' to explicitly perform those actions.
#'
#' @inheritParams append_table
#'
#' @returns TRUE invisibly.
#' @export
#'
#' @family basics
#'
#' @examples
#' \dontrun{
#' create_table(
#'   .data = my_dataframe,
#'   conn = my_connection,
#'   database = "my_database",
#'   schema = "my_schema",
#'   table = "my_table"
#' )
#' }
create_table <- function(
  .data,
  conn,
  database,
  schema,
  table
) {
  table_target <-
    make_table_target(
      conn,
      database,
      schema,
      table
    )

  succor::assert_dataframe_with_data(.data)

  DBI::dbWriteTable(
    conn,
    name = table_target,
    value = .data
  )
}

#' Drop a SQL Table
#'
#' @inheritParams truncate_table
#'
#' @family basics
#'
#' @returns TRUE invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' nuke_table(
#'   conn = my_connection,
#'   database = "my_database",
#'   schema = "my_schema",
#'   table = "my_table"
#' )
#' }
nuke_table <- function(
  conn,
  database,
  schema,
  table
) {
  # validate user input
  table_target <-
    check_connection(
      conn,
      database,
      schema,
      table
    )

  DBI::dbRemoveTable(
    conn,
    table_target
  )
}

## helpers
check_connection <- function(conn, database, schema, table) {
  # check arguments and make target
  table_target <-
    make_table_target(
      conn,
      database,
      schema,
      table
    )

  # check existence
  if (!DBI::dbExistsTable(conn = conn, name = table_target)) {
    rlang::abort("Table target does not exist.")
  }

  invisible(table_target)
}

make_table_target <- function(conn, database, schema, table) {
  # check arguments and/or fail immediately
  checkmate::assert(
    checkmate::check_class(database, "character"),
    checkmate::check_class(schema, "character"),
    checkmate::check_class(table, "character"),
    checkmate::check_class(conn, "DBIConnection"),
    combine = "and"
  )

  # make Id
  make_dbi_id(
    database,
    schema,
    table
  )
}

make_dbi_id <- function(database, schema, table) {
  DBI::Id(
    catalog = database,
    schema = schema,
    table = table
  )
}

table_or_lazy <- function(table_target, conn, lazy) {
  table <-
    dplyr::tbl(
      src = conn,
      table_target
    ) |>
    dplyr::select(
      !dplyr::starts_with(
        c("created", "modified"),
        ignore.case = TRUE
      )
    )

  if (!lazy) table <- dplyr::collect(table)
  table
}

#' Truncate and Append a SQL table - Preserving Structure
#'
#' Truncate and append data to a SQL table without losing
#' SQL identities and without changing the table structure.
#'
#' @inheritParams append_table
#'
#' @family basics
#'
#'
#' @returns A scalar numeric.
#' @export
#'
#' @examples
#' \dontrun{
#' overwrite_table(
#'   .data = my_dataframe,
#'   conn = my_connection,
#'   database = "my_database",
#'   schema = "my_schema",
#'   table = "my_table"
#' )
#' }
overwrite_table <- function(
  .data,
  conn,
  database,
  schema,
  table
) {
  succor::assert_dataframe_with_data(.data)
  truncate_table(conn, database, schema, table)
  append_table(.data, conn, database, schema, table)
}
