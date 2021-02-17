import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String name;
  final List<String> leaders, members, subCommunities;

  Community(
      {this.leaders, this.name, this.subCommunities, this.members});

  static Community fromDocument(DocumentSnapshot documentSnapshot) {
    return Community(
      name: documentSnapshot.data()['name'],
      leaders: documentSnapshot.data()['members'] ?? [],
      members: documentSnapshot.data()['members'] ?? [],
      subCommunities: documentSnapshot.data()['subCommunities'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'leaders': leaders,
      'members': members,
      'subCommunities': subCommunities,
    };
    return map;
  }
}
