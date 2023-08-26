import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:logisset/auth/login.dart';

class UserScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Screen'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 300),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.red,
                ),
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Email: ${_auth.currentUser?.email ?? "Not available"}',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Oswald',
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Reset password
                  await _auth.sendPasswordResetEmail(
                      email: _auth.currentUser!.email!);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Password Reset'),
                      content: Text('Password reset link sent to your email.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Reset Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout),
        //     onPressed: () => _logout(context),
        //   ),
        // ],
