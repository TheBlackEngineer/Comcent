import 'package:cloud_firestore/cloud_firestore.dart';

class SubCommunity {
  final String name, master;
  final List<dynamic> members;

  SubCommunity({
    this.name,
    this.master,
    this.members,
  });

  static SubCommunity fromDocument(DocumentSnapshot documentSnapshot) {
    return SubCommunity(
      name: documentSnapshot.data()['name'],
      master: documentSnapshot.data()['master'],
      members: documentSnapshot.data()['members'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'master': master,
      'members': members,
    };
    return map;
  }
}

