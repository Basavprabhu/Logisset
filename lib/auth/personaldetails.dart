import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';

class PersonalDetailsPage extends StatefulWidget {
  final String userId;

  PersonalDetailsPage(this.userId);

  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  DateTime? _selectedDate;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _departmentController = TextEditingController();
  TextEditingController _usnController = TextEditingController();
  TextEditingController _semesterController = TextEditingController();
  bool _agreeToTerms = false;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                      text: _selectedDate != null
                          ? _selectedDate!.toLocal().toString().split(' ')[0]
                          : ''),
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                ),
              ),
            ),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            TextField(
              controller: _usnController,
              decoration: InputDecoration(labelText: 'USN'),
            ),
            TextField(
              controller: _semesterController,
              decoration: InputDecoration(labelText: 'Current Semester'),
            ),
            CheckboxListTile(
              title: Text('I agree to all terms and conditions'),
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_agreeToTerms) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .update({
                    'first_name': _firstNameController.text,
                    'last_name': _lastNameController.text,
                    'dob': _selectedDate != null
                        ? Timestamp.fromDate(_selectedDate!)
                        : null,
                    'gender': _genderController.text,
                    'department': _departmentController.text,
                    'usn': _usnController.text,
                    'semester': _semesterController.text,
                  });

                  // User? user = FirebaseAuth.instance.currentUser;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Registration Complete'),
                      content:
                          Text('Details saved and verification email sent.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Terms and Conditions'),
                      content:
                          Text('Please agree to the terms and conditions.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Save and Send Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
