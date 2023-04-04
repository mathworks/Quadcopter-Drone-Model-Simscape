% Add folder with qc_weather.py to Python path
%

% Copyright 2022-2023 The MathWorks, Inc.

pathToAQ = fileparts(which('qc_weather.py'));
if count(py.sys.path,pathToAQ) == 0
    insert(py.sys.path,int32(0),pathToAQ);
end

