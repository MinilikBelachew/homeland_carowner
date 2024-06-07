import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_owner/config_maps.dart'; // Assuming this is your configuration file

class VehicleManagementPage extends StatefulWidget {
  @override
  _VehicleManagementPageState createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage>
    with AutomaticKeepAliveClientMixin {
  final DatabaseReference carsRef = FirebaseDatabase.instance
      .ref()
      .child('car_owners')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child('cars');
  List<Map<String, dynamic>> carsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    setState(() {
      _isLoading = true;
    });
    try {
      DatabaseEvent event = await carsRef.once();
      if (event.snapshot.value != null) {
        setState(() {
          carsList = (event.snapshot.value as Map<dynamic, dynamic>)
              .entries
              .map((entry) {
            return Map<String, dynamic>.from(entry.value)..['key'] = entry.key;
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No cars found'),
          backgroundColor: Colors.orange,
        ));
      }
    } catch (e) {
      print('Error fetching cars: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching cars: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> updateCar(Map<String, dynamic> carData, String carKey) async {
    await carsRef.child(carKey).update(carData);
    fetchCars();
  }

  Future<void> addCar(Map<String, dynamic> carData) async {
    await carsRef.push().set(carData);
    fetchCars();
  }

  Future<void> deleteCar(String carKey) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this car?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await carsRef.child(carKey).remove();
      fetchCars();
    }
  }

  void _showEditCarDialog({Map<String, dynamic>? carData, String? carKey}) {
    final isUpdating = carData != null && carKey != null;
    final makeController = TextEditingController(text: carData?['make'] ?? '');
    final modelController =
    TextEditingController(text: carData?['model'] ?? '');
    final yearController = TextEditingController(text: carData?['year'] ?? '');
    final plateNumberController =
    TextEditingController(text: carData?['plateNumber'] ?? '');
    final bodyTypeController =
    TextEditingController(text: carData?['bodyType'] ?? '');
    final colorController =
    TextEditingController(text: carData?['color'] ?? '');
    String truckType = carData?['truckType'] ?? 'light trucks';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdating ? 'Update Car Details' : 'Add New Car'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: makeController,
                decoration: InputDecoration(labelText: 'Make'),
              ),
              TextField(
                controller: modelController,
                decoration: InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: plateNumberController,
                decoration: InputDecoration(labelText: 'Plate Number'),
              ),
              TextField(
                controller: bodyTypeController,
                decoration: InputDecoration(labelText: 'Body Type'),
              ),
              TextField(
                controller: colorController,
                decoration: InputDecoration(labelText: 'Color'),
              ),
              DropdownButtonFormField<String>(
                value: truckType,
                decoration: InputDecoration(labelText: 'Truck Type'),
                items: [
                  DropdownMenuItem(value: 'light trucks', child: Text('Light Trucks')),
                  DropdownMenuItem(value: 'medium trucks', child: Text('Medium Trucks')),
                  DropdownMenuItem(value: 'heavy trucks', child: Text('Heavy Trucks')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    truckType = value;
                  }
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final make = makeController.text.trim();
              final model = modelController.text.trim();
              final year = yearController.text.trim();
              final plateNumber = plateNumberController.text.trim();
              final bodyType = bodyTypeController.text.trim();
              final color = colorController.text.trim();

              if (make.isEmpty ||
                  model.isEmpty ||
                  year.isEmpty ||
                  plateNumber.isEmpty ||
                  bodyType.isEmpty ||
                  color.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please fill in all required fields'),
                  backgroundColor: Colors.red,
                ));
                return;
              }

              final updatedCarData = {
                'make': make,
                'model': model,
                'year': year,
                'plateNumber': plateNumber,
                'bodyType': bodyType,
                'color': color,
                'truckType': truckType,
              };

              if (isUpdating) {
                updateCar(updatedCarData, carKey!);
              } else {
                addCar(updatedCarData);
              }

              Navigator.pop(context);
            },
            child: Text(isUpdating ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Management'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchCars,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey[200]!, Colors.blueGrey[100]!],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : carsList.isEmpty
            ? Center(
          child: Text(
            'No vehicles found',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
        )
            : ListView.builder(
          itemCount: carsList.length,
          itemBuilder: (context, index) {
            final car = carsList[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal[100]!, Colors.teal[50]!],
                  ),
                ),
                child: ListTile(
                  title: Text('${car['make']} ${car['model']}'),
                  subtitle: Text(
                      'Year: ${car['year']}, Plate: ${car['plateNumber']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditCarDialog(
                            carData: car, carKey: car['key']),
                      ),
                      SizedBox(
                          width: 8), // Adjust spacing between buttons
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteCar(car['key']),
                        color: Colors.red, // Set the color to red
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditCarDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
