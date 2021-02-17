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
          // account icon
          Column(
            children: [
              CircleAvatar(
                child: Icon(Icons.person),
              ),
              SizedBox(height: 8.0),
              Text('Account',
                  style: TextStyle(color: Theme.of(context).primaryColor))
            ],
          ),

          // account actions
          Column(
            children: [
              // privacy
              ListTile(
                  title:
                      Text('Privacy', style: TextStyle(color: Colors.black54)),
                  leading: CircleAvatar(
                    child:
                        Icon(Feather.lock, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PrivacyScreen(),
                        ));
                  }),

              // edit profile
              ListTile(
                  title: Text('Edit profile',
                      style: TextStyle(color: Colors.black54)),
                  leading: CircleAvatar(
                    child: Icon(AntDesign.edit, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => EditProfile(),
                        ));
                  }),

              // edit interests
              ListTile(
                  title: Text('Edit interests',
                      style: TextStyle(color: Colors.black54)),
                  leading: CircleAvatar(
                    child: Icon(Icons.topic, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => EditInterests(),
                        ));
                  }),
            ],
          ),

          Divider(),
          SizedBox(height: 20.0),

          // account icon
          Column(
            children: [
              CircleAvatar(
                child: Icon(AntDesign.warning),
              ),
              SizedBox(height: 8.0),
              Text('Other',
                  style: TextStyle(color: Theme.of(context).primaryColor))
            ],
          ),

          // logout
          ListTile(
            leading: CircleAvatar(
              child: Icon(AntDesign.logout),
            ),
            title: Text('Log out', style: TextStyle(color: Colors.black54)),
            onTap: () async {
              await controlLogout(context);
            },
          ),

          Divider(),
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
