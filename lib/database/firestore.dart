import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_textfield.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts = FirebaseFirestore.instance.collection("Posts");



  Future<void> addPost (String title, String message){
    return posts.add({
      'UserEmail': user!.email,
      'PostTitle': title,
      'PostMessage': message
    });
  }

  Stream<QuerySnapshot> getPostStream(){
    final postsStream = FirebaseFirestore.instance.collection('Posts').snapshots();
    return postsStream;
  }

  Future<void> updatePost(String docID,String newPost){
    return posts.doc(docID).update({
      'PostMessage':newPost
    });

  }
  Future<void> deletePost(String docID){
    return posts.doc(docID).delete();
  }
}