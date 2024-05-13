


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningTabPage extends StatelessWidget {
  const EarningTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Container(
          color: Colors.black87,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text("Total Earning", style: TextStyle(color: Colors.white),),
                Text("jhgf", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold,fontSize: 30),)
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            //AssistantMethods.retriveHistoryInfo(context);
            //Navigator.push(context, MaterialPageRoute(builder: (context)=> HistoryScreen()));

            // Implement your button action here
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 18.0),
            child: Row(
              children: [
                Image.asset(
                  "images/car_ios.png",
                  width: 70.0,
                ),
                const SizedBox(width: 16.0),
                Text(
                  "Total Journey",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // Dim white color for text
                  ),
                ),
                 Expanded(
                  child: Text(
                    "kgkhg",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black, // Dim white color for text
                    ),
                  ),
                ),
              ],
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.white.withOpacity(0.12), // Text color for pressed state
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Rectangular button with rounded corners
            ),
            shadowColor: Colors.black.withOpacity(0.5), // Shadow color
            elevation: 4.0, // Shadow elevation
          ),
        )



      ],
    );
  }
}
