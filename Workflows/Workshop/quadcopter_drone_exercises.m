function quadcopter_drone_exercises(ex_num)

bdclose all
close all

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
        mfile = 'quadcopter_ex05_profit_app.m';
    otherwise
        mdl = 'none';
        disp(['No exercise ' num2str(ex_num)])

end

if(~strcmpi(mdl,'none'))
    cd(fileparts(which(mdl)))
    open_system(mdl);
elseif(~isempty(mfile))
    run(mfile)
end
