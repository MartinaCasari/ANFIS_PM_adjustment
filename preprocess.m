function [complete_train_table, complete_test_table] = preprocess(train_dataset, test_dataset, input_features)
    %% FUNCTION: preprocess
    % PURPOSE: Prepare raw datasets for fuzzy inference system training and testing
    % INPUTS:
    %   train_dataset - raw training data table with mixed data types
    %   test_dataset - raw testing data table with mixed data types
    %   input_features - cell array of feature names to be used as FIS inputs
    % OUTPUTS:
    %   complete_train_table - preprocessed and normalized training dataset
    %   complete_test_table - preprocessed and normalized testing dataset
    
    disp('--- Start preprocessing')
    
    
    %% ========== NUMERIC COLUMN EXTRACTION ==========
    disp('--- --- Keep numeric columns')
    
    % Extract only numeric columns from training dataset
    % Removes categorical, string, and other non-numeric data types
    train_dataset_numeric = train_dataset(:, vartype('numeric'));
    
    % Restore the 'valid_at' timestamp column (datetime type, not numeric)
    % Required for temporal analysis and month extraction later
    train_dataset_numeric.valid_at = train_dataset.valid_at;
    
    % Extract only numeric columns from test dataset
    % Ensures consistent data structure between train and test sets
    test_dataset_numeric = test_dataset(:, vartype('numeric'));
    
    % Restore the 'valid_at' timestamp column to test dataset
    test_dataset_numeric.valid_at = test_dataset.valid_at;
    
    
    %% ========== MISSING VALUE IMPUTATION ==========
    disp('--- --- Fill missing values linearly')
    
    % Fill missing values using linear interpolation method
    % Linear interpolation estimates missing values based on neighboring points
    % Example: if value at t=2 is missing and t=1 is 10, t=3 is 20, then t=2 becomes 15
    train_dataset_numeric = fillmissing(train_dataset_numeric, 'linear');
    test_dataset_numeric = fillmissing(test_dataset_numeric, 'linear');
    
    % Restore the 'sensor_id' identifier column (categorical, not numeric)
    % Essential for tracking which sensor produced each measurement
    train_dataset_numeric.sensor_id = train_dataset.sensor_id;
    test_dataset_numeric.sensor_id = test_dataset.sensor_id;
    
    % Update main dataset variables with numeric-only versions
    % Overwrites original mixed-type datasets
    train_dataset = train_dataset_numeric;
    test_dataset = test_dataset_numeric;
    
    
    %% ========== OUTLIER REMOVAL ==========
    disp('--- --- If present remove high values')
    
    % Remove outliers where PM2.5 sensor readings exceed 500 µg/m³
    % These values likely represent sensor malfunctions or extreme anomalies
    % pm2p5_x: uncalibrated/raw PM2.5 sensor measurement
    % pm2p5_y: reference/calibrated PM2.5 measurement
    
    % Remove training samples with extreme pm2p5_x values
    train_dataset(train_dataset.pm2p5_x > 500, :) = [];
    
    % Remove training samples with extreme pm2p5_y values
    train_dataset(train_dataset.pm2p5_y > 500, :) = [];
    
    % Remove test samples with extreme pm2p5_x values
    test_dataset(test_dataset.pm2p5_x > 500, :) = [];
    
    % Remove test samples with extreme pm2p5_y values
    test_dataset(test_dataset.pm2p5_y > 500, :) = [];
    
    
    %% ========== TEMPORAL FEATURE ENGINEERING ==========
    disp('--- --- Create month column')
    
    % Extract month number (1-12) from datetime timestamp
    % Captures seasonal patterns that may affect air quality measurements
    train_dataset.month = month(train_dataset.valid_at);
    test_dataset.month = month(test_dataset.valid_at);
    
    
    %% ========== FUZZY LOGIC RANGE ADJUSTMENT ==========
    % CRITICAL: Fuzzy logic systems require well-defined input ranges for membership functions
    % This block ensures training data spans the full range of test data values
    % Without this, the FIS may not generalize properly to test set extremes
    
    % Initialize empty tables to collect extreme value rows
    minRowsTable = table();  % Will store rows with minimum feature values
    maxRowsTable = table();  % Will store rows with maximum feature values
    
    % Iterate over each input feature to find and extract extreme values
    for i = 1:numel(input_features)
        
        %% ===== FIND EXTREME VALUES IN TEST SET =====
        % Get the column index for the current feature name
        % strcmp performs string comparison to match feature name
        featureIndex = find(strcmp(test_dataset.Properties.VariableNames, input_features{i}));
        
        % Find the row index with the minimum value for current feature
        % [~, minRowIndex] discards the actual min value, keeps only the row index
        [~, minRowIndex] = min(test_dataset.(featureIndex));
        
        % Find the row index with the maximum value for current feature
        [~, maxRowIndex] = max(test_dataset.(featureIndex));
        
        
        %% ===== EXTRACT EXTREME VALUE ROWS =====
        % Extract the complete row containing the minimum value
        % This ensures the training set can handle the lowest test values
        minRow = test_dataset(minRowIndex, :);
        
        % Extract the complete row containing the maximum value
        % This ensures the training set can handle the highest test values
        maxRow = test_dataset(maxRowIndex, :);
        
        
        %% ===== ACCUMULATE EXTREME ROWS =====
        % Append minimum value row to collection table
        minRowsTable = [minRowsTable; minRow];
        
        % Append maximum value row to collection table
        maxRowsTable = [maxRowsTable; maxRow];
        
        
        %% ===== REMOVE FROM TEST SET TO AVOID DUPLICATION =====
        % Remove the extracted minimum row from test dataset
        % Prevents these samples from appearing in both train and test sets
        test_dataset(minRowIndex, :) = [];
        
        % Remove the extracted maximum row from test dataset
        % Note: Must remove max AFTER min to avoid index shifting issues
        test_dataset(maxRowIndex, :) = [];
        
    end
    % End feature iteration loop
    
    
    %% ===== TRANSFER EXTREME VALUES TO TRAINING SET =====
    % Append all collected minimum value rows to training dataset
    % Expands training data range to cover test set lower bounds
    train_dataset = [train_dataset; minRowsTable];
    
    % Append all collected maximum value rows to training dataset
    % Expands training data range to cover test set upper bounds
    train_dataset = [train_dataset; maxRowsTable];
    
    
    %% ========== MIN-MAX NORMALIZATION ==========
    disp('--- --- Normalize columns')
    
    %% ===== DATA EXTRACTION =====
    % Extract input feature columns as numeric arrays from both datasets
    data1 = table2array(train_dataset(:, input_features));
    data2 = table2array(test_dataset(:, input_features));
    
    
    %% ===== GLOBAL NORMALIZATION PARAMETERS =====
    % Concatenate training and test data to compute global min/max
    % This ensures both datasets are normalized to the same scale [0, 1]
    % Critical for consistent fuzzy membership function behavior
    all_data = [data1; data2];
    
    % Compute minimum value for each feature across all data
    % Used as the lower bound in min-max normalization
    min_vals = min(all_data);
    
    % Compute maximum value for each feature across all data
    % Used as the upper bound in min-max normalization
    max_vals = max(all_data);
    
    
    %% ===== APPLY MIN-MAX NORMALIZATION =====
    % Normalize training data: normalized = (x - min) / (max - min)
    % Maps all values to range [0, 1]
    normalized_data1 = (data1 - min_vals) ./ (max_vals - min_vals);
    
    % Normalize test data using the same min/max parameters
    % Ensures consistent scaling between training and test sets
    normalized_data2 = (data2 - min_vals) ./ (max_vals - min_vals);
    
    % Legacy code: Alternative approach using array2table (commented out)
    % normalized_table1 = array2table(normalized_data1, 'VariableNames', train_dataset(:,input_features).Properties.VariableNames);
    % normalized_table2 = array2table(normalized_data2, 'VariableNames', test_dataset(:,input_features).Properties.VariableNames);
    
    
    %% ===== PRESERVE ORIGINAL PM2.5 VALUES =====
    % Save original (unnormalized) PM2.5 sensor readings for later analysis
    % Required for calculating real-world error metrics and visualization
    train_dataset.pm2p5_x_original = train_dataset.pm2p5_x;
    test_dataset.pm2p5_x_original = test_dataset.pm2p5_x;
    
    
    %% ===== REPLACE WITH NORMALIZED VALUES =====
    % Replace each input feature column in training dataset with normalized version
    % Iterates through all features to update in-place
    for i = 1:size(data1, 2)
        train_dataset.(train_dataset(:, input_features).Properties.VariableNames{i}) = normalized_data1(:, i);
    end
    
    % Replace each input feature column in test dataset with normalized version
    for i = 1:size(data2, 2)
        test_dataset.(test_dataset(:, input_features).Properties.VariableNames{i}) = normalized_data2(:, i);
    end
    
    
    %% ========== FINAL TABLE CONSTRUCTION ==========
    % Create final training table with selected columns in specific order:
    %   - valid_at: timestamp for temporal analysis
    %   - sensor_id: sensor identifier
    %   - pm2p5_x: normalized raw PM2.5 reading (FIS input)
    %   - relative_humidity: normalized humidity (FIS input)
    %   - temperature: normalized temperature (FIS input)
    %   - pressure: normalized atmospheric pressure (FIS input)
    %   - pm2p5_y: normalized reference PM2.5 (FIS target output)
    %   - pm2p5_x_original: original unnormalized PM2.5 for evaluation
    complete_train_table = train_dataset(:, {'valid_at'; 'sensor_id'; 'pm2p5_x'; 'relative_humidity'; 'temperature'; 'pressure'; 'pm2p5_y'; 'pm2p5_x_original'});
    
    % Create final test table with identical column structure
    % Ensures consistency for FIS evaluation and validation
    complete_test_table = test_dataset(:, {'valid_at'; 'sensor_id'; 'pm2p5_x'; 'relative_humidity'; 'temperature'; 'pressure'; 'pm2p5_y'; 'pm2p5_x_original'});
    
    disp('--- End preprocessing')
    
end