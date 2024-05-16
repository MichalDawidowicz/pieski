import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_textfield.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts = FirebaseFirestore.instance.collection("Posts");
  final CollectionReference offers = FirebaseFirestore.instance.collection("Offers");
  final CollectionReference users = FirebaseFirestore.instance.collection("Users");


  Future<void> addPost (String title, String message,String photoUrl){
    return posts.add({
      'UserEmail': user!.email,
      'PostTitle': title,
      'PostMessage': message,
      'Photo' : photoUrl,
      'PostState' : 'nowe',
      'Uemail': ''
    });
  }
  Future<void> updateProfile(String docID,String info){
    return users.doc(docID).update({
      'Info':info,
    });
  }


  Future<String> getPostState(String postId) async {
    try {
      // Pobierz dokument o określonym postId z kolekcji "posts"
      var docSnapshot = await FirebaseFirestore.instance.collection('Posts').doc(postId).get();

      // Sprawdź, czy dokument istnieje
      if (docSnapshot.exists) {
        // Jeśli istnieje, zwróć wartość pola 'state'
        return docSnapshot.data()?['PostState'] ?? "";
      } else {
        // Jeśli dokument nie istnieje, zwróć pustą wartość
        return "";
      }
    } catch (e) {
      // Obsłuż błąd
      print("Error while fetching post state: $e");
      throw e; // Rzuć wyjątek, aby móc go obsłużyć w widoku
    }
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
  Stream<QuerySnapshot> getOfferStream(){
    final postsStream = FirebaseFirestore.instance.collection('Offers').snapshots();
    return postsStream;
  }
  Stream<QuerySnapshot> getUserPostStream(String userEmail) {
    return FirebaseFirestore.instance
        .collection('Posts')
        .where('UserEmail', isEqualTo: userEmail)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserCoopStream(String userEmail) {
    return FirebaseFirestore.instance
        .collection('Posts')
        .where('Uemail', isEqualTo: userEmail)
        .snapshots();
  }

  Future<void> updatePostTitle(String docID,String newTitle){
    return posts.doc(docID).update({
      'PostTitle':newTitle,
    });
  }
  Future<void> updateUrl(String docID,String newUrl){
    return posts.doc(docID).update({
      'Photo':newUrl,
    });
  }


  Future<void> updateAll(String docID,String newPost,String newTitle,String newUrl){
    return posts.doc(docID).update({
      'PostMessage':newPost,
      'PostTitle':newTitle,
      'Photo':newUrl
    });
  }
  Future<void> updatePost(String docID,String newPost){
    return posts.doc(docID).update({
      'PostMessage':newPost,
    });
  }

  Future<void> changeState(String docID,String newState, String uemail){
    return posts.doc(docID).update({
      'PostState':newState,
      'Uemail': uemail,
    });
  }

  Future<void> deletEmail(String docID){
    return posts.doc(docID).update({
      'Uemail': "",
    });
  }

  Future<void> updateState(String docID,String newState){
    return posts.doc(docID).update({
      'PostState':newState,
    });
  }

  // Future<void> deleteState(String docID,String newState){
  //   return posts.doc(docID).update({
  //     'PostState':'nowy',
  //   });
  // }

  Future<void> addOffer (String name, String message,String photoUrl){
    return offers.add({
      'UserEmail': user!.email,
      'OfferName': name,
      'OfferText': message,
      'OfferPhoto' : photoUrl
    });
  }

  Future<void> updateOffer(String docID,String newText, String newName, String newUrl){
    return offers.doc(docID).update({
      'OfferText':newText,
      'OfferName':newName,
      'OfferPhoto':newUrl
    });
  }
  Future<void> updateOfferUrl(String docID,String newUrl){
    return offers.doc(docID).update({
      'OfferPhoto':newUrl,
    });
  }

  Future<void> updateOfferName(String docID,String newTitle){
    return offers.doc(docID).update({
      'OfferName':newTitle,
    });
  }
  Future<void> updateOfferText(String docID,String newPost){
    return offers.doc(docID).update({
      'OfferText':newPost,
    });
  }
  Future<void> deletePost(String docID){
    return posts.doc(docID).delete();
  }
  Future<void> deleteOffer(String docID){
    return offers.doc(docID).delete();
  }
}