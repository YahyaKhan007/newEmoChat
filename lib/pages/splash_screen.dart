import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/colors/colors.dart';
import 'package:simplechat/main.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/pages/homepage.dart';

import '../provider/loading_provider.dart';
import '../provider/randomNameGenerator.dart';
import 'screens.dart';

class Splash extends StatelessWidget {
  final User? firebaseUser;
  final UserModel? userModel;
  const Splash({super.key, this.firebaseUser, this.userModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ListenableProvider(create: (_) => LoadingProvider()),
          ListenableProvider(create: (_) => RandomName())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Emochat",
          home: SplashScreen(firebaseUser: firebaseUser, userModel: userModel),
        ));
  }
}

class SplashScreen extends StatefulWidget {
  final User? firebaseUser;
  final UserModel? userModel;

  const SplashScreen(
      {super.key, required this.firebaseUser, required this.userModel});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context,
            PageTransition(
                duration: const Duration(milliseconds: 700),
                type: PageTransitionType.fade,
                child: widget.firebaseUser != null
                    ? MyAppLoggedIn(
                        userModel: widget.userModel!,
                        user: widget.firebaseUser!)
                    : MyApp(),
                isIos: true)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      body: Center(
        child: Image.asset("assets/logo.png"),
      ),
    );
  }
}
