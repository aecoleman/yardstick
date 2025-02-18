validate_numeric_truth_numeric_estimate <- function(truth,
                                                    estimate,
                                                    call = caller_env()) {
  if (!is.numeric(truth)) {
    cls <- class(truth)[[1]]
    abort(paste0(
      "`truth` should be a numeric, not a `", cls, "`."
    ), call = call)
  }

  if (!is.numeric(estimate)) {
    cls <- class(estimate)[[1]]
    abort(paste0(
      "`estimate` should be a numeric, not a `", cls, "`."
    ), call = call)
  }

  if (is.matrix(estimate)) {
    abort(paste0(
      "`estimate` should be a numeric vector, not a numeric matrix."
    ), call = call)
  }

  if (is.matrix(truth)) {
    abort(paste0(
      "`truth` should be a numeric vector, not a numeric matrix."
    ), call = call)
  }

  n_truth <- length(truth)
  n_estimate <- length(estimate)

  if (n_truth != n_estimate) {
    abort(paste0(
      "Length of `truth` (", n_truth, ") ",
      "and `estimate` (", n_estimate, ") must match."
    ), call = call)
  }
}

validate_factor_truth_factor_estimate <- function(truth,
                                                  estimate,
                                                  call = caller_env()) {
  if (!is.factor(truth)) {
    cls <- class(truth)[[1]]
    abort(paste0(
      "`truth` should be a factor, not a `", cls, "`."
    ), call = call)
  }

  if (!is.factor(estimate)) {
    cls <- class(estimate)[[1]]
    abort(paste0(
      "`estimate` should be a factor, not a `", cls, "`."
    ), call = call)
  }

  lvls_t <- levels(truth)
  lvls_e <- levels(estimate)

  if (!identical(lvls_t, lvls_e)) {
    lvls_t <- paste0(lvls_t, collapse = ", ")
    lvls_e <- paste0(lvls_e, collapse = ", ")
    abort(
      paste0(
        "`truth` and `estimate` levels must be equivalent.\n",
        "`truth`: ",    lvls_t, "\n",
        "`estimate`: ", lvls_e, "\n"
      ),
      call = call
    )
  }

  n_truth <- length(truth)
  n_estimate <- length(estimate)

  if (n_truth != n_estimate) {
    abort(
      paste0(
        "Length of `truth` (", n_truth, ") ",
        "and `estimate` (", n_estimate, ") must match."
      ),
      call = call
    )
  }
}

validate_factor_truth_matrix_estimate <- function(truth,
                                                  estimate,
                                                  estimator,
                                                  call = caller_env()) {
  if (!is.factor(truth)) {
    cls <- class(truth)[[1]]
    abort(paste0(
      "`truth` should be a factor, not a `", cls, "`."
    ), call = call)
  }

  if (estimator == "binary") {
    if (is.matrix(estimate)) {
      abort(paste0(
        "You are using a binary metric but have passed multiple columns to `...`."
      ), call = call)
    }

    if (!is.numeric(estimate)) {
      cls <- class(estimate)[[1]]
      abort(paste0(
        "`estimate` should be a numeric vector, not a `", cls, "` vector."
      ), call = call)
    }

    n_lvls <- length(levels(truth))
    if (n_lvls != 2) {
      abort(paste0(
        "`estimator` is binary, only two class `truth` factors are allowed. ",
        "A factor with ", n_lvls, " levels was provided."
      ), call = call)
    }
  } else {
    n_lvls <- length(levels(truth))
    if (is.matrix(estimate)) {
      n_cols <- ncol(estimate)
    } else {
      n_cols <- 1L
    }


    if (n_lvls != n_cols) {
      abort(paste0(
        "The number of levels in `truth` (", n_lvls, ") ",
        "must match the number of columns supplied in `...` (", n_cols, ")."
      ), call = call)
    }

    if (!is.numeric(as.vector(estimate))) {
      cls <- class(as.vector(estimate))[[1]]
      abort(paste0(
        "The columns supplied in `...` should be numerics, not `", cls, "`s."
      ), call = call)
    }
  }
}

