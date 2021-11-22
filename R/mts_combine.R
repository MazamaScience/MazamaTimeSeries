#' @export
#' @importFrom rlang .data
#'
#' @title Combine multiple \code{mts} objects
#'
#' @param ... Any number of valid \emph{mts} objects.
#'
#' @return A combined \code{mts} object.
#'
#' @description Create a combined \emph{mts} from any number of \emph{mts}
#' objects or from a list of \emph{mts} objects. The resulting \emph{mts}
#' object with contain all \code{deviceDeploymentIDs} found in any incoming
#' \emph{mts} and will have a regular time axis covering the the entire range
#' of incoming data.
#'
#' If incoming time ranges are non-contiguous, the resulting \emph{mts} will
#' have gaps filled with \code{NA} values.
#'
#' An error is generated if the incoming \emph{mts} objects have
#' non-identical metadata for the same \code{deviceDeploymentID}.
#'
#' @note Data are combined with a "latest is best" sensibility where any
#' data overlaps exist. Incoming \emph{mts} objects are ordered based on the
#' time stamp of their last record. Then \code{dplyr::distinct()} is used to
#' remove records with duplicate \code{datetime} fields. Any data records found
#' in "later" \emph{mts} objects are preferentially retained before the data
#' are finally reordered by ascending \code{datetime}.
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' ids1 <- example_mts$meta$deviceDeploymentID[1:5]
#' ids2 <- example_mts$meta$deviceDeploymentID[4:6]
#' ids3 <- example_mts$meta$deviceDeploymentID[8:10]
#'
#' mts1 <-
#'   example_mts %>%
#'   mts_filterMeta(deviceDeploymentID %in% ids1) %>%
#'   mts_filterDate(20190701, 20190703)
#'
#' mts2 <-
#'   example_mts %>%
#'   mts_filterMeta(deviceDeploymentID %in% ids2) %>%
#'   mts_filterDate(20190704, 20190706)
#'
#' mts3 <-
#'   example_mts %>%
#'   mts_filterMeta(deviceDeploymentID %in% ids3) %>%
#'   mts_filterDate(20190705, 20190708)
#'
#' mts <- mts_combine(mts1, mts2, mts3)
#'
#' # Should have 1:6 + 8:10 = 9 meta records and the full date range
#' nrow(mts$meta)
#' range(mts$data$datetime)
#'

mts_combine <- function(
  ...
) {

  # Accept any number of mts objects
  mtsList <- list(...)

  # ----- Validate parameters --------------------------------------------------

  if ( length(mtsList) == 0 )
    stop("no 'mts' arguments provided")

  # NOTE:  If the first element is just a plain "list" of length 1, assume we are
  # NOTE:  being handed a list of mts objects rather than separate mts objects.
  if ( length(class(mtsList[[1]])) == 1 && class(mtsList[[1]]) == "list" ) {
    mtsList <- mtsList[[1]]
  }

  # NOTE:  This loop will stop() if there are any problems.
  for ( mts in mtsList ) {
    result <- mts_check(mts)
  }

  # ----- Combine 'meta' -------------------------------------------------------

  metaList <- lapply(mtsList, `[[`, "meta")

  # Combine 'meta' tibbles
  meta <-
    dplyr::bind_rows(metaList) %>%
    dplyr::distinct()

  # NOTE:  We should stop if any 'deviceDeploymentIDs' have non-identical
  # NOTE:  metadata.

  duplicatedMask <- duplicated(meta$deviceDeploymentID)
  if ( sum(duplicatedMask) > 0 ) {
    stop(sprintf(
      "The following ids have non-identical metadata: %s",
      paste0(meta$deviceDeploymentID[duplicatedMask], collapse = ", ")
    ))
  }

  # ----- Combine 'data' -------------------------------------------------------

  dataList <- lapply(mtsList, `[[`, "data")

  # NOTE:  Our "latest is best" approach means that we should organize our
  # NOTE:  dataframes in most-recent-first order so that application of
  # NOTE:  dplyr::distinct(), which preserves the first instance of a duplicate,
  # NOTE:  will retain the most recent record.

  lastDatetime <-
    sapply(dataList, function(x) { x$datetime[nrow(x)] } ) %>%
    as.numeric()
  dataOrder <- order(lastDatetime, decreasing = TRUE)
  dataList <- dataList[dataOrder]

  # Combine 'data' tibbles
  data <-
    dplyr::bind_rows(dataList) %>%
    dplyr::distinct(.data$datetime, .keep_all = TRUE) %>%
    dplyr::arrange(.data$datetime)

  # ----- Regular time axis ----------------------------------------------------

  # Create the full time axis
  datetime <- seq(min(data$datetime), max(data$datetime), by = "hours")
  hourlyDF <- data.frame(datetime = datetime)

  # Merge data onto full time axis
  data <- dplyr::full_join(hourlyDF, data, by = "datetime")

  # NOTE:  The columns in 'data' must always match the rows in 'meta'

  colNames <- c('datetime', meta$deviceDeploymentID)
  data <-
    dplyr::select(data, dplyr::all_of(colNames))

  # ----- Create the 'mts' object ----------------------------------------------

  mts <- list(meta = meta, data = data)
  class(mts) <- c("mts", class(mts))

  # ----- Return ---------------------------------------------------------------

  return(invisible(mts))

}
