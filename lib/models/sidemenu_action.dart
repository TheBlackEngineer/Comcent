import 'package:flutter/material.dart';

class SideMenuAction {
  final IconData iconData;
  final String title;
  final Function onTap;

  const SideMenuAction(
      {Key key,
      @required this.iconData,
      @required this.title,
      @required this.onTap});
}
