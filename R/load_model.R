#' Load the RBee XGBoost Classifier
#'
#' Loads the pretrained XGBoost model and its metadata,
#' including the required CpG features and class labels.
#'
#' @return A list containing the trained model and metadata.
#' @keywords internal
load_rbee_model <- function() {

  model_path <- system.file(
    "extdata", "xgb_final.model",
    package = "RBee",
    mustWork = TRUE
  )

  info_path <- system.file(
    "extdata", "xgb_final_model.rds",
    package = "RBee",
    mustWork = TRUE
  )

  model <- xgboost::xgb.load(model_path)
  info <- readRDS(info_path)

  list(
    model = model,
    info = info
  )
}
