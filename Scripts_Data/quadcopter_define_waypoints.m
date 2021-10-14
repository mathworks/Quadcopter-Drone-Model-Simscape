%% Path 1
waypts_path1 = [ ...
    -2    -2    -2 0 2 5
    -2    -2    -2 0 0 0
     0.15 0.15   6 6 6 1];

segment_speeds_path1 =  [0 0.5 0.15 0.15 0.15];
yaw_traj_path1 = [0 pi/4 pi/4 0 0 0];

 %% Path 2: Move along z, then y, then x
waypts_path2 = [...
    -2   -2    -2  -2  -2 -2  2  2
    -2   -2    -2  -2   2  2  2  2
	0.15  0.15  6   6   6  6  6  6];
segment_speeds_path2 =  [0 0.5 0 0.5 0  0.15 0];
yaw_traj_path2 = [0 0 pi/3 pi/3 pi/3 0 0 0];

 %% Path 3: Increase altitude and hover
waypts_path3 = [...
	-2   -2    -2  -2  -2 -2 -2 -2
    -2   -2    -2  -2  -2 -2 -2 -2
    0.15 0.15   4   4   4  4  4  4];
segment_speeds_path3 =  [0 0.5 0 0 0  0 0];
yaw_traj_path3 = [0 0 pi/4 pi/4 pi/4 0 0 0];

%% Set waypoints and define trajectory
waypoints = waypts_path1;
yaw_traj  = yaw_traj_path1;
[timespot, spline_data] = quadcopter_define_trajectory(waypoints, segment_speeds_path1, 2);
