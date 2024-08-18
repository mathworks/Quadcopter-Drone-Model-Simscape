function wayp_path_vis = quadcopter_waypoints_to_path_vis(waypoints)

if(~(size(waypoints,2)==3))
    waypoints = waypoints';
end

% Eliminate duplicate, sequential points
diff_waypts = diff(waypoints);
dist_waypts = vecnorm(diff_waypts,2,2);

ind_pts_spl = find(dist_waypts);
wayp_unique = waypoints([1;ind_pts_spl+1],:);

% Calculate unit vector along each segment
wayp_dist   = vecnorm(diff(wayp_unique),2,2);

% Create set of points to visualize linear path between waypoints
wayp_path_vis(1,:) = wayp_unique(1,:);

for i = 1:size(wayp_dist,1)
    wayp_vis_x = linspace(wayp_unique(i,1),wayp_unique(i+1,1),floor(wayp_dist(i))*4);
    wayp_vis_y = linspace(wayp_unique(i,2),wayp_unique(i+1,2),floor(wayp_dist(i))*4);
    wayp_vis_z = linspace(wayp_unique(i,3),wayp_unique(i+1,3),floor(wayp_dist(i))*4);

    wayp_path_vis = [wayp_path_vis;wayp_vis_x(2:end)' wayp_vis_y(2:end)' wayp_vis_z(2:end)'];
end

