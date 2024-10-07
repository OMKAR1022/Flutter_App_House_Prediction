import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
class HomePricePredictor extends StatefulWidget {
  @override
  _HomePricePredictorState createState() => _HomePricePredictorState();
}

class _HomePricePredictorState extends State<HomePricePredictor> {
  List<String> _locations = [];
  String? _selectedLocation;
  final TextEditingController _sqftController = TextEditingController();
  final TextEditingController _bhkController = TextEditingController();
  final TextEditingController _bathController = TextEditingController();
  String? _predictionPrice;

  @override
  void initState() {
    super.initState();
    _fetchLocations();  // Fetch locations when the app starts
  }

  // Function to get locations from the Flask server
  Future<void> _fetchLocations() async {
    final url = Uri.parse('http://127.0.0.1:5000/get_location_names'); // Replace with your Flask server URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _locations = List<String>.from(data['locations']);
      });
    } else {
      print('Failed to fetch locations');
    }
  }

  // Function to predict the home price
  Future<void> _predictPrice() async {
    final url = Uri.parse('http://127.0.0.1:5000/predict_home_price'); // Replace with your Flask server URL
    final response = await http.post(url, body: {
      'total_sqft': _sqftController.text,
      'location': _selectedLocation ?? '',
      'bhk': _bhkController.text,
      'bath': _bathController.text
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _predictionPrice = data['prediction_price'].toString();
      });
    } else {
      print('Failed to predict price');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.cyan,


        title: Text('Bengaluru Home Price Predictor',style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.bold),),
      ),
      body: Scaffold(

        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
          child: Column(
            children: [
              Container(child: Lottie.network('https://lottie.host/100ed979-a8f0-4b9b-897a-69f852d2380d/HvaCXxpphQ.json'),height: 230,width: 400,),
              // Dropdown for location
              DropdownButton<String>(

                elevation: 50,
                isExpanded: true,
                value: _selectedLocation,
                hint: Text('Select Location',style: TextStyle(fontSize: 20),),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                  });
                },
                items: _locations.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    alignment: Alignment.center,
                    value: value,
                    child: Text(value,style: TextStyle(fontSize: 20),),
                  );
                }).toList(),
              ),
              SizedBox(height: 20,),
              TextField(

                controller: _sqftController,
                decoration: InputDecoration(labelText: 'Total Sqft',border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20,),
              TextField(
                controller: _bhkController,
                decoration: InputDecoration(labelText: 'BHK',border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20,),
              TextField(
                controller: _bathController,
                decoration: InputDecoration(labelText: 'Bath',border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predictPrice,
                child: Text('Predict Price'),
              ),
              SizedBox(height: 20),
              _predictionPrice != null
                  ? Text(
                'Predicted Price : ₹$_predictionPrice'' Lakh',

                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),
              )
                  : Container(),
            ],
          ),
        ),
       bottomNavigationBar: BottomNavigationBar( items: const <BottomNavigationBarItem>[
         BottomNavigationBarItem(
           icon: Icon(Icons.home_filled),
           label: 'Home',
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.settings),
           label: 'Setting',
         ),
       ],),
      ),
    );
  }
}

