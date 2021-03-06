#' @export
#' @importFrom rlang .data
#'
#' @title Datetime filtering for MazamaSingleTimeseries objects
#'
#' @param sts MazamaSingleTimeseries \emph{sts} object.
#' @param startdate Desired start datetime (ISO 8601).
#' @param enddate Desired end datetime (ISO 8601).
#' @param timezone Olson timezone used to interpret dates.
#'
#' @description Subsets a MazamaSingleTimeseries object by datetime. This function
#' allows for sub-day filtering as opposed to \code{sts_filterDate()} which
#' always filters to day-boundaries.
#'
#' Datetimes can be anything that is understood by
#' \code{MazamaCoreUtils::parseDatetime()}. For non-\code{POSIXct} values,
#' the recommended format is \code{"YYYY-mm-dd HH:MM:SS"}.
#'
#' Timezone determination precedence assumes that if you are passing in
#' \code{POSIXct} values then you know what you are doing.
#'
#' \enumerate{
#' \item{get timezone from \code{startdate} if it is \code{POSIXct}}
#' \item{use passed in \code{timezone}}
#' \item{get timezone from \code{sts}}
#' }
#'
#' @return A subset of the given \emph{sts} object.
#'
#' @seealso \link{sts_filter}
#' @seealso \link{sts_filterDate}
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' example_sts %>%
#'   sts_filterDatetime(
#'     startdate = "2018-08-08 06:00:00",
#'     enddate = "2018-08-14 18:00:00"
#'   ) %>%
#'   sts_extractData() %>%
#'   head()
#'

sts_filterDatetime <- function(
  sts = NULL,
  startdate = NULL,
  enddate = NULL,
  timezone = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(sts)
  MazamaCoreUtils::stopIfNull(startdate)
  MazamaCoreUtils::stopIfNull(enddate)

  if ( !sts_isValid(sts) )
    stop("Parameter 'sts' is not a valid 'sts' object.")

  if ( sts_isEmpty(sts) )
    stop("Parameter 'sts' has no data.")

  # Remove any duplicate data records
  sts <- sts_distinct(sts)

  # Timezone determination precedence assumes that if you are passing in
  # POSIXct times then you know what you are doing.
  #   1) get timezone from startdate if it is POSIXct
  #   2) use passed in timezone
  #   3) get timezone from sts

  if ( lubridate::is.POSIXt(startdate) ) {
    timezone <- lubridate::tz(startdate)
  } else {
    if ( is.null(timezone) ) {
      timezone <- sts$meta$timezone
    }
  }

  if ( !timezone %in% OlsonNames() )
    stop(sprintf("timezone '%s' is not a valid Olson timezone", timezone))

  # ----- Get the start and end times ------------------------------------------

  timeRange <- MazamaCoreUtils::timeRange(
    starttime = startdate,
    endtime = enddate,
    timezone = timezone,
    unit = "sec",
    ceilingStart = FALSE,
    ceilingEnd = FALSE
  )

  # ----- Subset the 'sts' object ----------------------------------------------

  # NOTE:  When processing lots of data automatically, it is best not to stop()
  # NOTE:  when no data exist for a requested date range. Instead, return a
  # NOTE:  valid 'sts' object with zero rows of data.

  if (timeRange[1] > sts$data$datetime[length(sts$data$datetime)] |
      timeRange[2] < sts$data$datetime[1]) {

    message(sprintf(
      "sts (%s) does not contain requested time range",
      sts$meta$siteName
    ))

    data <- sts$data[0,]

  } else {

    data <-
      sts$data %>%
      dplyr::filter(.data$datetime >= timeRange[1]) %>%
      dplyr::filter(.data$datetime < timeRange[2])

  }

  sts$data <- data

  # ----- Return ---------------------------------------------------------------

  return(sts)

}
