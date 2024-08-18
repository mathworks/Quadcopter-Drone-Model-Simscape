%% Use Parallel Computing and Fast Restart to sweep parameter value
% Copyright 2021-2024 The MathWorks, Inc.

% Move to folder where script is saved
cd(fileparts(which(mfilename)));

% Open model and save under another name for test
orig_mdl = 'quadcopter_package_delivery';
open_system(orig_mdl);
quadcopter_package_parameters
[waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = ...
    quadcopter_package_select_trajectory(2);

qc_motor.max_power = 160;

mdl = [orig_mdl '_pct_temp'];
save_system(orig_mdl,mdl);

%% Generate parameter sets
% Sweep package mass, scaling factor on wind
pkgSize = evalin('base','pkgSize');
pkgVol  = pkgSize(1)*pkgSize(2)*pkgSize(3);
pkgDensity_array = linspace(0.5/pkgVol,2.2/pkgVol,12); 
windSpeed_array  = linspace(0, 24,19); 

% For short sweep
%pkgDensity_array = linspace(0.5/pkgVol,2.2/pkgVol,3); 
%windSpeed_array  = linspace(0  ,24,4); 

clear simInput
simInput(1:(length(pkgDensity_array)*length(windSpeed_array))) = Simulink.SimulationInput(mdl);
runNum = 0;
for i=1:length(pkgDensity_array)
    for j=1:length(windSpeed_array)
        runNum = runNum+1;
        simInput(runNum) = simInput(runNum).setVariable('pkgDensity',pkgDensity_array(i));
        simInput(runNum) = simInput(runNum).setVariable('wind_speed',windSpeed_array(j));
    end
end

pkgDensity = pkgDensity_array(1);
wind_speed = 10;
save_system(mdl);

%% Run one simulation to see time used
timerVal = tic;
sim(mdl)
Elapsed_Sim_Time_single = toc(timerVal);
disp(['Elapsed Simulation Time Single Run: ' num2str(Elapsed_Sim_Time_single)]);

% Plot wind
log_t = logsout_quadcopter_package_delivery.get('Environment').Values.wind.vx.Time;
log_wvx = logsout_quadcopter_package_delivery.get('Environment').Values.wind.vx.Data;
log_wvy = logsout_quadcopter_package_delivery.get('Environment').Values.wind.vy.Data;
log_wvz = logsout_quadcopter_package_delivery.get('Environment').Values.wind.vz.Data;
figure
plot(log_t,log_wvx,log_t,log_wvy,log_t,log_wvz,'LineWidth',1);
xlabel('Time')
ylabel('Force (N)')
title('Force due to Wind')
legend({'x','y','z'},'Location','Best');
grid on

%% Adjust settings and save
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off');
set_param(mdl,'SimscapeLogType','none');
set_param(mdl,'SimscapeLogToSDI','off');
save_system(mdl)

%% Run parameter sweep in parallel
warning off physmod:common:logging2:mli:mcos:kernel:SdiStreamSaveError
timerVal = tic;
simOut = parsim(simInput,'ShowSimulationManager','on',...
    'ShowProgress','on','UseFastRestart','on',...
    'TransferBaseWorkspaceVariables','on');
Elapsed_Time_Time_parallel  = toc(timerVal);
warning on physmod:common:logging2:mli:mcos:kernel:SdiStreamSaveError

%% Calculate elapsed time less setup of parallel
Elapsed_Time_Sweep = ...
    (datenum(simOut(end).SimulationMetadata.TimingInfo.WallClockTimestampStop) - ...
    datenum(simOut(1).SimulationMetadata.TimingInfo.WallClockTimestampStart)) * 86400;
disp(['Elapsed Sweep Time Total:       ' sprintf('%5.2f',Elapsed_Time_Sweep)]);
disp(['Elapsed Sweep Time/(Num Tests): ' sprintf('%5.2f',Elapsed_Time_Sweep/length(simOut))]);
disp(' ');

%% Plot results
plot_sim_res(simInput,simOut,waypoints,planex,planey,'Parallel Test',Elapsed_Time_Time_parallel)
plot_sim_res_batt(simInput,simOut)
plot_mission_status(simInput,simOut)

%% Close parallel pool
delete(gcp);

%% Cleanup directory
bdclose(mdl);
delete([mdl '.slx']);

%%  Function to plot paths during tests
function plot_sim_res(simInput,simOut,waypoints,planex,planey,annotation_str,elapsed_time)

% Create/Reuse figure and define handle in workspace
fig_handle_name =   'h4_quadcopter_package_delivery_pct_mass';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Plot trajectories
legendstr = cell(1,length(simOut));
pkgSize = evalin('base','pkgSize');
for i=1:length(simOut)
    data_px = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.px;
    data_py = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.py;
    data_pz = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.pz;
    missionStatus = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Load.status.Data(end);
    LineStyle = '-';
    LineWidth = 2;
    if(missionStatus == 0)
        % If joint is still engaged at finish, mission failed
        LineStyle = ':';
        LineWidth = 0.5;
    end
    plot3(data_px.Data,data_py.Data,data_pz.Data,'LineWidth',LineWidth,'LineStyle',LineStyle)
    legendstr{i} = sprintf('%3.2f kg',simInput(i).Variables(1).Value(end)*pkgSize(1)*pkgSize(2)*pkgSize(3));
    hold all
end

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
%legend(legendstr,'Location','West');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
axis equal
set(gca,'XLim',[-0.5 0.5]*planex,'YLim',[-0.5 0.5]*planey)
view(-5,16)

text(0.5,0.15,sprintf('%s\n%s',annotation_str,['Elapsed Time: ' num2str(elapsed_time)]),'Color',[1 1 1]*0.6,'Units','Normalized');
end

%%  Function to plot electrical quantities during tests
function plot_sim_res_batt(simInput,simOut)

% Create/Reuse figure and define handle in workspace
fig_handle_name =   'h5_quadcopter_package_delivery_pct_mass';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Plot state of charge
legendstr = cell(1,length(simOut));
pkgSize = evalin('base','pkgSize');
for i=1:length(simOut)
    data_soc = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Battery.SOC;
    missionStatus = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Load.status.Data(end);
    LineStyle = '-';
    LineWidth = 2;
    if(missionStatus == 0)
        % If joint is still engaged at finish, mission failed
        LineStyle = ':';
        LineWidth = 0.5;
    end
    plot(data_soc.Time,data_soc.Data,'LineWidth',LineWidth,'LineStyle',LineStyle)
    legendstr{i} = sprintf('%3.2f kg',simInput(i).Variables(1).Value(end)*pkgSize(1)*pkgSize(2)*pkgSize(3));
    hold all
end

grid on
title('Effect of Package Mass on Battery SOC');
box on
% Uncomment to add legend
%legend(legendstr,'Location','Best');
xlabel('Time (sec)');
ylabel('SOC (A*hr)');

end

%%  Function to plot mission outcome
function plot_mission_status(simInput,simOut)

% Create/Reuse figure and define handle in workspace
fig_handle_name =   'h6_quadcopter_package_delivery_pct_status';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Extract parameter values and mission status
legendstr = cell(1,length(simOut));
pkgSize = evalin('base','pkgSize');
for i=1:length(simInput)
    simres(i).(simInput(i).Variables(1).Name) = simInput(i).Variables(1).Value;
    simres(i).(simInput(i).Variables(2).Name) = simInput(i).Variables(2).Value;
    simres(i).Status = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Load.status.Data(end);
end

% Put parameter values in vectors
parSet1 = unique([simres(:).(simInput(i).Variables(1).Name)]);
% Smallest numbers in last row of matrix
parSet2 = fliplr(unique([simres(:).(simInput(i).Variables(2).Name)]));

% Put mission outcome in matrix
statusMatrix = ones(length(parSet2),length(parSet1))*2;
for i = 1:length(simres)
    val1 = simres(i).(simInput(i).Variables(1).Name);
    val2 = simres(i).(simInput(i).Variables(2).Name);
    statusMatrix(parSet2 == val2,parSet1 == val1) = -simres(i).Status;
end

% Put mission parameters and outcome in table
T = table;
for i = 1:size(statusMatrix,2)
    weight = parSet1(i)*pkgSize(1)*pkgSize(2)*pkgSize(3);
    T.(sprintf('%3.2f',weight)) = statusMatrix(:,i);
end

% Assign names for rows
T.Properties.RowNames = strsplit(num2str(parSet2))';

% Plot mission outcome as a heatmap
h=heatmap(T.Properties.VariableNames,T.Properties.RowNames,T.Variables,...
    'ColorbarVisible','off','CellLabelColor','none');

% Add title and labels
h.Title = 'Mission Outcome: Success (dark), Failure (light)';
h.XLabel = 'Load Mass (kg)';
h.YLabel = 'Wind Speed (m/s)';

end
