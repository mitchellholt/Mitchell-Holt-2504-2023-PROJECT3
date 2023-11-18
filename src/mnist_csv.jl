using Pkg; Pkg.activate(".")

using CSV, MLDatasets, Tables


# Save MNIST data to CSV
function save_data_csv(data, file_path)
    imgs = data[1]
    labels = data[2]

    images_vec = [imgs[:, :, k]' for k in 1:length(labels)]

    out_matrix = Matrix{Int}(undef, length(images_vec), (28 * 28) + 1)
    for k in 1:length(images_vec)
        out_matrix[k, 1] = labels[k]
        out_matrix[k, 2:end] = images_vec[k]
    end
    CSV.write(file_path, Tables.table(out_matrix))
end


save_data_csv(MLDatasets.MNIST.traindata(Int), "data/MNIST/mnist_train.csv")
save_data_csv(MLDatasets.MNIST.testdata(Int), "data/MNIST/mnist_test.csv")
