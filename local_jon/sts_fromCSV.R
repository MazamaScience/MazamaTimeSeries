#' @export
#' @importFrom rlang .data
#'
#' @title Create a SingleTimeSeries object from a csv file
#'
#' @param csv CSV file.
#' @param dataMapping List mapping CSV column names to \emph{sts} object data
#' column names.
#' @param metaList List of spatial metadata values to be used.
#'
#' @description A CSV file will be parsed and used to create an \emph{sts}
#' object adhering to internal standards.
#'
#' @section Identifying Data
#'
#' In order to stay generic \emph{sts} data model has only a single required
#' column name -- \code{datetime} for the \code{POSIXct} datetime of each record.
#' The \pkg{MazamaTimeSeries} package is agnostic about all other column names
#' allowing any kind of timeseries data to be stored.
#'
#' It is thus incumbent upon users combining data from different sources to
#' develop internal standards for how parameters are named. We recommend using
#' either well known abbreviations or full English names in lowerCamelCase
#' \emph{e.g.}:
#'
#' \itemize{
#'   \item{code{pm25} -- Particulate matter 2.5 microns or less}
#'   \item{code{pm10} -- Particulate matter 10 microns or less}
#'   \item{code{temperature}}
#'   \item{code{humidity}}
#'   \item{code{windSpeed}}
#' }
#'
#' It is up to end users to ensure that all data ingested have the same units.
#'
#' The \code{dataMapping} parameter is a list mapping incoming column names
#' onto internally standardized names. All incoming columns not named in
#' \code{dataMapping} will retain their names. Example:
#'
#' \preformatted{
#' dataMapping <- list(
#'   "time" = "datetime",
#'   "value" = "pm25"
#' )
#' }
#'
#' @section Specifying Metadata
#'
#' The following columns will be created in \code{sts$meta}:
#'
#' \itemize{
#'   \item{\code{deviceDeploymentID} -- unique identifier (see \pkg{MazmaLocationUtils})}
#'   \item{\code{deviceID} -- device identifier}
#'   \item{\code{locationID} -- location identifier (see \pkg{MazmaLocationUtils})}
#'   \item{\code{siteName} -- English language name}
#'   \item{\code{longitude} -- decimal degrees E}
#'   \item{\code{latitude} -- decimal degrees N}
#'   \item{\code{elevation} -- elevation of station in m}
#'   \item{\code{countryCode} -- ISO 3166-1 alpha-2}
#'   \item{\code{stateCode} -- ISO 3166-2 alpha-2}
#'   \item{\code{timezone} -- Olson time zone}
#' }
#'
#' Of these, users are only required to specify \code{deviceID},
#' \code{longitude} and \code{latitude} as all other fields can be derived.
#' However, it is best to provide additional metadata if you have it. This will
#' speed the data ingest process and avoid rare errors in assigning state,
#' country or timezone.
#'
#' Specify metadata by passing in a \code{metaList} object:
#'
#' \preformatted{
#' metaList <- list(
#'   deviceID = "TEST-006",
#'   longitude = -118.2437,
#'   latitude = 34.0500,
#'   countryCode = "US",
#'   stateCode = "CA",
#'   timezone = "America/Los_Angeles"
#' )
#' }
#'
#' Any spatial metadata specified in \code{metaList} will override values
#' found in the CSV file.
#'
#'
#' @return An \emph{sts} object.
#'
sts_fromCSV <- function(
  csv = NULL,
  dataMapping = NULL,
  metaList = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(csv)

  # ----- Parse the CSV file ---------------------------------------------------


  # ----- Return ---------------------------------------------------------------

  return(sts)

}
