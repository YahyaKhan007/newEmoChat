import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/pages/zoom_drawer.dart';
import 'package:simplechat/provider/loading_provider.dart';
import '../colors/colors.dart';
import '../models/user_model.dart';
import '../provider/user_model_provider.dart';

class Requests extends StatefulWidget {
  final UserModel currentUserModel;

  const Requests({super.key, required this.currentUserModel});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  late UserModelProvider userProvider;

  @override
  void initState() {
    userProvider = Provider.of<UserModelProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool pending = true;
    final LoadingProvider provider = Provider.of<LoadingProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70.w,
        backgroundColor: AppColors.backgroudColor,
        elevation: 0.3,
        leading: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: CircleAvatar(
                // radius: 40,
                backgroundImage:
                    NetworkImage(userProvider.userModel.profilePicture!),
                backgroundColor: Theme.of(context).colorScheme.onBackground),
            onPressed: () {
              drawerController.toggle!();

              // Navigator.push(
              // context,
              // PageTransition(
              //     duration: const Duration(milliseconds: 700),
              //     type: PageTransitionType.fade,
              //     child: const Profile(),
              //     isIos: true));
            }),
        title: Text(
          "Requests",
          style: TextStyle(letterSpacing: -2, color: Colors.grey.shade900),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Container(
            decoration: BoxDecoration(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        provider.changePending(value: true);
                        log(provider.pending.toString());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration:
                            BoxDecoration(color: AppColors.backgroudColor),
                        height: 35,
                        child: Text(
                          "Pending Requests",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: provider.pending == true
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        provider.changePending(value: false);
                        log(provider.pending.toString());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration:
                            BoxDecoration(color: AppColors.backgroudColor),
                        height: 35,
                        child: Text(
                          "Sent Requests",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: provider.pending == true
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                      ),
                    )
                  ]),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: userDataController.stream,
              // FirebaseFirestore.instance
              //     .collection("requests")
              //     .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                    CollectionReference ref =
                        FirebaseFirestore.instance.collection('requests');

                    if (dataSnapshot.docs.isNotEmpty) {
                      return ListView.builder(
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userData =
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>;

                            UserModel endUser = UserModel.fromMap(userData);

                            UserModel? pendingModel;

                            try {
                              log(endUser.reciever.toString());
                              Future.delayed(
                                Duration(seconds: 3),
                                () async {
                                  pendingModel =
                                      await FirebaseHelper.getUserModelById(
                                          endUser.reciever.toString());
                                },
                              );
                              log(pendingModel.toString());
                              // log(pendingModel.);
                            } catch (e) {
                              log(e.toString());
                            }

                            return endUser.reciever ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? ListTile(
                                    trailing: Container(
                                      width: 70.w,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                                radius: 15.r,
                                                backgroundColor:
                                                    AppColors.backgroudColor,
                                                child: CupertinoButton(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () async {
                                                    log("Current User Model -================>>>>" +
                                                        widget.currentUserModel
                                                            .uid
                                                            .toString());
                                                    log("End User Model -================>>>>" +
                                                        endUser.uid.toString());
                                                    try {
                                                      provider.changeLoading(
                                                          value: true);

                                                      widget.currentUserModel
                                                          .friends!
                                                          .add(endUser.uid);

                                                      endUser.friends!.add(
                                                          widget
                                                              .currentUserModel
                                                              .uid);

                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("users")
                                                          .doc(widget
                                                              .currentUserModel
                                                              .uid!)
                                                          .set(widget
                                                              .currentUserModel
                                                              .toMap());

                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("users")
                                                          .doc(endUser.uid!)
                                                          .set(endUser.toMap());
                                                      provider.changeLoading(
                                                          value: false);

                                                      ref
                                                          .doc(endUser.uid)
                                                          .delete();
                                                    } catch (e) {
                                                      provider.changeLoading(
                                                          value: false);
                                                      log(e.toString());
                                                    }
                                                  },
                                                  child: provider.loading
                                                      ? SpinKitSpinningLines(
                                                          color: Colors.black,
                                                          size: 15.0,
                                                        )
                                                      : Center(
                                                          child: Icon(
                                                          Icons.check,
                                                          size: 20,
                                                          color: Colors.grey,
                                                        )),
                                                )),
                                            CircleAvatar(
                                                radius: 15.r,
                                                backgroundColor:
                                                    AppColors.backgroudColor,
                                                child: CupertinoButton(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    ref
                                                        .doc(endUser.uid)
                                                        .delete();
                                                  },
                                                  child: Center(
                                                      child: Icon(
                                                    Icons.close,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  )),
                                                )),
                                          ]),
                                    ),
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundImage:
                                          NetworkImage(endUser.profilePicture!),
                                    ),
                                    title: Text(
                                      endUser.fullName!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                    subtitle: Text(
                                      endUser.bio!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11.sp),
                                    ),
                                  )
                                : Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 250.h),
                                      child: Text("No Requests"),
                                    ),
                                  );
                          });
                    } else {
                      return SizedBox();
                    }
                  } else {
                    return Center(
                      child: Text("No Requests yet"),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )
          // : Expanded(
          //     child: StreamBuilder(
          //       stream: FirebaseFirestore.instance
          //           .collection("requests")
          //           .snapshots(),
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.active) {
          //           if (snapshot.hasData) {
          //             log(snapshot.data!.size.toString());

          //             QuerySnapshot dataSnapshot =
          //                 snapshot.data as QuerySnapshot;

          //             CollectionReference ref =
          //                 FirebaseFirestore.instance.collection('requests');

          //             if (dataSnapshot.docs.isNotEmpty) {
          //               return ListView.builder(
          //                   itemCount: dataSnapshot.docs.length,
          //                   itemBuilder: (context, index) {
          //                     Map<String, dynamic> userData =
          //                         dataSnapshot.docs[index].data()
          //                             as Map<String, dynamic>;

          //                     UserModel endUser =
          //                         UserModel.fromMap(userData);
          //                     return endUser.sender ==
          //                             FirebaseAuth.instance.currentUser!.uid
          //                         ? ListTile(
          //                             trailing: Text(
          //                               "Status\nPending",
          //                               style: TextStyle(
          //                                   fontSize: 11.sp,
          //                                   fontStyle: FontStyle.italic,
          //                                   color: Colors.green),
          //                             ),
          //                             leading: CircleAvatar(
          //                               radius: 28,
          //                               backgroundImage: NetworkImage(
          //                                   endUser.profilePicture!),
          //                             ),
          //                             title: Text(
          //                               endUser.fullName!,
          //                               overflow: TextOverflow.ellipsis,
          //                               style: TextStyle(fontSize: 14.sp),
          //                             ),
          //                             subtitle: Text(
          //                               endUser.bio!,
          //                               overflow: TextOverflow.ellipsis,
          //                               style: TextStyle(fontSize: 11.sp),
          //                             ),
          //                           )
          //                         : Center(
          //                             child: Padding(
          //                               padding:
          //                                   EdgeInsets.only(top: 250.h),
          //                               child: Text("No Requests"),
          //                             ),
          //                           );
          //                   });
          //             } else {
          //               return SizedBox();
          //             }
          //           } else {
          //             return Center(
          //               child: Text("No Requests yet"),
          //             );
          //           }
          //         } else {
          //           return Center(
          //             child: CircularProgressIndicator(),
          //           );
          //         }
          //       },
          //     ),
          //   )
        ],
      ),
    );
  }
}
