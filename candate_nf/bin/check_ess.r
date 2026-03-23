#!/usr/bin/env Rscript
library(tracerer)

# 1. Capture 6 command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 6) {
  stop("Usage: Rscript check_ess_final.R <log_file> <burn_in_fraction> <sample_interval> <non_base_ess> <base_freq_ess> <out_prefix>")
}

log_file         <- args[1]
burn_in_fraction <- as.numeric(args[2])
sample_interval  <- as.numeric(args[3])
non_base_target  <- as.numeric(args[4])
base_freq_target <- as.numeric(args[5])
out_prefix       <- args[6]

# 2. Parse and process log file
result <- tryCatch({
  
  beast_log_full <- parse_beast_tracelog_file(log_file)
  beast_log      <- remove_burn_ins(beast_log_full, burn_in_fraction)
  esses          <- calc_esses(beast_log, sample_interval = sample_interval)
  
  # 3. Create a data frame for the CSV output
  ess_df <- data.frame(
    Parameter = names(esses),
    ESS = as.numeric(esses),
    stringsAsFactors = FALSE
  )
  
  # Write to CSV
  csv_filename <- paste0(out_prefix, "_ess_report.csv")
  write.csv(ess_df, file = csv_filename, row.names = FALSE)
  
  # 4. Logical Check for console output
  is_freq        <- grepl("^freqParameter", ess_df$Parameter)
  
  esses_base     <- ess_df$ESS[is_freq]
  esses_non_base <- ess_df$ESS[!is_freq]
  
  pass_non_base  <- all(esses_non_base >= non_base_target)
  pass_base      <- all(esses_base >= base_freq_target)
  
  # 5. Final Output to STDOUT
  if (pass_non_base && pass_base) {
    cat(non_base_target, "\n")
  } else {
    cat(0, "\n")
  }
  
}, error = function(e) {
  # In case of error, still output 0 for pipeline stability
  cat(0, "\n")
})
