% Startup script for project Quadcopter_Drone.prj
% Copyright 2018-2024 The MathWorks, Inc.

%% Code for building Simscape custom library at startup
% Change to folder with package directory
curr_proj = simulinkproject;
cd(curr_proj.RootFolder)

% Change to root folder
cd(curr_proj.RootFolder)

% If running in a parallel pool
% do not open model or demo script
open_start_content = 1;
if(~isempty(ver('parallel')))
    if(~isempty(getCurrentTask()))
        open_start_content = 0;
    end
end

if(open_start_content)
    % Parameters
    quadcopter_package_parameters;
    % Define trajectory
    [waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = quadcopter_package_select_trajectory(1,true);
    % Set Python environment (if needed)
    check_pyenv
    % Open Model
    quadcopter_package_delivery % Not for Workshop
    % Open Exercises
    %quadcopter_workshop_prefs
    %quadcopter_drone_exercises_app_run  % For Workshop
end