validate_surv_truth_list_estimate <- function(truth,
                                              estimate,
                                              call = caller_env()) {
  if (!inherits(truth, "Surv")) {
    cls <- class(truth)[[1]]
    abort(paste0(
      "`truth` should be a Surv object, not a `", cls, "`."
    ), call = call)
  }

  if (!is.list(estimate)) {
    cls <- class(estimate)[[1]]
    abort(paste0(
      "`estimate` should be a list, not a `", cls, "`."
    ), call = call)
  }

  if (!all(vapply(estimate, is.data.frame, FUN.VALUE = logical(1)))) {
    abort("All elements of `estimate` should be data.frames.", call = call)
  }

  valid_names <- c(".eval_time", ".pred_survival", ".weight_censored")
  has_names <- vapply(
    estimate,
    function(x) all(valid_names %in% names(x)),
    FUN.VALUE = logical(1)
  )

  if (!all(has_names)) {
    abort(paste0(
      "All data.frames of `estimate` should include column names: ",
      "`.eval_time`, `.pred_survival`, and `.weight_censored`."
    ), call = call)
  }

  n_truth <- nrow(truth)
  n_estimate <- length(estimate)

  if (n_truth != n_estimate) {
    abort(paste0(
      "Length of `truth` (", n_truth, ") ",
      "and `estimate` (", n_estimate, ") must match."
    ), call = call)
  }
}

validate_surv_truth_numeric_estimate <- function(truth,
                                                 estimate,
                                                 call = caller_env()) {
  if (!.is_surv(truth, fail = FALSE)) {
    cls <- class(truth)[[1]]
    abort(paste0(
      "`truth` should be a Surv object, not a `", cls, "`."
    ), call = call)
  }

  if (!is.numeric(estimate)) {
    cls <- class(estimate)[[1]]
    abort(paste0(
      "`estimate` should be a numeric, not a `", cls, "`."
    ), call = call)
  }

  if (is.matrix(estimate)) {
    abort(paste0(
      "`estimate` should be a numeric vector, not a numeric matrix."
    ), call = call)
  }

  n_truth <- nrow(truth)
  n_estimate <- length(estimate)

  if (n_truth != n_estimate) {
    abort(paste0(
      "Length of `truth` (", n_truth, ") ",
      "and `estimate` (", n_estimate, ") must match."
    ), call = call)
  }
}

validate_binary_estimator <- function(truth, estimator, call = caller_env()) {
  if (estimator != "binary") {
    return()
  }

  lvls <- levels(truth)
  if (length(lvls) != 2) {
    abort(paste0(
      "`estimator` is binary, only two class `truth` factors are allowed. ",
      "A factor with ", length(lvls), " levels was provided."
    ), call = call)
  }
}

#' @section Estimator Validation:
#' `validate_estimator()` is called from your metric specific method of
#' `finalize_estimator_internal()` and ensures that a user provided estimator
#' is of the right format and is one of the allowed values.
#'
#' @param estimator_override A character vector overriding the default allowed
#' estimator list of
#' `c("binary", "macro", "micro", "macro_weighted")`. Set
#' this if your classification estimator does not support all of these methods.
#' @rdname developer-helpers
#' @export
validate_estimator <- function(estimator,
                               estimator_override = NULL,
                               call = caller_env()) {
  if (is.null(estimator)) {
    return()
  }

  if (!is.null(estimator_override)) {
    allowed <- estimator_override
  } else {
    allowed <- c("binary", "macro", "micro", "macro_weighted")
  }

  if (length(estimator) != 1) {
    abort(paste0(
      "`estimator` must be length 1, not ", length(estimator), "."
    ), call = call)
  }

  if (!is.character(estimator)) {
    abort(paste0(
      "`estimator` must be a character, not a ", class(estimator)[1], "."
    ), call = call)
  }

  estimator_ok <- (estimator %in% allowed)

  if (!estimator_ok) {
    allowed <- paste0(dQuote(allowed), collapse = ", ")
    abort(paste0(
      "`estimator` must be one of: ", allowed,
      ". Not ", dQuote(estimator), "."
    ), call = call)
  }
}

validate_case_weights <- function(case_weights, size, call = caller_env()) {
  if (is.null(case_weights)) {
    return(invisible())
  }

  size_case_weights <- length(case_weights)

  if (size_case_weights != size) {
    abort(paste0(
      "`case_weights` (", size_case_weights, ") must have the same ",
      "length as `truth` (", size, ")."
    ), call = call)
  }

  invisible()
}
