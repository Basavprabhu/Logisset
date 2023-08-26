import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UpdateAssetName {
  Future<void> updateAssetName(
      BuildContext context,
      DatabaseReference databaseRef,
      String mainCollection,
      String subNodeKey,
      String newName) async {
    try {
      DatabaseReference assetRef =
          databaseRef.child(mainCollection).child(subNodeKey);

      // Listen for changes to the current asset node
      assetRef.onValue.listen((event) async {
        DataSnapshot snapshot = event.snapshot;
        Map<String, dynamic>? data = snapshot.value as Map<String, dynamic>?;

        // If data is null or 'name' key is not present, do not proceed
        if (data == null || !data.containsKey('name')) {
          // Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to update asset name. Invalid data format.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        String? currentName = data['name'];

        // If the current name is null, do not proceed
        if (currentName == null) {
          // Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to update asset name. Current name is null.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Update the asset name
        await assetRef.update({'name': newName});

        // Traverse through all main collections
        databaseRef.once().then((rootSnapshot) {
          Map<dynamic, dynamic> rootData =
              rootSnapshot.snapshot.value as Map<dynamic, dynamic>;

          rootData.forEach((mainCollectionKey, mainCollectionData) {
            if (mainCollectionData is Map<dynamic, dynamic>) {
              mainCollectionData.forEach((subNodeKey, subNodeData) {
                if (subNodeData is Map<String, dynamic> &&
                    subNodeData['name'] == currentName &&
                    subNodeKey != subNodeKey) {
                  // Get a reference to the subcollection node
                  DatabaseReference subCollectionRef =
                      databaseRef.child(mainCollectionKey).child(subNodeKey);

                  // Update the name in the subcollection node
                  subCollectionRef.update({'name': newName});
                }
              });
            }
          });
        });

        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asset name updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      });
    } catch (e) {
      // Show an error message to the user if the update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update asset name. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
