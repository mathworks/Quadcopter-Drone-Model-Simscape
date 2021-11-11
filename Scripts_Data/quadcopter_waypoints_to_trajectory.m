function [timespot_spl, spline_data, spline_yaw] = quadcopter_waypoints_to_trajectory(waypoints,max_speed,min_speed,xApproach,vApproach,varargin)
%quadcopter_waypoints_to_trajectory Generate trajectory for quadcopter 
%   [timespot_spl, spline_data, spline_yaw] = quadcopter_waypoints_to_trajectory(waypoints,max_speed,min_speed,xApproach,vApproach,varargin)
%   This function calculates the key parameters that define the
%   quadcopter's trajectory. To calculate the trajectory you must define
%
%       waypoints       Key x-y-z locations the quadcopter will pass through
%       max_speed       The maximum speed of the quadcopter along the trajectory.
%                       This will be used on straight segments
%       min_speed       The minimum speed of the quadcopter along the trajectory.
%                       This will be used on the sharpest curves
%       xApproach       The distance prior to the final position where 
%                       the quadcopter will slow down.  Provide two
%                       values in meters.  The first value is where the
%                       slowdown will begin, the final is where the
%                       vApproach speed will be reached.
%       vApproach       The speed at which the quadcopter will approach the
%                       final waypoint.
% 
% The function returns
%  
%       timespot_spl    Times the quadcopter will pass through points along
%                       the spline that defines its path
%       spline_data     Points used for interpolating the spline that
%                       defines the path of the quadcopter
%       spline_yaw      Yaw angle at the spline_data points
%
%   The spline data are the set of points that will be used for spline
%   interpolation to define the path of the quadcopter.  This permits the
%   path to curve near the corners.  The curvature of the path is used to
%   derive the speed along the path. The speed along the path is used to
%   calculate the times the quadcopter will pass through the points along
%   the spline.

% Copyright 2021 The MathWorks, Inc.

% If no arguments are passed, plot the trajectory with some assumptions
% about the key parameters.
if (nargin == 0)
    waypoints = evalin('base','waypoints');
    max_speed = 1;
    min_speed = 0.1;
    showplot  = 'plotpath';
    xApproach = [4 0.5];
    vApproach = 0.1;
end

% Determine if plots should be produced
if(nargin>5)
    showplot = varargin(1);
elseif(nargin==5)
    showplot = 'none';
end

% Transpose if necessary
if(~(size(waypoints,2)==3))
    waypoints = waypoints';
end

% Eliminate duplicate, sequential points
diff_waypts   = diff(waypoints);
dist_waypts   = vecnorm(diff_waypts,2,2);

ind_pts_spl = find(dist_waypts);
wayp_unique = waypoints([1;ind_pts_spl+1],:);

% Calculate unit vector along each segment
wayp_dist   = vecnorm(diff(wayp_unique),2,2);
wayp_uvec   = diff(wayp_unique)./wayp_dist;

% Loop over each segment
spl_x = wayp_unique(1,1);
spl_y = wayp_unique(1,2);
spl_z = wayp_unique(1,3);

numpts_per_seg = 6;  % Point for spline for each segment
dist_for_curve = 1;  % Distance before corner to start curve

