from flask import Flask, request, jsonify
import pandas as pd 
import numpy as np
import requests
import pickle
import jsonpickle
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/api", methods=["GET"])
def returnAscii():
    inputchr = str(request.args.get("query"))
    latitude, longitude = inputchr.split('|')
    
    # Debugging prints
    print("Latitude:", latitude)
    print("Longitude:", longitude)

    # Weather API URLs
    weather_api_url = f"http://api.weatherapi.com/v1/current.json?key=ef67efc7ab6d48cd89540707230204&q={latitude},{longitude}&aqi=no"
    openweather_api_url = f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}&appid=2f9acd1647dc42725f32b2808ae1fbb3"
    forecast_api_url = f"http://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longitude}&appid=2f9acd1647dc42725f32b2808ae1fbb3"
    geocode_api_url = f"https://api.opencagedata.com/geocode/v1/json?q={latitude},{longitude}&key=ad68d89e3fb04932819549fd3e22ca24"

    # Fetch data from APIs
    response = requests.get(weather_api_url)
    response2 = requests.get(openweather_api_url)
    responseP = requests.get(geocode_api_url).json()
    print("Geocoding API Response:", responseP) 
    print(weather_api_url)
    print(openweather_api_url)
    print(forecast_api_url)
    print(geocode_api_url)

    # Validate geocoding response
   # if 'results' in responseP and responseP['results']:
     #   place_nameP = responseP['results'][0]['formatted']
     #   city = place_nameP.split(',')[2].split('-')[0].strip()
    #else:
   #     return jsonify({"error": "Location not found."}), 404

    if 'results' in responseP and len(responseP['results']) > 0:
      place_nameP = responseP['results'][0].get('formatted', '')
      if place_nameP:
        parts = place_nameP.split(',')
        if len(parts) >= 3:
            city = parts[2].split('-')[0].strip()
        else:
            city = "Unknown"
      else:
        city = "Unknown"
    else:
       return jsonify({"error": "Location not found."}), 404


    forecastresponse = requests.get(forecast_api_url)

    # Check API responses
    if response.status_code != 200 or response2.status_code != 200 or forecastresponse.status_code != 200:
        return jsonify({"error": "Error fetching data from weather APIs."}), 500

    data = response.json()
    data2 = response2.json()
    forecastdata = forecastresponse.json()

    # Extract relevant weather information
    temperature = data["current"]["temp_c"]
    humidity = data["current"]["humidity"]
    rainfall = data["current"]["precip_mm"]
    visibility = data["current"]["vis_km"]
    windspeed = data["current"]["wind_kph"]
    
    # Process forecast data
    forecasts = []
    for i in range(0, 40, 8):  # Adjust to get every 8th forecast (3 hours apart)
        forecast_entry = forecastdata["list"][i]
        forecasts.append({
            "temperature": forecast_entry["main"]["temp"] - 273.15,
            "humidity": forecast_entry["main"]["humidity"],
            "rainfall": forecast_entry.get("rain", {}).get("3h", 0),
            "visibility": forecast_entry["visibility"],
            "windspeed": forecast_entry["wind"]["speed"]
        })

    # Load model
    with open('random_forest_regression_model1.pkl', 'rb') as f:
        loaded_model = pickle.load(f)
        print("Model file opened successfully.")

    # Prepare input data for prediction
    predictions = []
    for forecast in forecasts:
        input_data = np.array([
            forecast["temperature"],  # Current temperature
            forecast["temperature"],  # Min temperature (use current for simplicity)
            forecast["temperature"],  # Max temperature (use current for simplicity)
            forecast["humidity"],
            forecast["rainfall"],
            forecast["visibility"],
            forecast["windspeed"],
            forecast["windspeed"]  # Placeholder for another windspeed value
        ]).reshape(1, -1)
        prediction = loaded_model.predict(input_data)
        predictions.append(prediction.tolist())

    return jsonify({"city": city, "predictions": predictions})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000,debug=True)
