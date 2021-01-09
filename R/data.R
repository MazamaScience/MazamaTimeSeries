#' @title Example SingleTimeSeries dataset
#' @format An S3 object composed of "meta" and "data" dataframes.
#' @description The \code{example_sts} dataset provides a quickly loadable
#' version of an \emph{sts} object for practicing and code examples.
#'
#' This dataset was was generated on 2021-01-08 by running:
#'
#' \preformatted{
#' library(AirSensor)
#'
#' example_sts <- example_pat
#' example_sts$meta$elevation <- as.numeric(NA)
#' example_sts$meta$siteName <- example_sts$meta$label
#'
#' save(example_sts, file = "data/example_sts.rda")
#' }
"example_sts"


#' @title Example MultipleTimeSeries dataset
#' @format An S3 object composed of "meta" and "data" dataframes.
#' @description The \code{example_mts} dataset provides a quickly loadable
#' version of a \emph{mts} object for practicing and code examples.
#'
#' This dataset was was generated on 2021-01-09 by running:
#'
#' \preformatted{
#' library(AirSensor)
#'
#' example_mts <- example_sensor
#'
#' save(example_mts, file = "data/example_mts.rda")
#' }
"example_mts"


