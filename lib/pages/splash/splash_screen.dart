import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/colors/colors.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import '../../zoom_drawer.dart';
import '../screens/screens.dart';

// class Splash extends StatelessWidget {
//   final User? firebaseUser;
//   final UserModel? userModel;
//   const Splash({super.key, this.firebaseUser, this.userModel});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//         providers: [
//           ListenableProvider(create: (_) => LoadingProvider()),
//           ListenableProvider(create: (_) => RandomName())
//         ],
//         child: MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: "Emochat",
//           home: SplashScreen(firebaseUser: firebaseUser, userModel: userModel),
//         ));
//   }
// }

class SplashScreen extends StatefulWidget {
  final User? firebaseUser;
  final UserModel? userModel;

  const SplashScreen(
      {super.key, required this.firebaseUser, required this.userModel});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late UserModelProvider provider;

  @override
  void initState() {
    provider = Provider.of<UserModelProvider>(context, listen: false);
    Future.delayed(const Duration(seconds: 1), () {
      if (widget.firebaseUser != null) {
        provider.updateUser(widget.userModel!);
        provider.updateFirebaseUser(widget.firebaseUser!);
      }
      return Navigator.pushReplacement(
          context,
          PageTransition(
              duration: const Duration(milliseconds: 700),
              type: PageTransitionType.fade,
              child: widget.firebaseUser != null
                  ? MyHomePage()

                  // FlutterZoomDrawerDemo()

                  // HomePage(
                  //     firebaseUser: widget.firebaseUser!,
                  //     userModel: widget.userModel!,
                  //   )
                  : Login(),
              isIos: true));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // provider = Provider.of<UserModelProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: Image.asset("assets/logo.png"),
      ),
    );
  }
}
