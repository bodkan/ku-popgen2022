library(slendr)
library(tidyverse)

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

Ne_grid <- seq(from = 1000, to = 30000, by = 1000)

afs_grid <- lapply(Ne_grid, simulate_afs)

afs_observed <- c(2520, 1449, 855, 622, 530, 446, 365, 334, 349, 244, 264, 218,
                  133, 173, 159, 142, 167, 129, 125, 143)

# Plot the observed AFS and overlay the simulated AFS vectors on top of it
plot(afs_observed, type = "b", col = "red", lwd = 3)
for (i in seq_along(Ne_grid)) {
  lines(afs_grid[[i]], lwd = 0.5)
}

# Compute mean-squared error of the AFS produced by each Ne value across the grid
errors <- sapply(afs_grid, function(afs) {
  sum((afs - afs_observed)^2) / length(afs)
})

# plot the errors, highlight the most likely value
plot(Ne_grid, errors)
abline(v = Ne_grid[which.min(errors)], col = "green")
abline(v = TRUE_NE, col = "purple")
legend("topright", legend = c(paste("inferred Ne =", Ne_grid[which.min(errors)]),
                              paste("true Ne =", TRUE_NE)),
       col = c("green", "purple"), lty = 2)

# Plot the AFS again, highlighting the most likely spectrum
plot(afs_observed, type = "b", col = "red", lwd = 1)
for (i in seq_along(Ne_grid)) {
  color <- if (i == which.min(errors)) "green" else "gray"
  width <- if (i == which.min(errors)) 2 else 0.5
  lines(afs_grid[[i]], lwd = width, col = color)
}
legend("topright", legend = paste("Ne =", Ne_grid[which.min(errors)]),
       col = "green", lty = 2)
