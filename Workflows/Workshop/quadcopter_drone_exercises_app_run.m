% Script to run (instead of edit) vehicle configuration app
% and ensure only one copy of the UI is opened.

% Copyright 2019-2024 The MathWorks, Inc.

if(exist('quadcopter_drone_app_uifigure','var'))
    if(~isempty(quadcopter_drone_app_uifigure))
        if(length(quadcopter_drone_app_uifigure.findprop('Quadcopter_Drone_Exercises'))==1)
            % Figure is already open, bring it to the front
            figure(quadcopter_drone_app_uifigure.Quadcopter_Drone_Exercises);
        else
            % Open UI again and store figure handle
            quadcopter_drone_app_uifigure = quadcopter_drone_exercises_app;
        end
    else
        % Open UI again and store figure handle
        quadcopter_drone_app_uifigure = quadcopter_drone_exercises_app;
    end
else
    % Open UI again and store figure handle
    quadcopter_drone_app_uifigure = quadcopter_drone_exercises_app;
end
