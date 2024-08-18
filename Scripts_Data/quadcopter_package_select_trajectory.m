function [waypoints, timespot_spl, spline_data, spline_yaw, wayp_path_vis] = quadcopter_package_select_trajectory(path_number,varargin)
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

% Copyright 2021-2024 The MathWorks, Inc.

if(nargin == 2)
    roundtrip = varargin{1};
else
    roundtrip = false;
end

switch (path_number)
    case 1
        waypoints = [ ...
            -2    -2 0 2 5
            -2    -2 0 0 0
            0.14   6 6 6 0.14];
        max_speed = 1;
        min_speed = 0.1;
        xApproach = [4 0.5];
        vApproach = 0.1;

    case 2
        waypoints = [...
            -2    -2  -2  -2 -2  2  2
            -2    -2  -2   2  2  2  2
            0.15  6   6   6  6  6  0.15];
        max_speed = 1;
        min_speed = 0.1;
        xApproach = [2 0.5];
        vApproach = 0.1;

    case 3
        % Note: This trajectory defines the waypoints, spline data, and yaw
        % data explicitly and does not use the function to calculate the
        % target speed and yaw angle based on the path.
        waypoints = [...
            -2   -2    -2     -2  -2  -2 -2  -2  -2 -2 -2 -2 -2 -2
            -2   -2    -2     -2  -2  -2 -2  -2  -2 -2 -2 -2  0  0
            0.15 0.15   0.15   4   4   4  4   4   4  4  4  4  4  0.14];
        spline_data = waypoints';
        timespot_spl = [0:4:11*4 11*4+6 11*4+6+6]';
        spline_yaw   = [0 0 0 pi/4 pi/4 pi/4 0 0 0 -pi/4 -pi/4 -pi/4 -pi/4 -pi/4];

    case 4
        waypoints = [...
            -3.0000    0.5633    4.5492    7.7662    9.0011    7.3491    3.7145   -0.0156    2.2687    5.0000
            -5.0000   -4.4724   -4.5758   -2.3910    1.5272    5.3013    6.5986    6.8774    9.5797    8.0000
            0.1500    6.0000    6.0000    6.0000    6.0000    6.0000    6.0000    6.0000    6.0000    0.15];
        max_speed = 1;
        min_speed = 0.1;
        xApproach = [4 0.5];
        vApproach = 0.1;

    case 5
        waypoints = [ ...
            0    0 50  50 100  100 150 150 150
            0    0  0  50  50  100 100 150 150
            0.15 6  6   6   6    6   6   6 0.14];
        max_speed = 2;
        min_speed = 0.1;
        xApproach = [4 1];
        vApproach = 0.1;
        
    case 6
        waypoints = [ ...
            0    0 150 150 150
            0    0 0   150 150
            0.15 6 6   6   0.14];
        max_speed = 2;
        min_speed = 0.1;
        xApproach = [4 1];
        vApproach = 0.1;
end

% Only call the function to calculate target speed and yaw angle if needed
% Paths that define the spline data and yaw angles explictly should not
% define parameter xApproach
if(exist("xApproach","var"))
    if(roundtrip)
        [timespot_spl_re, spline_data_re, spline_yaw_re, ~] = ...
            quadcopter_waypoints_to_trajectory(...
            fliplr(waypoints),max_speed,min_speed,xApproach,vApproach);

        [timespot_spl_to, spline_data_to, spline_yaw_to, wayp_path_vis] = ...
            quadcopter_waypoints_to_trajectory(...
            waypoints,max_speed,min_speed,xApproach,vApproach);
        
        pause_at_target = 5; % sec
        timespot_spl = [timespot_spl_to; timespot_spl_re+timespot_spl_to(end)+pause_at_target];

        spline_data = [spline_data_to;spline_data_re];
        spline_yaw = [spline_yaw_to spline_yaw_re];
        spline_yaw = unwrap(spline_yaw,1.5*pi);
    else
        [timespot_spl, spline_data, spline_yaw, wayp_path_vis] = ...
            quadcopter_waypoints_to_trajectory(...
            waypoints,max_speed,min_speed,xApproach,vApproach);
    end
else
    % Obtain data to visualize path between waypoints
    wayp_path_vis = quadcopter_waypoints_to_path_vis(waypoints);
    if(roundtrip)
        spline_data  = [spline_data; flipud(spline_data)];
        %timespot_spl
        timespot_spl = [timespot_spl; timespot_spl(end)+5; ...
            timespot_spl(end)+5+cumsum(flipud(diff(timespot_spl)))];
        spline_yaw = unwrap([spline_yaw flipud(spline_yaw)+pi],1.5*pi);
    end
end
