library(slendr)
library(tidyverse)
library(parallel)

simulate_afs <- function(Ne) {
  model_path <- tempfile()
  on.exit(unlink(model_path, recursive = TRUE, force = TRUE))

  pop <- population("pop", N = Ne, time = 100000)
  model <- compile_model(pop, generation_time = 1, direction = "backward",
                         path = model_path, overwrite = TRUE, force = TRUE)

  ts <-
    msprime(model, sequence_length = 10e6, recombination_rate = 1e-8) %>%
    ts_mutate(mutation_rate = 1e-8)

  samples <- ts_samples(ts) %>% sample_n(10) %>% pull(name)

  afs <- ts_afs(ts, list(samples), polarised = TRUE)

  afs
}

# Compute a single AFS given input Ne sampled from the prior, return the
# error vs observed AFS together with the Ne
compute_Ne_error <- function(Ne) {
  prior <- seq(1000, 30000, by = 1)
  Ne <- sample(prior, 1)

  afs <- simulate_afs(Ne)

  error <- sum((afs - afs_observed)^2) / length(afs)

  data.frame(
    Ne = Ne,
    error = error
  )
}

run_abc <- function(n_iterations, afs_observed) {
  # generate a list of all individual ABC runs (pairs Ne-vs-error)
  abc_runs <- mclapply(1:n_iterations, compute_Ne_error)
  # join all runs into a single data frame and return it
  abc_df <- do.call(rbind, abc_runs)
  abc_df
}

if (file.exists("exercise_1_abc.rds")) {
  abc_results <- readRDS("exercise_1_abc.rds")
} else {
  abc_results <- run_abc(1000, afs_observed)
  saveRDS(abc_results, "exercise_1_abc.rds")
}


error_cutoff <- quantile(abc_results$error, 0.05)

ggplot(abc_results, aes(Ne)) +
  geom_histogram(bins = 100) +
  ggtitle("Prior Ne distribution") +
  xlim(1000, 30000)

ggplot(abc_results[abc_results$error < error_cutoff, ], aes(Ne)) +
  geom_histogram(bins = 100) +
  geom_vline(xintercept = TRUE_NE, color = "red") +
  ggtitle("Posterior Ne distribution") +
  xlim(1000, 30000)

# summarise the 95% HPD interval of the Ne
filter(abc_results, error < error_cutoff) %>% pull(Ne) %>% summary

TRUE_NE
