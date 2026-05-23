%% Accuracy Analysis – Distance & Elevation (Gain / Loss)
clear; clc; close all;

% File definitions
files.main           = "global_kpi_log.csv";
files.ekf            = "global_kpi_log_100%EKF_100%EKF.csv";
files.gps            = "global_kpi_log_baroEkf_Fusion_100%Gps.csv";
files.calibration    = "global_kpi_log_calibration.csv";


% Load data
T_main     = readtable(files.main);
T_ekf      = readtable(files.ekf);
T_gps      = readtable(files.gps);
T_calib    = readtable(files.calibration);


%% BLAND–ALTMAN PLOTS 

% global_kpi_logs
blandAltmanPlot(T_main.Distance_m, T_main.GT_Dist, ...
    'Bland–Altman – Distance (global\_kpi\_log)', 'Distance Error (m)');

blandAltmanPlot(T_main.Elevation_Gain, T_main.GT_Ele_Gain, ...
    'Bland–Altman – Elevation Gain (global\_kpi\_log)', 'Elevation Gain Error (m)');

blandAltmanPlot(T_main.Elevation_Loss, T_main.GT_Ele_drop, ...
    'Bland–Altman – Elevation Loss (global\_kpi\_log)', 'Elevation Loss Error (m)');

% EKF
blandAltmanPlot(T_ekf.Distance_m, T_ekf.GT_Dist, ...
    'Bland–Altman – Distance (100% EKF)', 'Distance Error (m)');

blandAltmanPlot(T_ekf.Elevation_Gain, T_ekf.GT_Ele_Gain, ...
    'Bland–Altman – Elevation Gain (100% EKF)', 'Elevation Gain Error (m)');

blandAltmanPlot(T_ekf.Elevation_Loss, T_ekf.GT_Ele_drop, ...
    'Bland–Altman – Elevation Loss (100% EKF)', 'Elevation Loss Error (m)');

% Calibration pure gps for distance and 50/50 ekf baro for elevatio n 
blandAltmanPlot(T_gps.Distance_m, T_gps.GT_Dist, ...
    'Bland–Altman – Distance (Baro + GPS)', 'Distance Error (m)');

blandAltmanPlot(T_gps.Elevation_Gain, T_gps.GT_Ele_Gain, ...
    'Bland–Altman – Elevation Gain (Baro + GPS)', 'Elevation Gain Error (m)');

blandAltmanPlot(T_gps.Elevation_Loss, T_gps.GT_Ele_drop, ...
    'Bland–Altman – Elevation Loss (Baro + GPS)', 'Elevation Loss Error (m)');

% Calibration 
blandAltmanPlot(T_calib.Distance_m, T_calib.GT_Dist, ...
    'Calibration – Bland–Altman Elevation Gain', 'Elevation Gain Error (m)');

blandAltmanPlot(T_calib.Elevation_Gain, T_calib.GT_Ele_Gain, ...
    'Calibration – Bland–Altman Elevation Gain', 'Elevation Gain Error (m)');

blandAltmanPlot(T_calib.Elevation_Loss, T_calib.GT_Ele_drop, ...
    'Calibration – Bland–Altman Elevation Loss', 'Elevation Loss Error (m)');



%% GLOBAL ACCURACY METRICS – ALL KPI LOGS

sigma_GT = 1.0;   % DGM uncertainty (m)

datasets = {
    'Final Evaluation', T_main;
    'EKF_100%',       T_ekf;
    'BaroGpsFusionElevation_100%GPSDistance',       T_gps;
    'Calibration',    T_calib
};

results = [];

for d = 1:size(datasets,1)

    name = datasets{d,1};
    T    = datasets{d,2};

    % Distance
    [RMSE, nRMSE, MAE, MARE, MAX] = ...
        computeMetrics(T.Distance_m, T.GT_Dist);

    results = [results; ...
        {name, 'Distance', RMSE, NaN, nRMSE, MAE, MARE, MAX}];

    % Elevation Gain
    [RMSE, nRMSE, MAE, MARE, MAX] = ...
        computeMetrics(T.Elevation_Gain, T.GT_Ele_Gain);

    RMSE_Bayes = sqrt(max(RMSE^2 - sigma_GT^2, 0));

    results = [results; ...
        {name, 'Elevation Gain', RMSE, RMSE_Bayes, nRMSE, MAE, MARE, MAX}];

    % Elevation Loss
    [RMSE, nRMSE, MAE, MARE, MAX] = ...
        computeMetrics(T.Elevation_Loss, T.GT_Ele_drop);

    RMSE_Bayes = sqrt(max(RMSE^2 - sigma_GT^2, 0));

    results = [results; ...
        {name, 'Elevation Loss', RMSE, RMSE_Bayes, nRMSE, MAE, MARE, MAX}];

end

% Create final summary table
AccuracyTable_All = cell2table(results, ...
    'VariableNames', { ...
        'Dataset', ...
        'Metric', ...
        'RMSE_m', ...
        'RMSE_BayesCorr_m', ...
        'nRMSE_percent', ...
        'MAE_m', ...
        'MARE_percent', ...
        'MaxError_m' ...
    });

disp(AccuracyTable_All)

function [RMSE, nRMSE, MAE, MARE, MAXERR] = computeMetrics(measured, gt)

    valid = ~isnan(measured) & ~isnan(gt);

    if nnz(valid) < 2
        RMSE = NaN; nRMSE = NaN; MAE = NaN; MARE = NaN; MAXERR = NaN;
        return
    end

    err = measured(valid) - gt(valid);

    RMSE = sqrt(mean(err.^2));
    MAE  = mean(abs(err));
    MAXERR = max(abs(err));

    MARE = mean(abs(err) ./ abs(gt(valid))) * 100;
    nRMSE = RMSE / mean(abs(gt(valid))) * 100;
end


%% Local function – Bland–Altman
function blandAltmanPlot(measured, gt, titleStr, yLabelStr)

    valid = ~isnan(measured) & ~isnan(gt);
    diff  = measured(valid) - gt(valid);

    mu = mean(diff);
    sd = std(diff);

    figure('Color','w'); hold on; grid on;

    scatter(zeros(size(diff)), diff, 60, 'filled', ...
        'MarkerFaceAlpha',0.7, ...
        'MarkerFaceColor',[0.25 0.25 0.25]);

    yline(0, '-k', 'Zero Error', 'LineWidth',1.2);
    yline(mu, '--k', 'Mean Difference', 'LineWidth',1.5);
    yline(mu + 1.96*sd, ':k', '+1.96 SD', 'LineWidth',1.2);
    yline(mu - 1.96*sd, ':k', '-1.96 SD', 'LineWidth',1.2);

    xlim([-0.5 0.5])
    set(gca,'XTick',[])
    ylabel(yLabelStr)
    title(titleStr)
    set(gca,'FontSize',12)

end
