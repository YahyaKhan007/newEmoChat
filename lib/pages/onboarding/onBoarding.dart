import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplechat/constants/images.dart';
import 'package:simplechat/provider/notifyProvider.dart';

import '../../main.dart';
import '../../provider/loading_provider.dart';
import '../../provider/randomNameGenerator.dart';

class OnBoardingScreen extends StatelessWidget {
  final currentUser;
  final thisUserModel;
  final firstCamera;
  const OnBoardingScreen(
      {super.key,
      required this.currentUser,
      required this.thisUserModel,
      required this.firstCamera});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => LoadingProvider()),
        ListenableProvider(create: (_) => RandomName()),
        ListenableProvider(create: (_) => NotifyProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OnBoarding(
          currentUser: currentUser,
          thisUserModel: thisUserModel,
          firstCamera: firstCamera,
        ),
      ),
    );
  }
}

class OnBoarding extends StatefulWidget {
  final currentUser;
  final thisUserModel;
  final firstCamera;
  const OnBoarding(
      {super.key, this.currentUser, this.thisUserModel, this.firstCamera});

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  List<String> boardingText = [
    "Chat anyOne along with emotions",
    "Meet awesom people",
    "Hangout with friends and attend events"
  ];

  String text = 'simple signup and Enjoy chatting';
  @override
  Widget build(BuildContext context) {
    NotifyProvider notifyProvider =
        Provider.of<NotifyProvider>(context, listen: true);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView(
              children: [
                Container(
                  height: size.height,
                  width: size.width,
                  child: Stack(
                    children: [
                      Positioned(
                        top: size.height * 0.2189,
                        left: size.width * 0.4214413,
                        child: SizedBox(
                          height: size.height * 0.19907822,
                          width: size.width * 0.395976,
                          child: CircleAvatar(
                              backgroundImage: AssetImage(Images.images[2])),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.21764179,
                        left: size.width * 0.17825312,
                        child: SizedBox(
                          height: size.height * 0.04608885,
                          width: size.width * 0.09167303,
                          child: CircleAvatar(
                              backgroundImage: AssetImage(Images.images[4])),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.49417488,
                        left: size.width * 0.25464731,
                        child: SizedBox(
                          height: size.height * 0.09729868,
                          width: size.width * 0.19353196,
                          child: CircleAvatar(
                              backgroundImage: AssetImage(Images.images[3])),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.30213801,
                        left: -size.width * 0.05092946,
                        child: SizedBox(
                          height: size.height * 0.16131097,
                          width: size.width * 0.29793736,
                          child: CircleAvatar(
                              backgroundImage: AssetImage(Images.images[8])),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.39559595,
                        left: size.width * 0.85561497,
                        child: SizedBox(
                          height: size.height * 0.09391883,
                          width: size.width * 0.20117138,
                          child: CircleAvatar(
                              backgroundImage: AssetImage(Images.images[4])),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.530021764,
                        left: -size.width * 0.0331041508,
                        child: SizedBox(
                          height: size.height * 0.104980156,
                          width: size.width * 0.208810797,
                          child: CircleAvatar(
                              backgroundImage: AssetImage(Images.images[1])),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.495074837,
                        left: size.width * 0.570409982,
                        child: SizedBox(
                          height: size.height * 0.128024581,
                          width: size.width * 0.254647313,
                          child: CircleAvatar(
                              backgroundImage: AssetImage(Images.images[8])),
                        ),
                      ),
                      Positioned(
                          top: size.height * 0.750224043,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.0891265597),
                            child: Container(
                              width: size.width * 0.791953145,
                              child: Text(
                                boardingText[0],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lobster(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.black,
                                    // backgroundColor: Colors.grey.shade100,
                                    color: Colors.black,
                                    fontSize: 25.sp),
                              ),
                            ),
                          )),
                      Positioned(
                          top: size.height * 0.850224043,
                          right: 55.w,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.08912656),
                            child: Text(
                              text,
                              style: GoogleFonts.pacifico(
                                  textStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                  // fontWeight: FontWeight.bold,
                                  decorationColor: Colors.black,
                                  // backgroundColor: Colors.grey.shade100,
                                  color: Colors.blueAccent.shade100,
                                  fontSize: 16.sp),
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                  height: size.height,
                  width: size.width,
                  child: Stack(
                    children: [
                      Positioned(
                          top: size.height * 0.422621943,
                          left: -size.width * 0.10974026,
                          child: SizedBox(
                            height: size.height * 0.199078223,
                            width: size.width * 0.395976572,
                            child: CircleAvatar(
                                backgroundImage: AssetImage(Images.images[1])),
                          )),
                      Positioned(
                          top: size.height * 0.186775076,
                          left: size.width * 0.198624905,
                          child: SizedBox(
                            height: size.height * 0.26781334,
                            width: size.width * 0.55258467,
                            child: CircleAvatar(
                                backgroundImage: AssetImage(Images.images[8])),
                          )),
                      Positioned(
                          top: size.height * 0.422621943,
                          right: -size.width * 0.063,
                          child: SizedBox(
                            height: size.height * 0.199078223,
                            width: size.width * 0.395976572,
                            child: CircleAvatar(
                                backgroundImage: AssetImage(Images.images[4])),
                          )),
                      Positioned(
                          top: size.height * 0.7937524,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.0891265597),
                            child: Container(
                              width: size.width * 0.791953145,
                              child: Text(
                                boardingText[1],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lobster(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.black,
                                    // backgroundColor: Colors.grey.shade100,
                                    color: Colors.black,
                                    fontSize: 30.sp),
                              ),
                            ),
                          )),
                      Positioned(
                        top: size.height * 0.850224043,
                        right: 55.w,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.0891265597),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lobster(
                                textStyle:
                                    Theme.of(context).textTheme.bodyLarge,
                                fontWeight: FontWeight.bold,
                                decorationColor: Colors.black,
                                // backgroundColor: Colors.grey.shade100,
                                color: Colors.blueAccent.shade100,
                                fontSize: 15.sp),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                //  ******************************** Last  Screen
                Container(
                  height: size.height,
                  width: size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Swiper(
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Image.asset(
                              Images.images[index],
                              fit: BoxFit.cover,
                            ),
                            color: Colors.green,
                          );
                        },
                        itemCount: Images.images.length,
                        itemWidth: 300.0,
                        itemHeight: 320.0,
                        layout: SwiperLayout.TINDER,
                      ),
                      Positioned(
                          top: size.height * 0.750224043,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.0891265597),
                            child: Container(
                              width: size.width * 0.791953145,
                              child: Text(
                                boardingText[2],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lobster(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.black,
                                    // backgroundColor: Colors.grey.shade100,
                                    color: Colors.black,
                                    fontSize: 20.sp),
                              ),
                            ),
                          )),
                      Positioned(
                          top: size.height * 0.850224043,
                          right: 85.w,
                          child: Padding(
                            padding: EdgeInsets.only(left: 200.w),
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pacifico(
                                  textStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                  decorationColor: Colors.black,
                                  // backgroundColor: Colors.grey.shade100,
                                  color: Colors.blueAccent.shade100,
                                  fontSize: 16.sp),
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                bottom: size.height * 0.01920369,
                right: size.width * 0.07130125,
                child: TextButton(
                  onPressed: () async {
                    termsAndConditon();
                  },
                  child: Text(
                    "Skip",
                    style: GoogleFonts.lobster(
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                        fontWeight: FontWeight.bold,
                        decorationColor: Colors.black,
                        // backgroundColor: Colors.grey.shade100,
                        color: Colors.blue,
                        fontSize: 30.sp),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  termsAndConditon() async {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Material(
                type: MaterialType.transparency,
                child: Consumer<NotifyProvider>(
                  builder: (context, notifyProvider, child) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.w),
                      height: 400,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(
                          vertical: 25.h, horizontal: 30.w),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r)),
                      child: ListView(children: [
                        Center(
                          child: Text(
                            "Privacy Policy",
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 18.sp,
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              decorationColor: Colors.black,
                              backgroundColor: Colors.grey.shade100,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text("${longText}"),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: notifyProvider.acceptTermsCondition,
                          onChanged: (val) {
                            notifyProvider.changeAcceptTermsCondition(
                                value: val!);
                          },
                          checkColor: Colors.black,
                          title: Text("I agree to the Privacy Policy",
                              style: GoogleFonts.merriweather(
                                fontSize: 12.sp,
                                textStyle:
                                    Theme.of(context).textTheme.bodyMedium,
                                decorationColor: Colors.black,
                                backgroundColor: Colors.grey.shade100,
                              )),
                        ),
                        SizedBox(
                            height:
                                notifyProvider.acceptTermsCondition ? 0 : 40),
                        Visibility(
                            visible: notifyProvider.acceptTermsCondition,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                label: Text(
                                  "Submit",
                                  style: GoogleFonts.croissantOne(
                                    fontSize: 17.sp,
                                    textStyle:
                                        Theme.of(context).textTheme.bodyMedium,
                                    decorationColor: Colors.black,
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                ),
                                icon: Icon(Icons.forward),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString("isFirstTime", "Not Anymore");
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyApp(
                                        firstCamera: widget.firstCamera,
                                        currentUser: widget.currentUser,
                                        thisUserModel: widget.thisUserModel,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )),
                      ]),
                    );
                  },
                )),
          );
        });
  }
}

final String longText =
    '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vel risus ac turpis auctor rhoncus nec non orci. Suspendisse aliquet, turpis ac venenatis tempus, metus augue cursus mi, ac aliquet nunc ex non velit. Nulla facilisi. Suspendisse potenti. Pellentesque fringilla nibh eget tellus egestas luctus. Integer hendrerit, nisi id efficitur tincidunt, libero velit elementum dolor, quis vehicula urna mi vel felis. Quisque vel felis sed purus pellentesque suscipit. Aenean eget orci id urna hendrerit fringilla in sit amet lectus.

Proin ullamcorper justo ut est laoreet, at elementum orci scelerisque. Nunc bibendum nisi a leo vehicula, vel iaculis dolor vestibulum. Vivamus a purus ac ex eleifend dapibus. Fusce id ipsum a est dignissim lacinia sit amet id risus. Nullam efficitur vehicula enim, sit amet laoreet tortor. Ut dictum, nunc ut venenatis tincidunt, lorem est malesuada urna, in ultricies lorem erat ut felis. Nullam sit amet enim quis tellus volutpat iaculis. Integer quis mauris orci. Sed ut tortor nec risus malesuada laoreet non id mi.

Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed placerat ut nulla in feugiat. Sed at enim vel massa semper dapibus ut quis libero. Vivamus eu elit nisl. Morbi tincidunt vel tortor id fermentum. Nam congue sit amet leo id laoreet. Sed dignissim dui non velit dapibus interdum. Fusce vitae odio a elit fermentum faucibus. Donec luctus ex id ante vehicula ultricies.

Donec tincidunt quam ac viverra facilisis. Proin id lacinia erat. Nullam sagittis urna ut velit hendrerit interdum. Fusce id tristique nulla. Fusce at odio vel justo elementum lacinia. Vivamus vitae volutpat est. Sed id sodales ex, vel venenatis elit. Vivamus id ultricies urna. Nam tristique lacus non malesuada interdum. Nullam fringilla, nunc quis eleifend tincidunt, ipsum ipsum aliquet nisi, id auctor lectus risus quis felis.

Vivamus eget lectus tincidunt, auctor felis eu, malesuada tortor. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla facilisi. Fusce posuere, turpis a facilisis dictum, massa justo scelerisque leo, eu dignissim lectus est ac ex. Fusce eu orci bibendum, auctor odio a, eleifend orci. Morbi gravida quam vel arcu varius viverra. Suspendisse nec nunc id metus vestibulum feugiat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

Praesent eleifend justo id auctor dictum. Curabitur sed ligula eu leo semper facilisis. Fusce non hendrerit nunc. Integer ac dictum tellus. Donec auctor, nunc ut facilisis eleifend, quam odio luctus elit, sed egestas urna ipsum in libero. Aliquam a nunc tellus. Suspendisse potenti. Suspendisse nec justo vel ex volutpat efficitur. Duis id eros vel lorem consectetur venenatis. Nullam semper velit at ante viverra, sit amet dignissim ante tristique.

Nunc venenatis dui in tellus ultrices, sed condimentum arcu tristique. Sed consectetur tristique arcu, non fringilla metus pharetra sed. Nulla facilisi. Nam laoreet libero et ipsum scelerisque, nec malesuada odio convallis. Fusce vitae est quam. Suspendisse potenti. Sed lacinia, justo nec cursus malesuada, nunc purus cursus leo, id euismod nulla velit sit amet dui.

In vel leo non lorem varius volutpat in non libero. Fusce a varius odio. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut in metus nec arcu tincidunt fringilla non vel dolor. Sed suscipit mauris ac eleifend tincidunt. Vestibulum pharetra vestibulum dapibus. Vestibulum congue aliquam est, a vulputate justo. Cras venenatis lectus non nisi congue, ac tristique orci laoreet. Morbi fermentum feugiat nunc, eu cursus nisl interdum non. Nullam rhoncus sit amet ex in tincidunt. Vivamus id condimentum quam. Phasellus scelerisque, libero id tincidunt blandit, sapien ex volutpat quam, sit amet volutpat risus felis et mi.

Mauris non sapien nec erat posuere fringilla non at elit. Donec non sodales urna. Suspendisse eu justo vitae purus condimentum laoreet. Ut eget vestibulum metus. Aenean pharetra, ex vel blandit condimentum, mi odio consequat sapien, auctor faucibus tortor nunc a justo. In efficitur turpis eu ex venenatis, vel hendrerit libero dictum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas tincidunt facilisis quam, in lacinia est auctor a. Cras eu urna eu justo dictum volutpat. Pellentesque tincidunt arcu non urna auctor, a volutpat elit elementum. Sed sit amet bibendum leo. Nullam euismod tortor libero, non feugiat sapien luctus nec. Vestibulum consectetur lacus id tortor pellentesque, ut semper arcu luctus. Donec id orci nec elit hendrerit bibendum sit amet id justo.

Aenean sed arcu a metus ultricies rhoncus. Fusce a elit urna. Donec cursus lectus non pharetra tincidunt. Aenean ac odio bibendum, euismod justo nec, lacinia velit. Ut eleifend erat ut mauris hendrerit varius. Vivamus sit amet lacus et sapien malesuada dapibus id quis ipsum. Vestibulum fermentum ipsum id neque congue, et bibendum justo ullamcorper. Morbi convallis ex id elit pellentesque, id fermentum ante malesuada. Nullam rhoncus, metus at bibendum dapibus, est enim rhoncus orci, a pellentesque orci nisi vel lorem. Pellentesque tincidunt vel ipsum eu volutpat. Maecenas rhoncus urna a lorem eleifend, sit amet volutpat ante tincidunt. Nullam at odio vel ligula laoreet gravida nec sed sem. Aenean vehicula dapibus diam nec blandit. Curabitur vestibulum facilisis ex eget congue. Proin malesuada, libero ac varius feugiat, tellus leo convallis mi, ac auctor dolor risus sit amet turpis.

Quisque rhoncus nisl vel mauris faucibus, quis iaculis nisi suscipit. Sed dictum lectus ut magna auctor, sed suscipit risus venenatis. Nunc euismod gravida tincidunt. Donec egestas odio sit amet sapien laoreet, nec volutpat dui tempus. Curabitur egestas quam nec odio lacinia, at aliquam purus viverra. Praesent in rhoncus est, id iaculis felis. Maecenas et ligula bibendum, luctus eros sed, venenatis quam. Phasellus ut purus ut ipsum bibendum volutpat. Fusce et neque sed nisi tincidunt dictum. Praesent posuere augue non ipsum iaculis hendrerit.

Integer convallis sem eu efficitur tristique. Suspendisse in ex vel massa auctor facilisis non eu velit. Phasellus sagittis nec neque ac convallis. Nullam sit amet nisl massa. Curabitur convallis augue ut erat accumsan, id facilisis arcu facilisis. Maecenas viverra semper ex in vehicula. Nullam eget ultricies risus, et rhoncus elit. Nullam sit amet justo vitae odio consectetur dignissim id a elit. Aenean eu odio at nulla dictum facilisis sit amet sit amet urna. Curabitur vel gravida elit, eu facilisis dui. Sed viverra, odio vel vestibulum vehicula, arcu erat ullamcorper leo, nec dapibus turpis arcu nec tortor.

Sed posuere non orci sed rhoncus. Quisque in diam erat. Suspendisse vestibulum elit ac nunc vulputate aliquam. Nunc varius scelerisque arcu, ac rhoncus ipsum feugiat ac. Sed maximus vitae tortor a volutpat. Fusce et tellus ac leo feugiat blandit at sit amet orci. Vivamus eget tincidunt felis. Sed lacinia nulla vel orci tristique, in ullamcorper dolor vestibulum. Ut dapibus lacinia felis, in efficitur justo fermentum vel. Vivamus auctor eu justo quis blandit.

Proin finibus justo sed metus vehicula, sed interdum ipsum dapibus. Integer efficitur libero risus, eget auctor erat tristique nec. Proin euismod bibendum nunc non volutpat. Vestibulum bibendum orci eu magna facilisis, vel convallis nisl venenatis. Integer nec vulputate purus. Vivamus tristique feugiat lacus, a lacinia arcu finibus ut. Vivamus a luctus arcu. Phasellus aliquam orci ac elit aliquet, et tristique tortor vestibulum. Donec id tristique enim. Nullam nec feugiat urna. Cras aliquam ipsum eu libero lacinia ultrices. Nullam nec tristique leo, vel aliquet lectus.

Nullam rhoncus fermentum lectus a scelerisque. Vivamus id lacinia metus. Maecenas feugiat lacinia ex. Vestibulum congue, augue nec consectetur interdum, odio dolor euismod quam, quis venenatis quam dolor id ex. Etiam venenatis congue ultrices. Suspendisse interdum dolor quis ex ultricies bibendum. Aliquam eu ipsum non augue sodales malesuada.

Duis vehicula varius auctor. Maecenas in eleifend nulla. Vivamus vel odio neque. Fusce condimentum, lectus non luctus egestas, lectus sem malesuada metus, a consectetur libero ipsum id orci. Integer efficitur bibendum libero in volutpat. In hac habitasse platea dictumst. Nulla tincidunt tristique mi ut varius. Vivamus id erat mi. Phasellus hendrerit, arcu eget ullamcorper hendrerit, odio quam aliquet odio, ut dignissim sapien arcu non elit. Donec sit amet leo ac justo efficitur suscipit. Sed et viverra neque. Curabitur ullamcorper metus id mi vestibulum, ac dictum dolor bibendum. Donec eget ligula non sapien pharetra dictum nec in arcu. Vivamus nec sollicitudin libero. Suspendisse congue a nulla a malesuada.

Praesent tristique nulla et nunc dignissim, non lacinia nunc fermentum. Duis cursus lacinia arcu, at vehicula augue bibendum at. Nullam mattis nisi eget volutpat facilisis. Sed egestas mi ac lectus bibendum, nec ultrices ipsum malesuada. Curabitur non mauris a risus tincidunt blandit in a neque. Suspendisse potenti. Sed vel nisi quis arcu bibendum malesuada. Maecenas nec libero sit amet orci volutpat rhoncus eget nec libero. Praesent consectetur sodales justo, eget rhoncus risus bibendum nec. Suspendisse finibus justo ut ante tristique venenatis. Praesent bibendum, augue ac congue egestas, dui turpis scelerisque arcu, sit amet sodales neque quam sed dolor. Aliquam id fringilla justo. Praesent sit amet mi tristique, vestibulum lectus ac, tempus purus. Proin posuere nisl quis odio fermentum, at gravida turpis dignissim. Sed tincidunt nec quam nec suscipit.

Phasellus viverra tellus sit amet malesuada pharetra. Suspendisse fringilla, elit ac efficitur auctor, dolor erat placerat purus, ac vestibulum tortor sapien vel ex. Fusce sagittis odio id eros gravida, vel sollicitudin neque efficitur. Nulla id libero eu ex pellentesque bibendum a at metus. Cras tristique ex vel justo dictum, nec posuere nisl vehicula. Sed eget egestas quam. Donec fringilla quam nec hendrerit commodo. Nullam malesuada diam nec leo varius, at rhoncus
''';
