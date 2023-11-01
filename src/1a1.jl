using Pkg
Pkg.activate(".")

using Plots, DataFrames, CSV


function last_less_index(item, categories)
    for (i, cat) in enumerate(categories)
        item < cat && return i - 1
    end
    return length(categories)
end


"""
Count the number of items in the iterator iter belonging to each category. The
items of iter must be totally ordered and of the same type of those in
categories.
"""
function category_counts(iter, categories)
    results = zeros(Int, length(categories))
    for item in iter
        results[last_less_index(item, categories)] += 1
    end
    return results
end


function category_counts(iter)
    categories = Dict{String, Int}()
    for item in iter
        categories[item] = haskey(categories, item) ? categories[item] + 1 : 1
    end
    results = collect(categories)
    return (first.(results), last.(results))
end


data = DataFrame(CSV.File("data/Melbourne_housing_FULL.csv"; missingstring = "NA"))

room() = bar(
    ["1", "2", "3", "4", "5", "6+"],
    category_counts(data.Rooms, 1:6);
    title = "Room Distribution",
    label = false)

prices() = histogram(
    [parse(Int, x) for x in data.Price if length(x) > 0];
    title = "Prices Distribution",
    legend = false)

method() = bar(category_counts(data.Method)...;
    title = "Method",
    label = false)

distance() = histogram(
    [parse(Float32, x) for x in data.Distance if isdigit(first(x))];
    title = "Distance",
    xlabel = "Distance from CBD (km)",
    label = false)

const superscript_2 = Char(0x00B2)

function landsize()
    land_data = [parse(Int, x) for x in data.Landsize if length(x) > 0]
    buckets = collect(0:200:1000)
    labels = Vector{String}(undef, length(buckets))
    for i in 2:length(buckets)
        labels[i - 1] = "$(buckets[i - 1])-$(buckets[i] - 1)"
    end
    labels[end] = "$(buckets[end])+"
    return bar(
        labels,
        category_counts(land_data, buckets);
        title = "Land Sizes",
        label = false,
        xlabel = "Land size (m$superscript_2)")
end
