% Code to plot simulation results from quadcopter_package_delivery
%% Plot Description:
%
% This plot shows the position, velocity, and attitude of the quadcopter as
% it attempts to follow a trajectory
%
% Copyright 2021 The MathWorks, Inc.

% Generate simulation results if they don't exist
if ~exist('simlog_quadcopter_package_delivery', 'var')
    sim('quadcopter_package_delivery')
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_quadcopter_package_delivery', 'var') || ...
        ~isgraphics(h1_quadcopter_package_delivery, 'figure')
    h1_quadcopter_package_delivery = figure('Name', 'quadcopter_package_delivery');
end
figure(h1_quadcopter_package_delivery)
clf(h1_quadcopter_package_delivery)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_px = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.px.Data;
simlog_py = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.py.Data;
simlog_pz = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.pz.Data;
simlog_vx = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.vx.Data;
simlog_vy = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.vy.Data;
simlog_vz = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.vz.Data;
simlog_qx = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.roll.Data;
simlog_qy = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.pitch.Data;
simlog_qz = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.yaw.Data;
simlog_t  = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.px.Time;

ref_pxyz = logsout_quadcopter_package_delivery.get('Ref').Values.pos.Data(:,:)';
ref_vxyz = logsout_quadcopter_package_delivery.get('Ref').Values.vel.Data(:,:)';
ref_roll = logsout_quadcopter_package_delivery.get('Ref').Values.roll.Data(:,:)';
ref_pitch = logsout_quadcopter_package_delivery.get('Ref').Values.pitch.Data(:,:)';
ref_yaw = logsout_quadcopter_package_delivery.get('Ref').Values.yaw.Data(:,:)';

% Plot results
simlog_handles(1) = subplot(3, 3, 1);
if(size(ref_pxyz,2)>3)
    ref_pxyz = ref_pxyz';
    ref_vxyz = ref_vxyz';
end
plot(simlog_t, ref_pxyz(:,1), 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, simlog_px, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Pos x (m)')
legend('Location','Best');

simlog_handles(2) = subplot(3, 3, 2);
plot(simlog_t, ref_vxyz(:,1), 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, simlog_vx, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Vel x (m/s)')

simlog_handles(3) = subplot(3, 3, 3);
plot(simlog_t, ref_roll*180/pi, 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, squeeze(simlog_qx)*180/pi, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Roll (deg)')
linkaxes(simlog_handles, 'x')

simlog_handles(4) = subplot(3, 3, 4);
plot(simlog_t, ref_pxyz(:,2), 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, simlog_py, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Pos y')
linkaxes(simlog_handles, 'x')

simlog_handles(5) = subplot(3, 3, 5);
plot(simlog_t, ref_vxyz(:,2), 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, simlog_vy, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Vel y')
linkaxes(simlog_handles, 'x')

simlog_handles(6) = subplot(3, 3, 6);
plot(simlog_t, ref_pitch*180/pi, 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, squeeze(simlog_qy)*180/pi, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Pitch')
linkaxes(simlog_handles, 'x')

simlog_handles(7) = subplot(3, 3, 7);
plot(simlog_t, ref_pxyz(:,3), 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, simlog_pz, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Pos z')
xlabel('Time (s)')
linkaxes(simlog_handles, 'x')

simlog_handles(8) = subplot(3, 3, 8);
plot(simlog_t, ref_vxyz(:,3), 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, simlog_vz, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Vel z')
xlabel('Time (s)')
linkaxes(simlog_handles, 'x')

simlog_handles(9) = subplot(3, 3, 9);
plot(simlog_t, ref_yaw*180/pi, 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot(simlog_t, squeeze(simlog_qz)*180/pi, 'LineWidth', 1,'DisplayName','Meas');
hold off
grid on
title('Yaw (deg)')
linkaxes(simlog_handles, 'x')
xlabel('Time (s)')
 
% Remove temporary variables
clear simlog_t simlog_handles
clear simlog_R1i simlog_C1v temp_colororder

