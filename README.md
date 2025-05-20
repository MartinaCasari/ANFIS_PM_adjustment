# ANFIS low-cost PM adjustment

## Description:
This MATLAB code implements the Adaptive Neuro-Fuzzy Inference System (ANFIS) to adjust low-cost PM (Particulate Matter) data. The framework includes preprocessing, training, evaluation, and now supports rule pruning techniques to improve model efficiency and interpretability.

## Files:
### call_fuzzy.mlx:

This is the main script to run the ANFIS-based model.

- Takes as input two CSV files for training and testing datasets.
- Allows specification of feature combinations and corresponding numbers of membership functions (input_features_num_mf).
- Contains parameters for membership function type and optimization algorithm.

Update:
Now includes the option to iteratively reduce fuzzy rules using two evaluation methods:
- Binary Activation Method (BAM): Counts the number of times a rule is activated (non-zero).
- Weighted Activation Method (WAM): Accumulates the activation strength across the dataset.
- Rules with low usage or low weight are progressively pruned, and model performance is re-evaluated at each iteration.

This capability allows for:
- Model simplification and reduced memory usage
- Performance stability during pruning, especially when using WAM
- Enhanced interpretability of the final rule base

Evaluates the trained ANFIS model using the test set.
Computes key performance metrics:

- Pearson correlation coefficient
- MAE (Mean Absolute Error)
- MSE (Mean Squared Error)
- RMSE (Root Mean Squared Error)

Outputs both per-sensor metrics (by SensorID) and global aggregated performance.

### fitFuzzySystem.m:

This MATLAB function creates and trains the ANFIS model using the provided training data.
The ANFIS model is trained over a specified number of epochs (e.g., 100 epochs).

### evalFuzzySystem.m:

This MATLAB function evaluates the trained ANFIS model using the provided test set.
It calculates performance metrics such as R2 (Coefficient of Determination), MAE (Mean Absolute Error), MSE (Mean Squared Error), and RMSE (Root Mean Squared Error) for each _'SensorID'_ in the training and test set.
Global metrics are also provided under the _'all'_ category, aggregating the performance across all sensors.

## Usage:
Ensure that MATLAB is installed on your system.
Place the input CSV files containing the training and test sets in the same directory as the MATLAB scripts.
Open and run the call_fuzzy.mlx MATLAB Live Script to execute the ANFIS modeling, training, and evaluation process.
Review the output results and performance metrics generated to assess the ANFIS model's performance.

Be sure that _fitFuzzySystem.m_ and _evalFuzzySystem.m_ are in the _Search Path_.
