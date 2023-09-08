import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/notification/local_notification.dart';
import 'package:simplechat/pages/onboarding/onBoarding.dart';
import 'package:simplechat/pages/screens/varifyEmail.dart';
import 'package:simplechat/pages/splash/splash_screen.dart';
import 'package:simplechat/provider/notifyProvider.dart';
import 'package:simplechat/provider/randomNameGenerator.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:simplechat/provider/tokenProvider.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'bloc/internetBloc.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

var uuid = const Uuid();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String? title = message.notification!.title;
  String? body = message.notification!.body;

  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 123,
          channelKey: 'call_channel',
          title: title,
          body: body,
          category: NotificationCategory.Call,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: true,
          backgroundColor: Colors.orange),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          color: Colors.green,
          label: 'Accept Call',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'REJECT',
          label: 'Reject Call',
          color: Colors.red,
          autoDismissible: true,
        ),
      ]);
}

List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  UserModel? thisUserModel;

  final prefs = await SharedPreferences.getInstance();

  LocalNotificationServic.initialize();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call Channel',
          channelDescription: 'Channel of Calling',
          defaultColor: Colors.redAccent,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone),
    ],
  );
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
            ? OnBoardingScreen(
                currentUser: currentUser,
                thisUserModel: thisUserModel,
              )
            : MyApp(
                currentUser: currentUser,
                thisUserModel: thisUserModel,
              );
      }));
}

class MyApp extends StatelessWidget {
  final currentUser;
  final thisUserModel;
  const MyApp(
      {super.key, required this.currentUser, required this.thisUserModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => LoadingProvider()),
        ListenableProvider(create: (_) => UserModelProvider()),
        ListenableProvider(create: (_) => RandomName()),
        ListenableProvider(create: (_) => TokenProvider()),
        ListenableProvider(create: (_) => NotifyProvider()),
        BlocProvider(create: (_) => InternetCubit())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Emochat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          primaryColor: Color.fromARGB(255, 134, 77, 232),
          useMaterial3: true,
        ),
        home:
            // VarifyEmailPage(
            //   email: "yahya.ali.barki@gmail.com",
            // )
            // ForgetPassword()
            //  CompleteProfile(
            //     userModel: thisUserModel, firebaseUser: currentUser),
            // NewScreen()
            SplashScreen(
          firebaseUser: currentUser,
          userModel: thisUserModel,
        ),
      ),
    );
  }
}
