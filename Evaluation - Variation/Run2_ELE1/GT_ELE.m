%% Elevation Gain & Loss – DGM 

clear; clc;

data = readtable('Elevation_eval1.csv');

%% Extract Z
z = data.Z_1;     
z = z(~isnan(z));

%% round to first decimal
z_1deci = round(z,1);

%% oving average over 5 meters
%  1 sample = 1 meter
windowSize = 5;        % 5 m
z_processesed = movmean(z_1deci, windowSize);

%% Elevation Gain & Loss (reference-based) 
ref = z_processesed(1);
Elevation_Gain = 0;
Elevation_Loss = 0;

for k = 2:length(z_processesed)
    dz = z_processesed(k) - ref;

    if dz >= 1
        Elevation_Gain = Elevation_Gain + dz;
        ref = z_processesed(k);
    elseif dz <= -1
        Elevation_Loss = Elevation_Loss - dz;
        ref = z_processesed(k);
    end
end

%% Results
fprintf('Elevation Gain (rounded + 5m MA): %.1f m\n', Elevation_Gain);
fprintf('Elevation Loss (rounded + 5m MA): %.1f m\n', Elevation_Loss);

%% Debug plot
figure;
plot(z, 'Color', [0.75 0.75 0.75]); hold on;
plot(z_processesed, 'k', 'LineWidth', 1.5);
ylabel('Elevation [m]');
xlabel('Sample');
legend('Raw Z', 'Processed Z');
grid on;
