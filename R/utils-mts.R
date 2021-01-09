#' @export
#'
#' @name mts_isValid
#' @title Test \emph{mts} object for correct structure
#'
#' @param mts \emph{mts} object
#'
#' @description The \code{mts} is checked for the presence of core
#' \code{meta} and \code{data} columns.
#'
#' Core \code{meta} columns include:
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
#' Core \code{data} columns include:
#'
#' \itemize{
#'   \item{\code{datetime} -- measurement time (UTC)}
#' }
#'
#' @return \code{TRUE} if \code{mts} has the correct structure,
#' \code{FALSE} otherwise.
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' mts_isValid(example_mts)
#'
mts_isValid <- function(
  mts = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(mts)

  # TODO:  Include class name check when this won't break AirSensor or PWFSLSmoke
  # if ( !("mts" %in% class(mts)) ) return(FALSE)

  if ( !("meta" %in% names(mts)) ) return(FALSE)
  if ( !("data" %in% names(mts)) ) return(FALSE)

  requiredNamesMeta <- c(
    'deviceDeploymentID', 'deviceID', 'locationID', 'siteName',
    'longitude', 'latitude', 'elevation',
    'countryCode', 'stateCode', 'timezone'
  )

  if ( !all(requiredNamesMeta %in% names(mts$meta)) )
    return(FALSE)

  # Guarantee that 'data' columns exactly match meta$deviceDeploymentID
  # NOTE:  This is a core guarantee of the 'mts' data model.
  if ( !identical(names(mts$data), c('datetime', mts$meta$deviceDeploymentID)) )
    stop(paste0(
      "Mismatch between mts$meta$monitorID and names(mts$data)\n",
      "Columns in 'data' must be in the same order as rows in 'meta'."
    ))

  if ( any(duplicated(mts$data$datetime)) )
    warning("Duplicate timesteps found in 'mts' object.")

  # Nothing failed so return TRUE
  return(TRUE)

}


#' @export
#'
#' @title Test for an empty \emph{mts} object
#'
#' @param mts \emph{mts} object
#' @return \code{TRUE} if no data exist in \code{mts}, \code{FALSE} otherwise.
#' @description Convenience function for \code{nrow(mts$data) == 0}.
#' This makes for more readable code in functions that need to test for this.
#' @examples
#' library(MazamaTimeSeries)
#'
#' mts_isEmpty(example_mts)
#'
mts_isEmpty <- function(mts) {

  MazamaCoreUtils::stopIfNull(mts)
  # NOTE:  Use minimal validation for improved speed
  if ( !'data' %in% names(mts) || !'data.frame' %in% class(mts$data) )
    stop("Not a valid 'mts' object.")

  return( nrow(mts$data) == 0 )

}


#' @importFrom rlang .data
#' @export
#'
#' @title Retain only distinct data records in mts$data
#'
#' @param mts \emph{mts} object
#'
#' @return A \emph{mts} object with no duplicated data records.
#'
#' @description Two successive steps are used to guarantee that the
#' \code{datetime} axis contains no repeated values:
#'
#' \enumerate{
#' \item{remove any duplicate records}
#' \item{guarantee that rows are in \code{datetime} order}
#' }
#'
mts_distinct <- function(mts) {

  # NOTE:  Use minimal validation for improved speed
  if ( !'data' %in% names(mts) || !'data.frame' %in% class(mts$data) )
    stop("Not a valid 'mts' object.")

  mts$data <-
    mts$data %>%
    dplyr::distinct() %>%
    dplyr::arrange(.data$datetime)

  if ( any(duplicated(mts$data$datetime)) )
    stop("Duplicate timesteps with differing values found in 'mts' object.")

  return( mts )

}


#' @title Extract dataframes from \emph{mts} objects
#'
#' @description
#' These functions are convenient wrappers for extracting the dataframes that
#' comprise a \emph{mts} object. These functions are designed to be useful when
#' manipulating data in a pipeline chain using \code{\%>\%}.
#'
#' Below is a table showing equivalent operations for each function.
#'
#' \tabular{ll}{
#'   \strong{Function} \tab \strong{Equivalent Operation}\cr
#'   \code{mts_extractData(mts)} \tab \code{mts$data}\cr
#'   \code{mts_extractMeta(mts)} \tab \code{mts$meta}
#' }
#'
#' @param mts \emph{mts} object to extract dataframe from.
#'
#' @return A dataframe from the given \emph{mts} object
#'
#' @name mts_extractDataFrame
#' @aliases mts_extractData mts_extractMeta
#'
NULL


#' @export
#' @rdname mts_extractDataFrame
#'
mts_extractData <- function(mts) {

  # NOTE:  Use minimal validation for improved speed
  if ( !'data' %in% names(mts) || !'data.frame' %in% class(mts$data) )
    stop("Not a valid 'mts' object.")

  return(mts$data)

}


#' @export
#' @rdname mts_extractDataFrame
#'
mts_extractMeta <- function(mts) {

  # NOTE:  Use minimal validation for improved speed
  if ( !'meta' %in% names(mts) || !'data.frame' %in% class(mts$meta) )
    stop("Not a valid 'mts' object.")

  return(mts$meta)

}

