% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/basics.R
\name{create_table}
\alias{create_table}
\title{Create a new SQL table}
\usage{
create_table(.data, conn, database, schema, table)
}
\arguments{
\item{.data}{Dataframe to append to the SQL table.}

\item{conn}{A DBIConnection object, as returned by \code{\link[DBI:dbConnect]{DBI::dbConnect()}}.}

\item{database}{Name of database or catalog.}

\item{schema}{Name of schema.}

\item{table}{Name of table.}
}
\value{
TRUE invisibly.
}
\description{
\code{create_table} creates a new SQL table from a dataframe.
It will not append a table if it already exists, nor
will it overwrite an existing table.  Users should
use \code{append_table}, \code{truncate_table} or \code{overwrite_table}
to explicitly perform those actions.
}
\examples{
\dontrun{
create_table(
  .data = my_dataframe,
  conn = my_connection,
  database = "my_database",
  schema = "my_schema",
  table = "my_table"
)
}
}
\seealso{
Other basics: 
\code{\link{append_table}()},
\code{\link{nuke_table}()},
\code{\link{overwrite_table}()},
\code{\link{read_table}()},
\code{\link{survey_table}()},
\code{\link{truncate_table}()}
}
\concept{basics}
