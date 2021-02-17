import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class CommunityProvider extends ChangeNotifier {
  List<SubCommunity> communities;
  Person person = Person();
  CommunityProvider({@required this.communities});
}
