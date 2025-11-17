function [r2_train, r2_test, mae_train, mae_test] = evaluateRulesReductionWithTuning(outputFIS, ruleUsageCounter, complete_train_table, complete_test_table, currentCombination, display_results)
    %% FUNCTION: evaluateRulesReductionWithTuning
    % PURPOSE: Progressively reduce rules one-by-one and retrain FIS to find optimal rule count
    % INPUTS:
    %   outputFIS - original fuzzy inference system with all rules
    %   ruleUsageCounter - vector of rule activation frequencies
    %   complete_train_table - training dataset
    %   complete_test_table - test dataset
    %   currentCombination - array of input feature names
    %   display_results - boolean flag to display evaluation results during iteration
    % OUTPUTS:
    %   r2_train, r2_test - R² scores for each rule configuration (training and test)
    %   mae_train, mae_test - Mean Absolute Error for each rule configuration
    %   mse_train, mse_test - Mean Squared Error for each rule configuration
    %   rmse_train, rmse_test - Root Mean Squared Error for each rule configuration
    
    
    %% ========== INITIALIZATION ==========
    % Get the total number of rules in the original FIS
    numRules = length(outputFIS.Rules);
    
    % Sort rules by their activation frequency in descending order (most used first)
    [~, sortedIndices] = sort(ruleUsageCounter, 'descend');
    
    % Suppress all warnings (particularly ANFIS warnings about rule firing)
    warning('off','all')
    
    
    %% ========== PRE-ALLOCATE PERFORMANCE METRICS ARRAYS ==========
    % Initialize arrays to store performance metrics for each iteration
    % Each iteration removes one more rule (starting from numRules-1 down to 1 rule)
    r2_train = zeros(1, numRules-1);
    r2_test = zeros(1, numRules-1);
    mae_train = zeros(1, numRules-1);
    mae_test = zeros(1, numRules-1);
    mse_train = zeros(1, numRules-1);
    mse_test = zeros(1, numRules-1);
    rmse_train = zeros(1, numRules-1);
    rmse_test = zeros(1, numRules-1);
    
    
    %% ========== ITERATIVE RULE REDUCTION LOOP ==========
    % Loop through each possible rule configuration from (numRules-1) down to 1 rule
    for iter = 1:numRules-1
        
        %% ===== RULE SELECTION =====
        % Keep only the top (numRules - iter + 1) rules
        % In first iteration: keep all but 1 rule
        % In last iteration: keep only 1 rule
        selectedRulesIdx = sortedIndices(1:end-iter+1);
        
        
        %% ===== FIS REDUCTION =====
        % Create a copy of the original FIS for modification
        reducedFIS = outputFIS;
        
        % Extract input features (X) and output target (y) from training data
        x = complete_train_table(:,currentCombination);
        y = complete_train_table(:,{'pm2p5_y'});
        
        % Check if rule count differs from original full FIS (avoid unnecessary operations)
        if length(selectedRulesIdx) ~= 48
            % Keep only the selected rules by indexing into the Rules array
            reducedFIS.Rules = reducedFIS.Rules(selectedRulesIdx);
            
            % Remove output membership functions that correspond to removed rules
            % This maintains consistency between rules and output fuzzy sets
            reducedFIS.Output.MembershipFunctions = reducedFIS.Output.MembershipFunctions(selectedRulesIdx);
        end
        
        
        %% ===== FIS RETRAINING WITH ANFIS TUNING =====
        disp('Retraining...');
        
        % Set up ANFIS tuning options for optimization
        opt = tunefisOptions("Method","anfis");
        
        % Get tunable parameters (input/output membership functions and rules)
        [in, out, ~] = getTunableSettings(reducedFIS);
        
        % Convert table data to array format for ANFIS
        x_data = x{:,:};
        y_data = y{:,:};
        
        % Validate that input and output have matching number of samples
        assert(size(x_data,1) == size(y_data,1), 'Input/output size mismatch');
        
        % Retrain/tune the reduced FIS using ANFIS algorithm
        % This optimizes membership function parameters for the current rule subset
        retrainedFIS = tunefis(reducedFIS,[in;out],x{:,:}, y{:,:},opt);
        
        
        %% ===== MODEL EVALUATION =====
        % Display iteration progress if requested
        if display_results
            disp(['Iteration ', num2str(iter), ': Evaluating with ', num2str(length(selectedRulesIdx)), ' rules']);
        end
        
        % Evaluate the retrainedFIS on the training dataset
        result_train = evalFuzzySystem(retrainedFIS, complete_train_table, currentCombination, display_results);
        
        % Extract and store training performance metrics from the last row of results
        r2_train(iter) = table2array(result_train(height(result_train),2));
        mae_train(iter) = table2array(result_train(height(result_train),3));
        mse_train(iter) = table2array(result_train(height(result_train),4));
        rmse_train(iter) = table2array(result_train(height(result_train),5));
        
        % Evaluate the retrainedFIS on the test dataset
        result_test = evalFuzzySystem(retrainedFIS, complete_test_table, currentCombination, display_results);
        
        % Extract and store test performance metrics from the last row of results
        r2_test(iter) = table2array(result_test(height(result_test),2));
        mae_test(iter) = table2array(result_test(height(result_test),3));
        mse_test(iter) = table2array(result_test(height(result_test),4));
        rmse_test(iter) = table2array(result_test(height(result_test),5));
        
    end
    % End of iterative reduction loop
    
end