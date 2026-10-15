#' Display the RBee Mascot
#'
#' Displays the RBee ASCII bee in the R console.
#'
#' @keywords internal
show_rbee <- function() {

  bee <- c(
    "         \\     /",
    "          \\   /",
    "        .---^---.",
    "       /  o   o  \\",
    "    __(     w     )__",
    "  (___ \\_________/ ___)",
    "      /===========\\",
    "     (=============)",
    "     (=============)",
    "      \\===========/",
    "       \\=========/",
    "         \\_____/",
    "            V",
    "",
    "   RBee - RetinoBlastoma boosted ensemble estimator",
    ""
  )

  cat(paste(bee, collapse = "\n"), "\n")
}
