import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import '../../zoom_drawer.dart';
import '../screens/screens.dart';
import 'package:simplechat/provider/notifyProvider.dart';

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
  late UserModelProvider userModelProvider;
  late NotifyProvider notifyProvider;

  void uploaddata(
      {required User user,
      required UserModelProvider userModelProvider}) async {
    print(
        "*****************************************************\n********************************\n\n\nDONE\n************************\n***************************");
    widget.userModel!.isVarified = user.emailVerified;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel!.uid!)
        .set(widget.userModel!.toMap())
        .then((value) => userModelProvider.updateUser(widget.userModel!));
  }

  // Future<void> checkEmailVerificationStatus() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   await user!.reload(); // Reloads the user's authentication state
  //   uploaddata(user: user, userModelProvider: userModelProvider);
  //   notifyProvider.changeCloseOption(value: !widget.userModel!.isVarified!);
  //   print("Email is Varified ?  ${user.emailVerified}");
  // }

  @override
  void initState() {
    userModelProvider = Provider.of<UserModelProvider>(context, listen: false);
    notifyProvider = Provider.of<NotifyProvider>(context, listen: false);

    Future.delayed(const Duration(seconds: 2), () {
      if (widget.firebaseUser != null) {
        userModelProvider.updateUser(widget.userModel!);
        userModelProvider.updateFirebaseUser(widget.firebaseUser!);
        // checkEmailVerificationStatus();
      }

      return Navigator.pushReplacement(
          context,
          PageTransition(
              duration: const Duration(milliseconds: 700),
              type: PageTransitionType.fade,
              child: widget.firebaseUser != null
                  ? widget.userModel!.fullName == ""
                      ? CompleteProfile(
                          userModel: widget.userModel!,
                          firebaseUser: widget.firebaseUser!)
                      : MyHomePage()

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
      // backgroundColor: Colors.blue.shade100,
      body: Center(
        child: Text(
          "EmoChat",
          style: GoogleFonts.blackOpsOne(
            fontSize: 50.sp,
            textStyle: Theme.of(context).textTheme.bodyMedium,
            decorationColor: Colors.black,
            backgroundColor: Colors.grey.shade100,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
