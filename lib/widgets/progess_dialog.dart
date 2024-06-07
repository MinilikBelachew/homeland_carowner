// import "package:flutter/material.dart";
// class ProgressDialog extends StatelessWidget {
//   //ProgressDialog({super.key});
//
//   String message;
//   ProgressDialog({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.tealAccent,
//       child: Container(
//         margin: EdgeInsets.all(15),
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(6)
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(15),
//           child: Row(
//             children: [
//               SizedBox(width: 6,),
//               CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),),
//               SizedBox(width: 26,),
//               Text(message,
//               style: TextStyle(color: Colors.black,fontSize: 15),)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;

  const ProgressDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor, // Use theme color
      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Content doesn't expand the dialog
          children: [
            const SizedBox(width: 10.0), // Spacing before indicator
            const CircularProgressIndicator(), // Use default style
            const SizedBox(width: 20.0), // Spacing after indicator
            Text(message, style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color)), // Use theme text color
          ],
        ),
      ),
    );
  }
}

