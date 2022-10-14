# -*- coding: utf-8 -*-
'''
Created on Thu Jan  4 20:41:45 2018
Modified Feb 2022

@author: hgorr, ydebray
Copyright 2018-2022 The MathWorks, Inc.

'''

# qc_weather.py
import csv
import datetime
import json  
import urllib.request

BASE_URL = 'https://api.openweathermap.org/data/2.5/{}?q={},{}&units={}&appid={}'
FORECAST_KEYS = {'current_time':'DateLocal', 'temp':'T', 'deg':'WindDir',
                 'speed':'WindSpd', 'humidity':'RH', 'pressure':'P'}

def get_current_weather(city, country, apikey,**kwargs):  
    '''get current conditions in specified location
    get_current_weather('boston','us',key,units='metric')'''
            
    info = {'units':'imperial'}     
    for key, value in kwargs.items():
        info[key] = value
    # Read current conditions
    try:
        # url = 'https://api.openweathermap.org/data/2.5/weather?q=Boston,us&appid=11111'
        url = BASE_URL.format('weather',city,country,info['units'],apikey)
        json_data = json.loads(urllib.request.urlopen(url).read())        
    except urllib.error.URLError:
        # If weather API doesnt work, return an error
        print('We cannot access the weather service')  

    return json_data


def parse_current_json(json_data):
    '''parse and extract json data from the current weather data''' 

    try:
        # select data of interest from dictionary
        weather_info = json_data['main']
        weather_info.update(json_data['wind'])
        weather_info.update(json_data['coord'])
        weather_info['city'] = json_data['name']
        # add current date and time
        weather_info['current_time'] = str(datetime.datetime.now())
        # Make sure values are returned as floats
        weather_info['temp'] = float(weather_info['temp'])
        weather_info['feels_like'] = float(weather_info['feels_like'])
        weather_info['temp_min'] = float(weather_info['temp_min'])
        weather_info['temp_max'] = float(weather_info['temp_max'])
        weather_info['pressure'] = float(weather_info['pressure'])
        weather_info['humidity'] = float(weather_info['humidity'])
        weather_info['speed'] = float(weather_info['speed'])
        weather_info['deg'] = float(weather_info['deg'])
        # weather_info['gust'] = float(weather_info['gust'])
        weather_info['lon'] = float(weather_info['lon'])
        weather_info['lat'] = float(weather_info['lat'])

    except KeyError as e:
        # use current dictionary (because it probably came from backup file) 
        try:
            # If this fails then the json_data didn't come from backup file
            json_data.pop('City')
            weather_info = json_data
        except:
            print('Something else went wrong while parsing current json')
            raise e
    
    return weather_info


def get_forecast(city, country, apikey, **kwargs):
    '''get forecast conditions in specified location'''
        
    # include keyword args for numdays=3  and units='metric'    
    info = {'units':'imperial', 'days':5}     
    for key, value in kwargs.items():
        info[key] = value
        
    # get forecast    
    try:
        url = BASE_URL.format('forecast',city,country,info['units'],apikey)
        json_data = json.loads(urllib.request.urlopen(url).read())    
    except: 
        with open('backupforecast.csv', newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            json_data = {'City':city}
            for key in FORECAST_KEYS.keys():
                json_data[key] = []
            for s in [*reader]:
                if s['City'] == city:
                    for key,value in FORECAST_KEYS.items():
                        json_data[key].append(dict(s)[value])
    return json_data

def parse_forecast_json(json_data):
    '''parse and extract json data from the weather forecast data'''     
    
    try:
        # parse forecast json data
        data = json_data['list']
        wind_keys = ['deg','speed']
        weather_info = dict(zip(FORECAST_KEYS.keys(), 
                                [[] for i in range(len(FORECAST_KEYS))]))
        for data_point in data[0:40]:
            for k in list(FORECAST_KEYS.keys())[1:]: #Taking a slice so we don't add the city every time
                weather_info[k].append(float(data_point['wind' if k in wind_keys else 'main'][k]))
            weather_info['current_time'].append(data_point['dt_txt'])
    except KeyError as e:
        # use current dictionary (because it probably came from backup file) 
        try:
            # If this fails then the json_data didn't come from backup file
            json_data.pop('City') 
            weather_info = json_data
        except:
            # print('Something else went wrong while parsing forecast json')
            raise e

    return weather_info


def parse_forecast(json_data):
    import array
    # parse forecast json data
    try:
        data = json_data['list']
        # create arrays
        temp = array.array('f')
        pressure = array.array('f')
        humidity = array.array('f')
        speed = array.array('f')
        deg = array.array('f')
        date = []
        
        # loop over all and add to arrays
        for i in range(40):
            x1 = data[i]
            temp.append(x1['main']['temp'])
            pressure.append(x1['main']['pressure'])
            humidity.append(x1['main']['humidity'])
            speed.append(x1['wind']['speed'])
            deg.append(x1['wind']['deg'])
            date.append(x1['dt_txt'])
                       
        # create dictionary
        weather_info = dict(current_time=date,temp=temp,deg=deg,
                                speed=speed,humidity=humidity,pressure=pressure)         
    except KeyError:
        # use current dictionary 
        try:
            json_data.pop('City')
            weather_info = json_data
        except:
            print('Something else went wrong')
    return weather_info
