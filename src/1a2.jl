using Pkg
Pkg.activate(".")

using Plots, DataFrames, CSV

data = DataFrame(CSV.File("data/Melbourne_housing_FULL.csv"; missingstring = "NA"))


