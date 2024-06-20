# Load datasets
library(dplyr)
# Helpers
named_group_split <- function(.tbl, ..., verbose = F, keep = T, sep = " / ") {
  grouped <- dplyr::group_by(.tbl, ...)
  if (verbose) {
    names <- rlang::eval_bare(rlang::expr(paste(!!!dplyr::group_keys(grouped) %>%
      purrr::imap(~ paste(.y, .x, sep = "==")), sep = sep)))
  } else {
    names <- rlang::eval_bare(rlang::expr(paste(!!!dplyr::group_keys(grouped),
      sep = sep
    )))
  }
  if (length(names) == 0) {
    names <- NULL
  }
  grouped %>%
    dplyr::group_split(.keep = keep) %>%
    rlang::set_names(names)
}
# Reports
unlink("output/log.txt")
unlink("output/sensitive.txt")
unlink("output/error.txt")
add_to_output <- function(msg, file) {
  file <- file.path("output", file)
  write(msg, file = file, append = TRUE)
}
log_error <- function(msg) {
  add_to_output(msg, "error.txt")
}
log_sensitive <- function(msg) {
  add_to_output(msg, "sensitive.txt")
}
log <- function(msg) {
  add_to_output(msg, "log.txt")
}
log_all <- function(msg) {
  log(msg)
  log_sensitive(msg)
  log_error(msg)
}
# Load Data
load_file <- function(x){
  filename <- Sys.glob(glue::glue("input/{x}*.csv"))
  log(filename)
  readr::read_csv(filename)
}
adsl <- load_file("ADSL")
adtte <- load_file("ADTTE")
adlong <- load_file("ADLONG")
adevent <- load_file("ADEVENT")
# ADSL
# Check only on entry per patient
log("v0.1")
log_all("===ADSL===")
tryCatch(
  {
    patients_with_more_than_one_entry <- adsl %>%
      dplyr::group_by(person_id) %>%
      dplyr::summarize(n = n()) %>%
      dplyr::filter(n > 1)
    # Log patient with more than one entry this is sensitive
    log_sensitive("Patients with more than one entry in ADSL:")
    log_sensitive(knitr::kable(patients_with_more_than_one_entry))
    log_sensitive(knitr::kable(adsl %>% dplyr::filter(person_id %in% patients_with_more_than_one_entry$person_id)))
    # Log number of patients_with_more_than_one_entry
    log(paste(
      "Number of patients with more than one entry: ",
      nrow(patients_with_more_than_one_entry)
    ))
    # Check diagnosis
    log("Unique diagnosis in ADSL:")
    log(unique(adsl$ms_diag))
  },
  error = function(e) {
    log_all(paste("Error in ADSL: ", e))
  }
)
# ADlONG
log_all("===ADLONG===")
tryCatch({
  log("---Params in ADLONG---")
  log(unique(adlong$param))
}, error = function(e){
    print(e)
    log_error(paste("Error in ADLONG: ", e))
})
tryCatch(
  {
    source("R/change_functions.R")
    log_sensitive("---Number of records per patient and param---")
    .tbl <- adlong %>%
      dplyr::group_by(person_id, param) %>%
      dplyr::summarise(n = dplyr::n()) %>%
      dplyr::arrange(dplyr::desc(n)) %>%
      knitr::kable()
    log_sensitive(.tbl)
    log("---Changes per param---")
    .tbl <- adlong %>%
      dplyr::mutate(chg_fl = factor(chg_fl)) %>%
      dplyr::mutate(chg_fl = forcats::fct_na_value_to_level(chg_fl)) %>%
      dplyr::group_by(param, chg_fl) %>%
      dplyr::summarise(n = dplyr::n()) %>%
      knitr::kable()
    log(.tbl)
    log("---Checking change functions---")
    change_checks <- adlong %>%
      named_group_split(param) %>%
      purrr::imap(function(.d, param) {
        check_param <- .d %>%
          named_group_split(person_id) %>%
          purrr::imap(function(.dd, person) {
            tryCatch({
              # Check if is sinlge record
              checks <- list()
              # Check ady calcualtion
              ady <- as.Date(.dd$adt) - as.Date(.dd$het_start)
              # Check ref_flag
              if (!(all(is.na(ady)))) checks$A <- all(.dd$ady == as.numeric(ady))
              min_ady_index <- which.min(abs(ady))
              if (length(min_ady_index) > 0) {
                checks$B <- .dd$ref_fl[min_ady_index] == 1
              }
              if (nrow(.dd) == 1) {
                checks$C <- .dd$single_record_flag == 1 #2
                if (!(checks$C)) log(.dd %>% dplyr::select(ady, aval, single_record_flag) %>% knitr::kable())
              } else {
                # Check Calculation
                .f <- WORSENING_FUNCTIONS[[param]]
                if(is.null(.f)) log(paste("No function found: ", param))
                res <- .dd %>%
                  dplyr::group_by_all() %>%
                  dplyr::group_split() %>%
                  purrr::map(function(rec) {
                    base <- .dd %>%
                      dplyr::filter(ady < rec$ady) %>%
                      dplyr::filter(before_reference_flag == 0) %>%
                      dplyr::filter(chg_fl == 1 | ref_fl == 1) %>%
                      dplyr::arrange(ady) %>%
                      tail(1)
                    if (nrow(base) > 0) {
                      .checks = NULL
                      tryCatch({
                        chg <- .f(base, rec)
                        .checks <- c(chg == rec$chg_fl) #...
                      }, error = function(e){
                        log_error(as.character(e))
                        log_error(param)
                        return(NULL)
                      })
                      if(is.na(.checks) || is.null(.checks) || !(.checks)){
                        log("---Error---")
                        log("Record:")
                        log(rec %>%
                          dplyr::select(param, ady, aval, base_ady, base_chg, chg_fl, record_id, ref_id,  base_id) 
                          %>% knitr::kable())
                        log("Base:")
                        log(base %>%
                          dplyr::select(param, ady, aval, base_ady, base_chg, chg_fl, record_id, ref_id,  base_id) 
                          %>% knitr::kable())
                        log(.dd %>%
                          dplyr::select(param, ady, aval, base_ady, base_chg, chg_fl, record_id, ref_id,  base_id) 
                          %>% knitr::kable())
                        log("---")
                      }
                      return(.checks)
                    } else {
                      return(NULL)
                    }
                  })
                checks$D <- all(unlist(purrr::compact(res)))
                if (all(unlist(checks))){
                  checks <- list(All = TRUE)
                } else {
                  checks$person_id <- person
                  checks$param <- param
                }
                return(checks)
              }
              }, error = function(e){
                cli::cli_alert_danger(as.character(e))
                log_error(as.character(e))
                return(FALSE)
              })
            if (!all(unlist(unname(checks)))) {
              log_sensitive("------")
              log_sensitive(knitr::kable(.dd %>%
                dplyr::select(
                  param,
                  ady,
                  aval,
                  ref_fl,
                  ref_ady,
                  ref_aval,
                  ref_chg,
                  base_ady,
                  base_aval,
                  chg_fl,
                  before_reference_flag,
                  single_record_flag
                )))
            }
            #if (!all(checks)) log(paste("Checks failed for param: ", param))
            if (all(unlist(checks))){
              checks <- list(All = TRUE)
            } else {
              checks$person_id <- person
              checks$param <- param
            }
            return(checks)
          }) %>%
          dplyr::bind_rows()
        log(paste0(param, ":"))
        log(check_param %>% dplyr::distinct() %>% knitr::kable())
      })
      if (all(unlist(change_checks), na.rm = T)){log("All checks passed")}
      # check that all base_fl records are chg_fl 0
      log("---Checking ref_fl---")
      res <- adlong %>% 
        dplyr::filter(param != "relapse") %>%
        dplyr::group_by_all() %>%
        dplyr::mutate(x = sum(ref_fl, chg_fl)) %>%
        dplyr::ungroup() %>%
        dplyr::filter(x > 1) %>%
        nrow()
      log(paste("Number of records with ref_fl plus chg_fl > 1: ", res))
  },
  error = function(e) {
    print(e)
    log_error(paste("Error in ADLONG: ", e))
  }
)
# ADTTE
log_all("===ADTTE===")
tryCatch(
  {
    .tbl <- adtte %>%
      dplyr::group_by(param, event) %>%
      dplyr::summarise(n = dplyr::n())
    .tbl <- knitr::kable(.tbl)
    log(.tbl)
  },
  error = function(e) {
    log_error(paste("Error in ADTTE: ", e))
  }
)
tryCatch(
  {
    # Check that each patients has one, but only one entry per param
    patients_with_more_than_one_entry_adtte <- adtte %>%
      dplyr::group_by(person_id, param) %>%
      dplyr::summarize(n = n()) %>%
      dplyr::filter(n > 1)
    # Log patients with more than one entry this is sensititve
    log_sensitive("Patients with more than one entry in ADTTE: ")
    log_sensitive(knitr::kable(patients_with_more_than_one_entry_adtte))
    log_sensitive(knitr::kable(adtte %>% dplyr::filter(person_id %in% patients_with_more_than_one_entry$person_id)))
    # Log number of patients_with_more_than_one_entry_adtte
    log(paste(
      "Number of patients with more than one entry: ",
      nrow(patients_with_more_than_one_entry_adtte)
    ))
    # Check that every patient has an entry for each param
    person_ids <- adsl$person_id
    adtte %>%
      named_group_split(param) %>%
      purrr::iwalk(function(.d, .param) {
        patients_not_in <- person_ids[!person_ids %in% .d$person_id]
        log_sensitive(paste("Patients not in ADTTE", .param, ":", patients_not_in))
        log(paste("Number of patients not in ADTTE", .param, ":", length(patients_not_in)))
      })
  },
  error = function(e) {
    log_error(paste("Error in ADTTE: ", e))
  }
)
# ADEVENT
log_all("===ADEVENT===")
tryCatch(
  {
    .tbl <- adevent %>%
      dplyr::group_by(param) %>%
      dplyr::summarise(n = dplyr::n())
    .tbl <- knitr::kable(.tbl)
    log(.tbl)
  },
  error = function(e) {
    log_error(paste("Error in ADEVENT: ", e))
  }
)
tryCatch(
  {
    # Check that first chg_fl entry is in adtte
    res <- adevent %>%
      named_group_split(person_id) %>%
      purrr::map(function(.d) {
        .d %>%
          named_group_split(param) %>%
          purrr::imap(function(.dd, .param) {
            first_entry <- .dd %>%
              dplyr::arrange(ady) %>%
              dplyr::filter(chg_fl == 1 & before_reference_flag == 0) %>%
              head(1)
            if (length(first_entry$record_id) > 0) {
              first_entry$record_id %in% adtte$record_id
            } else {
              return(NULL)
            }
          })
      }) %>%
      unlist() %>%
      all()
    log(paste("All entries in ADTTE corresponding to first ADEVENT entry after het start:", res))
  },
  error = function(e) {
    print(e)
    log_error(paste("Error in ADLONG: ", e))
  }
)
log_all("===END===")
