function [r2_train, r2_test, mae_train, mae_test] = evaluateRulesReduction(outputFIS, ruleUsageCounter, complete_train_table, complete_test_table, currentCombination, display_results)
    %% FUNCTION: evaluateRulesReduction
    % PURPOSE: Iteratively reduce fuzzy rules and evaluate model performance degradation
    % INPUTS:
    %   outputFIS - trained fuzzy inference system with complete rule base
    %   ruleUsageCounter - vector containing activation counts for each rule
    %   complete_train_table - training dataset table for model evaluation
    %   complete_test_table - testing dataset table for model validation
    %   currentCombination - array of input feature names being evaluated
    %   display_results - boolean flag to control console output verbosity
    % OUTPUTS:
    %   r2_train - vector of R-squared values on training data at each reduction level
    %   r2_test - vector of R-squared values on test data at each reduction level
    %   mae_train - vector of Mean Absolute Error on training data at each reduction level
    %   mae_test - vector of Mean Absolute Error on test data at each reduction level
    
    
    %% ========== INITIALIZATION ==========
    % Get the total number of rules in the Fuzzy Inference System
    numRules = length(outputFIS.Rules);
    
    % Sort rules by usage frequency in descending order (most used first)
    % sortedIndices contains rule indices ordered from highest to lowest activation count
    % The tilde (~) discards the sorted values, keeping only the indices
    [~, sortedIndices] = sort(ruleUsageCounter, 'descend');
    
    
    %% ========== WARNING SUPPRESSION ==========
    % Suppress all MATLAB warnings to prevent console clutter during iterations
    % Particularly important to suppress warnings about:
    %   - No rules firing in reduced FIS
    %   - Empty or undefined fuzzy outputs
    warning('off','all');
    
    
    %% ========== PERFORMANCE METRICS ARRAYS INITIALIZATION ==========
    % Pre-allocate arrays to store performance metrics for each iteration
    % Array size is (numRules-1) because we evaluate from full rules down to 2 rules
    % (we never reduce to 1 rule or 0 rules as the system would be non-functional)
    r2_train = zeros(1, numRules-1);   % R-squared (coefficient of determination) for training data
    r2_test = zeros(1, numRules-1);    % R-squared for test data
    mae_train = zeros(1, numRules-1);  % Mean Absolute Error for training data
    mae_test = zeros(1, numRules-1);   % Mean Absolute Error for test data
    
    
    %% ========== ITERATIVE RULE REDUCTION LOOP ==========
    % Progressively reduce the number of rules by removing least-used rules one at a time
    % At each iteration, evaluate model performance to analyze degradation
    % Iteration 1: removes 1 least-used rule (keeps numRules-1)
    % Iteration 2: removes 2 least-used rules (keeps numRules-2)
    % ... continues until only 2 rules remain
    for iter = 1:numRules-1
        
        %% ===== RULE SELECTION BLOCK =====
        % Select the top N most frequently activated rules, where N decreases each iteration
        % Formula: end-iter+1 ensures we remove one more rule each iteration
        % Example with 10 total rules:
        %   iter=1: sortedIndices(1:10) -> keeps 10 rules (removes 0)
        %   iter=2: sortedIndices(1:9)  -> keeps 9 rules (removes 1)
        %   iter=3: sortedIndices(1:8)  -> keeps 8 rules (removes 2)
        %   ... and so on
        selectedRulesIdx = sortedIndices(1:end-iter+1);
        
        % Optional display of selected rule indices for debugging and tracking
        if display_results
            display(selectedRulesIdx)
        end
        
        
        %% ===== REDUCED FIS CREATION BLOCK =====
        % Create a copy of the original FIS to avoid modifying the source
        reducedFIS = outputFIS;
        
        % Update the FIS to contain only the selected rules
        % This removes the least-used rules from the rule base
        reducedFIS.Rules = outputFIS.Rules(selectedRulesIdx);
        
        %% ===== OUTPUT MEMBERSHIP FUNCTIONS UPDATE =====
        % Conditional update of output membership functions
        % Only update if we're not at the initial full rule set (48 rules)
        if length(selectedRulesIdx) ~= numRules
            % disp(length(reducedFIS.Output.MembershipFunctions));  % Debug: before
            
            % Update output membership functions to match the reduced rule set
            % Each rule typically has an associated output membership function
            % Removing rules requires removing their corresponding output MFs
            reducedFIS.Output.MembershipFunctions = outputFIS.Output.MembershipFunctions(selectedRulesIdx);
            
            % disp(length(reducedFIS.Output.MembershipFunctions));  % Debug: after
        end
        
        % display(reducedFIS.Rules);  % Debug: show reduced rule structure
        
        
        %% ===== PERFORMANCE EVALUATION BLOCK =====
        % Display progress information for current iteration
        if display_results
            disp(['Iteration ', num2str(iter), ': Evaluating with ', num2str(length(selectedRulesIdx)), ' rules']);
        end
        
        % evalFuzzySystem(reducedFIS, complete_train_table, currentCombination);  % Legacy call
        % evalFuzzySystem(reducedFIS, complete_test_table, currentCombination);   % Legacy call
        
        
        %% ===== TRAINING DATA EVALUATION =====
        % Evaluate the reduced FIS on training data
        % Returns a results table containing R-squared, MAE, and other metrics
        result_train = evalFuzzySystem(reducedFIS, complete_train_table, currentCombination, display_results);
        
        % Extract R-squared value from the last row of results table (summary row)
        % Column 2 contains the R-squared metric
        r2_train(iter) = table2array(result_train(height(result_train), 2));
        
        % Extract Mean Absolute Error from the last row of results table
        % Column 3 contains the MAE metric
        mae_train(iter) = table2array(result_train(height(result_train), 3));
        
        
        %% ===== TEST DATA EVALUATION =====
        % Evaluate the reduced FIS on test data for validation
        % Same structure as training evaluation but on unseen data
        result_test = evalFuzzySystem(reducedFIS, complete_test_table, currentCombination, display_results);
        
        % Extract R-squared value for test data from summary row
        r2_test(iter) = table2array(result_test(height(result_test), 2));
        
        % Extract Mean Absolute Error for test data from summary row
        mae_test(iter) = table2array(result_test(height(result_test), 3));
        
    end
    % End iterative rule reduction loop
    
end