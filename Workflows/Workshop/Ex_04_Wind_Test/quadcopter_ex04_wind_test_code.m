%% Test Effect of Wind
% Copyright 2021-2022 The MathWorks, Inc.

% Move to folder where script is saved
cd(fileparts(which(mfilename)));

% Open model and save under another name for test
mdl = 'quadcopter_ex04_wind_test';
open_system(mdl);
quadcopter_package_parameters
[waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] =...
    quadcopter_package_select_trajectory(2,true);

qc_motor.max_power = 160;

%% Simulate no Wind
wind_speed = 0;
sim(mdl)

% Store results
logsout_noWind = logsout_quadcopter_package_delivery;

%% Simulate with wind
wind_speed = 12;
sim(mdl)

% Store results
logsout_Wind = logsout_quadcopter_package_delivery;

%% Plot wind
log_t = logsout_Wind.get('Environment').Values.wind.vx.Time;
log_wvx = logsout_Wind.get('Environment').Values.wind.vx.Data;
log_wvy = logsout_Wind.get('Environment').Values.wind.vy.Data;
log_wvz = logsout_Wind.get('Environment').Values.wind.vz.Data;

% Reuse figure if it exists, else create new figure
if ~exist('h3_quadcopter_package_delivery_wind_test', 'var') || ...
        ~isgraphics(h3_quadcopter_package_delivery_wind_test, 'figure')
    h3_quadcopter_package_delivery_wind_test = figure('Name', 'quadcopter_package_delivery');
end
figure(h3_quadcopter_package_delivery_wind_test)
clf(h3_quadcopter_package_delivery_wind_test)

plot(log_t,log_wvx,log_t,log_wvy,log_t,log_wvz,'LineWidth',1);
xlabel('Time (sec)')
ylabel('Speed (m/s)')
title('Wind Speed at Drone Location')
legend({'x','y','z'},'Location','Best');
grid on

%% Plot trajectory
fht = plot_sim_res_trajectory(logsout_noWind,logsout_Wind,waypoints,planex,planey);

%% Plot results
fhb = plot_sim_res_batt(logsout_noWind,logsout_Wind);

% Offset figure so that figures are not hidden
posfht = get(evalin('base',fht),'Position');
posfhb = get(evalin('base',fhb),'Position');
if(posfht == posfhb)
    % Make front figure 10% smaller
    % Cannot simply offset figures as bottom and left properties
    % are ignored in MATLAB Online
    set(evalin('base',fhb),'Position',posfhb.*[1 1 0.9 0.9]);
end

%%  Function to plot paths during tests
function fht = plot_sim_res_trajectory(logsout_noWind,logsout_Wind,waypoints,planex,planey)

% Create/Reuse figure and define handle in workspace
fig_handle_name =   'h1_quadcopter_package_delivery_wind_test';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Plot trajectories
data_pxN = logsout_noWind.get('Quadcopter').Values.Chassis.px;
data_pyN = logsout_noWind.get('Quadcopter').Values.Chassis.py;
data_pzN = logsout_noWind.get('Quadcopter').Values.Chassis.pz;
data_pxW = logsout_Wind.get('Quadcopter').Values.Chassis.px;
data_pyW = logsout_Wind.get('Quadcopter').Values.Chassis.py;
data_pzW = logsout_Wind.get('Quadcopter').Values.Chassis.pz;
plot3(data_pxN.Data,data_pyN.Data,data_pzN.Data,'LineWidth',2)
legendstr{1} = 'No Wind';
hold on
plot3(data_pxW.Data,data_pyW.Data,data_pzW.Data,'LineWidth',2)
legendstr{2} = 'Wind';

% Plot waypoints
wayp_unique = unique(waypoints','rows');
plot3(wayp_unique(:,1),wayp_unique(:,2),wayp_unique(:,3),'o','MarkerSize',6,'MarkerFaceColor','cyan','MarkerEdgeColor','none','DisplayName','Waypoints')
legendstr{end+1} = 'Waypoints';
[planeMeshx,planeMeshy] = meshgrid([-0.5 0.5]*planex,[-0.5 0.5]*planey);
surf(planeMeshx, planeMeshy, zeros(size(planeMeshx)),'FaceColor',[0.8 0.9 0.8],'DisplayName','')
legendstr{end+1} = '';
hold off

% Setup axes
ah = gca;
% Uncomment to disable clipping 
% Keep clipping on if missions go far from target
%ah.Clipping = 'off';
grid on
title('Parameter Sweep Results (Package Mass)');
box on
% Uncomment to add legend
legend(legendstr,'Location','Best');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
axis equal
set(gca,'XLim',[-0.5 0.5]*planex,'YLim',[-0.5 0.5]*planey)
view(-5,16)

%text(0.5,0.15,sprintf('%s\n%s',annotation_str,['Elapsed Time: ' num2str(elapsed_time)]),'Color',[1 1 1]*0.6,'Units','Normalized');

fht = fig_handle_name;
end

%%  Function to plot electrical quantities during tests
function fhb = plot_sim_res_batt(logsout_noWind,logsout_Wind)

% Create/Reuse figure and define handle in workspace
fig_handle_name =   'h2_quadcopter_package_delivery_wind_test';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Plot state of charge
data_socN = logsout_noWind.get('Quadcopter').Values.Motor.Battery.SOC;
data_socW = logsout_Wind.get('Quadcopter').Values.Motor.Battery.SOC;

plot(data_socN.Time,data_socN.Data,'LineWidth',2,'DisplayName','No Wind')
hold on
plot(data_socW.Time,data_socW.Data,'LineWidth',2,'DisplayName','Wind')
hold off
grid on
title('Battery SOC');
box on
% Uncomment to add legend
legend('Location','Best');
xlabel('Time (sec)');
ylabel('SOC (A*hr)');

fhb = fig_handle_name;

end