for i = 2:size(wayp_unique,1)
    % Evenly space fixed number of points per segment
    if(wayp_dist(i-1)<=(dist_for_curve*2))
        % For short segments, evenly space the points along the segment
        % "Short" is less than 2x the distance we leave to curve the path
        % at a corner
        spl_x_seg = linspace(wayp_unique((i-1),1),wayp_unique(i,1),numpts_per_seg+1);
        spl_y_seg = linspace(wayp_unique((i-1),2),wayp_unique(i,2),numpts_per_seg+1);
        spl_z_seg = linspace(wayp_unique((i-1),3),wayp_unique(i,3),numpts_per_seg+1);
        spl_x_seg = spl_x_seg(2:end);
        spl_y_seg = spl_y_seg(2:end);
        spl_z_seg = spl_z_seg(2:end);
    elseif(i == size(wayp_unique,1))
        % For short segments, evenly space the points along the segment
        % "Short" is less than 2x the distance we leave to curve the path
        % at a corner
        spl_x_seg = linspace(wayp_unique((i-1),1),wayp_unique(i,1),numpts_per_seg*2);
        spl_y_seg = linspace(wayp_unique((i-1),2),wayp_unique(i,2),numpts_per_seg*2);
        spl_z_seg = linspace(wayp_unique((i-1),3),wayp_unique(i,3),numpts_per_seg*2);
        spl_x_seg = spl_x_seg(2:end);
        spl_y_seg = spl_y_seg(2:end);
        spl_z_seg = spl_z_seg(2:end);
    else
        % For long segments, evenly place the points on a straight line
        % on a segment in the middle of the segment, leaving space for the
        % curved portion of the path at the corners.
        % "Long" is less than 2x the distance we leave to curve the path
        % at a corner

        % Identify two endpoints for the series of points directly on the
        % line between the two waypoints.
        spl_pta = wayp_unique(i-1,:)+wayp_uvec(i-1,:)*dist_for_curve;
        spl_ptb = wayp_unique(i,:)  -wayp_uvec(i-1,:)*dist_for_curve;

        % Evenly space the points along that segment
        spl_x_seg = [linspace(spl_pta(1),spl_ptb(1),numpts_per_seg) wayp_unique(i,1)];
        spl_y_seg = [linspace(spl_pta(2),spl_ptb(2),numpts_per_seg) wayp_unique(i,2)];
        spl_z_seg = [linspace(spl_pta(3),spl_ptb(3),numpts_per_seg) wayp_unique(i,3)];
    end

    % Add the points from this segment to the end of the line
    spl_x = [spl_x spl_x_seg];
    spl_y = [spl_y spl_y_seg];
    spl_z = [spl_z spl_z_seg];
end

spline_data =[spl_x;spl_y;spl_z]';

% Remove any sequentially duplicate points
% Find distance between points
diff_spline = diff(spline_data);
dist_spline = vecnorm(diff_spline,2,2);
% Remove points where distance between points is zero
ind_pts_spl = find(dist_spline);
spl_unique  = spline_data([1;ind_pts_spl+1],:);
spline_data = spl_unique;

% Calculate cumulative distance for interpolation
cum_dist_spline = [0; cumsum(dist_spline)];

spline_yaw = atan2(diff(spl_y),diff(spl_x));

spline_yaw = [spline_yaw(1) spline_yaw];

% Create points along path using interpolation
% Points will be used to determine curvature, which is needed for target speed
points_per_meter = 4;
numpts_for_path = ceil(max(cum_dist_spline)*points_per_meter); % Points roughly every 0.1 m
x_ctr = interp1(cum_dist_spline,spline_data(:,1),linspace(0,cum_dist_spline(end),numpts_for_path),'spline');
y_ctr = interp1(cum_dist_spline,spline_data(:,2),linspace(0,cum_dist_spline(end),numpts_for_path),'spline');
z_ctr = interp1(cum_dist_spline,spline_data(:,3),linspace(0,cum_dist_spline(end),numpts_for_path),'spline');

