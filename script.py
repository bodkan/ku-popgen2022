import msprime

demography = msprime.Demography()
demography.add_population(name="A", initial_size=10_000)
demography.add_population(name="B", initial_size=5_000)
demography.add_population(name="C", initial_size=1_000)
demography.add_population_split(time=1000, derived=["A", "B"], ancestral="C")

ts = msprime.sim_ancestry(
  sequence_length=10e6,
  recombination_rate=1e-8,
  samples={"A": 100, "B": 100},
  demography=demography
)
