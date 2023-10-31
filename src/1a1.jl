using Pkg
Pkg.activate(".")

using Plots, DataFrames, CSV


function get_data()
    return DataFrame(CSV.File("data/Melbourne_housing_FULL.csv"; missingstring = "NA"))
end


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


data = get_data()


room_bar() = bar(
    ["1", "2", "3", "4", "5", "6+"],
    category_counts(data.Rooms, 1:6);
    title = "Room Distribution",
    label = false)


function prices_bar()
    # Drop data that is the empty string
    prices = map(y -> parse(Int, y), filter(x -> length(x) > 0, data.Price))
    categories = collect(0:Int(3e5):Int(1.5e6))

    labels = Vector{String}(undef, length(categories))
    for (i, lower) in enumerate(categories)
        labels[i] = "$(lower)+"
    end

    return bar(
        labels,
        category_counts(prices, categories);
        title = "Price Distribution",
        label = false)
end


method_bar() = bar(category_counts(data.Method)...;
    title = "Method",
    label = false)


display(method_bar())
