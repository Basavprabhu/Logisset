import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logisset/Screens/navbar.dart';
import 'package:logisset/Screens/studentnavbar.dart';
import 'package:logisset/auth/register.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'auth/login.dart';
import 'firebase_options.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notification',
  importance: Importance.high,
  playSound: true,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseApp secondaryApp = await Firebase.initializeApp(
    name: 'secondary',
    options: FirebaseOptions(
        appId: '1:450978768566:android:657a73cd963bb3ae236817',
        apiKey: 'AIzaSyBV5Aql4yqK1cvig7_Y_5_yPRmsOjr6H4s',
        projectId: 'esp8266-192bf',
        messagingSenderId: '450978768566',
        storageBucket: 'esp8266-192bf.appspot.com'
        // Add other configuration options as needed
        ),
  );

  runApp(MyApp());

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.subscribeToTopic('asset_triggered');
  await FirebaseMessaging.instance.subscribeToTopic('asset_moved');
  await FirebaseMessaging.instance.subscribeToTopic('battery_low');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: channel.importance,
              playSound: channel.playSound,
              icon: android.smallIcon,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title!),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(notification.body!)],
                ),
              ),
            );
          },
        );
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Logisset',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error loading user data');
          } else if (snapshot.hasData) {
            if (snapshot.data!.exists) {
              String role = snapshot.data!['role'] ?? '';
              if (role == 'admin' && user.emailVerified) {
                return MainPageView();
              } else if (role == 'student') {
                return StudentMainPageView();
              } else {
                return LoginPage();
              }
            } else {
              return RegisterPage();
            }
          } else {
            return RegisterPage();
          }
        },
      );
    } else {
      return LoginPage();
    }
  }
}































// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:logisset/firebase_options.dart';

// import 'auth_gate.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel',
//   'High Importance Notification',
//   importance: Importance.high,
//   playSound: true,
// );

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A bg message just showed up: ${message.messageId}');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(MaterialApp(
//     title: 'Flutter App',
//     theme: ThemeData(
//       primaryColor: Colors.grey[200],
//       accentColor: Colors.redAccent,
//       fontFamily: 'Montserrat',
//       textTheme: TextTheme(
//         bodyText1: TextStyle(fontSize: 16, color: Colors.black),
//         bodyText2: TextStyle(fontSize: 16, color: Colors.black),
//       ),
//     ),
//     home: MyApp(),
//   ));

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // Subscribe to topics
//   await FirebaseMessaging.instance.subscribeToTopic('asset_triggered');
//   await FirebaseMessaging.instance.subscribeToTopic('asset_moved');
//   await FirebaseMessaging.instance.subscribeToTopic('battery_low');
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               color: Colors.blue,
//               playSound: true,
//               icon: '@mipmap/ic_launcher',
//             ),
//           ),
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null) {
//         showDialog(
//           context: context,
//           builder: (_) {
//             return AlertDialog(
//               title: Text(notification.title!),
//               content: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [Text(notification.body!)],
//                 ),
//               ),
//             );
//           },
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Logisset',
//       home: const AuthGate(),
//     );
//   }
// }
















