import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/models/models.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("email",
                  isEqualTo: FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                if (dataSnapshot.docs.isNotEmpty) {
                  Map<String, dynamic> userMap =
                      dataSnapshot.docs[0].data() as Map<String, dynamic>;
                  UserModel userModel = UserModel.fromMap(userMap);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.background),
                            child: Center(
                              child: CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    NetworkImage(userModel.profilePicture!),
                              ),
                            )),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, left: 10),
                          child: Text(
                            "Full Name :",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        simpleText(
                          context: context,
                          text: userModel.fullName!,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, left: 10),
                          child: Text(
                            "Email :",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        simpleText(context: context, text: userModel.email!),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: GestureDetector(
                            onTap: () {
                              FirebaseController().signout(context: context);
                            },
                            child: SizedBox(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                color: Colors.grey.shade100,
                                child: const Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 25, left: 25),
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.only(right: 30),
                                      trailing: Icon(
                                        Icons.logout_rounded,
                                        color: Colors.black,
                                        size: 26,
                                      ),
                                      title: Text("Logout from this Device"),
                                    )),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Text("NoOne Found");
                }
              } else {
                return CircularProgressIndicator();
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

Widget simpleText({
  required BuildContext context,
  required String text,
  TextStyle? style,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 25),
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ),
  );
}
