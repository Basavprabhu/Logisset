import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logisset/Screens/historypage.dart';
import 'package:logisset/Screens/homepage.dart';
import 'package:logisset/Screens/scanpage.dart';
import 'package:logisset/Screens/studentpage.dart';
import 'package:logisset/Screens/userpage.dart';

class StudentMainPageView extends StatefulWidget {
  const StudentMainPageView({super.key});

  @override
  State<StudentMainPageView> createState() => _StudentMainPageViewState();
}

class _StudentMainPageViewState extends State<StudentMainPageView> {
  List pages = [
    StudentPage(),
  
  
    UserScreen(),
  ];

  int currentIndex = 0;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.redAccent,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Profile',
            backgroundColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
