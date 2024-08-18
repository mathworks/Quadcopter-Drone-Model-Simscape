% Script for testing main model and publishing results
% Copyright 2021-2024 The MathWorks, Inc.

% List models with publish scripts that have the same name
mdl_list = {...
    'quadcopter_package_delivery',...
    };

% Close models to avoid shadowing issues
for mdl_list_i = 1:length(mdl_list)
    bdclose(mdl_list{mdl_list_i});
end

curr_proj = simulinkproject;

% Loop over models with publish script
for mdl_list_i = 1:length(mdl_list)
    cd(curr_proj.RootFolder)
    % Move to folder with publish scripts
    fm = dir(['**' filesep mdl_list{mdl_list_i} '.m']);
    %cd(fileparts(which(mdl_list{mdl_list_i})))
    %cd('Overview')
    cd(fm(1).folder)
    
    % Loop over publish scripts
    filelist_m=dir('*.m');
    filenames_m = {filelist_m.name};
    warning('off','Simulink:Engine:MdlFileShadowedByFile');
    for filenames_m_i=1:length(filenames_m)
        publish(filenames_m{filenames_m_i},'showCode',false)
    end    
end

cd(curr_proj.RootFolder)
fm = dir(['**' filesep 'quadcopter_package_delivery_param_sweep.m']);
cd(fm(1).folder)
publish('quadcopter_package_delivery_param_sweep.m','showCode',false)

cd(curr_proj.RootFolder)

fm = dir(['**' filesep 'quadcopter_delivery_tradeoff_cost.m']);
cd(fm(1).folder)
publish('quadcopter_delivery_tradeoff_cost.m','showCode',true)

cd(curr_proj.RootFolder)
fm = dir(['**' filesep 'quadcopter_package_delivery_weather.m']);
cd(fm(1).folder)
publish('quadcopter_package_delivery_weather.m','showCode',true)

% Ensure workshop models are saved with scopes open
wrkshp_mdls = {...
    'quadcopter_ex01_motor','/Scope';
    'quadcopter_ex02_motor_sweep','/Scope';...
    'quadcopter_ex03_wind_conditions','/Scope';...
    'quadcopter_ex04_wind_test','/Environment/Scope'};

for i = 1:size(wrkshp_mdls,1)
    open_system([wrkshp_mdls{i,1}])
    open_system([wrkshp_mdls{i,1},wrkshp_mdls{i,2}])
    save_system(wrkshp_mdls{i,1})
    close_system(wrkshp_mdls{i,1})
end

clear filelist_m filenames_m filenames_m_i 
clear mdl_list mdl_list_i