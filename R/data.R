
#' Example DNA Methylation Beta Matrix
#'
#' A synthetic DNA methylation beta matrix for demonstrating
#' the functionality of the RBee classifier.
#'
#' The dataset contains 8,999 CpG features and three
#' artificially generated samples. Beta values were
#' randomly generated between 0 and 1.
#'
#' These data are intended exclusively for software testing
#' and demonstration. Classification results obtained from
#' this dataset have no biological interpretation.
#'
#' @format A numeric matrix with 8,999 rows and 3 columns:
#' \describe{
#'   \item{Rows}{CpG probe identifiers required by RBee.}
#'   \item{Columns}{Three synthetic samples: Example_01,
#'   Example_02, and Example_03.}
#' }
#'
#' @usage data(beta_example)
#' @name beta_example
NULL
