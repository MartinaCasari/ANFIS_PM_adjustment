function [r2_train, r2_test, mae_train, mae_test] = evaluateRulesReductionWithSpecificNumberOfRules(outputFIS, ruleUsageCounter, complete_train_table, complete_test_table, currentCombination, display_results, rules_befor_drop)
    %% FUNCTION: evaluateRulesReductionWithSpecificNumberOfRules
    % PURPOSE: Reduce FIS to a specific number of rules, retrain, and evaluate performance
    % INPUTS:
    %   outputFIS - original fuzzy inference system
    %   ruleUsageCounter - vector of rule activation frequencies
    %   complete_train_table - training dataset
    %   complete_test_table - test dataset
    %   currentCombination - array of input feature names
    %   display_results - boolean flag to display evaluation results
    %   rules_befor_drop - target number of rules to keep
    % OUTPUTS:
    %   r2_train, r2_test - R² scores for training and test sets
    %   mae_train, mae_test - Mean Absolute Error for training and test sets
    
    
    %% ========== WARNING SUPPRESSION ==========
    % Suppress all warnings (particularly ANFIS warnings about rule firing)
    warning('off','all')
    
    
    %% ========== RULE SELECTION BASED ON USAGE FREQUENCY ==========
    % Sort rules by their activation frequency in descending order (most used first)
    % sortedIndices: indices of rules ordered by frequency of activation
    [~, sortedIndices] = sort(ruleUsageCounter, 'descend');
    
    % Select only the top N rules where N = rules_befor_drop
    % This keeps the most frequently activated rules and removes less important ones
    selectedRulesIdx = sortedIndices(1:rules_befor_drop);
    
    
    %% ========== FIS REDUCTION ==========
    % Create a copy of the original FIS for modification
    reducedFIS = outputFIS;
    
    % Extract input features (X) and output target (y) from training data
    x = complete_train_table(:,currentCombination);
    y = complete_train_table(:,{'pm2p5_y'});
    
    % Check if rule count is different from original (avoid unnecessary operations)
    if length(selectedRulesIdx) ~= length(outputFIS.Rules)
        % Keep only the selected rules by indexing into the Rules array
        reducedFIS.Rules = reducedFIS.Rules(selectedRulesIdx);
        
        % Display the number of output membership functions before removal
        disp(length(reducedFIS.Output.MembershipFunctions));
        
        % Remove output membership functions that correspond to removed rules
        % This maintains consistency between rules and output fuzzy sets
        reducedFIS.Output.MembershipFunctions = reducedFIS.Output.MembershipFunctions(selectedRulesIdx);
        
        % Display the number of output membership functions after removal
        disp(length(reducedFIS.Output.MembershipFunctions));
    end
    
    
    %% ========== FIS RETRAINING WITH ANFIS TUNING ==========
    % Display status message
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
    % This optimizes membership function parameters for the selected rules
    retrainedFIS = tunefis(reducedFIS,[in;out],x{:,:}, y{:,:},opt);
    
    
    %% ========== TRAINING SET EVALUATION ==========
    % Evaluate the retrainedFIS on the training dataset
    result_train = evalFuzzySystem(retrainedFIS, complete_train_table, currentCombination, display_results);
    
    % Extract R² score from the last row of results
    r2_train = table2array(result_train(height(result_train),2));
    
    % Extract Mean Absolute Error from the last row of results
    mae_train = table2array(result_train(height(result_train),3));
    
    
    %% ========== TEST SET EVALUATION ==========
    % Evaluate the retrainedFIS on the test dataset
    [result_test, complete_table] = evalFuzzySystem(retrainedFIS, complete_test_table, currentCombination, display_results);
    
    % Extract R² score from the last row of results
    r2_test = table2array(result_test(height(result_test),2));
    
    % Extract Mean Absolute Error from the last row of results
    mae_test = table2array(result_test(height(result_test),3));
    
    % Optional: Export results to CSV file for further analysis
    % writetable(complete_table,"matlab_" + name + "_" + rules_befor_drop + "_rules.csv","Delimiter",",");
    
end