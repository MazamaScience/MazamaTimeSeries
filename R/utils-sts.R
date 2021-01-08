#' @export
#'
#' @name sts_isSts
#' @title Test \emph{sts_timeseries} object for correct structure
#'
#' @param sts \emph{sts_timeseries} object
#'
#' @description The \code{sts} is checked for the presence of core
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
#' @return \code{TRUE} if \code{sts} has the correct structure,
#' \code{FALSE} otherwise.
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' sts_isSts(example_sts)
#'
sts_isSts <- function(
  sts = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(sts)

  # TODO:  Include class name check when this won't break AirSensor or RAWSmet
  # if ( !("sts_timeseries" %in% class(sts)) ) return(FALSE)

  if ( !("meta" %in% names(sts)) ) return(FALSE)
  if ( !("data" %in% names(sts)) ) return(FALSE)

  requiredNamesMeta <- c(
    'deviceDeploymentID', 'deviceID', 'locationID', 'siteName',
    'longitude', 'latitude', 'elevation',
    'countryCode', 'stateCode', 'timezone'
  )

  if ( !all(requiredNamesMeta %in% names(sts$meta)) )
    return(FALSE)

  requiredNamesData <- c(
    'datetime'
  )

  if ( !all(requiredNamesData %in% names(sts$data)) )
    return(FALSE)

  if ( any(duplicated(sts$data$datetime)) )
    warning("Duplicate timesteps found in 'sts_timeseries' object.")

  # Nothing failed so return TRUE
  return(TRUE)

}


#' @export
#'
#' @title Test for an empty \emph{sts} object
#'
#' @param sts \emph{sts} object
#' @return \code{TRUE} if no data exist in \code{sts}, \code{FALSE} otherwise.
#' @description Convenience function for \code{nrow(sts$data) == 0}.
#' This makes for more readable code in functions that need to test for this.
#' @examples
#' library(MazamaTimeSeries)
#'
#' sts_isEmpty(example_sts)
#'
sts_isEmpty <- function(sts) {
  MazamaCoreUtils::stopIfNull(sts)
  # NOTE:  Use minimal validation
  if ( !'data' %in% names(sts) || !'data.frame' %in% class(sts$data) )
    stop("Not a valid 'sts' object.")

  return( nrow(sts$data) == 0 )
}


