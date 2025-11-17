function outputFIS = fitFuzzySystem(table_x, table_y, fis_options)
    %% FUNCTION: fitFuzzySystem
    % PURPOSE: Generate and train a fuzzy inference system using input-output data
    % INPUTS:
    %   table_x - table of input features (each column is a feature)
    %   table_y - table containing target output values
    %   fis_options - structure specifying FIS generation options (GridPartition or SubtractiveClustering)
    % OUTPUTS:
    %   outputFIS - trained fuzzy inference system with optimized membership functions
    
    
    %% ========== DATA CONVERSION ==========
    % Convert input feature table to numeric array format
    % Each row represents a sample, each column represents an input feature
    x = table_x{:,:};
    
    % Convert output target table to numeric array format
    % Each row represents the target output for corresponding input sample
    y = table_y{:,:};
    
    
    %% ========== INITIAL FIS GENERATION ==========
    % Generate initial fuzzy inference system structure from data
    % This creates:
    %   - Input/output membership functions based on data distribution
    %   - Fuzzy rules that map input combinations to outputs
    %   - System parameters configured according to fis_options
    % 
    % fis_options typically specifies:
    %   - Method: 'GridPartition' or 'SubtractiveClustering'
    %   - InputMembershipFunctionType: 'trimf' (triangular), 'trapmf' (trapezoidal), etc.
    %   - NumMembershipFunctions: number of fuzzy sets per input
    fisin = genfis(x, y, fis_options);
    
    
    %% ========== OPTIONAL: VISUALIZE INITIAL MEMBERSHIP FUNCTIONS ==========
    % The following commented code can be used to visualize initial MFs:
    %
    % figure;
    % for i = 1:numel(fisin.Inputs)
    %     subplot(numel(fisin.Inputs), 1, i);
    %     plotmf(fisin, 'input', i);
    %     title(['Input ' num2str(i) ' MF']);
    % end
    %
    % View the complete FIS structure graphically:
    % plotfis(fisin)
    
    
    %% ========== EXTRACT TUNABLE PARAMETERS ==========
    % Extract the tunable settings (parameters to be optimized) from the generated FIS
    % 'in' - tunable settings for input membership functions
    %        includes parameters for shape and position of fuzzy sets
    % 'out' - tunable settings for output membership functions
    %         includes parameters for output fuzzy sets
    % '~' - rule parameters (not extracted, hence the tilde)
    [in, out, ~] = getTunableSettings(fisin);
    
    
    %% ========== CONFIGURE ANFIS TRAINING OPTIONS ==========
    % Create options structure for ANFIS (Adaptive Neuro-Fuzzy Inference System) training
    opt = tunefisOptions("Method", "anfis");
    
    % Set the number of training epochs (iterations)
    % Higher epoch numbers allow more optimization iterations but increase computation time
    % 100 epochs is typically a good balance between accuracy and training time
    opt.MethodOptions.EpochNumber = 100;
    
    
    %% ========== TUNE FIS PARAMETERS WITH ANFIS ==========
    % Optimize the membership function parameters using ANFIS algorithm
    % This adjusts membership function shapes and positions to better fit the training data
    % 
    % Input arguments:
    %   fisin - initial FIS structure
    %   [in;out] - combined tunable parameters for inputs and outputs
    %   x - input training data
    %   y - target output training data
    %   opt - tuning options (ANFIS with 100 epochs)
    %
    % Output:
    %   outputFIS - optimized FIS with trained membership function parameters
    %   ~ - training error history (not used, hence the tilde)
    [outputFIS, ~] = tunefis(fisin, [in; out], x, y, opt);
    
    
    %% ========== DISPLAY TRAINED FIS ==========
    % Display the complete structure and parameters of the trained FIS to console
    % Shows information about inputs, outputs, membership functions, and rules
    display(outputFIS);
    
end