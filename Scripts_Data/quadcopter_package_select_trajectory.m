function [waypoints, timespot_spl, spline_data, spline_yaw] = quadcopter_package_select_trajectory(path_number)
%quadcopter_select_trajectory Obtain parameters for selected quadcopter trajectory
%   [waypoints, timespot_spl, spline_data, spline_yaw] = quadcopter_select_trajectory(path_number)
%   This function returns the essential parameters that define the
%   quadcopter's trajectory. The function returns
%  
%       waypoints       Key x-y-z locations the quadcopter will pass through
%       timespot_spl    Times the quadcopter will pass through points along
%                       the spline that defines its path
%       spline_data     Points used for interpolating the spline that
%                       defines the path of the quadcopter
%       spline_yaw      Yaw angle at the spline_data points

% Copyright 2021 The MathWorks, Inc.

switch (path_number)
    case 1
        waypoints = [ ...
            -2    -2 0 2 5
            -2    -2 0 0 0
            0.15   6 6 6 1];
        max_speed = 1;
        min_speed = 0.1;
        xApproach = [4 0.5];
        vApproach = 0.1;

    case 2
        waypoints = [...
            -2    -2  -2  -2 -2  2  2
            -2    -2  -2   2  2  2  2
        	0.15  6   6   6  6  6  6];
        max_speed = 1;
        min_speed = 0.1;
        xApproach = [2 0.5];
        vApproach = 0.1;
        
    case 3
        % Note: This trajectory defines the waypoints, spline data, and yaw
        % data explicitly and does not use the function to calculate the
        % target speed and yaw angle based on the path.
        waypoints = [...
        	-2   -2    -2     -2  -2  -2 -2  -2  -2 -2 -2 -2
            -2   -2    -2     -2  -2  -2 -2  -2  -2 -2 -2 -2
            0.15 0.15   0.15   4   4   4  4   4   4  4  4  4];
        spline_data = waypoints';
        timespot_spl = [0:4:11*4]';
        spline_yaw   = [0 0 0 pi/4 pi/4 pi/4 0 0 0 -pi/4 -pi/4 -pi/4];

    case 4
        waypoints = [...
            -3.0000    0.5633    4.5492    7.7662    9.0011    7.3491    3.7145   -0.0156    2.2687    5.0000
            -5.0000   -4.4724   -4.5758   -2.3910    1.5272    5.3013    6.5986    6.8774    9.5797    8.0000
            0.1500    6.0000    6.0000    6.0000    6.0000    6.0000    6.0000    6.0000    6.0000    1];
        max_speed = 1;
        min_speed = 0.1;
        xApproach = [4 0.5];
        vApproach = 0.1;
end

% Only call the function to calculate target speed and yaw angle if needed
% Paths that define the spline data and yaw angles explictly should not
% define parameter xApproach
if(exist("xApproach","var"))
    [timespot_spl, spline_data, spline_yaw] = ...
        quadcopter_waypoints_to_trajectory(...
        waypoints,max_speed,min_speed,xApproach,vApproach);
end
