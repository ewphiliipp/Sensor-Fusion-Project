%% Global Accuracy Evaluation Script (with RMSE & Loss Error)
clc; clear;
disp('--- Global Accuracy Evaluation Report (Updated with RMSE & Loss Error) ---');

log_filename = 'global_kpi_log.csv';
if ~isfile(log_filename)
    error('CSV file "%s" not found.', log_filename);
end

opts = detectImportOptions(log_filename);
opts.VariableNamingRule = 'preserve';
data = readtable(log_filename, opts);

% Initialisation for Accuracy & RMSE
sum_dist_acc = 0; count_dist = 0; sum_sq_err_dist = 0;
sum_gain_acc = 0; count_gain = 0; sum_sq_err_gain = 0;
sum_loss_acc = 0; count_loss = 0; sum_sq_err_loss = 0;

% print Header 
fprintf('\n%-12s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s\n', ...
    'Run Name', 'DistAcc%', 'DistErr(m)', 'GainAcc%', 'GainErr(m)', 'LossAcc%', 'LossErr(m)');
fprintf('----------------------------------------------------------------------------------------------------\n');

% Loop over Runs
for i = 1:height(data)
    dist_acc = "N/A"; dist_err = "N/A";
    gain_acc = "N/A"; gain_err = "N/A";
    loss_acc = "N/A"; loss_err = "N/A";
    
    %Distance
    if ~isnan(data.GT_Dist(i)) && data.GT_Dist(i) > 0
        err_d = data.Distance_m(i) - data.GT_Dist(i);
        acc_d = max(0, (1 - abs(err_d) / data.GT_Dist(i)) * 100);
        
        dist_acc = sprintf('%.2f', acc_d);
        dist_err = sprintf('%.2f', abs(err_d));
        
        sum_dist_acc = sum_dist_acc + acc_d;
        sum_sq_err_dist = sum_sq_err_dist + err_d^2;
        count_dist = count_dist + 1;
    end
    
    % Elevation Gain 
    if ~isnan(data.GT_Ele_Gain(i)) && data.GT_Ele_Gain(i) > 0
        err_g = data.Elevation_Gain(i) - data.GT_Ele_Gain(i);
        acc_g = max(0, (1 - abs(err_g) / data.GT_Ele_Gain(i)) * 100);
        
        gain_acc = sprintf('%.2f', acc_g);
        gain_err = sprintf('%.2f', abs(err_g));
        
        sum_gain_acc = sum_gain_acc + acc_g;
        sum_sq_err_gain = sum_sq_err_gain + err_g^2;
        count_gain = count_gain + 1;
    end
    
    % Elevation Loss 
    if ~isnan(data.GT_Ele_drop(i)) && data.GT_Ele_drop(i) > 0
        err_l = data.Elevation_Loss(i) - data.GT_Ele_drop(i);
        acc_l = max(0, (1 - abs(err_l) / data.GT_Ele_drop(i)) * 100);
        
        loss_acc = sprintf('%.2f', acc_l);
        loss_err = sprintf('%.2f', abs(err_l));
        
        sum_loss_acc = sum_loss_acc + acc_l;
        sum_sq_err_loss = sum_sq_err_loss + err_l^2;
        count_loss = count_loss + 1;
    end
    
    % print accuracy in % with loss
    fprintf('%-12s | %-10s | %-10s | %-10s | %-10s | %-10s | %-10s\n', ...
        data.Run_Name{i}, dist_acc, dist_err, gain_acc, gain_err, loss_acc, loss_err);
end

% Global Summary with RMSE
fprintf('\n-------------------- GLOBAL SUMMARY --------------------\n');
if count_dist > 0
    rmse_dist = sqrt(sum_sq_err_dist / count_dist);
    fprintf('Distance:      Accuracy: %.2f%% | RMSE: %.3f m (n=%d)\n', sum_dist_acc / count_dist, rmse_dist, count_dist);
end
if count_gain > 0
    rmse_gain = sqrt(sum_sq_err_gain / count_gain);
    fprintf('Elev. Gain:    Accuracy: %.2f%% | RMSE: %.3f m (n=%d)\n', sum_gain_acc / count_gain, rmse_gain, count_gain);
end
if count_loss > 0
    rmse_loss = sqrt(sum_sq_err_loss / count_loss);
    fprintf('Elev. Loss:    Accuracy: %.2f%% | RMSE: %.3f m (n=%d)\n', sum_loss_acc / count_loss, rmse_loss, count_loss);
end
fprintf('--------------------------------------------------------\n');