# Simulation lecture for PopGen 2022

## Prerequisites

-   Working R installation (at least R 3.6, preferably 4.x)
-   RStudio highly recommended
-   macOS or Linux (but Windows should work too! see the bottom of this page)

## Installation instructions

### *slendr* simulation package

Getting *slendr* to work is critical. The whole lecture is dedicated to this package.

First, run this in your R console:

    install.packages("slendr")

Assuming the above runs successfully, you will need to setup a dedicated Python environment with tools we'll be using for simulation and analysis. To do this, *slendr* provides a helper function that takes care of everything on your behalf.

First, load *slendr* itself. This will very likely write a message that you're:

1.  missing SLiM -- this is OK, feel free to ignore it

2.  missing a Python environment -- we'll deal with it in the following step

```{=html}
<!-- -->
```
    library(slendr)

Next, run the following function. This will ask for permission to install an isolated Python mini-environment just for slendr -- this won't affect your own Python setup at all, so don't be afraid to confirm this.

    setup_env()

Finally, make sure you get a positive confirmation from the following check:

    check_env()

## Other R package dependencies

I will use some tidyverse packages for analysis and plotting.

I recommend you at least install the following packages:

    install.packages(c("dplyr", "ggplot2", "magrittr", "forcats", "MASS"))

## Testing the setup

Copy the following script to your R session after you successfully installed your R dependencies as described above.

    library(slendr)

    o <- population("outgroup", time = 1, N = 10)
    b <- population("b", parent = o, time = 500, N = 10)
    c <- population("c", parent = b, time = 1000, N = 10)
    x1 <- population("x1", parent = c, time = 2000, N = 10000)
    x2 <- population("x2", parent = c, time = 2000, N = 10000)
    a <- population("a", parent = b, time = 1500, N = 10)

    gf <- gene_flow(from = b, to = x1, start = 2100, end = 2150, rate = 0.1)

    model <- compile_model(
      populations = list(a, b, x1, x2, c, o), gene_flow = gf,
      generation_time = 1, sim_length = 2200
    )

    ts <- msprime(model, sequence_length = 250e6, recombination_rate = 1e-8)

If this runs without error and you get a small summary table from the `ts` object, you're all set!

# IF THIS DOESN'T WORK

Reach out to the organizes (ideally Fernando) and ask them to get help from me (Martin P.). Or find me in person.

The software I will be teaching is currently fully supported on macOS and Linux. However, the parts we'll be covering in the lecture and exercises should also work on Windows. The only thing that will not work on Windows for the moment are spatial *slendr* simulations using SLiM but we won't be using those in the course, so this is not a problem.
