#'
#' @docType package
#' @name MazamaTimeSeries
#' @title Core Functionality for Environmental Time Series
#' @description Utility functions for working with environmental time
#' series data from known locations. The compact data model is structured as a
#' list with two dataframes. A 'meta' dataframe contains spatial metadata
#' associated with known locations. A 'data' dataframe contains a 'datetime'
#' column followed by measurements made at each time.

NULL

# ----- Internal Data -------------------------------------------------

#' requiredMetaNames
#'
#' @export
#' @docType data
#' @name requiredMetaNames
#' @title Required columns for the 'meta' dataframe
#' @format A vector with 10 elements
#' @description The 'meta' dataframe found in \emph{sts} and \emph{mts} objects
#' is required to have a minimum set of information for proper functioning of
#' the package. The names of those columns are specified in
#' \code{requiredMetaNames}.

requiredMetaNames <- c(
  "deviceDeploymentID",
  "deviceID",
  "locationID",
  "locationName",
  "longitude",
  "latitude",
  "elevation",
  "countryCode",
  "stateCode",
  "timezone"
)

