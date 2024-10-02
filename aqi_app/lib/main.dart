// ignore_for_file: unused_local_variable, unused_import, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Quality Prediction',
      theme: ThemeData(
        fontFamily: 'Gabarito',
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Air Quality Prediction',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: const HomeScreen(),
    );
  }
}

// Model Class for API Response
class ApiResponse {
  final String city;
  final List<double> predictions;

  ApiResponse({required this.city, required this.predictions});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      city: json['city'],
      predictions: List<double>.from(
        json['predictions'].map(
          (prediction) => (prediction[0] as num).toDouble(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double? p1;
  double? p2;
  double? p3;
  double? p4;
  String? place;
  DateTime today = DateTime.now();
  DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  DateTime dat = DateTime.now().add(const Duration(days: 2));
  DateTime dadat = DateTime.now().add(const Duration(days: 3));

  LocationData? _currentPosition;
  Location location = Location();

  // Replace 'YOUR_COMPUTER_IP' with your actual local network IP address
  final String apiBaseUrl = 'http://localhost:5000/api';

  Future<ApiResponse?> fetchData() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("Location services are disabled.");
        return null;
      }
    }

    // Check for location permissions
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Location permissions are denied.");
        return null;
      }
    }

    // Get current location
    _currentPosition = await location.getLocation();

    // Ensure location data is available
    if (_currentPosition == null ||
        _currentPosition!.latitude == null ||
        _currentPosition!.longitude == null) {
      print("Failed to get location data.");
      return null;
    }

    double latitude = _currentPosition!.latitude!;
    double longitude = _currentPosition!.longitude!;
    
    print("Latitude: $latitude, Longitude: $longitude");

    String url = '$apiBaseUrl?query=$latitude|$longitude';

    try {
      final res = await http.get(Uri.parse(url));
      print("API Response: ${res.body}");

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);

        if (jsonResponse.containsKey('error')) {
          print("API Error: ${jsonResponse['error']}");
          return null;
        }

        ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
        return apiResponse;
      } else {
        print("HTTP Error: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception during fetchData: $e");
      return null;
    }
  }

  late TabController tabController;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _tooltip = TooltipBehavior(enable: true);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // Helper method to determine AQI category
  String getAQICategory(double aqi) {
    if (aqi <= 50) {
      return 'Good';
    } else if (aqi <= 100) {
      return 'Moderate';
    } else if (aqi <= 150) {
      return 'Sensitive';
    } else if (aqi <= 200) {
      return 'Unhealthy';
    } else if (aqi <= 300) {
      return 'Very Unhealthy';
    } else {
      return 'Hazardous';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse?>(
      future: fetchData(),
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text(
                  'Hold your breath while I predict air quality...',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Error State
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'An error occurred: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // No Data State
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: const Text(
              'Failed to load data. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Data is successfully fetched and parsed
        ApiResponse apiResponse = snapshot.data!;

        // Assign the prediction values
        p1 = apiResponse.predictions.length > 0 ? apiResponse.predictions[0] : null;
        p2 = apiResponse.predictions.length > 1 ? apiResponse.predictions[1] : null;
        p3 = apiResponse.predictions.length > 2 ? apiResponse.predictions[2] : null;
        p4 = apiResponse.predictions.length > 3 ? apiResponse.predictions[3] : null;
        place = apiResponse.city;

        // Check if predictions are available
        if (p1 == null || p2 == null || p3 == null || p4 == null || place == null) {
          return const Center(
            child: Text(
              'Incomplete data received from the server.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Proceed with building the UI using the fetched data
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Radial Gauge for Current AQI
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: SfRadialGauge(
                    axes: [
                      RadialAxis(
                        minimum: 20,
                        maximum: 200,
                        interval: 10,
                        ranges: [
                          GaugeRange(
                            startWidth: 5,
                            endWidth: 10,
                            startValue: 20,
                            endValue: 80,
                            color: const Color(0xFF79AC78),
                          ),
                          GaugeRange(
                            startWidth: 10,
                            endWidth: 15,
                            startValue: 80,
                            endValue: 160,
                            color: const Color(0xFFF4E869),
                          ),
                          GaugeRange(
                            startWidth: 15,
                            endWidth: 15,
                            startValue: 160,
                            endValue: 200,
                            color: const Color(0xFFFF6969),
                          ),
                        ],
                        pointers: [
                          WidgetPointer(
                            value: p1!,
                            enableAnimation: true,
                            child: Image.asset(
                              'assets/images/air.png',
                              width: 30,
                            ),
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  p1!.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      getAQICategory(p1!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      FontAwesomeIcons.cloud,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            angle: 90,
                            positionFactor: 0.5,
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Line Chart for Predictions
                Container(
                  padding: const EdgeInsets.all(10),
                  child: SfCartesianChart(
                    tooltipBehavior: _tooltip,
                    title: ChartTitle(
                      text: 'Predicted Air Quality Index for $place',
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    series: <ChartSeries>[
                      LineSeries<double, String>(
                        dataSource: [p1!, p2!, p3!, p4!],
                        xValueMapper: (double value, index) {
                          switch (index) {
                            case 0:
                              return DateFormat('EEEE').format(today);
                            case 1:
                              return DateFormat('EEEE').format(tomorrow);
                            case 2:
                              return DateFormat('EEEE').format(dat);
                            case 3:
                              return DateFormat('EEEE').format(dadat);
                            default:
                              return '';
                          }
                        },
                        yValueMapper: (double value, index) => value,
                        color: Colors.green,
                        markerSettings: const MarkerSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
