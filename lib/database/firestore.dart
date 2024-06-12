import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_textfield.dart';

import '../pages/home_page.dart';
import '../pages/my_post_page.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts = FirebaseFirestore.instance.collection("Posts");
  final CollectionReference offers = FirebaseFirestore.instance.collection("Offers");
  final CollectionReference users = FirebaseFirestore.instance.collection("Users");
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addPostWithPhotos(Post post) async {
    try {
      // Dodaj post do kolekcji "Posts"
      DocumentReference postRef = await posts.add({
        'UserEmail': user!.email,
        'PostTitle': post.title,
        'PostMessage': post.post,
        'PostState': 'nowe',
        'Uemail': '',
      });

      // Dodaj zdjęcia do kolekcji "Photos" w bazie danych dla tego posta
      for (String photoUrl in post.photoUrls) {
        await postRef.collection('Photos').add({
          'PhotoUrl': photoUrl,
        });
      }
    } catch (e) {
      print("Error while adding post with photos: $e");
      throw e;
    }
  }

  Future<void> addPhotosToPost(String postID, List<File> newImages) async {
    try {
      // Pobierz referencję do istniejącego postu
      DocumentReference postRef = posts.doc(postID);

      // Dodaj nowe zdjęcia do kolekcji "Photos" w bazie danych dla tego postu
      for (File image in newImages) {
        String photoUrl = await uploadImageToFirebaseStorage(image);
        await postRef.collection('Photos').add({
          'PhotoUrl': photoUrl,
        });
      }
    } catch (e) {
      print("Error while adding additional photos to post: $e");
      throw e;
    }
  }

  Future<void> deletePhotoFromPost(String postID, String photoUrl) async {
    try {
      // Pobierz odniesienie do kolekcji Photos w danym poście
      CollectionReference photosCollection = posts.doc(postID).collection('Photos');

      // Znajdź dokument z adresem URL zdjęcia
      QuerySnapshot querySnapshot = await photosCollection.where('PhotoUrl', isEqualTo: photoUrl).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Usuń dokument
        await photosCollection.doc(querySnapshot.docs.first.id).delete();

        // Opcjonalnie: Usuń zdjęcie z Firebase Storage, jeśli przechowujesz zdjęcia także tam
        await _deletePhotoFromStorage(photoUrl);
      }
    } catch (e) {
      print('Error while deleting photo from post: $e');
    }
  }

  // Opcjonalna metoda do usunięcia zdjęcia z Firebase Storage
  Future<void> _deletePhotoFromStorage(String photoUrl) async {
    try {
      // Pobierz odniesienie do pliku w Firebase Storage
      Reference photoRef = _storage.refFromURL(photoUrl);
      await photoRef.delete();
    } catch (e) {
      print('Error while deleting photo from storage: $e');
    }
  }

  Future<PostData?> getPostData(String postID) async {
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(postID)
          .get();

      if (postSnapshot.exists) {
        Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;

        // Pobranie danych z głównego dokumentu postu
        String title = postData['PostTitle'];
        String message = postData['PostMessage'];
        String state = postData['PostState'];
        String vol = postData['Uemail'];

        // Pobranie zdjęć z podkolekcji photos
        QuerySnapshot photosSnapshot = await FirebaseFirestore.instance
            .collection('Posts')
            .doc(postID)
            .collection('Photos')
            .get();

        List<String> photoUrls = photosSnapshot.docs.map((doc) => doc['PhotoUrl'] as String).toList();

        return PostData(
          title: title,
          message: message,
          photoUrls: photoUrls,
          state: state,
          vol: vol,
        );
      } else {
        // Jeśli dokument nie istnieje, zwracamy null
        return null;
      }
    } catch (error) {
      // Obsługa błędów
      print('Error fetching post data: $error');
      return null;
    }
  }

  Future<void> updatePhotoUrl(String postID, String photoID, String newUrl) async {
    try {
      // Pobierz referencję do istniejącego URL-a zdjęcia
      DocumentReference photoRef = posts.doc(postID).collection('Photos').doc(photoID);

      // Zaktualizuj URL zdjęcia w bazie danych
      await photoRef.update({
        'PhotoUrl': newUrl,
      });
    } catch (e) {
      print("Error while updating photo URL: $e");
      throw e;
    }
  }

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



  Future<void> addOpinion(String userEmail, int rating, String comment) async {
    await users.doc(userEmail).collection('opinie').add({
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  Future<void> updateProfile(String docID,String info){
    return users.doc(docID).update({
      'Info':info,
    });
  }

  Future<List<String>> getPhotosForPost(String postId) async {
    try {
      // Pobierz referencję do kolekcji 'Photos' dla danego wpisu
      CollectionReference photosRef = FirebaseFirestore.instance.collection('Posts').doc(postId).collection('Photos');

      // Pobierz dokumenty (zdjęcia) z podkolekcji
      QuerySnapshot snapshot = await photosRef.get();

      // Mapuj snapshot na listę URL-i zdjęć
      List<String> photoUrls = [];

      // Iteruj przez dokumenty w snapshot
      snapshot.docs.forEach((doc) {
        // Upewnij się, że dokument istnieje i zawiera pole 'PhotoUrl'
        if (doc.exists && doc.data() != null) {
          // Pobierz dane dokumentu
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Sprawdź, czy dokument zawiera pole 'PhotoUrl' i czy nie jest puste
          if (data.containsKey('PhotoUrl') && data['PhotoUrl'] != null) {
            // Pobierz URL zdjęcia z pola 'PhotoUrl'
            String? url = data['PhotoUrl'];
            if (url != null && url.isNotEmpty) {
              photoUrls.add(url);
            }
          }
        }
      });

      return photoUrls;
    } catch (e) {
      // Obsłuż błąd, np. logując go lub zwracając pustą listę
      print('Error fetching photos: $e');
      return [];
    }
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

  Stream<QuerySnapshot<DocumentSnapshot>> getPostStreamTyped() {
    return FirebaseFirestore.instance.collection('Posts').snapshots().map((QuerySnapshot snapshot) {
      return snapshot as QuerySnapshot<DocumentSnapshot>;
    });
  }


  Stream<QuerySnapshot> getPostSearchStream(String searchQuery) {
    return FirebaseFirestore.instance
        .collection('Posts')
        .where('PostTitle', isGreaterThanOrEqualTo: searchQuery)
        .where('PostTitle', isLessThanOrEqualTo: searchQuery + '\uf8ff')
        .snapshots();
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

  Future<void> editPost(String docID,String newTitle, String newPost){
    return posts.doc(docID).update({
      'PostMessage':newPost,
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
  Future<void> updatePostMessage(String docID,String newPost){
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