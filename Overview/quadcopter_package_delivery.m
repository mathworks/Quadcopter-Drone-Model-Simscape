%% Quadcopter Package Delivery
% 
% This example models a quadcopter that navigates a path to deliver a
% package. The body was designed in CAD and imported into Simscape
% Multibody.  The electric motors capture the dynamics of the power
% conversion in an abstract manner to enable fast simulation.  The package
% is released from the quadcopter when it reaches the final waypoint and
% the release criteria are met.
% 
% Copyright 2021 The MathWorks, Inc.



%% Model

open_system('quadcopter_package_delivery')

set_param(find_system(bdroot,'FindAll','on','type','annotation','Tag','ModelFeatures'),'Interpreter','off');

%%
%
% <<quadcopter_package_deliver_mechExpAnim.png>>

%% Quadcopter Subsystem

open_system('quadcopter_package_delivery/Quadcopter','force')

%% Body Subsystem

open_system('quadcopter_package_delivery/Quadcopter/Body','force')

%% Motors Subsystem

open_system('quadcopter_package_delivery/Quadcopter/Electrical','force')

%% Maneuver Controller

set_param('quadcopter_package_delivery/Maneuver Controller','open','on');


%% Simulation Results from Simscape Logging: Path 1
%%
%

waypoints = waypts_path1;
yaw_traj  = yaw_traj_path1;
[timespot, spline_data] = quadcopter_define_trajectory(waypoints, segment_speeds_path1, 2);
sim('quadcopter_package_delivery');
quadcopter_package_delivery_plot2xyz;
quadcopter_package_delivery_plot1pvo;

%% Simulation Results from Simscape Logging: Path 2

waypoints = waypts_path2;
yaw_traj  = yaw_traj_path2;
[timespot, spline_data] = quadcopter_define_trajectory(waypoints, segment_speeds_path2, 2);
sim('quadcopter_package_delivery');
quadcopter_package_delivery_plot2xyz;
quadcopter_package_delivery_plot1pvo;

%% Simulation Results from Simscape Logging: Path 3

waypoints = waypts_path3;
yaw_traj  = yaw_traj_path3;
[timespot, spline_data] = quadcopter_define_trajectory(waypoints, segment_speeds_path3, 4);
sim('quadcopter_package_delivery');
quadcopter_package_delivery_plot2xyz;
quadcopter_package_delivery_plot1pvo;

%% Parameter Sweep: Package Mass
% Using parallel computing we vary the mass of the package to see its
% effect on the quadcopter trajectory.

quadcopter_package_delivery_sweep_load_mass

%% Parameter Sweep: Trajectory Speed
% Using parallel computing we vary the target speed of the quadcopter and
% see if the quadcopter can follow the target path.

quadcopter_package_delivery_sweep_load_speed

%%

%clear all
close all
bdclose all