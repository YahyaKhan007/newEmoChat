import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplechat/constants/images.dart';

import '../main.dart';
import '../provider/loading_provider.dart';
import '../provider/randomNameGenerator.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => LoadingProvider()),
        ListenableProvider(create: (_) => RandomName())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OnBoarding(),
      ),
    );
  }
}

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

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
                                style: TextStyle(
                                  fontSize: size.width * 0.0611153552,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                ),
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
                              style: TextStyle(
                                  fontSize: size.width * 0.038197097,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]),
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
                                style: TextStyle(
                                  fontSize: size.width * 0.0611153552,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                ),
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
                              style: TextStyle(
                                  fontSize: size.width * 0.038197097,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]),
                            ),
                          ))
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
                                style: TextStyle(
                                  fontSize: size.width * 0.0611153552,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                ),
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
                              style: TextStyle(
                                  fontSize: size.width * 0.038197097,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]),
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
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("isFirstTime", "Not Anymore");
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                        color: const Color(0xff0659FD),
                        fontSize: size.width * 0.038197097,
                        fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
