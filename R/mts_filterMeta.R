#' @export
#' @importFrom rlang .data
#'
#' @title General purpose metadata filtering for \emph{mts} objects
#'
#' @param mts \emph{mts} object.
#' @param ... Logical predicates defined in terms of the variables in
#' \code{mts$meta}.
#'
#' @description A generalized metadata filter for \emph{mts} objects to
#' choose rows/cases where conditions are true.  Multiple conditions are
#' combined with \code{&} or separated by a comma. Only rows where the condition
#' evaluates to TRUE are kept. Rows where the condition evaluates to \code{NA}
#' are dropped.
#'
#' @note Filtering is done on variables in \code{mts$meta}.
#'
#' @return A subset of the incoming \code{mts}.
#'
#' @seealso \link{mts_filter}
#' @seealso \link{mts_filterDate}
#' @seealso \link{mts_filterDatetime}
#' @examples
#'
#' library(MazamaTimeSeries)
#'
#' # Filter for all labels with "SCSH"
#' scap <-
#'   example_mts %>%
#'   mts_filterMeta(communityRegion == "Temescal Valley")
#'
#' dplyr::select(scap$meta, ID, label, longitude, latitude, communityRegion)
#'
#' head(scap$data)
#'

mts_filterMeta <- function(
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

  # ----- Filter meta ----------------------------------------------------------

  mts$meta <-
    dplyr::filter(mts$meta, ...)

  # ----- Filter data ----------------------------------------------------------

  # NOTE:  The columns in 'data' must always match the rows in 'meta'

  colNames <- c('datetime', mts$meta$deviceDeploymentID)
  mts$data <-
    dplyr::select(mts$data, dplyr::all_of(colNames))

  # ----- Return ---------------------------------------------------------------

  return(mts)

}
