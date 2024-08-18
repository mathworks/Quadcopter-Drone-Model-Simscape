%% Quadcopter Package Delivery, Parameter Sweeps
% 
% This example models a quadcopter that navigates a path to deliver a
% package. The body was designed in CAD and imported into Simscape
% Multibody.  The electric motors capture the dynamics of the power
% conversion in an abstract manner to enable fast simulation.  The package
% is released from the quadcopter when it reaches the final waypoint and
% the release criteria are met.
%
% The design space for the quadcopter and the missions it performs is
% explored by conducting a set of parameter sweeps.
% 
% Copyright 2021-2024 The MathWorks, Inc.



%% Model

open_system('quadcopter_package_delivery')

set_param(find_system(bdroot,'MatchFilter',@Simulink.match.allVariants,'FindAll','on','type','annotation','Tag','ModelFeatures'),'Interpreter','off');

%%
%
% <<quadcopter_package_deliver_mechExpAnim.png>>


%% Parameter Sweep: Package Mass
% Using parallel computing we vary the mass of the package to see its
% effect on the quadcopter trajectory.

quadcopter_package_delivery_sweep_load_mass

%% Parameter Sweep: Trajectory Speed
% Using parallel computing we vary the target speed of the quadcopter and
% see if the quadcopter can follow the target path.

quadcopter_package_delivery_sweep_load_speed

%% Parameter Sweep: Mass and Wind
% Using parallel computing we vary the mass of the package and the strength
% of wind gusts that strike the quadcopter during the test.

quadcopter_package_delivery_sweep_load_mass_wind

%% Parameter Sweep: Mass and Air Temperature
% Using parallel computing we vary the mass of the package and the
% temperature of the air with associated change in air density

quadcopter_package_delivery_sweep_load_mass_temp

%%

%clear all
close all
bdclose all