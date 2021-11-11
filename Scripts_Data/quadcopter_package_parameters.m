% Parameters for quadcopter_package_delivery
% Copyright 2021 The MathWorks, Inc.

% Size of the ground
planex = 12.5;           % m
planey = 8.5;            % m
planedepth = 0.2;        % m, distance from plane to the reference frame

% Battery Capacity
battery_capacity = 7.6;

%% Material Property
% Assuming the arm of the drone is manufractured by 3D Printing, the ideal
% material is PLA, safe, light and cheap, the only concern is its thermal
% property
rho_pla   = 1.25;            % g/cm^3 

%% package ground contact properties
%pkgGrndStiff  = 10000;
%pkgGrndDamp   = 300;
%pkgGrndTransW = 1e-3;

pkgGrndStiff  = 1000;
pkgGrndDamp   = 300;
pkgGrndTransW = 1e-3;


%% package size and density
pkgSize = [1 1 1]*0.15; % m
pkgDensity = 160; % kg/m^3

%% package size and density
propeller.diameter = 0.254; % m
propeller.Kthrust  = 0.1072; 
propeller.Kdrag    = 0.01;

air_rho = 1.225; % kg/m^3

%% Controller parameters
filtM_position = 0.05;
kp_position    = 1;
ki_position    = 0.08;
kd_position    = 1.6;
filtD_position = 100;
pos2attitude   = 0.6;

filtM_attitude = 0.01;
kp_attitude    = 25.7010;
ki_attitude    = 5.9203;
kd_attitude    = 78.2000*2;
filtD_attitude = 1000;
limit_attitude = 5;

filtM_yaw      = 0.01;
kp_yaw         = 25.7010*4*2;
ki_yaw         = 5.9203*0.01;
kd_yaw         = 78.2000*0.01;
filtD_yaw      = 100;
limit_yaw      = 20;

filtM_altitude = 0.01;
kp_altitude    = 0.27;
ki_altitude    = 0.07;
kd_altitude    = 0.35;
filtD_altitude = 10000;
limit_altitude = 10;

kp_motor       = 0.00375;
ki_motor       = 4.50000e-4;
kd_motor       = 0;
filtD_motor    = 10000;
filtSpd_motor    = 0.001;
limit_motor    = 0.25;

%% Drag coefficients
qd_drag.Cd_X = 0.35;
qd_drag.Cd_Y = 0.35;
qd_drag.Cd_Z = 0.6;
qd_drag.Roll = 0.2;
qd_drag.Pitch = 0.2;
qd_drag.Yaw = 0.2;
qd_area.YZ = 0.0175;
qd_area.XZ = 0.0180;
qd_area.XY = 0.2560;
qd_area.Roll = qd_area.XY*2;
qd_area.Pitch = qd_area.XY*2;
qd_area.Yaw = qd_area.XY;

