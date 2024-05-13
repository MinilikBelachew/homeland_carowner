import 'package:flutter/material.dart';
class CarDetail {
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController bodyTypeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
}

class CarDetailCard extends StatelessWidget {
  final CarDetail carDetail;
  final int index;

  const CarDetailCard({required this.carDetail, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: true,

      body:
      SingleChildScrollView(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
              children: [
                Text(
                  'Car $index Details',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Icon(Icons.directions_car),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: carDetail.makeController,
                        decoration: InputDecoration(labelText: 'Make'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Icon(Icons.model_training_outlined),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: carDetail.modelController,
                        decoration: InputDecoration(labelText: 'Model'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: carDetail.yearController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Year'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Icon(Icons.all_inclusive_rounded),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: carDetail.plateNumberController,
                        decoration: InputDecoration(labelText: 'Plate Number'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Icon(Icons.directions_car_filled),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: carDetail.bodyTypeController,
                        decoration: InputDecoration(labelText: 'Body Type'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Icon(Icons.color_lens),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: carDetail.colorController,
                        decoration: InputDecoration(labelText: 'Color'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
