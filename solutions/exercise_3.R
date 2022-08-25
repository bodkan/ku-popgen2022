library(slendr)

# define a couple of populations
chimp <- population("CH", time = 7e6, N = 7000)

afr <- population("AFR", parent = chimp, time = 6e6, N = 10000)
eur <- population("EUR", parent = afr, time = 70e3, N = 5000)

alt <- population("ALT", parent = afr, time = 700e3, N = 500)
vi <- population("VI", parent = alt, time = 120e3, N = 1000)

# define a gene-flow event from Neanderthals to Europeans at 3%
gf <- gene_flow(from = vi, to = eur, rate = 0.03, start = 50000, end = 40000)

# compile the model
model <- compile_model(
  populations = list(chimp, alt, vi, afr, eur), gene_flow = gf,
  generation_time = 30
)

# you can visualize the model by running
# plot_model(model, proportions = TRUE)
# plot_model(model, log = TRUE, proportions = TRUE)

# simulate 1Mb tree sequence data
ts <- msprime(model, sequence_length = 25e6, recombination_rate = 1e-8, random_seed = 123)