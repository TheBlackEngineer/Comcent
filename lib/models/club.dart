import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String id,
      name,
      description,
      creator, // the uid of the creator
      clubPhoto,
      master; // master refers to the community the club belongs to
  final List members,
      administrators,
      removedMembers,
      membershipRequests,
      clubRules;
  final Timestamp dateCreated;

  Club(
      {this.id,
      this.name,
      this.description,
      this.creator,
      this.clubPhoto,
      this.master,
      this.members,
      this.administrators,
      this.removedMembers,
      this.membershipRequests,
      this.clubRules,
      this.dateCreated});

  static Club fromDocument(DocumentSnapshot documentSnapshot) {
    return Club(
      id: documentSnapshot.data()['id'],
      master: documentSnapshot.data()['master'],
      name: documentSnapshot.data()['name'],
      clubPhoto: documentSnapshot.data()['clubPhoto'],
      description: documentSnapshot.data()['description'],
      creator: documentSnapshot.data()['creator'],
      members: documentSnapshot.data()['members'] ?? [],
      administrators: documentSnapshot.data()['administrators'] ?? [],
      removedMembers: documentSnapshot.data()['removedMembers'] ?? [],
      membershipRequests: documentSnapshot.data()['membershipRequests'] ?? [],
      clubRules: documentSnapshot.data()['clubRules'] ?? [],
      dateCreated: documentSnapshot.data()['dateCreated'],
    );
  }

  static Club fromMap(Map<String, dynamic> map) {
    return Club(
      id: map['id'],
      master: map['master'],
      name: map['name'],
      clubPhoto: map['clubPhoto'],
      description: map['description'],
      creator: map['creator'],
      members: map['members'],
      administrators: map['administrators'],
      removedMembers: map['removedMembers'],
      membershipRequests: map['membershipRequests'],
      clubRules: map['clubRules'],
      dateCreated: map['dateCreated'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'master': master,
      'name': name,
      'description': description,
      'creator': creator,
      'clubPhoto': clubPhoto,
      'members': members,
      'administrators': administrators,
      'removedMembers': removedMembers,
      'membershipRequests': membershipRequests,
      'clubRules': clubRules,
      'dateCreated': Timestamp.now(),
    };
    return map;
  }
}
