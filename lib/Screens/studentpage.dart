import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:logisset/auth/login.dart';

import 'functions/descriptionpage.dart';
import 'functions/detailspage.dart';

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
  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error during logout: $e');
      // Handle error, show a message to the user, etc.
    }
  }

  @override
  void initState() {
    super.initState();
    // Get a reference to the root node of your Realtime Database
    _databaseRef = FirebaseDatabase.instance.reference();

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

  ListTile _buildAssetTile(Map<dynamic, dynamic> subNode) {
    String name = subNode['subNodeData']['name'].toString();
    String address = subNode['address'].toString();

    return ListTile(
      title: Text('Name: $name', style: TextStyle(fontSize: 18)),
      subtitle: Text(
        'Address: $address\n',
        // 'RSSI: ${subNode['subNodeData']['rssi']}\n'
        // 'Time: ${subNode['subNodeData']['time']}\n'
        // 'Battery: ${subNode['subNodeData']['battery']} %',
        style: TextStyle(fontSize: 16),
      ),
      trailing: TextButton(
        onPressed: () => _openDetailsPage(name),
        child: Text('View more'),
      ),
      onTap: () async {
        // ... (rest of the onTap function)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset Status', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
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
                hintText: 'Search by asset name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
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
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        child: _buildAssetTile(subNodeList[index]),
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
