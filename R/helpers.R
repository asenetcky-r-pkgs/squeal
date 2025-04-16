data_or_exit_early <- function(.data) {
  if (nrow(.data) == 0) {
    return(invisible())
  }
  invisible(TRUE)
}

#' Helper function to assign list elements into global environment
#'
#' @description
#' This function is a wrapper around `list2env` that assigns the every object in
#' the list to the global environment as individual objects.
#'
#' This function is useful for loading dimension tables into the global
#' environment as individual dataframes or breaking down the prelude and pulling
#' it into the global environment for inspection.
#'
#' @param x list object.
#'
#' @returns The global environment invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' mylist <- dplyr::lst(
#'   table1 = mtcars,
#'   table2 = mtcars,
#'   table3 = mtcars
#' )
#'
#' assign_list_globally(mylist)
#' }
assign_list_globally <- function(x) {
  # check user input
  checkmate::assert_list(x)

  # load list to global environment
  list2env(x, .GlobalEnv) |>
    invisible()
}
