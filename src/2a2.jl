include("2a1.jl")

using LinearAlgebra
using Flux: onehotbatch

labels = 0:3

fashion_train_data = import_transformed_csv(fashion_mnist_rotations_train_path)
fashion_test_data = import_transformed_csv(fashion_mnist_rotations_test_path)

train_data = import_transformed_csv(mnist_rotations_train_path)
test_data = import_transformed_csv(mnist_rotations_test_path)

function train_linear_model(train_data)
    train_labels = first.(train_data)
    train_images = last.(train_data)
    n_train = length(train_data)

    X = vcat(map(transpose ∘ vec, train_images)...)

    A = [ones(n_train) X]
    Adag = pinv(A)

    tfPM(x) = x ? +1 : -1
    yDat(k) = tfPM.(onehotbatch(train_labels, labels)'[:,k+1])
    # this is the trained model (a list of 4 beta coeff vectors)
    bets = [Adag*yDat(k) for k in labels]
end


function test_model(test_data, coeff_vec)
    test_labels = first.(test_data)
    test_images = last.(test_data)
    n_test = length(test_data)

    linear_classify(square_image) = argmax(
        [([1 ; vec(square_image)])'*coeff_vec[k] for k in 1:4])-1

    predictions = linear_classify.(test_images)
    confusionMatrix = [
        sum((predictions .== i) .& (test_labels .== j)) for i in labels, j in labels
    ]
    acc = sum(diag(confusionMatrix))/n_test
    println("Accuracy: $acc")
end

# test_model(fashion_test_data, train_linear_model(fashion_train_data))
# test_model(test_data, train_linear_model(train_data))
