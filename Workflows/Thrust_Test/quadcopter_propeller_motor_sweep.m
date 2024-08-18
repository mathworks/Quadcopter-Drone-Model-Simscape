%% Use Parallel Computing and Fast Restart to sweep parameter value
% Copyright 2021-2024 The MathWorks, Inc.

% Move to folder where script is saved
cd(fileparts(which(mfilename)));

% Open model and save under another name for test
orig_mdl = 'quadcopter_propeller_test_harness';
open_system(orig_mdl);
quadcopter_package_parameters

mdl = [orig_mdl '_pct_temp'];
save_system(orig_mdl,mdl);

%% Generate parameter sets
motSize_array = linspace(40,160,9); 

clear simInput
simInput(1:length(motSize_array)) = Simulink.SimulationInput(mdl);
for i=1:length(motSize_array)
    simInput(i) = simInput(i).setVariable('motor_max_power',motSize_array(i));
end

motor_max_power = motSize_array(1);
wind_speed = 0;
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
simOut = sim(simInput,'ShowSimulationManager','on',...
    'ShowProgress','on','UseFastRestart','on');
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
plot_sim_res_batt(simInput,simOut)

%% Adjust settings and save
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','on');
set_param(mdl,'SimscapeLogType','all');
set_param(mdl,'SimscapeLogToSDI','on');
save_system(mdl)


%%  Function to plot electrical quantities during tests
function plot_sim_res_batt(simInput,simOut)

% Create/Reuse figure and define handle in workspace
fig_handle_name =   'h5_quadcopter_propeller_test_harness_pct_mass';

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
    maxThrust(i) = simOut(i).logsout_quadcopter_propeller_test_harness.get('Thrust').Values.Data(end);
    motPower(i)  = simInput(i).Variables(1).Value;
end
drone_mass = evalin('base','drone_mass');
maxLoadMass = maxThrust*4/9.81-drone_mass;
plot(motPower,maxLoadMass,'-o','LineWidth',2)
grid on
title('Max Load with Varying Motor Size');
box on
xlabel('Max Motor Power (W)');
ylabel('Maximum Load (kg)');

end