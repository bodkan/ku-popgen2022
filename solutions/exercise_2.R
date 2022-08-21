library(slendr)
library(tidyverse)

Ne_start <- 6543
Ne_factor <- 3

pop1 <- population("s1", N = Ne_start, time = 1)

pop2 <-
  population("s2", N = Ne_start, time = 2, parent = pop1) %>%
  resize(how = "step", N = as.integer(Ne_factor * Ne_start), time = 5000)

pop3 <-
  population("s3", N = Ne_start, time = 2, parent = pop1) %>%
  resize(how = "step", N = as.integer(Ne_start / Ne_factor), time = 5000)

model <- compile_model(
  populations = list(pop1, pop2, pop3),
  generation_time = 1,
  simulation_length = 10000
)

ts <-
  msprime(model, sequence_length = 10e6, recombination_rate = 1e-8) %>%
  ts_mutate(mutation_rate = 1e-8)

samples <- ts_samples(ts) %>%
  group_by(pop) %>%
  sample_n(20)

pop1_names <- filter(samples, pop == "s1")$name
pop2_names <- filter(samples, pop == "s2")$name
pop3_names <- filter(samples, pop == "s3")$name

afs1 <- ts_afs(ts, list(pop1_names), polarised = TRUE)
afs2 <- ts_afs(ts, list(pop2_names), polarised = TRUE)
afs3 <- ts_afs(ts, list(pop3_names), polarised = TRUE)

plot(afs2, type = "l", col = "blue", cex = 0.2, xlab = "allele count bin", ylab = "frequency")
lines(afs1, type = "l", cex = 0.2)
lines(afs3, type = "l", col = "green", cex = 0.2)
legend("topright", legend = c("constant", "expansion", "contraction"),
       fill = c("black", "blue", "green"))
