% Shutdown script for custom project
% Copyright 2019-2024 The MathWorks, Inc.

%% Code for cleaning Simscape custom library at shutdown
% Change to folder with package directory
curr_proj = simulinkproject;
cd(curr_proj.RootFolder)
cd('Libraries')

if(exist('quadcopter_drone_app_uifigure','var'))
    quadcopter_drone_app_uifigure.delete
    clear quadcopter_drone_app_uifigure
end

% Change to root folder
cd(curr_proj.RootFolder)

