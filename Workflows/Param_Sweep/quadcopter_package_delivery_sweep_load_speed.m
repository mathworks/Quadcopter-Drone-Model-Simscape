%% Use Parallel Computing and Fast Restart to sweep parameter value
% Copyright 2021 The MathWorks, Inc.

% Move to folder where script is saved
cd(fileparts(which(mfilename)));

% Open model and save under another name for test
orig_mdl = 'quadcopter_package_delivery';
open_system(orig_mdl);
quadcopter_package_parameters
[waypoints, timespot_spl, spline_data, spline_yaw] = quadcopter_package_select_trajectory(1);
mdl = [orig_mdl '_pct_temp'];
save_system(orig_mdl,mdl);

%% Configure model for tests
% Block paths
tunebpathA = [mdl '/Quadcopter/Load/Medical Kit/Medical Kit'];
refsys = [mdl '/Quadcopter'];

%% Generate parameter sets
% Delta is 10% of trajectory duration
timespot_spl_delta = floor(timespot_spl(end)*0.1);

% Set of deltas is multiples of timespot_delta
delta_set = linspace(0,7,8);

% Pre allocate variables
clear simInput
simInput(1:length(delta_set)) = Simulink.SimulationInput(mdl);

% Loop to set up simInput object
for i=1:length(delta_set)
    % Scale time vector so that duration 
    % is reduced by multiples of timespot_delta
    simInput(i) = simInput(i).setVariable('timespot_spl',timespot_spl*(timespot_spl(end)-timespot_spl_delta*delta_set(i))/timespot_spl(end));
end

save_system(mdl);

%% Run one simulation to see time used
timerVal = tic;
sim(mdl)
Elapsed_Sim_Time_single = toc(timerVal);
disp(['Elapsed Simulation Time Single Run: ' num2str(Elapsed_Sim_Time_single)]);

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

%% Plot results
plot_sim_res(simInput,simOut,waypoints,planex,planey,'Parallel Test',Elapsed_Time_Time_parallel)
plot_sim_res_batt(simInput,simOut)

%% Close parallel pool
delete(gcp);

%% Cleanup directory
bdclose(mdl);
delete([mdl '.slx']);

%%  Function to plot paths during tests
function plot_sim_res(simInput,simOut,waypoints,planex,planey,annotation_str,elapsed_time)

% Create figure
fig_handle_name =   'h4_quadcopter_package_delivery_pct_speed';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Plot trajectories
legendstr = cell(1,8);
for i=1:length(simOut)
    data_px = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.px;
    data_py = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.py;
    data_pz = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.pz;
    plot3(data_px.Data,data_py.Data,data_pz.Data,'LineWidth',1)
    legendstr{i} = sprintf('%3.1f sec',simInput(i).Variables(1).Value(end));
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
ah.Clipping = 'off';
grid on
title('Parameter Sweep Results (Trajectory Speed)');
box on
legend(legendstr,'Location','West');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
axis equal
view(-5,16)

% Annotate
text(0.5,0.15,sprintf('%s\n%s',annotation_str,['Elapsed Time: ' num2str(elapsed_time)]),'Color',[1 1 1]*0.6,'Units','Normalized');

end

%%  Function to plot electrical quantities during tests
function plot_sim_res_batt(simInput,simOut)

% Plot Results
fig_handle_name1 =   'h5_quadcopter_package_delivery_pct_speed_soc';
fig_handle_name2 =   'h5_quadcopter_package_delivery_pct_speed_i';

handle_var = evalin('base',['who(''' fig_handle_name1 ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
end

handle_var = evalin('base',['who(''' fig_handle_name2 ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name2 ' = figure(''Name'', ''' fig_handle_name2 ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name2 ' = figure(''Name'', ''' fig_handle_name2 ''');']);
end

figure(evalin('base',fig_handle_name1))
clf(evalin('base',fig_handle_name1))

% Plot trajectories
legendstr = cell(1,length(simOut));
delta_soc = ones(1,length(simOut));
for i=1:length(simOut)
    % Data for first plot
    data_imot1 = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot1.i;
    data_imot2 = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot2.i;
    data_imot3 = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot3.i;
    data_imot4 = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Mot4.i;
    plot(data_imot1.Time,data_imot1.Data+data_imot2.Data+data_imot3.Data+data_imot4.Data,'LineWidth',1)
    legendstr{i} = sprintf('%3.1f sec',simInput(i).Variables(1).Value(end));
    hold all

    % Data for second plot
    data_soc = simOut(i).logsout_quadcopter_package_delivery.get('Quadcopter').Values.Motor.Battery.SOC;
    delta_soc(i) = (data_soc.Data(end)/data_soc.Data(1))*100;
end
title('Effect of Trajectory Speed on Battery Current');
xlabel('Time (sec)');
ylabel('Battery Current (A)');
legend(legendstr,'Location','Best');

% Second plot for SOC
figure(evalin('base',fig_handle_name2))
clf(evalin('base',fig_handle_name2))
barh(delta_soc)
yticklabels(legendstr)
grid on
title('Effect of Trajectory Speed on Battery SOC');
box on
xlabel('Remaining Charge (%)');
ylabel('Trajectory Duration (sec)');

end