% Plot waypoints, points for spline, and path of spline
if(contains(showplot,'plot'))
    % Plot Results
    fig_handle_name1 =   'h1_waypoints_to_spline';

    handle_var = evalin('base',['who(''' fig_handle_name1 ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    end

    figure(evalin('base',fig_handle_name1))
    clf(evalin('base',fig_handle_name1))

    plot3(wayp_unique(:,1),wayp_unique(:,2),wayp_unique(:,3),'ro','MarkerFaceColor','r','DisplayName','Waypoints')
    hold on
    plot3(spline_data(:,1),spline_data(:,2),spline_data(:,3),'b-o','DisplayName','Points for Spline')
    plot3(x_ctr,y_ctr,z_ctr,'co','MarkerSize',3,'MarkerFaceColor','c','DisplayName','Interpolated path')
    hold off
    axis equal
    box on
    grid on
    ah = gca;
    ah.Clipping = 'off';
    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('z (m)')
    title('Points for Trajectory')
    legend('Location','Best')

    fig_handle_name1 =   'h1_waypoints_to_yaw';

    handle_var = evalin('base',['who(''' fig_handle_name1 ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    end

    figure(evalin('base',fig_handle_name1))
    clf(evalin('base',fig_handle_name1))

    plot(cum_dist_spline,spline_yaw);
    title('Yaw Angle Trajectory')
    xlabel('Distance Along Trajectory (m)')
    ylabel('Yaw Angle (rad)')
    grid on

end

%% Custom formula to determine target speed based on curvature.
% 1. Curvature is angle between current point and next point
% 2. Moving average used to reduce noise (function smooth())
% 3. Speed scaled to maximum speed at minimum curvature,
%    min speed at maximum curvature.
% 4. Exponential on curvature to reduce speed more at higher curvature
% 5. Additional smoothing applied at max speeds using min()

% Recalculate distances assuming straight line
pth_ctr     = [x_ctr' y_ctr' z_ctr'];
diff_s_ctr  = diff(pth_ctr);
dist_s_ctr  = vecnorm(diff_s_ctr,2,2);
s_ctr       = [0; cumsum(dist_s_ctr)];

% Determine angle between points along path
%path_pts = [x_ctr' y_ctr' z_ctr'];
path_ctr_vec = pth_ctr-circshift(pth_ctr,1,1);
path_ctr_vec(1,:) = path_ctr_vec(2,:);

% Determine angle between consecutive segments
path_ctr_ang = acos(min(dot(path_ctr_vec',circshift(path_ctr_vec,1,1)')./(vecnorm(path_ctr_vec').*vecnorm(circshift(path_ctr_vec,1,1)')),1));
path_ctr_ang(1) = 0;

aYaw_ctr = path_ctr_ang;
yaw4curvature = [aYaw_ctr(2) aYaw_ctr(2:end-1) aYaw_ctr(end-1) aYaw_ctr(end-1)];

% Coefficients for custom formula to calculate target speed
traj_coeff.diff_exp       = 1.1;    % Curvature exponent
traj_coeff.diff_smooth    = points_per_meter*2;     % Diff smoothing number of points
traj_coeff.curv_smooth    = points_per_meter*2;    % Curvature smoothing number of points
traj_coeff.lim_smooth     = points_per_meter*2;    % Limit smoothing number of points
traj_coeff.target_shape_smooth = points_per_meter*2;  % Number of points for smoothing
traj_coeff.vmax           = max_speed;   % Max speed, m/s
traj_coeff.vmin           = min_speed;    % Min speed, m/s
traj_coeff.decimation     = 4;      % Decimation for interpolation

d_e = traj_coeff.diff_exp;  % Curvature exponent
d_s = traj_coeff.diff_smooth;   % Diff smoothing number of points
c_s = traj_coeff.curv_smooth;   % Curvature smoothing number of points

% Get shape for target speed trajectory
curv4spd_raw   = abs(smooth(diff(yaw4curvature),d_s));
curv4spd_unit  = curv4spd_raw/max(curv4spd_raw);
curv4spd       = smooth(curv4spd_unit,c_s).^d_e;
tgt_spd_shape  = ones(size(curv4spd))-curv4spd;

% Use smoothing to generate limit for max speed
lim_s = traj_coeff.lim_smooth;
lim_spd_shape  = smooth(tgt_spd_shape,lim_s);

% Limit max speed
tgt_spd_shape_lim = min([tgt_spd_shape lim_spd_shape],[],2);

% Smooth limited shape curve
tgta_s = traj_coeff.target_shape_smooth;  % Number of points for smoothing
tgt_spd_smootha = smooth(tgt_spd_shape_lim,tgta_s);

% Scale curve to maximum and minimum speeds
s_mx = traj_coeff.vmax;   % Max speed, m/s
s_mn = traj_coeff.vmin;   % Min speed, m/s
tgt_spd_smooth_0 = tgt_spd_smootha-min(tgt_spd_smootha);
tgt_spd_smooth_1 = tgt_spd_smooth_0/max(tgt_spd_smooth_0);
tgt_spd_smooth   = tgt_spd_smooth_1*(s_mx-s_mn)+s_mn;

% Ramp down final speed
inds_final2 = find(s_ctr<(s_ctr(end)-xApproach(1)));
inds_final1 = find(s_ctr<(s_ctr(end)-xApproach(2)));
if(~isempty(inds_final2)&&~isempty(inds_final1))
    ind_final2 = inds_final2(end);
    ind_final1 = inds_final1(end);

    if(ind_final2<ind_final1)
        % Use spline interpolation to ramp down final speed
        tgt_spd_smooth(inds_final2(end):inds_final1(end)) = ...
            interp1([ind_final2-1 ind_final2 ind_final1-1 ind_final1],[tgt_spd_smooth(ind_final2-1:ind_final2)' vApproach vApproach],[ind_final2:1:ind_final1],'spline');
        tgt_spd_smooth(ind_final1:end)= 0.1;
    end
end

% Ramp up initial speed
inds_init1 = find(s_ctr>1);
ind_init1 = inds_init1(1);
tgt_spd_smooth(1:ind_init1) = ...
    linspace(0,tgt_spd_smooth(ind_init1),ind_init1);

% Obtain target speeds at path points
delta_t = [0 ;diff(s_ctr)./tgt_spd_smooth(2:end)];
timespot = cumsum(delta_t)';

% Obtain target speeds at spline points
% Avoid overshoot using pchip
spd4delta_t = interp1(s_ctr,tgt_spd_smooth,cum_dist_spline,'pchip');
delta_t_spl = [0; diff(cum_dist_spline)./spd4delta_t(2:end)];
timespot_spl = cumsum(delta_t_spl);

%% Plot target speed
if(strcmpi(showplot,'plot'))
    % Plot Results
    fig_handle_name1 =   'h1_waypoints_to_target_speed';

    handle_var = evalin('base',['who(''' fig_handle_name1 ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    end

    figure(evalin('base',fig_handle_name1))
    clf(evalin('base',fig_handle_name1))

    ax_h(1) = subplot(311);
    plot(s_ctr,aYaw_ctr,'LineWidth',1);
    title('Trajectory Angle');
    xlabel('Distance Traveled (m)');

    ax_h(2) = subplot(312);
    plot(s_ctr,abs(diff(yaw4curvature)),'LineWidth',1);
    hold on
    plot(s_ctr,abs(curv4spd),'--','LineWidth',1);
    hold off
    title('Trajectory Curvature');
    legend({'Raw','Smoothed'},'Location','Best');
    xlabel('Distance Traveled (m)');

    ax_h(3) = subplot(313);
    plot(s_ctr,tgt_spd_shape*s_mx);
    hold on
    plot(s_ctr,tgt_spd_shape_lim*s_mx,'--');
    plot(s_ctr,tgt_spd_smooth,'LineWidth',1);
    hold off
    title('Target Speed');
    legend({'Shape','Limited','Target'},'Location','Best');
    set(gca,'YLim',[0 1.1*s_mx]);
    xlabel('Distance Traveled (m)');

    linkaxes(ax_h,'x');

    % Plot Results
    fig_handle_name1 =   'h2_waypoints_to_target_speed';

    handle_var = evalin('base',['who(''' fig_handle_name1 ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
    end

    figure(evalin('base',fig_handle_name1))
    clf(evalin('base',fig_handle_name1))
    plot(s_ctr,tgt_spd_smooth,'-o','DisplayName','Speed from path');
    hold on
    plot(cum_dist_spline,spd4delta_t,'-x','DisplayName','Speed from spline points');
    hold off
    grid on
    xlabel('Distance Along Trajectory (m)')
    ylabel('Speed (m/s)')
    title('Target Speed Along Trajectory')
end

% Return waypoints matrix to have points as columns
% (Only needed for interactive testing)
if((size(waypoints,2)==3))
    waypoints = waypoints';
end


