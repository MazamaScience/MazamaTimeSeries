#' @export
#' @importFrom rlang .data
#'
#' @title Join \code{mts} objects along the time axis
#'
#' @param mts1 \emph{mts} object
#' @param mts2 \emph{mts} object
#'
#' @return A joined \code{mts} object with an extended time range.
#'
#' @description Create a merged timeseries using two \emph{mts}
#' objects. If \emph{mts} objects are non-contiguous, the resulting \emph{mts}
#' will have a regular hourly \code{datetime} axis with temporal gaps filled
#' with \code{NA}.
#'
#' For each timeseries found in \code{mts1} and \code{mts2}, data are
#' placed on an extended time axis covering both \emph{mts} objects.
#'
#' This is useful when the same \code{deviceDeploymentID} appears in different
#' \emph{mts} objects representing different time periods. The returned
#' \emph{mts} object will cover both time periods.
#'
#' Any gap between the end of the earlier \emph{mts} object and the start of the
#' later \emph{mts} object will be filled with missing values to guarantee a
#' regular houly axis.
#'
#' Missing values will also be used whenever a \code{deviceDeploymentID} found in
#' one \emph{mts} object is missing from the other. The returned \emph{mts}
#' object will contain all \code{deviceDeploymentIDs} found in \code{mts1} or
#' \code{mts2}.
#'
#' Overlaps will be treated with a "later is better" sensibility. Any data
#' records with timestamps found in both \emph{mts} objects will be removed from
#' the earlier \emph{mts} object (\emph{i.e.} the one whose last record is earlier).
#'
#' @note An error is generated if the incoming \emph{mts} objects have
#' non-identical metadata for shared \code{deviceDeploymentIDs}.
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' ids1 <- sample(example_mts$meta$deviceDeploymentID, 7)
#' ids2 <- sample(example_mts$meta$deviceDeploymentID, 5)
#'
#' mts1 <-
#'   example_mts %>%
#'   mts_filterMeta(deviceDeploymentID %in% ids1) %>%
#'   sts_filterDate(20190701, 20190703)
#'
#' mts2 <-
#'   example_mts %>%
#'   mts_filterMeta(deviceDeploymentID %in% ids2) %>%
#'   sts_filterDate(20190705, 20190708)
#'
#' mts <- mts_join2(mts1, mts2)
#'

mts_join2 <- function(
  mts1 = NULL,
  mts2 = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(mts1)
  MazamaCoreUtils::stopIfNull(mts2)

  mts_check(mts1)
  mts_check(mts2)

  # ----- Join 'meta' ----------------------------------------------------------

  shared_ids <- intersect(mts1$meta$deviceDeploymentID, mts2$meta$deviceDeploymentID)
  mts1_only_ids <- setdiff(mts1$meta$deviceDeploymentID, shared_ids)
  mts2_only_ids <- setdiff(mts2$meta$deviceDeploymentID, shared_ids)

  meta1_only <- dplyr::filter(mts1$meta, .data$deviceDeploymentID %in% mts1_only_ids)
  meta1_shared <- dplyr::filter(mts1$meta, .data$deviceDeploymentID %in% shared_ids)
  meta2_only <- dplyr::filter(mts2$meta, .data$deviceDeploymentID %in% mts2_only_ids)
  meta2_shared <- dplyr::filter(mts2$meta, .data$deviceDeploymentID %in% shared_ids)

  # NOTE:  See ?base::all.equal on comparing objects
  if ( !isTRUE(all.equal(meta1_shared, meta2_shared)) )
    stop(sprintf("'mts1' and 'mts2' have different metadata in some records"))

  meta <-
    dplyr::bind_rows(
      meta1_only,
      meta1_shared,
      meta2_only
    )

  # ----- Join 'data' ----------------------------------------------------------

  # Get proper time ordering
  max_datetime_1 <- max(mts1$data$datetime)
  max_datetime_2 <- max(mts1$data$datetime)

  if ( max(mts2$data$datetime) > max(mts1$data$datetime) ) {
    data1 <- mts1$data
    data2 <- mts2$data
  } else {
    data1 <- mts2$data
    data2 <- mts1$data
  }

  # Trim data1 if there is any overlap ("later is better")
  min_datetime_1 <- min(data1$datetime)
  max_datetime_1 <- max(data1$datetime)
  min_datetime_2 <- min(data2$datetime)
  max_datetime_2 <- max(data2$datetime)

  if ( max_datetime_1 > min_datetime_2 ) {
    data1 <- dplyr::filter(data1, .data$datetime < min_datetime_2)
    max_datetime_1 <- max(data1$datetime)
  }

  data <- dplyr::bind_rows(data1, data2)

  # ----- Regular time axis ----------------------------------------------------

  gapHours <-
    difftime(min_datetime_2, max_datetime_1, units = "hours") %>%
    as.numeric()

  # Fill gap if necessary
  if ( gapHours > 1 ) {

    # Create the full time axis
    datetime <- seq(min_datetime_1, max_datetime_2, by = "hours")
    hourlyDF <- data.frame(datetime = datetime)

    # Merge data onto full time axis
    data <- dplyr::full_join(hourlyDF, data, by = "datetime")

  }

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
