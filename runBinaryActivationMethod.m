function ruleUsageCounter = runBinaryActivationMethod(outputFIS, currentCombination, complete_train_table)
    %% FUNCTION: runBinaryActivationMethod
    % PURPOSE: Analyze rule activation patterns using binary method (rule fires if activation > 0)
    % INPUTS:
    %   outputFIS - trained fuzzy inference system with defined rules
    %   currentCombination - array of input feature names to evaluate
    %   complete_train_table - training dataset table
    % OUTPUTS:
    %   ruleUsageCounter - vector of binary activation counts (1 if fired, 0 if not) for each rule
    
    
    %% ========== INITIALIZATION ==========
    % Get the total number of rules in the FIS
    numRules = length(outputFIS.Rules);
    
    % Pre-allocate counter array to track binary activations for each rule
    % Counter increments by 1 each time a rule fires (activation > 0)
    ruleUsageCounter = zeros(1, numRules);
    
    % Get the number of samples in the training dataset
    numSamples = size(complete_train_table, 1);
    
    
    %% ========== MAIN SAMPLE PROCESSING LOOP ==========
    % Iterate through each sample in the training dataset
    for i = 1:numSamples
        
        %% ===== EXTRACT INPUT FEATURES =====
        % Get the input features for the current sample
        % x_i is a table row containing values for all input variables
        x_i = complete_train_table(i, currentCombination);
        
        
        %% ===== RULE ACTIVATION EVALUATION =====
        % Pre-allocate array to store activation values for all rules
        ruleActivation = zeros(1, numRules);
        
        % Evaluate each rule for the current sample
        for r = 1:numRules
            
            %% ===== ANTECEDENT MEMBERSHIP EVALUATION =====
            % Pre-allocate array for antecedent membership values
            % Antecedent = conjunction of membership function evaluations for each input
            antecedentValues = zeros(1, length(outputFIS.Rules(r).Antecedent));
            
            % Evaluate each input variable's membership function in the rule
            for j = 1:length(outputFIS.Rules(r).Antecedent)
                % Get the membership function index for the j-th input in this rule
                mfIndex = outputFIS.Rules(r).Antecedent(j);
                
                % Validate that the membership function index is valid
                if mfIndex > 0 && mfIndex <= length(outputFIS.Inputs(j).MembershipFunctions)
                    
                    % Convert table to numeric array for evaluation
                    x_i_numeric = table2array(x_i);
                    
                    % Evaluate the membership function at the current input value
                    % Returns degree of membership (0 to 1) for that fuzzy set
                    antecedentValues(j) = evalmf(outputFIS.Inputs(j).MembershipFunctions(mfIndex), x_i_numeric(j));
                else
                    % Invalid membership function index: set membership to 0
                    antecedentValues(j) = 0;
                end
            end
            
            
            %% ===== RULE ACTIVATION CALCULATION =====
            % Calculate overall rule activation using MIN operator (Mamdani inference)
            % Rule fires strongest to the degree of its weakest condition
            % This implements the fuzzy AND operation on antecedent conditions
            ruleActivation(r) = min(antecedentValues);
        end
        % End rule evaluation loop
        
        
        %% ===== BINARY ACTIVATION METHOD =====
        % Find all rules with non-zero activation (rules that "fire")
        % In binary method: if activation > 0, count as 1; otherwise 0
        ruleActivationIdx = find(ruleActivation > 0);
        
        % Increment usage counter for all rules that fired in this sample
        % This counts how many times each rule was activated across all samples
        ruleUsageCounter(ruleActivationIdx) = ruleUsageCounter(ruleActivationIdx) + 1;
        
    end
    % End sample loop
    
    
    %% ========== CALCULATE ACTIVATION FREQUENCY ==========
    % Normalize rule usage counts to get percentage of samples each rule fired
    % Frequency = (times rule fired) / (total number of samples)
    ruleUsageFrequency = ruleUsageCounter / numSamples;
    
    
    %% ========== DISPLAY RULE USAGE ANALYSIS ==========
    % Print detailed statistics for each rule's activation pattern
    disp('Rule Usage Frequency Analysis:');
    
    for r = 1:numRules
        % Display for each rule:
        %   - Rule number
        %   - Percentage of samples where rule fired
        %   - Absolute count of samples where rule fired
        fprintf('Rule %d: %.2f%% (Activation Count: %d)\n', ...
            r, ruleUsageFrequency(r) * 100, ruleUsageCounter(r));
    end
    
end