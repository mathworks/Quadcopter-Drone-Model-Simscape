% Script to check Python settings.

% Assume Python settings do not need to be updated
needToSetPyenv = false;

% Check current settings
info_pyenv = pyenv;
if(~isempty(info_pyenv.Version))
    % If no executable is found, need to update
    needToSetPyenv = true;
elseif(str2num(info_pyenv.Version) < 3.8)
    % If version is "old", need to update
    needToSetPyenv = true;
end

if(needToSetPyenv)
    try
        % Try windows default directory
        pyenv('Version','C:\Windows\py.exe');
    catch
        try
            % Try MATLAB Online setting
            pyenv("Version","/usr/bin/python3");
        end
    end
end
info_pyenv = pyenv;
if(strcmp(info_pyenv.Version,""))
    disp('Python executable not found.')
else
    disp(['Python version: ' char(info_pyenv.Version)]);
end