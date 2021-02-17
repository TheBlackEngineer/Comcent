import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class PrivacyScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          title: 'Privacy',
          context: context,
          onPressed: () => Navigator.pop(context)),
      body: StreamBuilder<Person>(
          stream: FirestoreService(uid: _authService.getCurrentUserID).userData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            } else {
              Person person = snapshot.data;
              return ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  //showPhone
                  SwitchListTile(
                    value: person.privateProfile,
                    onChanged: (value) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(person.id)
                          .update({
                        'privateProfile': value,
                      });
                    },
                    title: Text('Make my profile private'),
                    subtitle: Text(
                        'When on, other users cannot see your posts when they visit your profile'),
                  ),
                ],
              );
            }
          }),
    );
  }
}
