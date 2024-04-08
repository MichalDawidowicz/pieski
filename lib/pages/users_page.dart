import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/helper/helper_functions.dart';

import '../components/my_back_button.dart';
import '../database/firestore.dart';

class UsersPage extends StatelessWidget {
  final FirestoreDatabase database = FirestoreDatabase();
  UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("Users").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              displayMessageToUser("Coś poszło nie tak", context);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == null) {
              return const Text("Brak danych");
            }
            final users = snapshot.data!.docs;
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50.0, left: 25),
                  child: Row(
                    children: [
                      MyBackButton(),
                    ],
                  ),
                ),
                Expanded(
                  child:StreamBuilder(stream: database.getPostStream(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final posts =snapshot.data!.docs;
                      if(snapshot.data==null || posts.isEmpty){
                        return const Center(
                          child: Padding(padding: EdgeInsets.all(25),child: Text("Brak danych"),) ,
                        );
                      }
                      return Expanded(child: ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context,index){
                            final post =posts[index];
                            String title = post['PostTitle'];
                            String message = post['PostMessage'];
                            String userEmail = post['UserEmail'];

                            return ListTile(
                              title: Text(title),
                              subtitle: Text(message + userEmail),


                            );

                          }));
                    },)),
              ],
            );
          }),
    );
  }
}
