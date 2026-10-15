#' Predict Retinoblastoma Molecular Subtypes
#'
#' Classifies preprocessed DNA methylation array beta values
#' using the pretrained RBee XGBoost classifier.
#'
#' @param beta_matrix Numeric matrix or data.frame.
#'   Rows represent CpG IDs and columns represent samples.
#'   Beta values must be between 0 and 1.
#' @param verbose Logical. If TRUE, displays the RBee mascot
#'   and a message when loading the classifier.
#'   Default is TRUE.
#' @return A data.frame containing sample IDs, predicted
#'   molecular subtypes, and class probabilities.
#'
#' @export
predict_retinoblastoma <- function(beta_matrix, verbose = TRUE) {

  # Validate input
  if (!is.matrix(beta_matrix) &&
      !is.data.frame(beta_matrix)) {
    stop("Input must be a matrix or data.frame.")
  }

  beta_matrix <- as.matrix(beta_matrix)

  if (!is.numeric(beta_matrix)) {
    stop("Beta matrix must contain numeric values.")
  }

  if (is.null(rownames(beta_matrix)) ||
      is.null(colnames(beta_matrix))) {
    stop("CpG row names and sample column names are required.")
  }

  if (anyDuplicated(rownames(beta_matrix)) ||
      anyDuplicated(colnames(beta_matrix))) {
    stop("CpG IDs and sample IDs must be unique.")
  }

  if (ncol(beta_matrix) == 0L || nrow(beta_matrix) == 0L) {
    stop("Beta matrix must not be empty.")
  }

  if (any(!is.finite(beta_matrix) & !is.na(beta_matrix))) {
    stop("Beta matrix contains infinite values.")
  }

  if (any(beta_matrix < 0 | beta_matrix > 1, na.rm = TRUE)) {
    stop("Beta values must be between 0 and 1.")
  }

  # Display RBee mascot
  if (isTRUE(verbose)) {
    show_rbee()
    message("Loading RBee classifier...")
  }

  # Load pretrained classifier
  rb <- load_rbee_model()

  features <- rb$info$features
  classes <- rb$info$classes

  # Check available features
  missing_features <- setdiff(features, rownames(beta_matrix))

  if (length(missing_features) > 0L) {
    warning(
      length(missing_features),
      " of ", length(features),
      " required CpGs are missing and will be set to NA."
    )
  }

  if (length(missing_features) == length(features)) {
    stop("None of the required CpGs are present.")
  }

  # Construct matrix in training feature order
  X <- matrix(
    NA_real_,
    nrow = ncol(beta_matrix),
    ncol = length(features),
    dimnames = list(colnames(beta_matrix), features)
  )

  present <- intersect(features, rownames(beta_matrix))

  X[, present] <- t(
    beta_matrix[present, , drop = FALSE]
  )

  # Predict class probabilities
  dnew <- xgboost::xgb.DMatrix(
    data = X,
    missing = NA
  )

  probabilities <- stats::predict(rb$model, dnew)

  probabilities <- matrix(
    probabilities,
    ncol = length(classes),
    byrow = TRUE
  )

  colnames(probabilities) <- classes

  # Map original model classes to new subtype labels
  class_labels <- c(
    "ClusterA" = "Subtype1",
    "ClusterB" = "Subtype2_ClusterB",
    "ClusterC" = "Subtype2_ClusterC",
    "NormalRetina" = "NormalRetina",
    "DiseaseControl" = "DiseaseControl"
  )

  if (!all(classes %in% names(class_labels))) {
    stop("Unknown class labels in model metadata.")
  }

  colnames(probabilities) <- unname(class_labels[classes])

  predicted <- colnames(probabilities)[
    max.col(probabilities, ties.method = "first")
  ]

  # Return classification results
  results <- data.frame(
    Sample = rownames(X),
    Prediction = predicted,
    MaxProbability = apply(probabilities, 1, max),
    probabilities,
    check.names = FALSE,
    row.names = NULL
  )

  return(results)
}
