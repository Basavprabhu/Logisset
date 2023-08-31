import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:logisset/auth/login.dart';

import 'functions/descriptionpage.dart';
import 'functions/detailspage.dart';
import 'functions/reviewdisplay.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  late DatabaseReference _databaseRef;
  List<Map<dynamic, dynamic>> subNodeList = [];

  // Variables to handle search and sorting
  String searchQuery = '';
  String sortBy = 'none'; // Default sorting by none

  // Variables to handle animated transitions
  String? selectedGroup;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Future<void> _logout(BuildContext context) async {
  //   try {
  //     await _auth.signOut();
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //   } catch (e) {
  //     print('Error during logout: $e');
  //     // Handle error, show a message to the user, etc.
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // Get a reference to the root node of your Realtime Database
    _databaseRef = FirebaseDatabase.instance.ref().child('assets');

    // Listen for changes in the database
    _databaseRef.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        // Clear the existing subNodeList
        subNodeList.clear();

        // Extract the data from the snapshot
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        // Loop through each main collection (AECLAB, CSLAB, etc.)
        data.forEach((mainCollectionKey, mainCollectionData) {
          // Loop through the subnodes in the main collection
          mainCollectionData.forEach((subNodeKey, subNodeData) {
            // Check if the subnode is active
            if (subNodeData['active'] == true) {
              // Create a new subnode map with subnode key, data, and address
              Map<dynamic, dynamic> subNode = {
                'subNodeKey': subNodeKey,
                'subNodeData': subNodeData,
                'address': mainCollectionKey,
              };

              // Add the subnode to the subNodeList
              subNodeList.add(subNode);
            }
          });
        });

        // Sort the subNodeList based on RSSI value in ascending order
        subNodeList.sort((a, b) => int.parse(a['subNodeData']['rssi'])
            .compareTo(int.parse(b['subNodeData']['rssi'])));

        // If there are multiple subnodes with the same name, keep the one with the smallest RSSI value
        Map<String, Map<dynamic, dynamic>> subNodesMap = {};
        subNodeList.forEach((subNode) {
          String name = subNode['subNodeData']['name'];
          int rssi = int.parse(subNode['subNodeData']['rssi']);
          if (!subNodesMap.containsKey(name) ||
              rssi < int.parse(subNodesMap[name]!['subNodeData']['rssi'])) {
            subNodesMap[name] = subNode;
          }
        });
        subNodeList = subNodesMap.values.toList();

        // Update the widget with new data
        setState(() {});
      }
    });
  }

  Future<void> _openDetailsPage(String assetName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(assetName),
      ),
    );
  }

  Card _buildAssetTile(Map<dynamic, dynamic> subNode) {
    String name = subNode['subNodeData']['name'].toString();
    String address = subNode['address'].toString();

    return Card(
      child: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('asset_descriptions')
                .doc(name) // Assuming the document ID is the asset name
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading asset data');
              } else if (snapshot.hasData && snapshot.data!.exists) {
                String assetType = snapshot.data!['assetType'] ?? 'N/A';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(' ${assetType.toUpperCase()}',
                      style: GoogleFonts.lora(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text('NAME: $name',
                      style: GoogleFonts.lora(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                );
              }
            },
          ),
          CustomPaint(
            size: Size(250, 0.5),
            painter: LinePainter(),
          ),
          Row(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 30),
                    child: Text('ADDRESS: $address\n',
                        style: GoogleFonts.teko(
                            fontSize: 20,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500)),
                  ),
                  TextButton(
                    onPressed: () async {
                      String labAddress = subNode['address'].toString();
                      String userEmail =
                          FirebaseAuth.instance.currentUser?.email ?? '';

                      QuerySnapshot labAssistantsSnapshot =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .where('lab', isEqualTo: labAddress)
                              .get();

                      if (labAssistantsSnapshot.docs.isNotEmpty) {
                        final labAssistantData =
                            labAssistantsSnapshot.docs.first.data();

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Lab Assistant Information'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'First Name: ${labAssistantData is Map ? labAssistantData['first_name'] ?? 'N/A' : 'N/A'}'),
                                  Text(
                                      'Last Name: ${labAssistantData is Map ? labAssistantData['last_name'] ?? 'N/A' : 'N/A'}'),
                                  Text(
                                      'Qualification: ${labAssistantData is Map ? labAssistantData['qualification'] ?? 'N/A' : 'N/A'}'),
                                  Text(
                                      'Department: ${labAssistantData is Map ? labAssistantData['department'] ?? 'N/A' : 'N/A'}'),
                                  Text('Lab: $labAddress'),
                                  Text('Email: $userEmail'),
                                  Text(
                                      'Contact No: ${labAssistantData is Map ? labAssistantData['contact_no'] ?? 'N/A' : 'N/A'}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('No Lab Assistant found for this lab.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Contact Lab incharge',
                        style: GoogleFonts.overpass(
                            fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ReviewWidget(assetName: name),
                    Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: TextButton(
                        onPressed: () => _openDetailsPage(name),
                        child: Text(
                          'About the equipment',
                          style: GoogleFonts.overpass(
                              fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('STUDENT PAGE', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.redAccent,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout),
        //     onPressed: () => _logout(context),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.search_sharp),
                hintText: 'Search by asset name,location',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Sort By:',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: sortBy,
                  onChanged: (String? newValue) {
                    setState(() {
                      sortBy = newValue!;
                      selectedGroup =
                          null; // Reset selected group when sorting changes
                    });
                  },
                  items: <String>['location', 'assetname', 'none']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: sortBy == 'none'
                ? ListView.builder(
                    itemCount: subNodeList.length,
                    itemBuilder: (context, index) {
                      // Filter based on the search query
                      Map<dynamic, dynamic> subNode = subNodeList[index];
                      String name = subNode['subNodeData']['name'].toString();
                      String address = subNode['address'].toString();
                      if (searchQuery.isNotEmpty &&
                          !name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) &&
                          !address
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase())) {
                        return Container();
                      }

                      // Display the subnode information in list view
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35.0),
                            border: Border.all(
                                width: 2,
                                color: Color.fromARGB(255, 236, 89, 89)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                offset: Offset(10, 10),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: _buildAssetTile(subNodeList[index]),
                        ),
                      );
                    },
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Animated location or asset name buttons
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: sortBy != 'none'
                              ? Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8.0,
                                  children: List.generate(
                                    getUniqueCount(),
                                    (index) {
                                      String group = sortBy == 'location'
                                          ? subNodeList[index]['address']
                                          : subNodeList[index]['subNodeData']
                                              ['name'];

                                      return ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedGroup = group;
                                          });
                                        },
                                        child: Text(group,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.redAccent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(),
                        ),
                        // Animated documents
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: selectedGroup == null
                              ? SizedBox.shrink()
                              : Column(
                                  children: subNodeList.map((subNode) {
                                    String name = subNode['subNodeData']['name']
                                        .toString();
                                    String address =
                                        subNode['address'].toString();
                                    if (selectedGroup ==
                                        (sortBy == 'location'
                                            ? address
                                            : name)) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Name: $name',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black)),
                                            Text('Address: $address',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  int getUniqueCount() {
    if (sortBy == 'location') {
      return subNodeList.map((node) => node['address']).toSet().length;
    } else if (sortBy == 'assetname') {
      return subNodeList
          .map((node) => node['subNodeData']['name'])
          .toSet()
          .length;
    }
    return 1;
  }
}
