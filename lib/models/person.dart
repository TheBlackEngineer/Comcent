import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final int posts, numberOfWeOurPosts;
  final String id,
      firstName,
      lastName,
      phone,
      email,
      bio,
      community,
      subCommunity,
      gender,
      occupation,
      referrer,
      profilePhoto;
  final List interests;
  final bool isLeader, canPost, privateProfile;
  final Timestamp dateJoined, dob;

  Person({
    this.posts,
    this.numberOfWeOurPosts,
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.bio,
    this.community,
    this.subCommunity,
    this.gender,
    this.occupation,
    this.interests,
    this.referrer,
    this.profilePhoto,
    this.isLeader,
    this.canPost,
    this.privateProfile,
    this.dob,
    this.dateJoined,
  });

  static Person fromDocument(DocumentSnapshot documentSnapshot) {
    return Person(
      id: documentSnapshot.data()['id'],
      firstName: documentSnapshot.data()['firstName'],
      lastName: documentSnapshot.data()['lastName'],
      phone: documentSnapshot.data()['phone'],
      email: documentSnapshot.data()['email'],
      bio: documentSnapshot.data()['bio'],
      community: documentSnapshot.data()['community'],
      subCommunity: documentSnapshot.data()['subCommunity'],
      interests: documentSnapshot.data()['interests'] ?? [],
      posts: documentSnapshot.data()['posts'],
      numberOfWeOurPosts: documentSnapshot.data()['numberOfWeOurPosts'],
      profilePhoto: documentSnapshot.data()['profilePhoto'],
      referrer: documentSnapshot.data()['referrer'],
      occupation: documentSnapshot.data()['occupation'],
      gender: documentSnapshot.data()['gender'],
      dob: documentSnapshot.data()['dob'],
      isLeader: documentSnapshot.data()['isLeader'] ?? false,
      canPost: documentSnapshot.data()['canPost'] ?? true,
      privateProfile: documentSnapshot.data()['privateProfile'] ?? false,
      dateJoined: documentSnapshot.data()['dateJoined'],
    );
  }

  static Person fromMap(Map<String, dynamic> map) {
    return Person(
      posts: map['posts'],
      numberOfWeOurPosts: map['numberOfWeOurPosts'],
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      email: map['email'],
      bio: map['bio'],
      subCommunity: map['subCommunity'],
      community: map['community'],
      interests: map['interests'],
      profilePhoto: map['profilePhoto'],
      referrer: map['referrer'],
      occupation: map['occupation'],
      gender: map['gender'],
      dob: map['dob'],
      isLeader: map['isLeader'],
      canPost: map['canPost'],
      privateProfile: map['privateProfile'],
      dateJoined: map['dateJoined'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'posts': posts,
      'numberOfWeOurPosts': numberOfWeOurPosts,
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'bio': bio,
      'community': community,
      'subCommunity': subCommunity,
      'interests': interests,
      'referrer': referrer,
      'profilePhoto': profilePhoto,
      'occupation': occupation,
      'gender': gender,
      'dob': dob,
      'isLeader': isLeader,
      'canPost': canPost,
      'privateProfile': privateProfile,
      'dateJoined': Timestamp.now(),
    };
    return map;
  }
}
