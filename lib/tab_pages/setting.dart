import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_handler/app_data.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10, // Use theme color
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Back button
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          appData.isEnglishSelected ? 'Profile' : 'ፕሮፋይል',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold, // Bold title
           // White text for dark app bar
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text with heading style and slight margin
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                appData.isEnglishSelected ? 'Language:' : 'ቋንቋ:',
                style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.bold, // Bold heading
                ),
              ),
            ),
            // Setting with background container and rounded corners
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[500], // Light background color
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appData.isEnglishSelected ? 'English' : 'አማርኛ',
                    style: const TextStyle(fontSize: 16.0), // Adjust text size
                  ),
                  Switch.adaptive(
                    value: appData.isEnglishSelected,
                    onChanged: (value) => appData.toggleLanguage(value),
                    activeTrackColor: Theme.of(context).primaryColor,
                    activeColor: Colors.white,
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1.0), // Add a divider for separation
            const SizedBox(height: 20.0),

            // Theme mode toggle


            const Divider(thickness: 1.0), // Add a divider for separation
            const SizedBox(height: 20.0),

            // Additional content sections with headings, spacing, and backgrounds

            const SizedBox(height: 10.0),
            // Add information about your app or company
          ],
        ),
      ),
    );
  }
}
