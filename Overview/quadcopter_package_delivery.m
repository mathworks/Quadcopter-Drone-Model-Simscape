%% Quadcopter Package Delivery
% 
% This example models a quadcopter that navigates a path to deliver a
% package. The body was designed in CAD and imported into Simscape
% Multibody.  The electric motors capture the dynamics of the power
% conversion in an abstract manner to enable fast simulation.  The package
% is released from the quadcopter when it reaches the final waypoint and
% the release criteria are met.
% 
% Copyright 2022-2024 The MathWorks, Inc.



%% Model

open_system('quadcopter_package_delivery')

set_param(find_system(bdroot,'MatchFilter',@Simulink.match.allVariants,'FindAll','on','type','annotation','Tag','ModelFeatures'),'Interpreter','off');

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

[waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = quadcopter_package_select_trajectory(1);
quadcopter_package_plot_trajectory(waypoints, timespot_spl, spline_data, spline_yaw)
sim('quadcopter_package_delivery');
quadcopter_package_delivery_plot2xyz;
quadcopter_package_delivery_plot1pvo;

%% Simulation Results from Simscape Logging: Path 4

[waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = quadcopter_package_select_trajectory(4);
quadcopter_package_plot_trajectory(waypoints, timespot_spl, spline_data, spline_yaw)
sim('quadcopter_package_delivery');
quadcopter_package_delivery_plot2xyz;
quadcopter_package_delivery_plot1pvo;

%% Simulation Results from Simscape Logging: Path 4 with Wind

[waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = quadcopter_package_select_trajectory(4);
wind_speed = 10;
quadcopter_package_plot_trajectory(waypoints, timespot_spl, spline_data, spline_yaw)
sim('quadcopter_package_delivery');
quadcopter_package_delivery_plot2xyz;
quadcopter_package_delivery_plot1pvo;
wind_speed = 0;

%% Parameter Sweep: Package Mass
% Using parallel computing we vary the mass of the package to see its
% effect on the quadcopter trajectory.

quadcopter_package_delivery_sweep_load_mass

%% Parameter Sweep: Trajectory Speed
% Using parallel computing we vary the target speed of the quadcopter and
% see if the quadcopter can follow the target path.

quadcopter_package_delivery_sweep_load_speed

%% Simulation Results from Simscape Logging: Path 5, 6

[waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = quadcopter_package_select_trajectory(5,true);
quadcopter_package_plot_trajectory(waypoints, timespot_spl, spline_data, spline_yaw)
sim('quadcopter_package_delivery');

p5_time = simlog_quadcopter_package_delivery.Quadcopter.Electrical.Battery.charge.series.time;
p5_chrg = simlog_quadcopter_package_delivery.Quadcopter.Electrical.Battery.charge.series.values;

%%
[waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = quadcopter_package_select_trajectory(6,true);
quadcopter_package_plot_trajectory(waypoints, timespot_spl, spline_data, spline_yaw)
sim('quadcopter_package_delivery');

p6_time = simlog_quadcopter_package_delivery.Quadcopter.Electrical.Battery.charge.series.time;
p6_chrg = simlog_quadcopter_package_delivery.Quadcopter.Electrical.Battery.charge.series.values;

%%
figure
plot(p5_time,p5_chrg,'LineWidth',1,'DisplayName','Zig-Zag');
hold on
plot(p6_time,p6_chrg,'LineWidth',1,'DisplayName','L-Shaped');
hold off
title('Battery Charge on Two Paths')
xlabel('Time (s)')
ylabel('Charge (A*hr)');
legend('Location','Best')

%%

%clear all
close all
bdclose all