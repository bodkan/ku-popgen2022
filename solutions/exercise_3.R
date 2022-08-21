chimp <- population("CH", time = 7e6, N = 7000)

afr <- population("AFR", parent = chimp, time = 6e6, N = 10000)
eur <- population("EUR", parent = afr, time = 70e3, N = 5000)

alt <- population("ALT", parent = afr, time = 700e3, N = 500)
vi <- population("VI", parent = alt, time = 120e3, N = 1000)

gf <- gene_flow(from = vi, to = eur, rate = 0.03, start = 50000, end = 40000)

model <- compile_model(
  populations = list(chimp, alt, vi, afr, eur), gene_flow = gf,
  generation_time = 30
)

ts <- msprime(model, sequence_length = 100e6, recombination_rate = 1e-8) %>%
  ts_mutate(mutation_rate = 1e-8)