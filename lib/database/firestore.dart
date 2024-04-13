import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_textfield.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts = FirebaseFirestore.instance.collection("Posts");



  Future<void> addPost (String title, String message,String photoUrl){
    return posts.add({
      'UserEmail': user!.email,
      'PostTitle': title,
      'PostMessage': message,
      'Photo' : photoUrl
    });
  }
  // Funkcja do przesłania zdjęcia do Firebase Storage
  Future<String> uploadImageToFirebaseStorage(File imageFile) async {
    // Utwórz referencję do miejsca, gdzie zostanie przechowane zdjęcie w Firebase Storage
    Reference storageReference = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Prześlij plik do Firebase Storage
    await storageReference.putFile(imageFile);

    // Pobierz URL przesłanego obrazu
    return await storageReference.getDownloadURL();
  }
  Stream<QuerySnapshot> getPostStream(){
    final postsStream = FirebaseFirestore.instance.collection('Posts').snapshots();
    return postsStream;
  }

  Stream<QuerySnapshot> getUserPostStream(String userEmail) {
    return FirebaseFirestore.instance
        .collection('Posts')
        .where('UserEmail', isEqualTo: userEmail)
        .snapshots();
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