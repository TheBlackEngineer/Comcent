import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
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
  final List followers, following, posts, interests;
  final bool isLeader, canPost, privateProfile;
  final Timestamp dateJoined, dob;

  Person({
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
    this.followers,
    this.following,
    this.posts,
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
      followers: documentSnapshot.data()['followers'] ?? [],
      following: documentSnapshot.data()['following'] ?? [],
      posts: documentSnapshot.data()['posts'] ?? [],
      interests: documentSnapshot.data()['interests'] ?? [],
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

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'bio': bio,
      'community': community,
      'subCommunity': subCommunity,
      'followers': followers,
      'following': following,
      'posts': posts,
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
