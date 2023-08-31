import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:logisset/auth/login.dart';

import 'functions/descriptionpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseReference _databaseRef;
  List<Map<dynamic, dynamic>> subNodeList = [];

  // Variables to handle search and sorting
  String searchQuery = '';
  String sortBy = 'none'; // Default sorting by none

  // Variables to handle animated transitions
  String? selectedGroup;

  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // Future<void> _updateAssetName(
  //     String mainCollection, String subNodeKey, String newName) async {
  //   try {
  //     DatabaseReference assetRef =
  //         _databaseRef.child(mainCollection).child(subNodeKey);

  //     // Listen for changes to the current asset node
  //     assetRef.onValue.listen((event) async {
  //       DataSnapshot snapshot = event.snapshot;
  //       Map<String, dynamic>? data = snapshot.value as Map<String, dynamic>?;

  //       // If data is null or 'name' key is not present, do not proceed
  //       if (data == null || !data.containsKey('name')) {
  //         // Show an error message to the user
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content:
  //                 Text('Failed to update asset name. Invalid data format.'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //         return;
  //       }

  //       String? currentName = data['name'];

  //       // If the current name is null, do not proceed
  //       if (currentName == null) {
  //         // Show an error message to the user
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content:
  //                 Text('Failed to update asset name. Current name is null.'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //         return;
  //       }

  //       // Update the asset name
  //       await assetRef.update({'name': newName});

  //       // Traverse through all main collections
  //       _databaseRef.once().then((rootSnapshot) {
  //         Map<dynamic, dynamic> rootData =
  //             rootSnapshot.snapshot.value as Map<dynamic, dynamic>;

  //         rootData.forEach((mainCollectionKey, mainCollectionData) {
  //           if (mainCollectionData is Map<dynamic, dynamic>) {
  //             mainCollectionData.forEach((subNodeKey, subNodeData) {
  //               if (subNodeData is Map<String, dynamic> &&
  //                   subNodeData['name'] == currentName &&
  //                   subNodeKey != subNodeKey) {
  //                 // Get a reference to the subcollection node
  //                 DatabaseReference subCollectionRef =
  //                     _databaseRef.child(mainCollectionKey).child(subNodeKey);

  //                 // Update the name in the subcollection node
  //                 subCollectionRef.update({'name': newName});
  //               }
  //             });
  //           }
  //         });
  //       });

  //       // Show a success message to the user
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Asset name updated successfully.'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     });
  //   } catch (e) {
  //     // Show an error message to the user if the update fails
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to update asset name. Please try again.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<Map<String, String>?> _showRenameDialog(
  //     String subNodeKey, String currentName) async {
  //   TextEditingController _nameController =
  //       TextEditingController(text: currentName);
  //   Completer<Map<String, String>?> completer = Completer();

  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Rename Asset'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: _nameController,
  //               decoration: InputDecoration(
  //                 labelText: 'New Asset Name',
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               completer.complete(
  //                   null); // Return null if the user cancels the dialog
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               String newName = _nameController.text.trim();
  //               if (newName.isNotEmpty) {
  //                 Navigator.pop(context);
  //                 completer.complete({
  //                   'mainCollection':
  //                       'mainCollection', // Replace with the actual mainCollection value
  //                   'subNodeKey': subNodeKey,
  //                   'newName': newName,
  //                   'oldName': currentName,
  //                 }); // Return the new name if it's not empty
  //               }
  //             },
  //             child: Text('Rename'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   return completer.future;
  // }

  String _getCurrentTime() {
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Format the current time as desired
    String formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);

    return formattedTime;
  }

  Future<void> _openDescriptionPage(String assetName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DescriptionPage(assetName),
      ),
    );
  }

  Card _buildAssetTile(Map<dynamic, dynamic> subNode) {
    String name = subNode['subNodeData']['name'].toString();

    String address = subNode['address'].toString();

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Expanded(
              child: Text('NAME: $name',
                  style: GoogleFonts.lora(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          // Divider(
          //   thickness: 3,
          //   color: Colors.black,
          // ),
          CustomPaint(
            size: Size(250, 0.5),
            painter: LinePainter(),
          ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                    'ADDRESS: $address\n'
                    'RSSI: ${subNode['subNodeData']['rssi']}\n'
                    'TIME: ${_getCurrentTime()}\n'
                    'BATTERY: ${subNode['subNodeData']['battery']} %',
                    style: GoogleFonts.teko(
                        fontSize: 15,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              "Turn off the device",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          FutureBuilder<int>(
                            future: _getPowerStatusFromDatabase(
                                name), // Replace with your asset name
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                int powerStatus = snapshot.data ??
                                    0; // Default to 0 if data is null
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CupertinoSwitch(
                                      value: powerStatus == 1,
                                      onChanged: (newValue) {
                                        _updatePowerStatusDatabase(
                                            name,
                                            newValue
                                                ? 1
                                                : 0); // Replace with your asset name
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: TextButton(
                        onPressed: () => _openDescriptionPage(name),
                        child: Text(
                          'Add Description',
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

  // ListTile _buildAssetTile(Map<dynamic, dynamic> subNode) {
  //   String name = subNode['subNodeData']['name'].toString();
  //   String address = subNode['address'].toString();

  //   return ListTile(
  //     title: Padding(
  //       padding: const EdgeInsets.only(bottom: 0),
  //       child: Expanded(
  //         child: Text('NAME: $name',
  //             style:
  //                 GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold)),
  //       ),
  //     ),
  //     subtitle: Expanded(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                     'ADDRESS: $address\n'
  //                     'RSSI: ${subNode['subNodeData']['rssi']}\n'
  //                     'TIME: ${subNode['subNodeData']['time']}\n'
  //                     'BATTERY: ${subNode['subNodeData']['battery']} %',
  //                     style: GoogleFonts.teko(fontSize: 20, letterSpacing: 1)),
  //                 Row(
  //                   children: [
  //                     Expanded(child: Text("Turn off the device")),
  //                     FutureBuilder(
  //                       future: _getPowerStatusFromDatabase(
  //                           name), // Fetch power status from mainCollection->name->power
  //                       builder: (context, snapshot) {
  //                         if (snapshot.connectionState ==
  //                             ConnectionState.waiting) {
  //                           return CircularProgressIndicator();
  //                         } else if (snapshot.hasError) {
  //                           return Text('Error: ${snapshot.error}');
  //                         } else {
  //                           bool powerStatus = snapshot.data == 'on';
  //                           return CupertinoSwitch(
  //                             value: powerStatus,
  //                             onChanged: (newValue) {
  //                               _updatePowerStatus(name,
  //                                   newValue); // Update power status in subnode and mainCollection
  //                             },
  //                           );
  //                         }
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Flexible(
  //             child: TextButton(
  //               onPressed: () => _openDescriptionPage(name),
  //               child: Text(
  //                 'Add Description',
  //                 style: GoogleFonts.overpass(
  //                     fontWeight: FontWeight.w800, fontSize: 14),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Future<int> _getPowerStatusFromDatabase(String assetName) async {
    try {
      DatabaseReference secondaryDatabase = FirebaseDatabase.instance.ref();
      // app: Firebase.app('secondary'),

      DatabaseEvent snapshot =
          await secondaryDatabase.child(assetName).child('data').once();

      if (snapshot.snapshot.value != null) {
        return snapshot.snapshot.value as int;
      } else {
        print('No data found.');
        return 1; // Default to off if data doesn't exist
      }
    } catch (error) {
      print('Error fetching data: $error');
      return 1; // Default to off if an error occurs
    }
  }

  Future<void> _updatePowerStatusDatabase(
      String assetName, int newValue) async {
    try {
      DatabaseReference secondaryDatabase = FirebaseDatabase.instance.ref();
      // app: Firebase.app('secondary'),

      await secondaryDatabase.child(assetName).update({'data': newValue});

      // Update the UI state
      setState(() {
        // Find the corresponding subNode in the list and update its 'data' value
        for (int i = 0; i < subNodeList.length; i++) {
          if (subNodeList[i]['assetname'] == assetName) {
            subNodeList[i]['data'] = newValue;
            break; // Exit loop once the update is done
          }
        }
      });
    } catch (error) {
      print('Error updating data: $error');
      // Handle the error, show a message to the user, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 242, 236),
      appBar: AppBar(
        title: Center(
            child: Text('ADMIN PAGE', style: TextStyle(color: Colors.white))),
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
                        padding: const EdgeInsets.all(16.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          // margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(8.0),
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

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.5;

    final Offset start = Offset(0, size.height);
    final Offset end = Offset(size.width, size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}



























































































// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'dart:async';

// import 'package:logisset/auth/login.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late DatabaseReference _databaseRef;
//   List<Map<dynamic, dynamic>> subNodeList = [];

//   // Variables to handle search and sorting
//   String searchQuery = '';
//   String sortBy = 'none'; // Default sorting by none

//   // Variables to handle animated transitions
//   String? selectedGroup;

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   Future<void> _logout(BuildContext context) async {
//     try {
//       await _auth.signOut();
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => LoginPage()),
//       );
//     } catch (e) {
//       print('Error during logout: $e');
//       // Handle error, show a message to the user, etc.
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Get a reference to the root node of your Realtime Database
//     _databaseRef = FirebaseDatabase.instance.reference();

//     // Listen for changes in the database
//     _databaseRef.onValue.listen((event) {
//       DataSnapshot snapshot = event.snapshot;
//       if (snapshot.value != null) {
//         // Clear the existing subNodeList
//         subNodeList.clear();

//         // Extract the data from the snapshot
//         Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

//         // Loop through each main collection (AECLAB, CSLAB, etc.)
//         data.forEach((mainCollectionKey, mainCollectionData) {
//           // Loop through the subnodes in the main collection
//           mainCollectionData.forEach((subNodeKey, subNodeData) {
//             // Check if the subnode is active
//             if (subNodeData['active'] == true) {
//               // Create a new subnode map with subnode key, data, and address
//               Map<dynamic, dynamic> subNode = {
//                 'subNodeKey': subNodeKey,
//                 'subNodeData': subNodeData,
//                 'address': mainCollectionKey,
//               };

//               // Add the subnode to the subNodeList
//               subNodeList.add(subNode);
//             }
//           });
//         });

//         // Sort the subNodeList based on RSSI value in ascending order
//         subNodeList.sort((a, b) => int.parse(a['subNodeData']['rssi'])
//             .compareTo(int.parse(b['subNodeData']['rssi'])));

//         // If there are multiple subnodes with the same name, keep the one with the smallest RSSI value
//         Map<String, Map<dynamic, dynamic>> subNodesMap = {};
//         subNodeList.forEach((subNode) {
//           String name = subNode['subNodeData']['name'];
//           int rssi = int.parse(subNode['subNodeData']['rssi']);
//           if (!subNodesMap.containsKey(name) ||
//               rssi < int.parse(subNodesMap[name]!['subNodeData']['rssi'])) {
//             subNodesMap[name] = subNode;
//           }
//         });
//         subNodeList = subNodesMap.values.toList();

//         // Update the widget with new data
//         setState(() {});
//       }
//     });
//   }

//   Future<void> _updateAssetName(
//       String mainCollection, String subNodeKey, String newName) async {
//     try {
//       DatabaseReference assetRef =
//           _databaseRef.child(mainCollection).child(subNodeKey);

//       // Listen for changes to the current asset node
//       assetRef.onValue.listen((event) async {
//         DataSnapshot snapshot = event.snapshot;
//         Map<String, dynamic>? data = snapshot.value as Map<String, dynamic>?;

//         // If data is null or 'name' key is not present, do not proceed
//         if (data == null || !data.containsKey('name')) {
//           // Show an error message to the user
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content:
//                   Text('Failed to update asset name. Invalid data format.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }

//         String? currentName = data['name'];

//         // If the current name is null, do not proceed
//         if (currentName == null) {
//           // Show an error message to the user
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content:
//                   Text('Failed to update asset name. Current name is null.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }

//         // Update the asset name
//         await assetRef.update({'name': newName});

//         // Traverse through all main collections
//         _databaseRef.once().then((rootSnapshot) {
//           Map<dynamic, dynamic> rootData =
//               rootSnapshot.snapshot.value as Map<dynamic, dynamic>;

//           rootData.forEach((mainCollectionKey, mainCollectionData) {
//             if (mainCollectionData is Map<dynamic, dynamic>) {
//               mainCollectionData.forEach((subNodeKey, subNodeData) {
//                 if (subNodeData is Map<String, dynamic> &&
//                     subNodeData['name'] == currentName &&
//                     subNodeKey != subNodeKey) {
//                   // Get a reference to the subcollection node
//                   DatabaseReference subCollectionRef =
//                       _databaseRef.child(mainCollectionKey).child(subNodeKey);

//                   // Update the name in the subcollection node
//                   subCollectionRef.update({'name': newName});
//                 }
//               });
//             }
//           });
//         });

//         // Show a success message to the user
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Asset name updated successfully.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       });
//     } catch (e) {
//       // Show an error message to the user if the update fails
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update asset name. Please try again.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<Map<String, String>?> _showRenameDialog(
//       String subNodeKey, String currentName) async {
//     TextEditingController _nameController =
//         TextEditingController(text: currentName);
//     Completer<Map<String, String>?> completer = Completer();

//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Rename Asset'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'New Asset Name',
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 completer.complete(
//                     null); // Return null if the user cancels the dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 String newName = _nameController.text.trim();
//                 if (newName.isNotEmpty) {
//                   Navigator.pop(context);
//                   completer.complete({
//                     'mainCollection':
//                         'mainCollection', // Replace with the actual mainCollection value
//                     'subNodeKey': subNodeKey,
//                     'newName': newName,
//                     'oldName': currentName,
//                   }); // Return the new name if it's not empty
//                 }
//               },
//               child: Text('Rename'),
//             ),
//           ],
//         );
//       },
//     );

//     return completer.future;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Asset Status', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.redAccent,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => _logout(context),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search by asset name',
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text('Sort By:',
//                     style: TextStyle(fontSize: 18, color: Colors.black)),
//                 SizedBox(width: 10),
//                 DropdownButton<String>(
//                   value: sortBy,
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       sortBy = newValue!;
//                       selectedGroup =
//                           null; // Reset selected group when sorting changes
//                     });
//                   },
//                   items: <String>['location', 'assetname', 'none']
//                       .map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value,
//                           style: TextStyle(fontSize: 18, color: Colors.black)),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: sortBy == 'none'
//                 ? ListView.builder(
//                     itemCount: subNodeList.length,
//                     itemBuilder: (context, index) {
//                       // Filter based on the search query
//                       Map<dynamic, dynamic> subNode = subNodeList[index];
//                       String name = subNode['subNodeData']['name'].toString();
//                       String address = subNode['address'].toString();
//                       if (searchQuery.isNotEmpty &&
//                           !name
//                               .toLowerCase()
//                               .contains(searchQuery.toLowerCase()) &&
//                           !address
//                               .toLowerCase()
//                               .contains(searchQuery.toLowerCase())) {
//                         return Container();
//                       }

//                       // Display the subnode information in list view
//                       return AnimatedContainer(
//                         duration: Duration(milliseconds: 500),
//                         margin: EdgeInsets.symmetric(vertical: 4.0),
//                         padding: EdgeInsets.all(8.0),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(8.0),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               offset: Offset(0, 2),
//                               blurRadius: 2.0,
//                             ),
//                           ],
//                         ),
//                         child: ListTile(
//                           title: Text('Name: $name',
//                               style: TextStyle(fontSize: 18)),
//                           subtitle: Text(
//                               'Address: $address\n'
//                               'RSSI: ${subNode['subNodeData']['rssi']}\n'
//                               'Time: ${subNode['subNodeData']['time']}\n'
//                               'Battery: ${subNode['subNodeData']['battery']} %',
//                               style: TextStyle(fontSize: 16)),
//                           onTap: () async {
//                             Map<String, String>? result =
//                                 await _showRenameDialog(subNode['subNodeKey'],
//                                     subNode['subNodeData']['name']);
//                             if (result != null) {
//                               String oldName = result['oldName']!;
//                               String newName = result['newName']!;
//                               _updateAssetName(
//                                   address, subNode['subNodeKey'], newName);
//                             }
//                           },
//                         ),
//                       );
//                     },
//                   )
//                 : SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         // Animated location or asset name buttons
//                         AnimatedSwitcher(
//                           duration: Duration(milliseconds: 500),
//                           child: sortBy != 'none'
//                               ? Wrap(
//                                   alignment: WrapAlignment.center,
//                                   spacing: 8.0,
//                                   children: List.generate(
//                                     getUniqueCount(),
//                                     (index) {
//                                       String group = sortBy == 'location'
//                                           ? subNodeList[index]['address']
//                                           : subNodeList[index]['subNodeData']
//                                               ['name'];

//                                       return ElevatedButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             selectedGroup = group;
//                                           });
//                                         },
//                                         child: Text(group,
//                                             style: TextStyle(
//                                                 fontSize: 16,
//                                                 color: Colors.white)),
//                                         style: ElevatedButton.styleFrom(
//                                           primary: Colors.redAccent,
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 16.0, vertical: 8.0),
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8.0)),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 )
//                               : Container(),
//                         ),
//                         // Animated documents
//                         AnimatedSwitcher(
//                           duration: Duration(milliseconds: 500),
//                           child: selectedGroup == null
//                               ? SizedBox.shrink()
//                               : Column(
//                                   children: subNodeList.map((subNode) {
//                                     String name = subNode['subNodeData']['name']
//                                         .toString();
//                                     String address =
//                                         subNode['address'].toString();
//                                     if (selectedGroup ==
//                                         (sortBy == 'location'
//                                             ? address
//                                             : name)) {
//                                       return Container(
//                                         height:
//                                             MediaQuery.of(context).size.height *
//                                                 0.1,
//                                         padding: EdgeInsets.all(8.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[200],
//                                           border:
//                                               Border.all(color: Colors.grey),
//                                           borderRadius:
//                                               BorderRadius.circular(8.0),
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text('Name: $name',
//                                                 style: TextStyle(
//                                                     fontSize: 18,
//                                                     color: Colors.black)),
//                                             Text('Address: $address',
//                                                 style: TextStyle(
//                                                     fontSize: 16,
//                                                     color: Colors.black)),
//                                           ],
//                                         ),
//                                       );
//                                     } else {
//                                       return SizedBox.shrink();
//                                     }
//                                   }).toList(),
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   int getUniqueCount() {
//     if (sortBy == 'location') {
//       return subNodeList.map((node) => node['address']).toSet().length;
//     } else if (sortBy == 'assetname') {
//       return subNodeList
//           .map((node) => node['subNodeData']['name'])
//           .toSet()
//           .length;
//     }
//     return 1;
//   }
// }











