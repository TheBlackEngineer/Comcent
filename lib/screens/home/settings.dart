import 'package:comcent/widgets/theme_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          title: 'Settings',
          context: context,
          onPressed: () => Navigator.pop(context)),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: 20.0),

          // Privacy
          ListTile(
              title: Text('Privacy'),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Feather.lock, color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => PrivacyScreen(),
                    ));
              }),

          // Edit profile
          ListTile(
              title: Text('Edit profile'),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(AntDesign.edit, color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => EditProfile(),
                    ));
              }),

          // Edit interests
          ListTile(
              title: Text('Edit interests'),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.topic, color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => EditInterests(),
                    ));
              }),

          // Choose theme
          ListTile(
              title: Text('Choose theme'),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(FontAwesome5Solid.moon, color: Colors.white),
              ),
              onTap: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => ThemePage()));
              }),

          Divider(),
          SizedBox(height: 20.0),

          // logout
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(AntDesign.logout, color: Colors.white),
            ),
            title: Text('Log out'),
            onTap: () async {
              await controlLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Future controlLogout(BuildContext context) async {
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Log out'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              CupertinoDialogAction(
                child: Text('Yes'),
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      CupertinoPageRoute(builder: (context) => Authenticate()));
                  await AuthService().signOut();
                },
              ),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(ctx);
                },
              )
            ],
          );
        });
  }
}
