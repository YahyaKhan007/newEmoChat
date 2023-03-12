import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/notification/local_notification.dart';
import 'package:simplechat/pages/onBoarding.dart';
import 'package:simplechat/pages/splash_screen.dart';
import 'package:simplechat/provider/randomNameGenerator.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'pages/screens.dart';

var uuid = const Uuid();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log(message.data.toString());
  log(message.notification.toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  UserModel? thisUserModel;

  final prefs = await SharedPreferences.getInstance();

  LocalNotificationServic.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (currentUser != null) {
    thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
  }

  runApp(ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        var firstTime = prefs.getString('isFirstTime');

        // !********************************

        return firstTime == null
            ? OnBoardingScreen()
            : Splash(
                firebaseUser: currentUser,
                userModel: thisUserModel,
              );
      }));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => LoadingProvider()),
        ListenableProvider(create: (_) => RandomName())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Emochat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Login(),
      ),
    );
  }
}

// ! Logged In
class MyAppLoggedIn extends StatelessWidget {
  const MyAppLoggedIn({super.key, required this.user, required this.userModel});
  final User? user;
  final UserModel? userModel;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => LoadingProvider()),
        ListenableProvider(create: (_) => RandomName()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Emochat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: user != null
            ? HomePage(userModel: userModel!, firebaseUser: user!)
            : Login(),
      ),
    );
  }
}
