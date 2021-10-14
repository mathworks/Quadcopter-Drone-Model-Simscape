% Shutdown script for custom project
% Copyright 2019-2021 The MathWorks, Inc.

%% Code for cleaning Simscape custom library at shutdown
% Change to folder with package directory
curr_proj = simulinkproject;
cd(curr_proj.RootFolder)
cd('Libraries')

% Clean custom library
if(exist('+MyResistor','dir') && exist('MyResistor_lib.slx','file'))
    ssc_clean MyResistor
end

% Change to root folder
cd(curr_proj.RootFolder)

