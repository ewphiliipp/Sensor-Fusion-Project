%% Elevation Gain & Loss – DGM only
% Integer quantization -> 5 m moving average (no re-rounding)

clear; clc;

data = readtable('Elevation_eval1.csv');

%% --- Extract Z ---
z = data.Z_1;     % ggf. Spaltenname anpassen
z = z(~isnan(z));

%% --- Step 1: round to integer meters ---
z_int = round(z,1);

%% --- Step 2: moving average over 5 meters ---
% ASSUMPTION: 1 sample = 1 meter
windowSize = 5;        % 5 m
z_proc = movmean(z_int, windowSize);

%% --- Step 3: Elevation Gain & Loss (reference-based) ---
ref = z_proc(1);
Elevation_Gain = 0;
Elevation_Loss = 0;

for k = 2:length(z_proc)
    dz = z_proc(k) - ref;

    if dz >= 1
        Elevation_Gain = Elevation_Gain + dz;
        ref = z_proc(k);
    elseif dz <= -1
        Elevation_Loss = Elevation_Loss - dz;
        ref = z_proc(k);
    end
end

%% --- Results ---
fprintf('Elevation Gain (rounded + 5m MA): %.1f m\n', Elevation_Gain);
fprintf('Elevation Loss (rounded + 5m MA): %.1f m\n', Elevation_Loss);

%% --- Debug plot ---
figure;
plot(z, 'Color', [0.75 0.75 0.75]); hold on;
plot(z_proc, 'k', 'LineWidth', 1.5);
ylabel('Elevation [m]');
xlabel('Sample');
legend('Raw Z', 'Processed Z');
grid on;
