import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/provider/disableButtonProvider.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'pages/screens.dart';

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  UserModel? thisUserModel;

  if (currentUser != null) {
    thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);

    runApp(ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: false,
        builder: (context, child) {
          return MyAppLoggedIn(
            user: currentUser,
            userModel: thisUserModel,
          );
        }));
  } else {
    runApp(ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: false,
        builder: (context, child) {
          return const MyApp();
        }));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => LoadingProvider()),
        ListenableProvider(create: (_) => DisableButtonProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
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
      providers: [ListenableProvider(create: (_) => LoadingProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
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
