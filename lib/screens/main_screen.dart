import 'package:car_owner/tab_pages/driver_management_page.dart';
import 'package:car_owner/tab_pages/vehicle_management_screen.dart';
import 'package:car_owner/tab_pages/home_tab.dart';
import 'package:car_owner/tab_pages/profile_tab.dart';
import 'package:car_owner/screens/driver_account_creation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_handler/app_data.dart';
import '../tab_pages/setting.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String idScreen = "mainscreen";

  @override
  State<MainScreen> createState() => _MainScreenState();

  static void changeTab(BuildContext context, int index) {
    final _MainScreenState? state = context.findAncestorStateOfType<_MainScreenState>();
    state?.onItemClicked(index);
  }
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppData languageProvider = Provider.of<AppData>(context);
    var language = languageProvider.isEnglishSelected;
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          CarOwnerHomePage(),
          VehicleManagementPage(),
          DriverManagementPage(),
          ProfilePage(),
          SettingPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: language ? "Home" : "መነሻ ገጽ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              label: language ? "Vehicles" : "ተሽከርካሪዎች"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1_sharp),
              label: language ? "Drivers" : "አሽከርካሪዎች"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: language ? "Account" : "መለያ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: language ? "Setting" : "ቅንብሮች",
          ),
        ],
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.tealAccent,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
