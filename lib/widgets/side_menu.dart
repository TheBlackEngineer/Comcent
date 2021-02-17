import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class SideMenu extends StatefulWidget {
  static final AuthService authService = AuthService();

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  List<SideMenuAction> actions;
  CommunityProvider _provider;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<CommunityProvider>(context, listen: false);
    actions = [
      // settings
      SideMenuAction(
          iconData: Icons.settings,
          title: 'Settings',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => AccountSettings(),
                ));
          }),

      // bookmarks
      SideMenuAction(
          iconData: Icons.bookmark_border_rounded,
          title: 'Bookmarks',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => Bookmarks(person: _provider.person),
                ));
          }),

      // faq
      SideMenuAction(
          iconData: SimpleLineIcons.question,
          title: 'FAQs',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => FAQ(),
                ));
          }),

      // report a problem
      SideMenuAction(
          iconData: Icons.bug_report_outlined,
          title: 'Report a problem',
          onTap: () async => await sendMail()),

      // exit app
      SideMenuAction(
          iconData: Icons.exit_to_app,
          title: 'Exit app',
          onTap: () =>
              SystemChannels.platform.invokeMethod('SystemNavigator.pop')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (_provider.person.posts.length / 400) * 100;

    return Drawer(
      key: _scaffoldKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // user profile image, name, and occupation
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 50.0),
              child: GestureDetector(
                  child: Stack(
                    children: [
                      // teal bar showing name, occupation, and sub-community
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 8.0),
                        margin: const EdgeInsets.only(left: 50.0, top: 20.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(50.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0.0,
                              offset: Offset(0.0, 2.0), //(x,y)
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // username
                            Text(
                              '${_provider.person.firstName} ${_provider.person.lastName}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                            ),

                            // occupation
                            Text(
                              '${_provider.person.occupation}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.0,
                              ),
                            )
                          ],
                        ),
                      ),

                      // profile picture
                      CircleAvatar(
                        radius: 45.0,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.transparent,
                          child: _provider.person.profilePhoto != null
                              ? CircularProfileAvatar(
                                  _provider.person.profilePhoto,
                                )
                              : CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              Profile(userID: _provider.person.id),
                        ));
                  }),
            ),

            Divider(),

            _provider.person.isLeader
                ? SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Text('Leadership Progress',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),

                      // slider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: LinearPercentIndicator(
                                padding: const EdgeInsets.only(right: 12.0),
                                percent: percentage / 100,
                                lineHeight: 3.0,
                                backgroundColor: Colors.grey,
                                progressColor: Colors.blue,
                              ),
                            ),

                            // percentage
                            Text(
                              percentage.toString() + '%',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      ),

                      // description of leadership progress
                      Text(
                          'Your leadership progress is determined by how often you post using "we" or our". Also, by how active your profile is.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),

            // actions
            Flexible(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    SideMenuAction action = actions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(action.iconData, color: Colors.white),
                      ),
                      title: Text(action.title,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      onTap: action.onTap,
                    );
                  },
                  itemCount: actions.length),
            ),
          ],
        ),
      ),
    );
  }

  Future controlLogout(BuildContext ctx) async {
    showCupertinoDialog(
        context: _scaffoldKey.currentContext,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Log out'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              CupertinoDialogAction(
                child: Text('Yes'),
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.pop(context);
                  AuthService().signOut();
                  Navigator.of(ctx).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  // launches the user's mail app and prepares it for sending a mail
  Future<void> sendMail() async {
    final Email email = Email(
      body: '',
      subject: 'Feedback - Comcent App',
      recipients: ['othnielussher16@outlook.com', 'comcentlimited@gmail.com'],
      isHTML: false,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'Thanks for the feedback!';
    } catch (error) {
      platformResponse = error.toString();
    }

    showSnackBar(message: platformResponse, context: context);
  }
}
