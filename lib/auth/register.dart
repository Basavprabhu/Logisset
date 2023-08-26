import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logisset/auth/personaldetails.dart';

import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isPasswordStrong = false;

  void _checkPasswordStrength(String password) {
    setState(() {
      // Implement your password strength criteria here
      _isPasswordStrong = password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[0-9]')) &&
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // Future<void> _verifyEmail(String email) async {
  //   try {
  //     setState(() {
  //       _isVerifyingEmail = true;
  //     });

  //     await _auth.currentUser!.updateEmail(email);
  //     await _auth.currentUser!.sendEmailVerification();

  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Email Verification Sent'),
  //         content: Text(
  //             'An email verification link has been sent to your email address.'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error sending email verification: $e');
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Error'),
  //         content: Text(
  //             'An error occurred while sending the email verification link.'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isVerifyingEmail = false;
  //     });
  //   }
  // }

  Future<void> _showSecurityPopupDialog() async {
    final TextEditingController _securityKeyController =
        TextEditingController();

    final currentContext = context; // Store the context

    await showDialog<void>(
      context: currentContext, // Use the stored context
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Security Key'),
              content: TextField(
                controller: _securityKeyController,
                decoration: InputDecoration(labelText: 'Security Key'),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Verify'),
                  onPressed: () async {
                    if (_securityKeyController.text == 'basavprabhu') {
                      Navigator.of(context).pop();

                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        String userId = userCredential.user!.uid;

                        await _auth.currentUser!.sendEmailVerification();

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .set({
                          'role': 'admin',
                        });

                        Navigator.pushReplacement(
                          currentContext,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PersonalDetailsPage(userId)),
                        );
                      } catch (e) {
                        showDialog(
                          context: currentContext,
                          builder: (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text('An error occurred: $e'),
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
                    } else {
                      showDialog(
                        context: currentContext,
                        builder: (context) => AlertDialog(
                          title: Text('Unauthorized'),
                          content: Text('You are not authorized.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Try Again'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _securityKeyController.clear();
                                _showSecurityPopupDialog();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _registerAsStudent(String email) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      // Save user role as 'student' in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'role': 'student',
      });

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Complete'),
          content:
              Text('Email verification sent. You are registered as a student.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error during registration: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred during registration.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                // suffixIcon: _isVerifyingEmail
                //     ? CircularProgressIndicator()
                //     : _isEmailVerified
                //         ? Icon(Icons.check_circle, color: Colors.green)
                //         : Icon(Icons.error_outline, color: Colors.red),
                // helperText: _isVerifyingEmail
                //     ? 'Sending verification email...'
                //     : _isEmailVerified
                //         ? 'Email verified'
                //         : 'Email not verified',
                // helperStyle: TextStyle(
                //   color: _isEmailVerified ? Colors.green : Colors.red,
                // ),
              ),
              // onChanged: (email) {
              //   setState(() {
              //     _isEmailVerified = false;
              //   });
              // },
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              onChanged: _checkPasswordStrength,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: _passwordController.text.isNotEmpty
                    ? Icon(
                        _isPasswordStrong
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: _isPasswordStrong ? Colors.green : Colors.red,
                      )
                    : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Are you an admin?'),
                Checkbox(
                  value: _isAdmin,
                  onChanged: (value) {
                    setState(() {
                      _isAdmin = value!;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (_isAdmin) {
                  _showSecurityPopupDialog();
                } else {
                  if (_isPasswordStrong) {
                    final email = _emailController.text;

                    // _verifyEmail(email); // Send email verification
                    _registerAsStudent(email); // Register as student
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Weak Password'),
                        content: Text('Please choose a strong password.'),
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
                }
              },
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Already a user? Login here'),
            ),
          ],
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:logisset/auth/login.dart';

// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isAdmin = false;

//   Future<void> _register(String email, String password) async {
//     try {
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       String role = _isAdmin ? 'admin' : 'student';

//       // Save user role in Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'role': role,
//       });

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//       );
//     } catch (e) {
//       print('Error during registration: $e');
//       // Handle error, show a message to the user, etc.
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Register')),
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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Are you an admin?'),
//                 Checkbox(
//                   value: _isAdmin,
//                   onChanged: (value) {
//                     setState(() {
//                       _isAdmin = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _register(_emailController.text, _passwordController.text);
//               },
//               child: Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
