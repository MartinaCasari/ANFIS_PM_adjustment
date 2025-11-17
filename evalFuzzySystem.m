function [results_table, complete_table] = evalFuzzySystem(outputFIS, complete_table, currentCombination, display_results)
    %% FUNCTION: evalFuzzySystem
    % PURPOSE: Evaluate fuzzy inference system performance on input data
    % INPUTS:
    %   outputFIS - trained fuzzy inference system
    %   complete_table - dataset table containing input features and target output
    %   currentCombination - array of input feature names to use for prediction
    %   display_results - boolean flag to display results table to console
    % OUTPUTS:
    %   results_table - performance metrics table (R², MAE, MSE, RMSE per sensor + overall)
    %   complete_table - input table augmented with FIS predictions
    
    
    %% ========== DATA EXTRACTION ==========
    % Extract input features (X) from the table using specified feature names
    x_table = complete_table(:,currentCombination);
    
    y_table = complete_table(:,{'pm2p5_y'});
    
    x = x_table{:,:};
    y = y_table{:,:};
    
    
    %% ========== FIS INFERENCE ==========
    % Evaluate the fuzzy inference system on all input samples
    % outputTuned contains the predicted PM2.5 values for each input
    outputTuned = evalfis(outputFIS, x);
    
    %% ========== AUGMENT DATA TABLE WITH PREDICTIONS ==========
    % Add the FIS predictions as a new column to the complete table
    % Insert after the 'pm2p5_y' column for easy comparison with actual values
    complete_table = addvars(complete_table, outputTuned, 'After', 'pm2p5_y', 'NewVariableName', 'pm2p5_pred');
    
    % Sort the table by timestamp ('valid_at') in ascending order for temporal analysis
    complete_table = sortrows(complete_table, 'valid_at', 'ascend');
    
    
    %% ========== RESULTS TABLE INITIALIZATION ==========
    % Get unique sensor IDs from the dataset
    sensor_ids = unique(complete_table.sensor_id);
    
    % Pre-allocate results table with 5 columns for performance metrics
    % Columns: SensorID (string), R² (double), MAE (double), MSE (double), RMSE (double)
    results_table = table('Size', [0, 5], 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, 'VariableNames', {'SensorID', 'R2', 'MAE', 'MSE', 'RMSE'});
    
    
    %% ========== PER-SENSOR PERFORMANCE EVALUATION ==========
    % Loop through each sensor to calculate individual performance metrics
    for i = 1:length(sensor_ids)
        sensor_id = sensor_ids(i);
        
        % Extract data for the current sensor
        sensor_train_table = complete_table(complete_table.sensor_id == sensor_id, :);
        
        % Get actual and predicted PM2.5 values for this sensor
        y_true = sensor_train_table.pm2p5_y;
        y_pred = sensor_train_table.pm2p5_pred;
        
        
        %% ===== CALCULATE PERFORMANCE METRICS =====
        % R² Score: Correlation coefficient between predicted and actual values
        % Range: -∞ to 1, where 1 = perfect prediction, 0 = random, <0 = poor
        r2 = corr(y_pred, y_true, 'Type', 'Pearson');
        
        % Mean Absolute Error: Average absolute difference between predicted and actual
        % Units: same as target variable (PM2.5 in µg/m³)
        mae = mean(abs(y_true - y_pred));
        
        % Mean Squared Error: Average squared difference between predicted and actual
        % Penalizes larger errors more heavily than smaller ones
        mse = mean((y_true - y_pred).^2);
        
        % Root Mean Squared Error: Square root of MSE
        % Units: same as target variable (PM2.5 in µg/m³)
        rmse = sqrt(mse);
        
        % Add sensor results as a new row to the results table
        results_table = [results_table; {string(sensor_id), r2, mae, mse, rmse}];
    end
    % End per-sensor loop
    
    
    %% ========== OVERALL (ALL SENSORS) PERFORMANCE EVALUATION ==========
    % Calculate aggregate performance metrics across all sensors
    y_true = complete_table.pm2p5_y;
    y_pred = complete_table.pm2p5_pred;
    
    % R² Score: Overall correlation for entire dataset
    r2 = corr(y_pred, y_true, 'Type', 'Pearson');
    
    % Mean Absolute Error: Overall MAE across all data points
    mae = mean(abs(y_true - y_pred));
    
    % Mean Squared Error: Overall MSE across all data points
    mse = mean((y_true - y_pred).^2);
    
    % Root Mean Squared Error: Overall RMSE across all data points
    rmse = sqrt(mse);
    
    % Add aggregate results row to the results table with "all" as sensor identifier
    results_table = [results_table; {"all", r2, mae, mse, rmse}];
    
    
    %% ========== DISPLAY RESULTS ==========
    % Display the results table to console if requested by caller
    if display_results
        disp(results_table)
    end
    
end