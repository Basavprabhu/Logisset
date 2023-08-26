import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logisset/Screens/homepage.dart';
import 'package:logisset/Screens/navbar.dart';
import 'package:logisset/Screens/studentnavbar.dart';
import 'package:logisset/Screens/studentpage.dart';
import 'package:logisset/auth/register.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false; // To toggle password visibility

  Future<void> _login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userSnapshot = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userSnapshot.exists) {
        String role = userSnapshot['role'];
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPageView()),
          );
        } else if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentMainPageView()),
          );
        } else {
          _showErrorDialog('Invalid Role',
              'User role is not defined or invalid. Please contact support.');
        }
      } else {
        _showErrorDialog('User Not Found', 'User does not exist.');
      }
    } catch (e) {
      _showErrorDialog('Login Error', 'An error occurred during login.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login',
            style: GoogleFonts.lobster(fontSize: 35, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Add spacing between AppBar and images
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  height: 69,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.redAccent, width: 2), // Border
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent
                                      .withOpacity(0.5), // Red color shadow
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(
                                      0, 3), // Offset to create a shadow effect
                                ),
                              ],
                            ),
                            child:
                                Image.asset('assets/images/kletech_logo.png'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.redAccent, width: 2), // Border
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent
                                      .withOpacity(0.5), // Red color shadow
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(
                                      0, 3), // Offset to create a shadow effect
                                ),
                              ],
                            ),
                            child: Image.asset('assets/images/yesist_logo.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    'THIS APP HELPS YOU TO MONITOR VALUABLE ASSETS IN YOUR ORGANISATION',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible, // Toggle password visibility
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    _showErrorDialog('Empty Fields', 'Please fill all fields.');
                    return;
                  }

                  if (_passwordController.text.length < 6) {
                    _showErrorDialog('Password Too Short',
                        'Password should be at least 6 characters.');
                    return;
                  }

                  try {
                    UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    if (userCredential.user != null &&
                        userCredential.user!.emailVerified) {
                      _login(
                          _emailController.text,
                          _passwordController
                              .text // Replace HomeScreen with your desired screen
                          );
                    } else {
                      _showErrorDialog('Email Not Verified',
                          'Please verify your email before logging in.');
                    }
                  } catch (e) {
                    _showErrorDialog(
                        'Login Failed', 'Email and password do not match.');
                  }
                },
                child: Text('LOG IN'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent, // Use red accent color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),

              // SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  'Not yet registered? Click here',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    // Apply Roboto font
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 20, top: 80),
                child: Center(
                  child: Text('terms and conditions.@all rights are reserved',
                      style: GoogleFonts.merriweather(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 169, 169, 170),
                          fontSize: 8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



































// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:logisset/Screens/homepage.dart';
// import 'package:logisset/Screens/navbar.dart';
// import 'package:logisset/Screens/studentpage.dart';
// import 'package:logisset/auth/register.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();

//   Future<void> _login(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       DocumentSnapshot userSnapshot = await _firestore
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .get();

//       if (userSnapshot.exists) {
//         String role = userSnapshot['role'];
//         if (role == 'admin') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => MainPageView()),
//           );
//         } else if (role == 'student') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => StudentPage()),
//           );
//         } else {
//           print('User role is not defined or invalid');
//           // Handle this case as needed, e.g., show an error message to the user
//         }
//       } else {
//         print('User does not exist in Firestore');
//         // Handle this case as needed, e.g., show an error message to the user
//       }
//     } catch (e) {
//       print('Error during login: $e');
//       // Handle error, show a message to the user, etc.
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'Password'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   UserCredential userCredential =
//                       await FirebaseAuth.instance.signInWithEmailAndPassword(
//                     email: _emailController.text,
//                     password: _passwordController.text,
//                   );

//                   if (userCredential.user != null &&
//                       userCredential.user!.emailVerified) {
//                     // User is logged in and email is verified
//                     _login(
//                         _emailController.text,
//                         _passwordController
//                             .text // Replace HomeScreen with your desired screen
//                         );
//                   } else {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text('Email Not Verified'),
//                         content:
//                             Text('Please verify your email before logging in.'),
//                         actions: <Widget>[
//                           TextButton(
//                             child: Text('OK'),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   print('Error during login: $e');
//                   // Handle error, show a message to the user, etc.
//                 }
//               },
//               child: Text('Login'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => RegisterPage()),
//                 );
//               },
//               child: Text('Not yet registered?click here'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
