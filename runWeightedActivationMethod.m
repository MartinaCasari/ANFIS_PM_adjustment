function ruleUsageCounter = runWeightedActivationMethod(outputFIS, currentCombination, complete_train_table)
    %% FUNCTION: runWeightedActivationMethod
    % PURPOSE: Analyze rule activation patterns using weighted method (accumulates activation strengths)
    % INPUTS:
    %   outputFIS - trained fuzzy inference system with defined rules
    %   currentCombination - array of input feature names to evaluate
    %   complete_train_table - training dataset table
    % OUTPUTS:
    %   ruleUsageCounter - vector of weighted activation sums for each rule
    %
    % KEY DIFFERENCE FROM BINARY METHOD:
    %   Binary method: counts number of times a rule fires (0 or 1 per sample)
    %   Weighted method: accumulates the actual activation strength (0 to 1 per sample)
    %   Example: If a rule fires with strength 0.7 in 3 samples, 
    %            Binary counter = 3, Weighted counter = 2.1 (0.7 + 0.7 + 0.7)
    
    
    %% ========== INITIALIZATION ==========
    % Get the total number of rules in the FIS
    numRules = length(outputFIS.Rules);
    
    % Pre-allocate counter array to track weighted activations for each rule
    % Counter accumulates the activation strength (not just binary count)
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
        
        
        %% ===== LEGACY CODE: MAXIMUM ACTIVATION METHOD (COMMENTED OUT) =====
        % Alternative approach: only count the single most activated rule
        % This was replaced with the weighted method below
        % % Find the rule with maximum activation
        % [maxActivation, maxRuleIdx] = max(ruleActivation);
        
        
        %% ===== WEIGHTED ACTIVATION METHOD =====
        % Find all rules with non-zero activation (rules that "fire")
        % Unlike binary method, we keep the activation strength values
        ruleActivationIdx = find(ruleActivation > 0);
        
        % Increment usage counter by the actual activation strength (not just 1)
        % This accumulates the weighted contribution of each rule across all samples
        % Example: If rule 5 fires with strength 0.8, ruleUsageCounter(5) increases by 0.8
        % KEY DIFFERENCE: Binary method would increase by 1 regardless of strength
        ruleUsageCounter(ruleActivationIdx) = ruleUsageCounter(ruleActivationIdx) + ruleActivation(ruleActivationIdx);
        
    end
    % End sample loop
    
    
    %% ========== CALCULATE ACTIVATION FREQUENCY ==========
    % Normalize rule usage counts to get average activation strength per sample
    % Frequency = (sum of activation strengths) / (total number of samples)
    % For weighted method, this represents the average contribution of each rule
    ruleUsageFrequency = ruleUsageCounter / numSamples;
    
    
    %% ========== DISPLAY RULE USAGE ANALYSIS ==========
    % Print detailed statistics for each rule's weighted activation pattern
    disp('Rule Usage Frequency Analysis:');
    
    for r = 1:numRules
        % Display for each rule:
        %   - Rule number
        %   - Average activation percentage per sample
        %   - Total weighted activation count (sum of all activation strengths)
        % Note: Activation Count here is a weighted sum, not a simple count
        fprintf('Rule %d: %.2f%% (Activation Count: %d)\n', ...
            r, ruleUsageFrequency(r) * 100, ruleUsageCounter(r));
    end
    
    
    %% ========== VISUALIZATION (LEGACY/ERROR) ==========
    % WARNING: This line references undefined variable 'ruleUsageCounterBinary'
    % This appears to be leftover code that should either:
    %   1. Be removed, or
    %   2. Be corrected to: visualizeResults(ruleUsageCounter);
    visualizeResults(ruleUsageCounterBinary);
    
end