#' @export
#' @importFrom rlang .data
#'
#' @title Datetime filtering for \code{mts} objects
#'
#' @param mts \emph{mts} object.
#' @param startdate Desired start datetime (ISO 8601).
#' @param enddate Desired end datetime (ISO 8601).
#' @param timezone Olson timezone used to interpret dates.
#' @param unit Units used to determine time at end-of-day.
#' @param ceilingStart Logical instruction to apply
#'   \code{\link[lubridate]{ceiling_date}} to the \code{startdate} rather than
#'   \code{\link[lubridate]{floor_date}}
#' @param ceilingEnd Logical instruction to apply
#'   \code{\link[lubridate]{ceiling_date}} to the \code{enddate} rather than
#'   \code{\link[lubridate]{floor_date}}
#'
#' @description Subsets a \code{mts} object by datetime. This function
#' allows for sub-day filtering as opposed to \code{mts_filterDate()} which
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
#' \item{get timezone from \code{mts}}
#' }
#'
#' @return A subset of the given \emph{mts} object.
#'
#' @seealso \link{mts_filter}
#' @seealso \link{mts_filterDate}
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' example_mts %>%
#'   mts_filterDatetime(
#'     startdate = "2018-08-08 06:00:00",
#'     enddate = "2018-08-14 18:00:00"
#'   ) %>%
#'   mts_extractData() %>%
#'   head()
#'

mts_filterDatetime <- function(
  mts = NULL,
  startdate = NULL,
  enddate = NULL,
  timezone = NULL,
  unit = "sec",
  ceilingStart = FALSE,
  ceilingEnd = FALSE
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(mts)
  MazamaCoreUtils::stopIfNull(startdate)
  MazamaCoreUtils::stopIfNull(enddate)

  if ( !mts_isValid(mts) )
    stop("Parameter 'mts' is not a valid 'mts' object.")

  if ( mts_isEmpty(mts) )
    stop("Parameter 'mts' has no data.")

  # Remove any duplicate data records
  mts <- mts_distinct(mts)

  # Timezone determination precedence assumes that if you are passing in
  # POSIXct times then you know what you are doing.
  #   1) get timezone from startdate if it is POSIXct
  #   2) use passed in timezone
  #   3) get timezone from mts

  if ( lubridate::is.POSIXt(startdate) ) {

    timezone <- lubridate::tz(startdate)

  } else if ( !is.null(timezone) ) {

    # Do nothing

  } else {

    # Handle multiple timezones in 'mts'
    timezoneCount <- length(unique(mts$meta$timezone))

    # Use table(timezone) to find the most common one
    if ( timezoneCount > 1 ) {
      timezoneTable <- sort(table(mts$meta$timezone), decreasing = TRUE)
      timezone <- names(timezoneTable)[1]
      warning(sprintf(
        "Found %d timezones. Only %s will be used.",
        timezoneCount,
        timezone
      ))
    } else {
      timezone <- mts$meta$timezone[1]
    }

  }

  if ( !timezone %in% OlsonNames() )
    stop(sprintf("timezone '%s' is not a valid Olson timezone", timezone))

  # ----- Get the start and end times ------------------------------------------

  timeRange <- MazamaCoreUtils::timeRange(
    starttime = startdate,
    endtime = enddate,
    timezone = timezone,
    unit = unit,
    ceilingStart = ceilingStart,
    ceilingEnd = ceilingEnd
  )

  # ----- Subset the 'mts' object ----------------------------------------------

  # NOTE:  When processing lots of data automatically, it is best not to stop()
  # NOTE:  when no data exist for a requested date range. Instead, return a
  # NOTE:  valid 'mts' object with zero rows of data.

  if (timeRange[1] > mts$data$datetime[length(mts$data$datetime)] |
      timeRange[2] < mts$data$datetime[1]) {

    message(sprintf(
      "mts (%s) does not contain requested time range",
      mts$meta$siteName
    ))

    data <- mts$data[0,]

  } else {

    data <-
      mts$data %>%
      dplyr::filter(.data$datetime >= timeRange[1]) %>%
      dplyr::filter(.data$datetime < timeRange[2])

  }

  mts$data <- data

  # ----- Return ---------------------------------------------------------------

  return(mts)

}
