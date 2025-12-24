%% Quadcopter Package Delivery, Weather Conditions
% 
% This example shows how weather conditions can be obtained from the online
% weather service OpenWeather.  A Python script is called from within
% MATLAB to obtain weather for a specific location, either current
% conditions or a forecast for the next 5 days.
%
% The Python module reads and parses current weather data from the web API:
% https://openweathermap.org/api
%
% Copyright 2022-2025 The MathWorks, Inc.



%% Forecasted Wind Speed for Boston

wind_spd = quadcopter_drone_get_weather('Boston','forecast','showplot');


%% Current Weather Conditions for Boston
%

[wind_spd, weather_now]= quadcopter_drone_get_weather('Boston');

weather_now

%%

close all
bdclose all