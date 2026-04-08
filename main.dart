import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "";
  String temperature = "";
  String condition = "";
  bool isLoading = false;
  String error = "";

  Future<void> getWeather() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final response = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=YOUR_API_KEY&units=metric"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          temperature = data['main']['temp'].toString();
          condition = data['weather'][0]['main'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "City not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Something went wrong";
        isLoading = false;
      });
    }
  }

  Color getBackgroundColor() {
    if (condition.toLowerCase().contains("cloud")) {
      return Colors.grey;
    } else if (condition.toLowerCase().contains("rain")) {
      return Colors.blueGrey;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Enter City",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                city = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getWeather,
              child: const Text("Get Weather"),
            ),
            const SizedBox(height: 20),

            if (isLoading) const CircularProgressIndicator(),

            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),

            if (temperature.isNotEmpty)
              Column(
                children: [
                  Text(
                    "$temperature °C",
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    condition,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
