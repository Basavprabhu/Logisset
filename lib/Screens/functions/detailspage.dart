import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logisset/Screens/functions/reviewpage.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  final String assetName;

  DetailsPage(this.assetName);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<Map<String, dynamic>> assetDataFuture;
  late String imageUrl = '';

  @override
  void initState() {
    super.initState();
    assetDataFuture = fetchData();
    getImageUrl();
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('asset_descriptions')
              .doc(widget.assetName)
              .get();

      return documentSnapshot.data() ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<void> _openReviewPage(String assetName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(assetName),
      ),
    );
  }

  Future<void> getImageUrl() async {
    try {
      String downloadURL = await FirebaseStorage.instance
          .ref('images/${widget.assetName}.jpg')
          .getDownloadURL();

      setState(() {
        imageUrl = downloadURL;
      });
    } catch (e) {
      // Handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: assetDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Asset Details'),
              backgroundColor: Colors.redAccent,
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Asset Details'),
              backgroundColor: Colors.redAccent,
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Asset Details'),
              backgroundColor: Colors.redAccent,
            ),
            body: Center(
              child: Text('No data available'),
            ),
          );
        } else {
          Map<String, dynamic> assetData = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Asset Details'),
              backgroundColor: Colors.redAccent,
              actions: [
                IconButton(
                  icon: Icon(Icons.rate_review_sharp),
                  onPressed: () => _openReviewPage(widget.assetName),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  Center(
                      child: Text(
                    ' ${assetData['assetType'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 40),
                  )),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Placeholder(),
                  ),
                  SizedBox(height: 16),
                  if (assetData['crowded'] == 'Crowded')
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: Colors.red.withOpacity(0.8),
                      child: Text(
                        "The equipment's demand is high. Please wait for a few minutes.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  if (assetData['power'] == 'Powered')
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: Colors.red.withOpacity(0.8),
                      child: Text(
                        'The equipment is connected to a power board. Please follow necessary safety rules.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  if (assetData['supervised'] == 'Supervised')
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: Colors.red.withOpacity(0.8),
                      child: Text(
                        'The equipment is very complex. Please ensure you are under mentor\'s supervision.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  if (assetData['source'] == 'AC')
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: Colors.red.withOpacity(0.8),
                      child: Text(
                        'The equipment is AC driven. Please ensure necessary safety precautions.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text('Description: ${assetData['description'] ?? 'N/A'}'),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      final link = assetData['link'];
                      if (link != null && await canLaunch(link)) {
                        await launch(link);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not launch the link.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Link: ${assetData['link'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
