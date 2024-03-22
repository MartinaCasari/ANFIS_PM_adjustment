function results_table = evalFuzzySystem(outputFIS, complete_table, currentCombination)    
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

        figure;
        plot(sensor_train_table.valid_at, sensor_train_table.pm2p5_x_original, '-', 'DisplayName', 'pm2p5_x_original');
        hold on;
        plot(sensor_train_table.valid_at, sensor_train_table.pm2p5_y, '-', 'DisplayName', 'pm2p5_y', 'color', 'black');
        hold on;
        plot(sensor_train_table.valid_at, sensor_train_table.pm2p5_pred, '-', 'DisplayName', 'pm2p5_{pred}');
        hold off;

        % Add labels and legend
        xlabel('Date');
        ylabel('PM2.5 mass concentration');
        title(strcat('ari', string(sensor_id), ' PM2.5'));
        legend('show');
    
        r2 = 1 - sum((y_true - y_pred).^2) / sum((y_true - mean(y_true)).^2);
        mae = mean(abs(y_true - y_pred));
        mse = mean((y_true - y_pred).^2);
        rmse = sqrt(mse);
    
        results_table = [results_table; {string(sensor_id), r2, mae, mse, rmse}];
        
    end

    y_true = complete_table.pm2p5_y;
    y_pred = complete_table.pm2p5_pred;

    r2 = 1 - sum((y_true - y_pred).^2) / sum((y_true - mean(y_true)).^2);
    mae = mean(abs(y_true - y_pred));
    mse = mean((y_true - y_pred).^2);
    rmse = sqrt(mse);

    results_table = [results_table; {"all", r2, mae, mse, rmse}];
        
   
    disp(results_table)
        
end
