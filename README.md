# ANFIS low-cost PM adjustment

## Description:
This MATLAB code implements the Adaptive Neuro-Fuzzy Inference System (ANFIS) to adjust low-cost PM (Particulate Matter) data. The code consists of several MATLAB scripts and functions that perform data preprocessing, ANFIS modeling, training, and evaluation.

## Files:
### call_fuzzy.mlx:

This file serves as the main entry point for applying the ANFIS model.
It takes two input files, namely the training and test sets, in CSV format.
It analyzes specified combinations of features provided in the input files.
The number of membership functions (_input_features_num_mf_) for each feature should be ordered as the features list.
The optimization algorithm and membership type parameters are specified within this file.

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
