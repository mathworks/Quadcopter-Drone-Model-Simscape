function quadcopter_drone_exercises(ex_num)

quadcopter_ex02_motor_sweep_prefs
bdclose all

mfile = [];
switch ex_num
    case 1
        mdl = 'quadcopter_ex01_motor';
    case 2
        mdl = 'quadcopter_ex02_motor_sweep';
    case 3
        mdl = 'quadcopter_ex03_wind_conditions';
    case 4
        mdl = 'quadcopter_ex04_wind_test';
    case 5
        mdl = 'none';
        mfile = 'quadcopter_delivery_tradeoff_cost_app_run.m';
    otherwise
        mdl = 'none';
        disp(['No exercise ' num2str(ex_num)])

end

% Close figure windows
% close all % Closes app with R2022b
figList = findall(groot, 'Type', 'figure');
for i = 1:length(figList)
    if(~strcmp(figList(i).Name,'Exercise Selection App'))
        disp(['Closing figure ' figList(i).Name])
        delete(figList(i))
    end
end


if(~strcmpi(mdl,'none'))
    cd(fileparts(which(mdl)))
    open_system(mdl);
elseif(~isempty(mfile))
    % Need to run in base to check if UI is open
    evalin('base',['run(''' mfile ''')']);
end
