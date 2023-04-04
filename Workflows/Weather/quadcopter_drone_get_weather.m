function [wind_spd, weather_data] = quadcopter_drone_get_weather(location,varargin)
%quadcopter_drone_get_weather  Get weather data from specific cities
%  [wind_spd, weather_data] = quadcopter_drone_get_weather(location, <dataset>, <showplot>)
%
%  This function returns weather data for locations available in the
%  OpenWeather online service.  You can request data for Dublin, Boston, or
%  Centerville.  The function returns
%
%       wind_spd      Wind speed in meters/sec
%       weather_data  Full set of weather data supplied by OpenWeather
%
%   You can request
%       dataset = 'current'     Current conditions only
%       dataset = 'forecast'    Forecast for the next 5 days
%
%   If you request a forecast, setting showplot to 'showplot' will plot the
%   wind speed data for the next 5 days.
%
%   wind_spd = quadcopter_drone_get_weather('Boston','forecast','showplot');

% Copyright 2022-2023 The MathWorks, Inc.

dataset  = 'current';
plotdata = 'noplot';
if(nargin>1)
    dataset  = varargin{1};
end

if(nargin>2)
    plotdata = varargin{2};
end

qc_Set_Python_Path;
apikey = readtable("Open_Weather_AccessKey.txt","TextType","string");

switch lower(location)
    case 'dublin',       arg1 = "Dublin";      arg2 = "IE";
    case 'centerville',  arg1 = "Centerville"; arg2 = "US";
    case 'boston',       arg1 = "Boston";      arg2 = "US";
    otherwise            arg1 = "Boston";      arg2 = "US";
end

if(strcmpi(dataset,'current'))
    jsonData = py.qc_weather.get_current_weather(arg1,arg2,apikey.Key,pyargs('units','metric'));
    weatherData = py.qc_weather.parse_current_json(jsonData);
    weather_data = struct(weatherData);

    if (isfield(weather_data,'speed'))
        wind_spd = weather_data.speed;
    else
        wind_spd = 10;
    end

else % forecast
    jsonData      = py.qc_weather.get_forecast(arg1,arg2,apikey.Key,pyargs('units','metric'));
    weatherData   = py.qc_weather.parse_forecast(jsonData);
    weatherStruct = struct(weatherData);
    wind_spd      = double(weatherStruct.speed);
    foreTime      = cell(weatherStruct.current_time);
    T             = cellfun(@string,foreTime);
    time          = datetime(T);

    if(strcmpi(plotdata,'showplot'))
        % Create/Reuse figure and define handle in workspace
        fig_handle_name =   'h6_quadcopter_drone_get_weather';

        handle_var = evalin('base',['who(''' fig_handle_name ''')']);
        if(isempty(handle_var))
            evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
        elseif ~isgraphics(evalin('base',handle_var{:}))
            evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
        end
        figure(evalin('base',fig_handle_name))
        clf(evalin('base',fig_handle_name))

        plot(time,wind_spd,'LineWidth',2);
        grid on
        ylabel('Speed (m/s)')
        title(['Wind Speed in ' char(arg1) ', ' char(arg2)]);
    end
end