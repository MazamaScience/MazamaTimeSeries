#' @export
#' @importFrom rlang .data
#'
#' @title General purpose data filtering for \emph{mts} objects
#'
#' @param mts \emph{mts} object.
#' @param ... Logical predicates defined in terms of the variables in
#' \code{mts$data}.
#'
#' @description A generalized data filter for \emph{mts} objects to
#' choose rows/cases where conditions are true.  Multiple conditions should be
#' combined with \code{&} or separated by a comma. Only rows where the condition
#' evaluates to TRUE are kept. Rows where the condition evaluates to \code{NA}
#' are dropped.
#'
#' @note Filtering is done on variables in \code{mts$data}.
#'
#' @return A subset of the incoming \code{mts}.
#'
#' @seealso \link{mts_filterDate}
#' @seealso \link{mts_filterDatetime}
#' @seealso \link{mts_filterMeta}
#' @examples
#'
#' library(MazamaTimeSeries)
#'
#' # Are there any times when data exceeded 150?
#' sapply(example_mts$data, function(x) { any(x > 150, na.rm = TRUE) })
#'
#' # Filter for all times where da4cadd2d6ea5302_4686 > 150
#' very_unhealthy <-
#'   example_mts %>%
#'   mts_filterData(da4cadd2d6ea5302_4686 > 150)
#'
#' # Show all data
#' dplyr::glimpse(very_unhealthy$data)
#'

mts_filterData <- function(
  mts,
  ...
) {

  # ----- Validate parameters --------------------------------------------------

  # A little involved to catch the case where the user forgets to pass in 'mts'

  result <- try({
    if ( !mts_isValid(mts) )
      stop("First argument is not a valid 'mts' object.")
  }, silent = TRUE)

  if ( class(result) %in% "try-error" ) {
    err_msg <- geterrmessage()
    if ( stringr::str_detect(err_msg, "object .* not found") ) {
      stop(paste0(err_msg, "\n(Did you forget to pass in the 'mts' object?)"))
    }
  }

  if ( mts_isEmpty(mts) )
    stop("Parameter 'mts' has no data.")

  # Remove any duplicate data records
  mts <- mts_distinct(mts)

  # ----- Filter data ----------------------------------------------------------

  mts$data <-
    dplyr::filter(mts$data, ...)

  # ----- Return ---------------------------------------------------------------

  return(mts)

}
