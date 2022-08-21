library(slendr)
library(tidyverse)

# define components of the demographic history ----------------------------

chimp <- population("CH", time = 7e6, N = 7000)

afr <- population("AFR", parent = chimp, time = 6e6, N = 10000)
eur <- population("EUR", parent = afr, time = 70e3, N = 5000)

alt <- population("ALT", parent = afr, time = 700e3, N = 500)
vi <- population("VI", parent = alt, time = 120e3, N = 1000)

gf <- gene_flow(from = vi, to = eur, rate = 0.03, start = 50000, end = 40000)


# compile the slendr model ------------------------------------------------

model <- compile_model(
  populations = list(chimp, alt, vi, afr, eur), gene_flow = gf,
  generation_time = 30
)



# schedule sampling of individuals ----------------------------------------

schedule <- rbind(
  schedule_sampling(model, times = 70000, list(alt, 1)), # Altai individual
  schedule_sampling(model, times = 40000, list(vi, 1)),  # Vindija individual
  schedule_sampling(model, times = seq(from = 2000, to = 40000, by = 1000), list(eur, 1)), # EMH samples
  schedule_sampling(model, times = 0, list(chimp, 1), list(afr, 1), list(eur, 1))
)


# simulate tree sequence,  add mutations ----------------------------------

ts <-
  msprime(
    model, samples = schedule,
    sequence_length = 100e6, recombination_rate = 1e-8
  ) %>%
  ts_mutate(mutation_rate = 1e-8)


# extract information about samples from populations x1 and x2
europeans <- ts_samples(ts) %>% filter(pop == "EUR")
europeans

europeans$ancestry <- ts_f4ratio(
  ts, X = europeans$name,
  A = "ALT_1", B = "VI_1", C = "AFR_1", O = "CH_1"
)$alpha

ggplot(europeans, aes(time, ancestry)) +
  geom_point() +
  geom_smooth(method = "lm", linetype = 2, color = "red", size = 0.5) +
  xlim(40000, 0) + coord_cartesian(ylim = c(0, 0.1)) +
  labs(x = "time [years ago]", y = "Neanderthal ancestry proportion")
