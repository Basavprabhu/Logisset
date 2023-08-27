import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logisset/Screens/functions/reviewpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  bool loadingImage = false;

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
      setState(() {
        loadingImage = true;
      });

      String downloadURL = await FirebaseStorage.instance
          .ref('images/${widget.assetName}.jpg')
          .getDownloadURL();

      setState(() {
        imageUrl = downloadURL;
        loadingImage = false;
      });
    } catch (e) {
      setState(() {
        loadingImage = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while fetching the image URL.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
              title: Center(child: Text('EQUIPMENT DETAILS')),
              backgroundColor: Colors.redAccent,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.rate_review_sharp,
                    size: 25,
                  ),
                  onPressed: () => _openReviewPage(widget.assetName),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(
                right: 16,
                left: 16,
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, left: 20, right: 20, bottom: 2),
                    child: Center(
                      child: Text(
                        ' ${assetData['assetType']?.toUpperCase() ?? 'N/A'}', // Convert to uppercase
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CustomPaint(
                      size: Size(350, 5),
                      painter: LinePainter(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.redAccent, width: 4)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: loadingImage
                            ? SpinKitRipple(
                                color: Colors.redAccent,
                                size: 500.0,
                              )
                            : imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Placeholder(),
                      ),
                    ),
                  ),

                  // ElevatedButton(
                  //   onPressed: getImageUrl,
                  //   child: Text('Load Image'),
                  // ),
                  SizedBox(height: 4),
                  if (assetData['crowded'] == 'Crowded')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        color: Colors.red.withOpacity(1),
                        child: Text(
                          "The equipment's demand is high. Please wait for a few minutes.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 4),
                  if (assetData['power'] == 'Powered')
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      color: Colors.red.withOpacity(1),
                      child: Text(
                        'The equipment is connected to a power board. Please follow necessary safety rules.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  SizedBox(height: 4),
                  if (assetData['supervised'] == 'Supervised')
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      color: Colors.red.withOpacity(1),
                      child: Text(
                        'The equipment is very complex. Please ensure you are under mentor\'s supervision.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  SizedBox(height: 4),
                  if (assetData['source'] == 'AC')
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      color: Colors.red.withOpacity(1),
                      child: Text(
                        'The equipment is AC driven. Please ensure necessary safety precautions.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 2.0, right: 2, bottom: 2),
                    child: CustomPaint(
                      size: Size(350, 5),
                      painter: LinePainter(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                      child: Text(
                    'DESCRIPTION',
                    style: GoogleFonts.roboto(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  )),
                  CustomPaint(
                    size: Size(150, 5),
                    painter: LinePainter(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${assetData['description'] ?? 'N/A'}',
                      style: GoogleFonts.mPlus2(
                          fontSize: 15, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 2.0, right: 2, bottom: 2),
                    child: CustomPaint(
                      size: Size(350, 5),
                      painter: LinePainter(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Click on the link below to access exclusive video content:',
                      style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Keep content centered
                      children: [
                        Icon(
                          Icons.link,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(
                            width: 8), // Add some spacing between icon and text
                        Expanded(
                          child: Text(
                            ' ${assetData['link'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '|---end---|',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;

    final Offset start = Offset(0, size.height);
    final Offset end = Offset(size.width, size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
