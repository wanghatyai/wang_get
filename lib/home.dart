import 'package:flutter/material.dart';

import 'package:wang_get/add_product.dart';
import 'package:wang_get/report.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int currentIndex = 0;
  List pages = [AddProductPage(), ReportPage()];

  @override
  Widget build(BuildContext context) {

    Widget bottomNavBar = BottomNavigationBar(
        backgroundColor: Colors.white,
        fixedColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (int index){
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_to_photos),
              title: Text('รับสินค้า', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_list),
              title: Text('รายงาน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
        ]
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("ระบบรับสินค้า"),
        actions: <Widget>[

        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }
}
