#' @export
#' @importFrom rlang .data
#'
#' @title Trim an \emph{mts} object to full days
#'
#' @param mts \emph{mts} object.
#' @param timezone Olson timezone used to interpret dates.
#'
#' @description Trims the date range of an \emph{mts} object to local time date
#' boundaries which are \emph{within} the range of data. This has the effect
#' of removing partial-day data records at the start and end of the timeseries
#' and is useful when calculating full-day statistics.
#'
#' Day boundaries are calculated using the specified \code{timezone} or, if
#' \code{NULL},  \code{mts$meta$timezone}. Leaving \code{timezone = NULL}, the
#' default, results in "local time" date filtering which is the most
#' common use case.
#'
#' @return A subset of the given \emph{mts} object.
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' UTC_week <- mts_filterDate(
#'   example_mts,
#'   startdate = 20190703,
#'   enddate = 20190706,
#'   timezone = "UTC"
#' )
#'
#' # UTC day boundaries
#' range(UTC_week$data$datetime)
#'
#' # Trim to local time day boundaries
#' local_week <- mts_trimDate(UTC_week)
#' range(local_week$data$datetime)
#'

mts_trimDate <- function(
  mts = NULL,
  timezone = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(mts)

  if ( !mts_isValid(mts) )
    stop("Parameter 'mts' is not a valid 'mts' object.")

  if ( mts_isEmpty(mts) )
    stop("Parameter 'mts' has no data.")

  # Remove any duplicate data records
  mts <- mts_distinct(mts)

  # Use internal function to determine the timezone to use
  timezone <- .determineTimezone(mts, NULL, timezone, verbose = TRUE)

  # ----- Get the start and end times ------------------------------------------

  timeRange <- range(mts$data$datetime)

  # NOTE:  The dateRange() is used to restrict the time range to days that have
  # NOTE:  complete data.
  # NOTE:
  # NOTE:  floor/ceiling the start date depending on whether you are already
  # NOTE:  at the date boundary

  hour <-
    MazamaCoreUtils::parseDatetime(timeRange[1], timezone = timezone) %>%
    lubridate::hour() # hour resolution is good enough to count as an entire day

  if ( hour == 0 ) {
    ceilingStart = FALSE
  } else {
    ceilingStart = TRUE
  }

  dateRange <-
    MazamaCoreUtils::dateRange(
      startdate = timeRange[1],
      enddate = timeRange[2],
      timezone = timezone,
      unit = "sec",
      ceilingStart = ceilingStart, # date boundary *after* the start
      ceilingEnd = FALSE           # date boundary *before* the end
    )

  # ----- Subset the "mts" object ----------------------------------------------

  data <-
    mts$data %>%
    dplyr::filter(.data$datetime >= dateRange[1]) %>%
    dplyr::filter(.data$datetime < dateRange[2])

  mts$data <- data

  # ----- Return ---------------------------------------------------------------

  return(mts)

}
