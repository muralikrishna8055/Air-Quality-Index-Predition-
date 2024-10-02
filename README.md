# Air Quality Index Predition Using Deep Learning with Weather API Integration

![1](https://github.com/Vishnu-Priya0607/Air-Quality-Index-Predition-Using-Deep-Learning/assets/119881668/16408a08-d605-437c-8f20-b583d0126770)           ![2](https://github.com/Vishnu-Priya0607/Air-Quality-Index-Predition-Using-Deep-Learning/assets/119881668/630d07b0-2ce5-4f4a-8112-87632e1e108a)



Air quality index is an index for reporting air quality on a daily basis. it is a measure of how air pollution affects one’s health within a short time period. The AQI is calculated based on the average concentration of a particular pollutant measured over a standard time interval. The primary goal is to predict AQI, since the class label is continuous regression is used. The regression technique used is random forest regression. This project introduces a system for Air Quality Index (AQI) prediction that leverages deep learning in combination with real-time weather data sourced from APIs.  Key features of the system include the integration of weather data through a dedicated API. Parameters such as temperature, humidity, wind speed, and more are collected, as these elements significantly influence air quality. The system's core component is a deep learning model that undergoes training using historical data and the newly acquired meteorological parameters. To ensure personalized and location-specific AQI predictions, the system automatically retrieving the user's location. This feature allows the system to tailor its forecasts to the unique conditions of each area. In addition to real-time AQI predictions, the system offers the capability to forecast AQI for the next four days helping users to plan outdoor activities and make decisions based on projected air quality trends.

# PROPOSED SYSTEM
The proposed system in this project aims to develop a simple and user-friendly Air Quality Index (AQI) prediction model. It combines machine learning techniques, particularly Random Forest Regression, with meteorological factors to predict AQI levels. Additionally, the project involves the creation of a mobile-based application, with a Flask backend and a Flutter front-end, to provide users with easy access to real-time AQI predictions and historical air quality data.

# FEATURES OF PROPOSED SYSTEM
The system automatically fetches the user's location, ensuring that AQI predictions are made particularly to the specific geographic area in which the user is located. The system integrates with meteorological data sources through APIs, obtaining real-time data on factors such as temperature, humidity, rainfall, visibility, and wind speed. A machine learning model, specifically Random Forest Regression, is employed to predict AQI levels based on the combined data from meteorological sources and historical air quality data.

# FUNCTIONS OF PROPOSED SYSTEM
1. Automatic Location Retrieval: The system automatically identifies the user's location using the device's geolocation capabilities.
2.  Meteorological Data Retrieval: It fetches real-time meteorological data,including temperature, humidity, rainfall, visibility, and wind speed, from external APIs.
3.  AQI Prediction: The system employs a Random Forest Regression model to predict AQI levels based on both user location and meteorological data.
4.  AQI forecast: The system predicts AQI for the next 3 days providing user better understanding.
5.  User Interface: Through the Flutter-based front-end, the system provides users with an intuitive interface to access AQI predictions.

# Tools used 🛠️
1. Language: Python 3.9, Dart
2. Framework: Flutter
3. IDE: VS Code
4. Libraries Used: NumPy, Flask, Pandas, Scikit-learn
5. OpenWeatherMap API

# Steps to run ⚙️
1. Open AndroidStudio, in the *aqi_server* folder
2. Create a virtual environment
   ```
   python-m venv venv
   ```
   ```
   venv\Scripts\Activate
   ```
3. Run this command
   ```
   flask run
   ```
4. Locate in *aqi_app*, then run this command
   ```
   flutter run
   ```
