function visualizeRulesReduction(r2_train, r2_test, mae_train, mae_test, max_rules)
    %% FUNCTION: visualizeRulesReduction
    % PURPOSE: Visualize model performance metrics as rules are progressively reduced
    % This helps identify the optimal balance between model simplicity and accuracy
    % INPUTS:
    %   r2_train - vector of R² (Pearson correlation) values for training data
    %   r2_test - vector of R² (Pearson correlation) values for test data
    %   mae_train - vector of Mean Absolute Error values for training data
    %   mae_test - vector of Mean Absolute Error values for test data
    %   max_rules - maximum number of rule configurations to plot (for zooming in on early iterations)
    % OUTPUTS:
    %   Two figures displaying performance trends during rule reduction
    
    
    %% ========== FIGURE 1: PEARSON CORRELATION ANALYSIS ==========
    % Create figure 1 for R² (Pearson correlation) visualization
    figure(1);
    clf;  % Clear figure to ensure clean display
    
    % Plot training set R² values with circle markers
    % x-axis: number of rules removed (or remaining rules)
    % y-axis: Pearson correlation coefficient (R²)
    plot(1:max_rules, r2_train(1:max_rules), '-o', 'DisplayName', 'Train');
    
    % Hold the figure to overlay additional plots
    hold on;
    
    % Plot test set R² values with square markers for distinction
    % Higher R² indicates better fit; R² ranges from -∞ to 1
    plot(1:max_rules, r2_test(1:max_rules), '-s', 'DisplayName', 'Test');
    
    % Label the x-axis
    % Note: x-axis represents rule reduction iterations
    xlabel('Number of Rules Removed');
    
    % Label the y-axis
    % Pearson correlation coefficient (also called R² score)
    ylabel('Pearson Value');
    
    % Add descriptive title
    title('Pearson vs. Rule Reduction');
    
    % Display legend to distinguish train vs. test curves
    legend;
    
    % Enable grid for easier value reading
    grid on;
    
    % Force immediate figure update and display
    drawnow;
    
    
    %% ========== FIGURE 2: MEAN ABSOLUTE ERROR ANALYSIS ==========
    % Create figure 2 for MAE (Mean Absolute Error) visualization
    figure(2);
    clf;  % Clear figure to ensure clean display
    
    % Plot training set MAE values with circle markers
    % x-axis: number of rules removed (or remaining rules)
    % y-axis: Mean Absolute Error
    % Lower MAE indicates better predictions (closer to actual values)
    plot(1:max_rules, mae_train(1:max_rules), '-o', 'DisplayName', 'Train MAE');
    
    % Hold the figure to overlay additional plots
    hold on;
    
    % Plot test set MAE values with square markers
    % Comparison of train vs. test MAE helps identify overfitting/underfitting:
    %   - If test MAE >> train MAE: model is overfitting
    %   - If both increase together: model is underfitting
    plot(1:max_rules, mae_test(1:max_rules), '-s', 'DisplayName', 'Test MAE');
    
    % Label the x-axis
    xlabel('Number of Rules Removed');
    
    % Label the y-axis
    % Mean Absolute Error in same units as target variable (PM2.5 in µg/m³)
    ylabel('MAE Value');
    
    % Add descriptive title
    title('MAE vs. Rule Reduction');
    
    % Display legend to distinguish train vs. test curves
    legend;
    
    % Enable grid for easier value reading
    grid on;
    
    % Force immediate figure update and display
    drawnow;
    
end