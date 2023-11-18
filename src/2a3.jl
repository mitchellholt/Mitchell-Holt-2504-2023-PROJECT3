include("2a1.jl")

using Flux, Statistics, Random, StatsBase, Plots
using Flux: params, onehotbatch, crossentropy, update!

logistic_softmax_predict(img_vec, W, b) = softmax(W*img_vec .+ b)
logistic_sofmax_classifier(img_vec, W, b) = argmax(
    logistic_softmax_predict(img_vec, W, b)) - 1


function train_softmax_logistic(train_data, test_data, target_acc;
        mini_batch_size = 1000, seed = 0)

    Random.seed!(seed)

    train_labels = first.(train_data)
    train_images = last.(train_data)
    n_train = length(train_data)

    test_labels = first.(test_data)
    # test_images = last.(test_data)
    n_test = length(test_data)

    X_test = vcat(map(transpose ∘ vec, train_images)...)
    X = vcat(map(transpose ∘ vec, train_images)...)

    #Initilize parameters
    W = randn(4, 28*28)
    b = randn(4)

    opt = ADAM(0.01)
    loss(x, y) = crossentropy(
        logistic_softmax_predict(x, W, b), onehotbatch(y, 0:3))

    loss_value = 0.0
    epoch_num = 0

    #Training loop
    while true
        prev_loss_value = loss_value
        
        #Loop over mini-batches in epoch
        start_time = time_ns()
        for batch in Iterators.partition(1:n_train, mini_batch_size)
            gs = gradient(
                ()->loss(X'[:,batch], train_labels[batch]), params(W,b))
            for p in (W,b)
                update!(opt, p, gs[p])
            end
        end
        end_time = time_ns()

        #record/display progress
        epoch_num += 1
        loss_value = loss(X', train_labels)
        println("Epoch = $epoch_num ",
            "($(round((end_time-start_time)/1e9,digits=2)) sec) ",
            "Loss = $loss_value")
        
        if epoch_num == 1 || epoch_num % 5 == 0 
            acc = mean(
                [
                    logistic_sofmax_classifier(X_test'[:,k], W, b)
                    for k in 1:n_test
                ] .== test_labels)
            println("\tValidation accuracy: $acc") 
            
            #Stopping criteria
            if abs(prev_loss_value-loss_value) < 1e-3 || acc > target_acc
                break
            end
        end
    end
    return W, b
end

# Train model parameters
W, b = train_softmax_logistic(fashion_train_data, fashion_test_data);
