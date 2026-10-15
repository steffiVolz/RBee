test_that("RBee returns valid predictions", {

  # Load required CpG features
  model_info <- readRDS(
    system.file(
      "extdata", "xgb_final_model.rds",
      package = "RBee"
    )
  )

  # Create synthetic beta matrix
  set.seed(123)

  beta_test <- matrix(
    runif(length(model_info$features)),
    ncol = 1,
    dimnames = list(
      model_info$features,
      "TestSample"
    )
  )

  # Run classification
  result <- predict_retinoblastoma(
    beta_test,
    verbose = FALSE
  )

  # Check output
  expect_equal(nrow(result), 1L)
  expect_equal(result$Sample, "TestSample")

  expect_true(result$Prediction %in% c(
    "Subtype1",
    "Subtype2_ClusterB",
    "Subtype2_ClusterC",
    "NormalRetina",
    "DiseaseControl"
  ))

  # Probabilities must sum to 1
  probability_columns <- c(
    "Subtype1",
    "Subtype2_ClusterB",
    "Subtype2_ClusterC",
    "NormalRetina",
    "DiseaseControl"
  )

  expect_equal(
    sum(as.numeric(result[1, probability_columns])),
    1,
    tolerance = 1e-5
  )

})


test_that("RBee rejects invalid input", {

  # Invalid input type
  expect_error(
    predict_retinoblastoma("invalid", verbose = FALSE),
    "Input must be a matrix or data.frame"
  )

  # Beta values outside 0-1
  invalid_beta <- matrix(
    c(0.5, 1.5),
    nrow = 2,
    dimnames = list(
      c("cg00000029", "cg00000108"),
      "TestSample"
    )
  )

  expect_error(
    predict_retinoblastoma(invalid_beta, verbose = FALSE),
    "Beta values must be between 0 and 1"
  )

  # Duplicate CpG identifiers
  duplicate_beta <- matrix(
    c(0.3, 0.7),
    nrow = 2,
    dimnames = list(
      c("cg00000029", "cg00000029"),
      "TestSample"
    )
  )

  expect_error(
    predict_retinoblastoma(duplicate_beta, verbose = FALSE),
    "CpG IDs and sample IDs must be unique"
  )

})


test_that("RBee handles missing CpG features", {

  model_info <- readRDS(
    system.file(
      "extdata", "xgb_final_model.rds",
      package = "RBee",
      mustWork = TRUE
    )
  )

  # Create synthetic beta values for all required CpGs
  set.seed(123)

  beta_test <- matrix(
    runif(length(model_info$features)),
    ncol = 1,
    dimnames = list(
      model_info$features,
      "TestSample"
    )
  )

  # Remove 10 CpGs
  beta_missing <- beta_test[-seq_len(10), , drop = FALSE]

  # Missing CpGs should trigger a warning
  expect_warning(
    result <- predict_retinoblastoma(
      beta_missing,
      verbose = FALSE
    ),
    "10 of 8999 required CpGs are missing"
  )

  # Prediction should still return one sample
  expect_equal(nrow(result), 1L)

  # Predicted class should be valid
  expect_true(result$Prediction %in% c(
    "Subtype1",
    "Subtype2_ClusterB",
    "Subtype2_ClusterC",
    "NormalRetina",
    "DiseaseControl"
  ))

})

