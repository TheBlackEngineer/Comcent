import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

showSnackBar({@required String message, @required BuildContext context}) {
  return Flushbar(
    flushbarStyle: FlushbarStyle.FLOATING,
    margin: EdgeInsets.all(8.0),
    duration: Duration(seconds: 5),
    borderRadius: 5.0,
    reverseAnimationCurve: Curves.linear,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    messageText: Text(
      message,
      style: TextStyle(
        fontSize: 17.0,
        color: Colors.white,
      ),
    ),
  )..show(context);
}

showSendingAttachments(BuildContext context) {
  return Flushbar(
    title: 'Sending attachment',
    flushbarPosition: FlushbarPosition.BOTTOM,
    flushbarStyle: FlushbarStyle.GROUNDED,
    boxShadows: [
      BoxShadow(
          color: Colors.blue[800], offset: Offset(0.0, 2.0), blurRadius: 3.0)
    ],
    backgroundGradient: LinearGradient(colors: [Colors.blueGrey, Colors.black]),
    isDismissible: false,
    duration: Duration(seconds: 4),
    icon: Icon(
      Icons.check,
      color: Colors.greenAccent,
    ),
    mainButton: FlatButton(
      onPressed: () {},
      child: Text(
        "CLAP",
        style: TextStyle(color: Colors.amber),
      ),
    ),
    showProgressIndicator: true,
    progressIndicatorBackgroundColor: Colors.blueGrey,
    titleText: Text(
      "Hello Hero",
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.yellow[600],
          fontFamily: "ShadowsIntoLightTwo"),
    ),
    messageText: Text(
      "You killed that giant monster in the city. Congratulations!",
      style: TextStyle(
          fontSize: 18.0,
          color: Colors.green,
          fontFamily: "ShadowsIntoLightTwo"),
    ),
  )..show(context);
}
