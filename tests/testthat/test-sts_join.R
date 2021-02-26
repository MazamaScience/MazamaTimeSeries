test_that("joining sts", {
  
  raws_sts <- example_raws
  
  # Assign missing values (until RAWSmet assignes these)
  raws_sts$meta$deviceDeploymentID = ""
  raws_sts$meta$deviceID = ""
  raws_sts$meta$locationID = ""

  # Join two different devices  
  expect_error(
    sts_join(raws_sts, example_sts)
  )
  
  # Join with one object not being a sts
  expect_error(
    sts_join(example_sts, list("not", "a", "sts"))
  )
  
  # Joining a sts with itself should be the original sts
  expect_identical(
    sts_join(example_sts, example_sts) %>% sts_extractData(),
    example_sts %>% sts_extractData()
  )
  
  # Joining two partitions of a sts
  sts_1 <- sts_filterDate(example_sts, 20180801, 20180814)
  sts_2 <- sts_filterDate(example_sts, 20180814, 20180828)
  
  expect_identical(
    sts_join(sts_1, sts_2) %>% sts_extractData(),
    example_sts %>% sts_extractData()
  )
  
  # Joining three partitionsof a sts
  sts_1 <- sts_filterDate(example_sts, 20180801, 20180810)
  sts_2 <- sts_filterDate(example_sts, 20180810, 20180820)
  sts_3 <- sts_filterDate(example_sts, 20180820, 20180828)
  
  expect_identical(
    sts_join(sts_1, sts_2, sts_3) %>% sts_extractData(),
    example_sts %>% sts_extractData()
  )
  
})