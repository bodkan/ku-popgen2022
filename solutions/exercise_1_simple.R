library(slendr)
setup_env()
library(tidyverse)

simulate_afs <- function(Ne) {
  pop <- population("pop", N = Ne, time = 1)
  model <- compile_model(pop, generation_time = 1, simulation_length = 10000)
  
  ts <-
    msprime(model, sequence_length = 10e6, recombination_rate = 1e-8) %>%
    ts_mutate(mutation_rate = 1e-8)
  
  samples <- ts_samples(ts) %>% sample_n(10) %>% pull(name)
  
  afs <- ts_afs(ts, list(samples), polarised = TRUE)
  
  afs
}

afs_observed <- c(2520, 1449, 855, 622, 530, 446, 365, 334, 349, 244, 264, 218,
                  133, 173, 159, 142, 167, 129, 125, 143)

afs_Ne1000 <- simulate_afs(1000)
afs_Ne5000 <- simulate_afs(5000)
afs_Ne6000 <- simulate_afs(6000)
afs_Ne10000 <- simulate_afs(10000)
afs_Ne20000 <- simulate_afs(20000)

plot(afs_observed, type = "b", col = "black", lwd = 3,
     xlab = "allele count bin", ylab = "count", ylim = c(0, 10000))
lines(afs_Ne1000, lwd = 2, col = "blue")
lines(afs_Ne5000, lwd = 2, col = "green")
lines(afs_Ne6000, lwd = 2, col = "pink")
lines(afs_Ne10000, lwd = 2, col = "purple")
lines(afs_Ne20000, lwd = 2, col = "orange")
legend("topright", legend = c("observed AFS", "Ne = 1000", "Ne = 5000",
                              "Ne = 6000", "Ne = 10000", "Ne = 20000"),
       fill = c("black", "blue", "green", "pink", "purple", "orange"))
