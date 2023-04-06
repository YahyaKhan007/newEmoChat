import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NewRequests extends StatefulWidget {
  const NewRequests({super.key});

  @override
  State<NewRequests> createState() => _NewRequestsState();
}

class _NewRequestsState extends State<NewRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Requests")),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('requests').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> users = snapshot.data!.docs;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  QueryDocumentSnapshot user = users[index];
                  String endUserUid = user['sender'];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('requests')
                        .doc(endUserUid)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        DocumentSnapshot endUser = snapshot.data!;
                        // Access end user data and display it
                        return ListTile(
                          title: Text(endUser['fullName']),
                          subtitle: Text(endUser['email']),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  );
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}
