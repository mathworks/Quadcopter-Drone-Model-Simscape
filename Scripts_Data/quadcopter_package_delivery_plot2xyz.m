% Code to plot simulation results from quadcopter_package_delivery
%% Plot Description:
%
% This plot shows the 3D trajectory of the quadcopter.
%
% Copyright 2021 The MathWorks, Inc.

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
simlog_px = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.px.Data;
simlog_py = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.py.Data;
simlog_pz = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.pz.Data;
simlog_t  = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.px.Time;

load_final_x = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Load.px.Data(end);
load_final_y = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Load.py.Data(end);
load_final_z = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Load.pz.Data(end);

ref_pxyz = logsout_quadcopter_package_delivery.get('Ref').Values.pos.Data(:,:)';

% Plot results
if(size(ref_pxyz,2)>3)
    ref_pxyz = ref_pxyz';
end
plot3(ref_pxyz(:,1), ref_pxyz(:,2), ref_pxyz(:,3), 'k--','LineWidth', 1,'DisplayName','Ref')
hold on
plot3(simlog_px, simlog_py, simlog_pz, 'LineWidth', 1,'DisplayName','Ref')
plot3(simlog_px(1),   simlog_py(1),   simlog_pz(1),   'o','MarkerEdgeColor','#77AC30','MarkerFaceColor','#77AC30')
plot3(simlog_px(end), simlog_py(end), simlog_pz(end), 'o','MarkerFaceColor','r')

[planeMeshx,planeMeshy] = meshgrid(...
    [min(waypoints(1,:))-3 max(waypoints(1,:))+3],...
    [min(waypoints(2,:))-3 max(waypoints(2,:))+3]);

surf(planeMeshx, planeMeshy, zeros(size(planeMeshx)),'FaceColor',[0.8 0.9 0.8])

plot3(0.5*0.25*sin(linspace(0,2*pi,30))+waypoints(1,end),0.5*0.25*cos(linspace(0,2*pi,30))+waypoints(2,end),zeros(30,1),'b','LineWidth',2)
plot3(load_final_x,load_final_y,load_final_z,'r+','MarkerSize',8)
wayp_unique = unique(waypoints','rows');
plot3(wayp_unique(:,1),wayp_unique(:,2),wayp_unique(:,3),'o','MarkerSize',6,'MarkerFaceColor','cyan','MarkerEdgeColor','none','DisplayName','Waypoints')
legend({'Ref','Path','','','','','Load','Waypoints'})

ah = gca;
ah.Clipping = 'off';
hold off
grid on
title('Quadcopter Trajectory')
box on
legend('Location','Best');

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

axis equal


% Remove temporary variables
clear simlog_t simlog_handles
clear simlog_R1i simlog_C1v temp_colororder

