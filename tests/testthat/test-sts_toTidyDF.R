test_that("tidy dataframes", {

  # metaColumns <- c('deviceDeploymentID', 'locationName', 'longitude', 'latitude')
  # test_tidyDF <- sts_toTidyDF(example_sts, metaColumns = metaColumns)
  #
  # # -- check columns --
  #
  # expect_equal(
  #   length(names(test_tidyDF)),
  #   length(names(example_sts$data)) + length(metaColumns)
  # )
  #
  # expect_equal(
  #   names(test_tidyDF),
  #   c(names(example_sts$data), metaColumns)
  # )
  #
  # # -- check rows --
  #
  # expect_equal(
  #   nrow(test_tidyDF),
  #   nrow(example_sts$data)
  # )
  #
  # expect_equal(
  #   range(test_tidyDF$datetime),
  #   range(example_sts$data$datetime)
  # )
  #
  # # -- error with bad metaColumns --
  #
  # expect_error(
  #   sts_toTidyDF(example_sts, metaColumns = c("NotAValidColumnName"))
  # )
  #
  # expect_error(
  #   sts_toTidyDF(example_sts, metaColumns = c(1, list()))
  # )
  #
  # # -- error when sts is not a valid sts --
  #
  # expect_error(
  #   sts_toTidyDF(sts = list())
  # )
  #
  # # -- error when resulting tidyDF will be too large --
  #
  # expect_error(
  #   sts_toTidyDF(example_sts, sizeMax = 1)
  # )

})
