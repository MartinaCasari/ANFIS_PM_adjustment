function [results_table, complete_table] = evalFuzzySystem(outputFIS, complete_table, currentCombination)    
    x_table = complete_table(:,currentCombination);
    y_table = complete_table(:,{'pm2p5_y'});
    x = x_table{:,:};
    y = y_table{:,:};

    outputTuned = evalfis(outputFIS,x);
    % Plot the output of the tuned FIS along with the expected training output.
    complete_table = addvars(complete_table, outputTuned, 'After', 'pm2p5_y', 'NewVariableName', 'pm2p5_pred');
    complete_table  = sortrows(complete_table, 'valid_at', 'ascend');

    sensor_ids = unique(complete_table.sensor_id);
    results_table = table('Size', [0, 5], 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, 'VariableNames', {'SensorID', 'R2', 'MAE', 'MSE', 'RMSE'});
    
    for i = 1:length(sensor_ids)
        sensor_id = sensor_ids(i);
        
        % Extract data for the current category
        sensor_train_table = complete_table(complete_table.sensor_id == sensor_id, :);

        y_true = sensor_train_table.pm2p5_y;
        y_pred = sensor_train_table.pm2p5_pred;
    
        r2 = corr(y_pred, y_true, 'Type', 'Pearson'); % 1 - sum((y_true - y_pred).^2) / sum((y_true - mean(y_true)).^2); % corr(y_pred, y_true, 'Type', 'Pearson'); %
        mae = mean(abs(y_true - y_pred));
        mse = mean((y_true - y_pred).^2);
        rmse = sqrt(mse);
    
        results_table = [results_table; {string(sensor_id), r2, mae, mse, rmse}];
        
    end

    y_true = complete_table.pm2p5_y;
    y_pred = complete_table.pm2p5_pred;

    r2 = corr(y_pred, y_true, 'Type', 'Pearson'); % 1 - sum((y_true - y_pred).^2) / sum((y_true - mean(y_true)).^2); %  corr(y_pred, y_true, 'Type', 'Pearson'); %
    mae = mean(abs(y_true - y_pred));
    mse = mean((y_true - y_pred).^2);
    rmse = sqrt(mse);
    
    
    results_table = [results_table; {"all", r2, mae, mse, rmse}];
        
   
    disp(results_table)
        
end
