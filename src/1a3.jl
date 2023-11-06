include("1a1.jl")

struct Date
    month :: Int
    year :: Int
end

# Helper functions for date
function Base.isless(d1 :: Date, d2 :: Date)
    d1.year == d2.year ? d1.month < d2.month : d1.year < d2.year
end

# Assume the string is formatted dd/mm/yyyy
function parseDate(str)
    tokens = split(str, "/")
    return Date(
        parse(Int, tokens[2]),
        parse(Int, tokens[3]))
end

to_string(date :: Date) = "$(date.month)/$(date.year)"

# Do data stuff idk
relevant_data = select(data, [:Date, :Price, :Type])
filter!(:Price => s -> length(s) > 0, relevant_data)
transform!(relevant_data, :Price => ByRow(s -> parse(Int, s)) => :Price)
transform!(relevant_data, :Date => ByRow(parseDate) => :Date)

house_data = filter(:Type => ==("h"), relevant_data)

month_groups = groupby(relevant_data, :Date)
house_month_groups = groupby(house_data, :Date)

# Properties sold over time, with series for by volume and by value
function properties_time_volume(data_groups)
    volume = combine(data_groups, :Price => length)
    return plot(0:(nrow(volume) - 1), volume.Price_length;
        label = false,
        xlabel = "Number of months after $(to_string(first(volume.Date)))",
        ylabel = "Number of properties sold",
        title = "Volume of sales over time")
end

function properties_time_value(data_groups)
    value = combine(data_groups, :Price => sum)
    return plot(0:(nrow(value) - 1), value.Price_sum;
        label = false,
        xlabel = "Number of months after $(to_string(first(value.Date)))",
        ylabel = "Total value of properties sold",
        title = "Value of sales over time")
end
