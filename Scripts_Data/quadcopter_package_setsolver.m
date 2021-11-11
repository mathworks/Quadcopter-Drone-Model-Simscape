function solverBlock_pth = quadcopter_package_setsolver(mdl,deskreal)
% Copyright 2011-2021 The MathWorks, Inc.

desktop_solver = 'ode23t';

realtime_nonlinIter = '2';
realtime_stepSize = '0.01';
realtime_localSolver = 'NE_BACKWARD_EULER_ADVANCER';
realtime_globalSolver = 'ode14x';

solverBlock_pth = find_system(mdl,'FollowLinks','on','LookUnderMasks','on', 'SubClassName', 'solver');

if strcmpi(deskreal,'desktop')
    set_param(mdl,'Solver',desktop_solver);
    for svb_i=1:size(solverBlock_pth,1)
        set_param(char(solverBlock_pth(svb_i)), 'UseLocalSolver','off','DoFixedCost','off');
    end

    % Permit simulation to continue after package has been released
    set_param([mdl '/Quadcopter/Load/Disengage Logic'],'checkbox_stop_release','off')

else
    set_param(mdl,'Solver',realtime_globalSolver,'FixedStep',realtime_stepSize);
    for svb_i=1:size(solverBlock_pth,1)
        set_param(char(solverBlock_pth(svb_i)),...
            'UseLocalSolver','on',...
            'DoFixedCost','on',...
            'MaxNonlinIter',realtime_nonlinIter,...
            'LocalSolverChoice',realtime_localSolver,...
            'LocalSolverSampleTime',realtime_stepSize);
    end

    % Stop simulation once package has been released
    % Contact with ground requires smaller step size for fixed-step solver
    set_param([mdl '/Quadcopter/Load/Disengage Logic'],'checkbox_stop_release','on')
end
