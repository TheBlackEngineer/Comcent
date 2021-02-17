import 'package:comcent/imports.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get the uid of the current user logged in
  String get getCurrentUserID {
    return _auth.currentUser.uid;
  }

  // create a person object based on firebase user object
  Person _userFromFirebaseUser(User user) {
    return user != null ? Person(id: user.uid) : null;
  }

  // auth change user stream. We're listening to event changes i.e login and logout
  Stream<User> get firebaseUser => _auth.authStateChanges();

  // sign in with email and password
  Future logInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      return error.message + '-null';
    }
  }

  // sign up with email and password
  Future signUpWithEmailAndPassword({
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
    String community,
    String subCommunity,
    String gender,
    String occupation,
    bool canPost,
    Timestamp dob,
    List<String> interests,
    String profilePhoto,
    String referrer,
  }) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User user = result.user;

      // create a new document for the user with the uid
      await FirestoreService(uid: user.uid).setInitialUserData(
        id: user.uid,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: user.email,
        bio: null,
        community: community,
        subCommunity: subCommunity,
        gender: gender,
        occupation: occupation,
        followers: [],
        following: [],
        posts: [],
        interests: interests,
        profilePhoto: profilePhoto,
        referrer: referrer,
        isLeader: false,
        canPost: canPost,
        privateProfile: false,
        dob: dob,
        dateJoined: Timestamp.now(),
      );

      return _userFromFirebaseUser(user);
    } catch (error) {
      return error.message + '-null';
    }
  }

  // sign out
  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}

