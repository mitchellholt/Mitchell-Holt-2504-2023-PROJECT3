using Pkg; Pkg.activate(".")

using Plots, CSV, Tables, Random

# Paths to data
const fashion_mnist_train_path = "data/FashionMNIST/fashion-mnist_train.csv"
const fashion_mnist_rotations_train_path = begin
    "data/FashionMNIST/fashion-mnist-rotated_train.csv"
end
const fashion_mnist_test_path = "data/FashionMNIST/fashion-mnist_test.csv"
const fashion_mnist_rotations_test_path = begin
    "data/FashionMNIST/fashion-mnist-rotated_test.csv"
end
const mnist_train_path = "data/MNIST/mnist_train.csv"
const mnist_rotations_train_path = "data/MNIST/mnist-rotated_train.csv"
const mnist_test_path = "data/MNIST/mnist_test.csv"
const mnist_rotations_test_path = "data/MNIST/mnist-rotated_test.csv"

const img_dims = 28

const rotate_0_label = 0
const rotate_90_label = 1
const rotate_180_label = 2
const rotate_270_label = 3


# Identity function; indeed, the identity element of the monoid of functions of
# type a -> a
id(x) = x

# compose a map with itself k times (in the monoid of functions a -> a).
function compose(f :: Function, k :: Int)
    k < 0 && error("Cannot calculate inverse of an arbitrary function")
    return k == 0 ? id : f ∘ compose(f, k - 1)
end


# Rotate the matrix representation of the pixels in an image a quarter turn 
# counter-clockwise.
rotate_counter_clockwise(img) = mapslices(reverse, transpose(img); dims=1)


# Display an image from the training set
display_img(img) = heatmap(
    img;
    yflip = true, legend = false, c = cgrad([:black, :white]))


# Read all the data in the input CSV file, apply rotations and then save it to
# a CSV file
function transform_data(input_file_name :: String, output_file_name :: String;
        seed = 5)

    Random.seed!(seed)
    raw_data = Tables.matrix(
        CSV.File(input_file_name))
    # ignore existing labels, we will use our own
    imgs = [
        transpose(reshape(row[2:end], img_dims, img_dims))
        for row in eachrow(raw_data)
    ]
    transformed = [
        begin
            i = rand(0:3)
            (i, compose(rotate_counter_clockwise, 4 - i)(img))
        end
        for img in imgs
    ]
    # Plot example
    example = plot(map(x -> display_img(x[2]), transformed[1:4])...)
    # Save to csv
    out_matrix = Matrix{Int}(undef, length(transformed), (28 * 28) + 1)
    for k in 1:length(transformed)
        out_matrix[k, 1] = transformed[k][1]
        out_matrix[k, 2:end] = transformed[k][2]
    end
    CSV.write(output_file_name, Tables.table(out_matrix))
    return example
end


# Import transformed data from a given file
function import_transformed_csv(input_file_name :: String)
    raw_data = Tables.matrix(
        CSV.File(input_file_name)) # limit for debug, remove later
    return [
        (row[1], reshape(row[2:end], img_dims, img_dims))
        for row in eachrow(raw_data)
    ]
end


# transform_data(mnist_train_path, mnist_rotations_train_path)
# transform_data(mnist_test_path, mnist_rotations_test_path)

# transform_data(fashion_mnist_train_path, fashion_mnist_rotations_train_path)
# transform_data(fashion_mnist_test_path, fashion_mnist_rotations_test_path)
