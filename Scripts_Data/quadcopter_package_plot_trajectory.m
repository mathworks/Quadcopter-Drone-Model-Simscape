function quadcopter_package_plot_trajectory(waypoints, timespot_spl, spline_data, spline_yaw)
%quadcopter_plot_trajectory Plot planned quadcopter trajectory
%   quadcopter_plot_trajectory(waypoints, timespot_spl, spline_data, spline_yaw)
%   This function plots the target trajectory of the quadcopter.
%  
%       waypoints       Key x-y-z locations the quadcopter will pass through
%       timespot_spl    Times the quadcopter will pass through points along
%                       the spline that defines its path
%       spline_data     Points used for interpolating the spline that
%                       defines the path of the quadcopter
%       spline_yaw      Yaw angle at the spline_data points
%
%   Two plots are produced.  One shows the waypoints and spline data in 3-D
%   space.  The other plots the quadcopter speed and yaw of the trajectory.
%   If the trajectory has sequential, repeated waypoints, the trajectory is
%   plotted versus time.  If there are no sequential, repeated waypoints,
%   the trajectory is plotted versus distance along the trajectory

% Copyright 2021 The MathWorks, Inc.
 
% Transpose if necessary
if(~(size(waypoints,2)==3))
    waypoints = waypoints';
end

% Eliminate duplicate, sequential points
diff_waypts   = diff(waypoints);
dist_waypts   = vecnorm(diff_waypts,2,2);

ind_pts_spl = find(dist_waypts);
wayp_unique = waypoints([1;ind_pts_spl+1],:);

wayp_dist   = vecnorm(diff(wayp_unique),2,2);
cumsum_wayp_dist = [0; cumsum(wayp_dist)];

% Plot path in x-y-z coordinates
% Create figure if figure handled does not exist in MATLAB workspace
fig_handle_name1 =   'h1_waypoints_and_spline_xyz';
handle_var = evalin('base',['who(''' fig_handle_name1 ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
end

figure(evalin('base',fig_handle_name1))
clf(evalin('base',fig_handle_name1))

% Create plot
plot3(wayp_unique(:,1),wayp_unique(:,2),wayp_unique(:,3),'ro','MarkerFaceColor','r','DisplayName','Waypoints')
hold on
plot3(spline_data(:,1),spline_data(:,2),spline_data(:,3),'b-o','DisplayName','Points for Spline')
text(wayp_unique(:,1),wayp_unique(:,2),wayp_unique(:,3),string(1:length(cumsum_wayp_dist)),'HorizontalAlignment','left','VerticalAlignment','bottom')

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

% Plot speed and yaw of trajectory
fig_handle_name1 =   'h1_trajectory_speed_yaw';
handle_var = evalin('base',['who(''' fig_handle_name1 ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name1 ' = figure(''Name'', ''' fig_handle_name1 ''');']);
end

figure(evalin('base',fig_handle_name1))
clf(evalin('base',fig_handle_name1))

% Calculate cumulative distance
diff_spline = diff(spline_data);
dist_spline = vecnorm(diff_spline,2,2);
cum_dist_spline = [0; cumsum(dist_spline)];
target_spd = [0; dist_spline./diff(timespot_spl)];

if(find(dist_spline==0))
    % Sequential spline points are identical
    % Plot trajectory with respect to time
    ah(1) = subplot(211);
    plot(timespot_spl,target_spd,'LineWidth',1,'DisplayName','Speed');
    hold on
    plot(timespot_spl,target_spd,'ro','MarkerFaceColor','r','DisplayName','Waypoints');
    hold off
    text(timespot_spl,target_spd,string(1:length(timespot_spl)),'HorizontalAlignment','left','VerticalAlignment','bottom')
    ylim = get(gca,'YLim');
    set(gca,'YLim',ylim+[-1 1]*0.1*(ylim(2)-ylim(1)));
    title('Target Speed vs. Time')
    ylabel('Distance (m)')
    grid on
    legend('Location','Best')

    ah(2) = subplot(212);
    plot(timespot_spl,spline_yaw*180/pi,'LineWidth',1,'DisplayName','Yaw Angle');
    hold on
    %yaw_at_wayp = interp1(cum_dist_spline,spline_yaw*180/pi,cumsum_wayp_dist);
    plot(timespot_spl,spline_yaw*180/pi,'ro','MarkerFaceColor','r','DisplayName','Waypoints');
    hold off
    text(timespot_spl,spline_yaw*180/pi,string(1:length(timespot_spl)),'HorizontalAlignment','left','VerticalAlignment','bottom')
    ylim = get(gca,'YLim');
    set(gca,'YLim',ylim+[-1 1]*0.1*(ylim(2)-ylim(1)));
    title('Yaw Angle vs. Time')
    xlabel('Time (sec)')
    ylabel('Yaw Angle (deg)')
    legend('Location','Best')
    grid on

else
    % Sequential spline points are identical
    % Plot trajectory with respect to distance
    ah(1) = subplot(211);
    plot(cum_dist_spline,target_spd,'LineWidth',1,'DisplayName','Speed');
    hold on
    spd_at_wp = interp1(cum_dist_spline,target_spd,cumsum_wayp_dist);
    plot(cumsum_wayp_dist,spd_at_wp,'ro','MarkerFaceColor','r','DisplayName','Waypoints');
    hold off
    text(cumsum_wayp_dist,spd_at_wp,string(1:length(cumsum_wayp_dist)),'HorizontalAlignment','left','VerticalAlignment','bottom')
    text(0.05,0.1,['Target Duration: ' sprintf('%2.2f',timespot_spl(end)) ' sec'],'Units','Normalized')
    ylim = get(gca,'YLim');
    set(gca,'YLim',ylim+[-1 1]*0.1*(ylim(2)-ylim(1)));
    title('Target Speed Along Trajectory')
    ylabel('Distance (m)')
    grid on
    legend('Location','Best')

    ah(2) = subplot(212);
    plot(cum_dist_spline,spline_yaw*180/pi,'LineWidth',1,'DisplayName','Yaw Angle');
    hold on
    yaw_at_wayp = interp1(cum_dist_spline,spline_yaw*180/pi,cumsum_wayp_dist);
    plot(cumsum_wayp_dist,yaw_at_wayp,'ro','MarkerFaceColor','r','DisplayName','Waypoints');
    hold off
    text(cumsum_wayp_dist,yaw_at_wayp,string(1:length(cumsum_wayp_dist)),'HorizontalAlignment','left','VerticalAlignment','bottom')
    ylim = get(gca,'YLim');
    set(gca,'YLim',ylim+[-1 1]*0.1*(ylim(2)-ylim(1)));
    title('Yaw Angle Along Trajectory')
    xlabel('Time (sec)')
    ylabel('Yaw Angle (deg)')
    legend('Location','Best')
    grid on
end

linkaxes(ah,'x')

end
