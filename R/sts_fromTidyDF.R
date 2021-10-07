#' @export
#' @importFrom rlang .data :=
#' @importFrom MazamaLocationUtils location_createID
#'
#' @title Convert a tidy dataframe into a SingleTimeSeries object
#'
#' @param tidyDF Tidy dataframe containing data and metadata.
#' @param nameMapping List mapping columns in tidyDF to the required columns 
#' specified below
#'
#' @description Converts a tidy dataframe containing data and metadata from
#' one device into a \emph{sts} object.
#' 
#' The required metadata columns in the provided tidy dataframe are as follows:
#' \itemize{
#'   \item{\code{deviceID} -- device identifier (character, non-numeric)}
#'   \item{\code{longitude} -- decimal degrees E}
#'   \item{\code{latitude} -- decimal degrees N}
#'   \item{\code{countryCode} -- ISO 3166-1 alpha-2}
#'   \item{\code{stateCode} -- ISO 3166-2 alpha-2}
#'   \item{\code{timezone} -- Olson time zone}
#' }
#' 
#' Data stored in these columns will be put in the meta dataframe of the resulting 
#' \emph{sts} object.
#' 
#' The required data columns are as follows:
#' \itemize{
#'   \item{\code{datetime} -- measurement time (UTC)}
#' }
#' 
#' These columns along with any other numeric columns in the tidy dataframe will be 
#' put in the data dataframe of the resulting \emph{sts} object.
#' 
#' 
#' If the column names in 'tidyDF' do not match the names of the required columns,
#' they can be mapped to the correct column names with the 'nameMapping' parameter. 
#' 
#' For example, to map columns 'lon' and 'lat' in 'tidyDF' to 'longitude' and 'latitude',
#' 'nameMapping' can be defined as nameMapping = list("lon" = "longitude", "lat" = "latitude")
#'
#' @return A \emph{sts} object containing data and metadata from the original 
#' tidy dataframe
#'
#' @examples
#'
#' library(MazamaTimeSeries)
#'
#' # TODO: write example for sts_fromTidyDF()
#'

sts_fromTidyDF <- function(
  tidyDF = NULL,
  nameMapping = NULL
) {
  
  # ----- Validate parameters --------------------------------------------------
  
  requiredColumns = c('deviceID', 'longitude', 'latitude', 'countryCode', 
                      'stateCode', 'timezone', 'datetime')
  
  if( !is.null(nameMapping) && typeof(nameMapping) != "list")
    stop("Parameter 'nameMapping' must be a list.")
  
  for( name in names(nameMapping) ) {
    # Each element must be a single character
    if( length(nameMapping[[name]]) != 1 )
      stop("Elements of 'nameMapping' must be of length 1.")
    
    # Rename column in tidyDF as defined in 'nameMapping'
    if( name %in% names(tidyDF) ) 
      tidyDF <- tidyDF %>% dplyr::rename(!!nameMapping[[name]] := name)
  }
  
  # Check for missing required columns in tidyDF
  if ( !all(requiredColumns %in% names(tidyDF)) ) {
    badColumns <- setdiff(requiredColumns, names(tidyDF))
    stop(sprintf(
      "Required columns are not found in tidyDF: '%s'",
      paste(badColumns, collapse = ", ")
    ))
  }
  
  # Check for unique locations
  if ( length(unique(tidyDF$longitude)) > 1 || length(unique(tidyDF$latitude)) > 1 )
    stop("Duplicate locations were found in 'tidyDF'.")
  
  # Check for duplicate datetimes. wide data, long data
  if ( length(tidyDF$datetime[duplicated(tidyDF$datetime)]) > 0 )
    stop("Duplicated measurement times were found in 'tidyDF'.")
  
  # ----- Create meta dataframe ------------------------------------------------
  
  # Define columns for final meta dataframe
  allMetaColumns <- c('deviceID', 'locationID', 'locationName', 
                      'longitude', 'latitude', 'elevation', 'countryCode', 
                      'stateCode', 'timezone')
  
  meta <- data.frame(
    # create deviceDeploymentID. Will be overwritten if one was already
    # provided in tidyDF
    deviceDeploymentID = 
      MazamaLocationUtils::location_createID(unique(tidyDF$longitude), unique(tidyDF$latitude))
  )

  # Add all meta columns
  # NOTE: If a column was not provided in tidyDF, set it to NA
  for( col in allMetaColumns ) {
    if( col %in% names(tidyDF) ) {
      meta[col] <- unique(tidyDF[[col]])
    } else {
      meta[col] <- as.character(NULL)
    }
  }
  
  # Add all metadata columns to meta. These include:
  # - All other non-numeric columns (except for columns including 'datetime')
  # - All columns ending in ID (case sensitive) that contain a unique value
  # - All columns named elevation or elev (case sensitive) that contain a unique value
  for( col in names(tidyDF) ) {
    if( (!is.numeric(tidyDF[[col]]) & !col %in% names(meta) & !grepl('datetime', col)) | 
        (stringr::str_sub(tolower(col), -2) == 'id' & length(unique(tidyDF[[col]])) == 1) |
        (tolower(col) == 'elevation' | tolower(col) == 'elev' & length(unique(tidyDF[[col]])) == 1) ) {
      
      # requires a special check since 'elevation' is currently required by sts_isValid() 
      if ( tolower(col) == 'elevation' | tolower(col) == 'elev' )
        meta['elevation'] <- unique(tidyDF[[col]])
      else
        meta[col] <- unique(tidyDF[[col]])
    }
  }
  
  # ----- Create data dataframe ------------------------------------------------
  
  # The data dataframe contains all of the columns not in the meta dataframe
  # This will be all of the numeric columns along with datetime
  data <- tidyDF[, !names(tidyDF) %in% names(meta)]
  
  # ----- Create and validate final sts ----------------------------------------
  
  sts <- list(meta = meta, data = data)
  
  if ( !sts_isValid(sts) )
    stop("Resulting object is not a valid sts object.")
  
  # ----- Return ---------------------------------------------------------------

  return(sts)
  
}
