include("1a1.jl")

using StatsBase

# drop bad data and parse 
relevant_data = select(data, [:Distance, :Rooms, :Price])
filter!(:Distance => s -> isdigit(first(s)), relevant_data)
filter!(:Price => s -> length(s) > 0, relevant_data)
transform!(relevant_data, :Distance => ByRow(s -> parse(Float32, s)) => :Distance)
transform!(relevant_data, :Price => ByRow(s -> parse(Int, s)) => :Price)
transform!(relevant_data, :Rooms => ByRow(s -> s < 6 ? string(s) : "6+") => :Rooms)
sort!(relevant_data)

# Distance summary - plot price as a function of time
distance_price() = plot(
    relevant_data.Distance,
    relevant_data.Price;
    title = "Price vs Distance",
    label = false,
    xlabel = "Distance from CBD (km)",
    ylabel = "Price")

# Room summary - q1, median, q3 price (as series in a bar) for each room size.
# We need to transform the data into a matrix where rows are different room
#   categories, cols are q1, median, q3 resp.
function room_price()
    room_price_data = combine(groupby(relevant_data, :Rooms),
        :Price => x -> tuple(nquantile(x, 4)[2:4]))
    price_data = map(reverse ∘ first, room_price_data.Price_function)

    bar_array = Array{Float64}(undef, nrow(room_price_data), 3)
    for i in 1:nrow(room_price_data)
        bar_array[i,:] = price_data[i]
    end
    return bar(room_price_data.Rooms, bar_array;
        title = "Price vs Rooms summary",
        xlabel = "Number of rooms",
        ylabel = "Price",
        label = ["Q3" "Median" "Q1"])
end

function room_distance_price()
    room_data = filter(:Rooms => ==("1"), relevant_data)
    plt = plot(room_data.Distance, room_data.Price;
        title = "Price vs Distance Summary",
        xlabel = "Distance from CBD (km)",
        ylabel = "price",
        label = "1 room")
    for room_size in ["2", "3", "4", "5", "6+"]
        room_data = filter(:Rooms => ==(room_size), relevant_data)
        plot!(room_data.Distance, room_data.Price;
            label = "$room_size rooms")
    end
    return plt
end
