import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DescriptionPage extends StatefulWidget {
  final String assetName;

  DescriptionPage(this.assetName);

  @override
  _DescriptionPageState createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _assetTypeController = TextEditingController();
  String _crowded = 'Free';
  String _power = 'Powered';
  String _supervised = 'Unsupervised';
  String _source = 'AC';
  String _link = '';
  File? _image;
  final picker = ImagePicker();

  bool _uploading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveDescription() async {
    if (!mounted) return; // Check if the widget is still mounted

    String description = _descriptionController.text.trim();
    String assetType = _assetTypeController.text.trim();

    if (description.isNotEmpty) {
      try {
        await _firestore
            .collection('asset_descriptions')
            .doc(widget.assetName)
            .update({
          'description': description,
          'assetType': assetType,
          'crowded': _crowded,
          'power': _power,
          'supervised': _supervised,
          'source': _source,
          'link': _link,
        });

        if (!mounted) return; // Check again after the asynchronous operation

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Description saved successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return; // Check again after the asynchronous operation

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save description. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImageToFirestore() async {
    setState(() {
      _uploading = true;
    });

    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images/${widget.assetName}.jpg');
      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();

      setState(() {
        _uploading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Image Uploaded'),
            content: Text('The image was uploaded successfully.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _uploading = false;
      });

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while uploading the image.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset Description'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset Name: ${widget.assetName}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _assetTypeController,
                decoration: InputDecoration(
                  labelText: 'Asset Type',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 5000, // Set the maximum character limit
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 16),
              ListTile(
                title: Text('Crowded/Free:'),
                trailing: CupertinoSlidingSegmentedControl(
                  groupValue: _crowded,
                  children: {
                    'Free': Text('Free'),
                    'Crowded': Text('Crowded'),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      _crowded = value.toString();
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Supervised/Unsupervised:'),
                trailing: CupertinoSlidingSegmentedControl(
                  groupValue: _supervised,
                  children: {
                    'Unsupervised': Text('Unsupervised'),
                    'Supervised': Text('Supervised'),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      _supervised = value.toString();
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Powered/Powerless:'),
                trailing: CupertinoSlidingSegmentedControl(
                  groupValue: _power,
                  children: {
                    'Powerless': Text('Powerless'),
                    'Powered': Text('Powered'),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      _power = value.toString();
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('AC/DC:'),
                trailing: CupertinoSlidingSegmentedControl(
                  groupValue: _source,
                  children: {
                    'AC': Text('AC'),
                    'DC': Text('DC'),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      _source = value.toString();
                    });
                  },
                ),
              ),

              // ... Similar code for other segmented controls ...

              SizedBox(height: 16),
              _image != null ? Image.file(_image!) : Text('No image selected'),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Select Image'),
              ),
              ElevatedButton(
                onPressed: _uploading ? null : _uploadImageToFirestore,
                child: _uploading
                    ? CircularProgressIndicator() // Show progress indicator
                    : Text('Upload Image'),
              ),
              SizedBox(height: 16),
              Text('Please add https:// to your url:'),
              SizedBox(
                height: 8,
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _link = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Helpful Link',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveDescription,
                  child: Text('Save Description and Data'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.redAccent,
                      minimumSize: Size(100, 50),
                      side: BorderSide(width: 2, color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
