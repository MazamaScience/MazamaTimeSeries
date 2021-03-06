#' @export
#' @importFrom rlang .data
#'
#' @title Date filtering for MazamaSingleTimeseries objects
#'
#' @param sts MazamaSingleTimeseries \emph{sts} object.
#' @param startdate Desired start datetime (ISO 8601).
#' @param enddate Desired end datetime (ISO 8601).
#' @param days Number of days to include in the filterDate interval.
#' @param weeks Number of weeks to include in the filterDate interval.
#' @param timezone Olson timezone used to interpret dates.
#'
#' @description Subsets a MazamaSingleTimeseries object by date. This function
#' always filters to day-boundaries. For sub-day filtering, use
#' \code{sts_filterDatetime()}.
#'
#' Dates can be anything that is understood by \code{MazamaCoreUtils::parseDatetime()}
#' including either of the following recommended formats:
#'
#' \itemize{
#' \item{\code{"YYYYmmdd"}}
#' \item{\code{"YYYY-mm-dd"}}
#' }
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
#' @note The returned data will run from the beginning of \code{startdate} until
#' the \strong{beginning} of \code{enddate} -- \emph{i.e.} no values associated
#' with \code{enddate} will be returned. The exception being when
#' \code{enddate} is less than 24 hours after \code{startdate}. In that case, a
#' single day is returned.
#'
#' @return A subset of the given \emph{sts} object.
#'
#' @seealso \link{sts_filter}
#' @seealso \link{sts_filterDatetime}
#' @examples
#' library(MazamaTimeSeries)
#'
#' example_sts %>%
#'   sts_filterDate(startdate = 20180808, enddate = 20180815) %>%
#'   sts_extractData() %>%
#'   head()
#'

sts_filterDate <- function(
  sts = NULL,
  startdate = NULL,
  enddate = NULL,
  days = 7,
  weeks = NULL,
  timezone = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(sts)

  if ( !sts_isValid(sts) )
    stop("Parameter 'sts' is not a valid 'sts' object.")

  if ( sts_isEmpty(sts) )
    stop("Parameter 'sts' has no data.")

  # Remove any duplicate data records
  sts <- sts_distinct(sts)

  if ( is.null(startdate) && !is.null(enddate) )
    stop("At least one of 'startdate' or 'enddate' must be specified")

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

  if ( !is.null(weeks) ) {
    days <- weeks * 7
  }

  # NOTE:  MazamaCoreUtils::dateRange() ignores days if both startdate and
  # NOTE:  enddate are provided.
  dateRange <- MazamaCoreUtils::dateRange(
    startdate = startdate,
    enddate = enddate,
    timezone = timezone,
    unit = "sec",
    ceilingEnd = FALSE,
    days = days
  )

  # ----- Subset the 'sts' object ----------------------------------------------

  # NOTE:  When processing lots of data automatically, it is best not to stop()
  # NOTE:  when no data exist for a requested date range. Instead, return a
  # NOTE:  valid 'sts' object with zero rows of data.

  if (dateRange[1] > sts$data$datetime[length(sts$data$datetime)] |
      dateRange[2] < sts$data$datetime[1]) {

    message(sprintf(
      "sts (%s) does not contain requested date range",
      sts$meta$siteName
    ))

    data <- sts$data[0,]

  } else {

    data <-
    sts$data %>%
    dplyr::filter(.data$datetime >= dateRange[1]) %>%
    dplyr::filter(.data$datetime < dateRange[2])

  }

  sts$data <- data

  # ----- Return ---------------------------------------------------------------

  return(sts)

}
