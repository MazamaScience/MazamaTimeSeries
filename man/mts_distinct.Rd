% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-mts.R
\name{mts_distinct}
\alias{mts_distinct}
\title{Retain only distinct data records in mts$data}
\usage{
mts_distinct(mts)
}
\arguments{
\item{mts}{\emph{mts} object}
}
\value{
A \emph{mts} object with no duplicated data records.
}
\description{
Two successive steps are used to guarantee that the
\code{datetime} axis contains no repeated values:

\enumerate{
\item{remove any duplicate records}
\item{guarantee that rows are in \code{datetime} order}
}
}
