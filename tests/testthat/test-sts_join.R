
test_that("input is validated", {

  expect_error(
    sts_join()
  )

  expect_error(
    sts_join(example_sts, list("not", "an", "mts"))
  )

  raws_sts <- example_raws

  # Assign missing values (until RAWSmet assignes these)
  raws_sts$meta$deviceDeploymentID = ""
  raws_sts$meta$deviceID = ""
  raws_sts$meta$locationID = ""

  # Join two different devices
  expect_error(
    sts_join(raws_sts, example_sts)
  )

})


test_that("simple joining works", {

  # Joining an sts with itself should be the original sts
  expect_identical(
    sts_join(example_sts, example_sts) %>% sts_extractData(),
    example_sts %>% sts_extractData()
  )

  # Join 2
  sts_1 <- sts_filterDate(example_sts, 20180801, 20180814)
  sts_2 <- sts_filterDate(example_sts, 20180814, 20180828)

  expect_identical(
    sts_join(sts_1, sts_2) %>% sts_extractData(),
    example_sts %>% sts_extractData()
  )

  # Join 3
  sts_1 <- sts_filterDate(example_sts, 20180801, 20180810)
  sts_2 <- sts_filterDate(example_sts, 20180810, 20180820)
  sts_3 <- sts_filterDate(example_sts, 20180820, 20180828)

  expect_identical(
    sts_join(sts_1, sts_2, sts_3) %>% sts_extractData(),
    example_sts %>% sts_extractData()
  )

})
