function [timespot, spline_data] = quadcopter_define_trajectory(waypoints, v_avg, t_hold)

% waypoints     x-y-z matrix (3 x number of points)
% v_avg         Average speed per segment
% t_hold        Amount of time to wait if waypoint is duplicated

%% Create time vector based on target average speed per segment

% Handle case where copter hovers at a waypoint
v_avg(v_avg==0) = inf;

% Determine distances between waypoints
diff_waypts   = diff(waypoints,1,2);
dist_waypts   = vecnorm(diff_waypts,2,1);

% Determine time duration of each segment based on target speed
delta_t       = max(dist_waypts./v_avg,t_hold);

% Create vector of end times for each segment
timespot      = [0 cumsum(delta_t)];
timespot(end) = timespot(end)+5;

%% Create spline for path visualization
% Remove duplicate waypoints
ind_pts_spl = find(dist_waypts);
spline_waypts = waypoints(:,[1 ind_pts_spl+1]);

% Loop over each segment
spl_x = [];
spl_y = [];
spl_z = [];
for i = 2:size(spline_waypts,2)
    % Evenly space fixed number of points per segment
    numpts = 10;
    spl_x_seg = linspace(spline_waypts(1,(i-1)),spline_waypts(1,i),numpts);
    spl_y_seg = linspace(spline_waypts(2,(i-1)),spline_waypts(2,i),numpts);
    spl_z_seg = linspace(spline_waypts(3,(i-1)),spline_waypts(3,i),numpts);
    
    % Add extra points close to end to minimize spline curvature at corners
    spl_x_seg        = [spl_x_seg(1) spl_x_seg spl_x_seg(end)];
    spl_x_seg(2)     =  spl_x_seg(1)+0.05*(spl_x_seg(3)-spl_x_seg(1));
    spl_x_seg(end-1) =  spl_x_seg(end-2)+0.95*(spl_x_seg(end-1)-spl_x_seg(end-2));
    
    spl_y_seg        = [spl_y_seg(1) spl_y_seg spl_y_seg(end)];
    spl_y_seg(2)     =  spl_y_seg(1)+0.05*(spl_y_seg(3)-spl_y_seg(1));
    spl_y_seg(end-1) =  spl_y_seg(end-2)+0.95*(spl_y_seg(end-1)-spl_y_seg(end-2));
    
    spl_z_seg        = [spl_z_seg(1) spl_z_seg spl_z_seg(end)];
    spl_z_seg(2)     =  spl_z_seg(1)+0.05*(spl_z_seg(3)-spl_z_seg(1));
    spl_z_seg(end-1) =  spl_z_seg(end-2)+0.95*(spl_z_seg(end-1)-spl_z_seg(end-2));
    
    spl_x = [spl_x spl_x_seg];
    spl_y = [spl_y spl_y_seg];
    spl_z = [spl_z spl_z_seg];
    
    % Except for final segment, Remove endpoint to avoid duplication 
    if(i<size(spline_waypts,2))
        spl_x = spl_x(1:end-1);
        spl_y = spl_y(1:end-1);
        spl_z = spl_z(1:end-1);
    end
end

spline_data =[spl_x;spl_y;spl_z]';