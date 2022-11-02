library(AirMonitor)

a <- airnow_loadAnnual(2021)

hourlyDF <- a$data %>% dplyr::select("datetime")
dataBrick <- a$data %>% dplyr::select(-1) %>% as.matrix()

rowCount <- nrow(dataBrick)
colCount <- ncol(dataBrick)

mask <- matrix(FALSE, rowCount, colCount)
rowIndices <- sample(seq_len(rowCount), 20)
colIndices <- sample(seq_len(colCount), 20)

mask[rowIndices, colIndices] <- TRUE

dataBrick_s <- matrix(as.numeric(NA), rowCount, colCount)
dataBrick_s[mask] <- dataBrick[mask]
colnames(dataBrick_s) <- a$meta$deviceDeploymentID

dataTbl_s <- dplyr::as_tibble(dataBrick_s)

data_s <- dplyr::bind_cols(hourlyDF, dataTbl_s)

a_s <- a
a_s$data <- data_s

# ----- random sampling --------------------------------------------------------

library(AirMonitor)

a <- airnow_loadAnnual(2021)

hourlyDF <- a$data %>% dplyr::select("datetime")
dataBrick <- a$data %>% dplyr::select(-1) %>% as.matrix()
b <- as.numeric(dataBrick)
b_indices <- sample(seq_along(b), 2000)
c <- rep(as.numeric(NA), length = length(b))
c[b_indices] <- b[b_indices]
dataBrick_s <- matrix(c, nrow = rowCount, ncol = colCount)

dataBrick_s[mask] <- dataBrick[mask]
colnames(dataBrick_s) <- a$meta$deviceDeploymentID

dataTbl_s <- dplyr::as_tibble(dataBrick_s)

data_s <- dplyr::bind_cols(hourlyDF, dataTbl_s)

a_s <- a
a_s$data <- data_s

