% Code to plot simulation results from quadcopter_package_delivery
%% Plot Description:
%
% This plot shows the position, velocity, and attitude of the quadcopter as
% it attempts to follow a trajectory
%
% Copyright 2021-2024 The MathWorks, Inc.

% Generate simulation results if they don't exist
if ~exist('simlog_quadcopter_package_delivery', 'var')
    sim('quadcopter_package_delivery')
end

% Reuse figure if it exists, else create new figure
if ~exist('h2_quadcopter_package_delivery', 'var') || ...
        ~isgraphics(h2_quadcopter_package_delivery, 'figure')
    h2_quadcopter_package_delivery = figure('Name', 'quadcopter_package_delivery');
end
figure(h2_quadcopter_package_delivery)
clf(h2_quadcopter_package_delivery)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_t       = simlog_quadcopter_package_delivery.Quadcopter.Electrical.Battery.i.series.time;
simlog_battSOC = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Battery.SOC.Data;

simlog_batti   = simlog_quadcopter_package_delivery.Quadcopter.Electrical.Battery.i.series.values('A');
simlog_mot1i   = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot1.i.Data;
simlog_mot2i   = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot2.i.Data;
simlog_mot3i   = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot3.i.Data;
simlog_mot4i   = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot4.i.Data;

% Plot results
simlog_handles(1) = subplot(2, 1, 1);
plot(simlog_t, simlog_battSOC, 'LineWidth', 1,'DisplayName','Ref')
grid on
title('Battery State of Charge')
legend('Location','Best');
ylabel('Charge (A*hr)')

simlog_handles(2) = subplot(2, 1, 2);
plot(simlog_t, -simlog_batti, 'LineWidth', 1,'DisplayName','Battery');
hold on
plot(simlog_t, simlog_mot1i, 'LineWidth', 1,'DisplayName','Motor 1');
plot(simlog_t, simlog_mot2i, 'LineWidth', 1,'DisplayName','Motor 2');
plot(simlog_t, simlog_mot3i, 'LineWidth', 1,'DisplayName','Motor 3');
plot(simlog_t, simlog_mot4i, 'LineWidth', 1,'DisplayName','Motor 4');
hold off
grid on
title('Currents')
grid on
legend('Location','Best')
xlabel('Time (s)')
ylabel('Current (A)')

% Remove temporary variables
clear simlog_t simlog_handles
clear temp_colororder

