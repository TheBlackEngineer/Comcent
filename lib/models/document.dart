import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String ownerID;
  final String email;
  final String url;
  final Timestamp dateAdded;

  Document({
    this.ownerID,
    this.email,
    this.url,
    this.dateAdded,
  });

  static Document fromDocument(DocumentSnapshot documentSnapshot) {
    return Document(
      ownerID: documentSnapshot.data()['ownerID'],
      email: documentSnapshot.data()['email'],
      url: documentSnapshot.data()['url'],
      dateAdded: documentSnapshot.data()['dateAdded'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'ownerID': ownerID,
      'email': email,
      'url': url,
      'dateAdded': Timestamp.now(),
    };
    return map;
  }
}
