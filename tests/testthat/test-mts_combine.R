
test_that("input is validated", {

  expect_error(
    mts_combine()
  )

  expect_error(
    suppressWarningMessages({
      mts_combine(example_mts, list("not", "an", "mts"))
    })
  )

})

test_that("simple combination works", {

  # combining an mts with itself should be the original mts
  expect_identical(
    mts_combine(example_mts, example_mts) %>% mts_extractData(),
    example_mts %>% mts_extractData()
  )

  # combining 2
  mts_1 <- mts_filterDate(example_mts, 20190701, 20190703)
  mts_2 <- mts_filterDate(example_mts, 20190703, 20190708)

  expect_identical(
    mts_combine(mts_1, mts_2) %>% mts_extractData(),
    example_mts %>% mts_extractData()
  )

  # combining 3
  mts_1 <- mts_filterDate(example_mts, 20190701, 20190703)
  mts_2 <- mts_filterDate(example_mts, 20190703, 20190706)
  mts_3 <- mts_filterDate(example_mts, 20190706, 20190708)

  expect_identical(
    mts_combine(mts_1, mts_2, mts_3) %>% mts_extractData(),
    example_mts %>% mts_extractData()
  )

  # combining a list
  mts_1 <- mts_filterDate(example_mts, 20190701, 20190703)
  mts_2 <- mts_filterDate(example_mts, 20190703, 20190706)
  mts_3 <- mts_filterDate(example_mts, 20190706, 20190708)
  mtsList <- list(mts_1, mts_2, mts_3)

  expect_identical(
    mts_combine(mtsList) %>% mts_extractData(),
    example_mts %>% mts_extractData()
  )

})

test_that("gaps and overlaps are supported", {

  # gap
  mts_1 <- mts_filterDate(example_mts, 20190701, 20190703)
  mts_2 <- mts_filterDate(example_mts, 20190706, 20190708)

  expect_identical(
    mts_combine(mts_1, mts_2) %>% mts_extractData() %>% dplyr::pull(.data$datetime),
    example_mts %>% mts_extractData() %>% dplyr::pull(.data$datetime)
  )

  # overlap
  mts_1 <- mts_filterDate(example_mts, 20190701, 20190706)
  mts_2 <- mts_filterDate(example_mts, 20190703, 20190708)

  expect_identical(
    mts_combine(mts_1, mts_2) %>% mts_extractData() %>% dplyr::pull(.data$datetime),
    example_mts %>% mts_extractData() %>% dplyr::pull(.data$datetime)
  )


})

