function [r2_train, r2_test, mae_train, mae_test] = reduceRulesEvaluation(outputFIS, numRules, sortedIndices)
    %% FUNCTION: reduceRulesEvaluation
    % PURPOSE: Iteratively reduce fuzzy rules and evaluate model performance degradation
    % INPUTS:
    %   outputFIS - trained fuzzy inference system with complete rule base
    %   numRules - total number of rules in the original FIS
    %   sortedIndices - rule indices sorted by importance/usage (most important first)
    % OUTPUTS:
    %   r2_train - vector of R-squared values on training data at each reduction level
    %   r2_test - vector of R-squared values on test data at each reduction level
    %   mae_train - vector of Mean Absolute Error on training data at each reduction level
    %   mae_test - vector of Mean Absolute Error on test data at each reduction level
    %
    % NOTE: This function appears to be missing input parameters for evaluation:
    %       - complete_train_table (referenced but not passed as parameter)
    %       - complete_test_table (referenced but not passed as parameter)
    %       - currentCombination (referenced but not passed as parameter)
    %       These variables must exist in the calling workspace or be added as parameters
    
    
    %% ========== WARNING SUPPRESSION ==========
    % Suppress all MATLAB warnings to prevent console clutter during iterations
    % Particularly important to suppress warnings about:
    %   - No rules firing in reduced FIS
    %   - Empty or undefined fuzzy outputs
    %   - Membership function index mismatches
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
    % Progressively reduce the number of rules by removing least important rules one at a time
    % At each iteration, evaluate model performance to analyze degradation
    % Iteration 1: removes 1 least important rule (keeps numRules-1)
    % Iteration 2: removes 2 least important rules (keeps numRules-2)
    % ... continues until only 2 rules remain
    for iter = 1:numRules-1
        
        %% ===== RULE SELECTION BLOCK =====
        % Select the top N most important rules, where N decreases each iteration
        % Formula: end-iter+1 ensures we remove one more rule each iteration
        % Example with 10 total rules:
        %   iter=1: sortedIndices(1:10) -> keeps 10 rules (removes 0)
        %   iter=2: sortedIndices(1:9)  -> keeps 9 rules (removes 1)
        %   iter=3: sortedIndices(1:8)  -> keeps 8 rules (removes 2)
        %   ... and so on
        selectedRulesIdx = sortedIndices(1:end-iter+1);
        
        % Display selected rule indices for debugging and tracking
        % Shows which rules are retained at each iteration
        display(selectedRulesIdx);
        
        
        %% ===== REDUCED FIS CREATION BLOCK =====
        % Create a copy of the original FIS to avoid modifying the source
        reducedFIS = outputFIS;
        
        % Update the FIS to contain only the selected rules
        % This removes the least important rules from the rule base
        reducedFIS.Rules = outputFIS.Rules(selectedRulesIdx);
        
        
        %% ===== OUTPUT MEMBERSHIP FUNCTIONS UPDATE =====
        % Conditional update of output membership functions
        % Only update if we're not at the initial full rule set (48 rules)
        % The value 48 appears to be specific to this application's FIS architecture
        if length(selectedRulesIdx) ~= 48
            
            % Debug output: display MF count before modification
            disp(length(reducedFIS.Output.MembershipFunctions));
            
            % Update output membership functions to match the reduced rule set
            % Each rule typically has an associated output membership function
            % Removing rules requires removing their corresponding output MFs
            % This maintains consistency between rules and output MF definitions
            reducedFIS.Output.MembershipFunctions = outputFIS.Output.MembershipFunctions(selectedRulesIdx);
            
            // Debug output: display MF count after modification
            disp(length(reducedFIS.Output.MembershipFunctions));
        end
        
        % display(reducedFIS.Rules);  % Debug: show reduced rule structure (commented out)
        
        
        %% ===== ITERATION PROGRESS DISPLAY =====
        % Display progress information for current iteration
        % Shows iteration number and current rule count for monitoring
        disp(['Iteration ', num2str(iter), ': Evaluating with ', num2str(length(selectedRulesIdx)), ' rules']);
        
        
        %% ===== LEGACY EVALUATION CALLS (COMMENTED OUT) =====
        % Previous version of evaluation calls without return values
        % Replaced with the current implementation that captures results
        % evalFuzzySystem(reducedFIS, complete_train_table, currentCombination);
        % evalFuzzySystem(reducedFIS, complete_test_table, currentCombination);
        
        
        %% ===== TRAINING DATA EVALUATION =====
        % Evaluate the reduced FIS on training data
        % WARNING: complete_train_table and currentCombination are not function parameters
        % These variables must be available in the calling workspace or should be added as inputs
        % Returns a results table containing R-squared, MAE, and other metrics
        result_train = evalFuzzySystem(reducedFIS, complete_train_table, currentCombination);
        
        % Extract R-squared value from the last row of results table (summary row)
        % Column 2 contains the R-squared metric
        % height(result_train) gets the total number of rows (last row is summary)
        r2_train(iter) = table2array(result_train(height(result_train), 2));
        
        % Extract Mean Absolute Error from the last row of results table
        % Column 3 contains the MAE metric
        mae_train(iter) = table2array(result_train(height(result_train), 3));
        
        
        %% ===== TEST DATA EVALUATION =====
        % Evaluate the reduced FIS on test data for validation
        % WARNING: complete_test_table is not a function parameter
        % Same structure as training evaluation but on unseen data
        result_test = evalFuzzySystem(reducedFIS, complete_test_table, currentCombination);
        
        % Extract R-squared value for test data from summary row
        % Provides measure of model generalization at this rule count
        r2_test(iter) = table2array(result_test(height(result_test), 2));
        
        % Extract Mean Absolute Error for test data from summary row
        % Provides absolute error metric for model validation
        mae_test(iter) = table2array(result_test(height(result_test), 3));
        
    end
    % End iterative rule reduction loop
    
end