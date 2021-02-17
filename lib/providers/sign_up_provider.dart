import 'package:comcent/imports.dart';

// ignore: must_be_immutable
class SignUpModel extends ChangeNotifier {
  // needed before one can sign up
  String firstName;
  String lastName;
  String phone;
  String email;
  String password;
  String community;
  String subCommunity;
  String documentPath;
  String gender;
  String occupation;
  String referrer;
  Timestamp dob;
  List<String> interests = [];

  bool signingUpAsMember;

  // optional

  File profileImage;

  void addTopic(String topic) {
    interests.add(topic);
    notifyListeners();
  }

  void removeTopic(String topic) {
    interests.remove(topic);
    notifyListeners();
  }
}
