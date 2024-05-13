import 'package:car_owner/tab_pages/earnings_tab.dart';
import 'package:car_owner/tab_pages/home_tab.dart';
import 'package:car_owner/tab_pages/profile_tab.dart';
import 'package:car_owner/tab_pages/driver_account_creation.dart';
import 'package:flutter/material.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String idScreen = "mainscreen";


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
  TabController? tabController;
  int selectedIndex=0;
  void onItemClicked(int index)
  {setState(() {
    selectedIndex=index;
    tabController!.index=selectedIndex;
  });

  }


  @override
  void initState() {


    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController!.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          CarOwnerHomePage(),
          EarningTabPage(),
          DriverRegistrationForm(),
          CarOwnerProfilePage()

        ],


      ),

      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home),
          label: "Home"
          ),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card),
              label: "Earnings"
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star),
              label: "Rating"
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person),
              label: "Account"
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
