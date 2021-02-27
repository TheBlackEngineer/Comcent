import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class NoGroupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Ionicons.chatbox, color: Colors.grey[700], size: 75.0),
            SizedBox(height: 20.0),
            Text(
              "You've not joined any clubs",
              style: TextStyle(color: Colors.grey, fontSize: 16.0),
            ),
            SizedBox(height: 3.0),
            RichText(
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: ' Create a club',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => CreateAClub(),
                        )),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18.0,
                  ),
                ),
                TextSpan(
                  text: ' or search for one',
                  style: TextStyle(color: Colors.grey, fontSize: 18.0),
                )
              ]),
            ),
          ],
        ));
  }
}
