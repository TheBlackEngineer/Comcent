import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class InterestsPage extends StatefulWidget {
  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  List<int> selectedIndexList = new List<int>();
  SignUpModel provider;
  CommunityProvider communityProvider;
  AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<SignUpModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'Interests',
          onPressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 40.0),
              children: [
                // image
                Image.asset('assets/illustrations/interests.png'),

                // heading
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    'Choose at least one topic or interest to help us know you more',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),

                // interest tags
                GridView.count(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  childAspectRatio: 2.7,
                  crossAxisCount: 3,
                  children: List.generate(
                    topics.length,
                    (index) => GestureDetector(
                      child: Chip(
                        elevation: 2.0,
                        backgroundColor: selectedIndexList.contains(index)
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        label: Text(topics[index]),
                        labelStyle: TextStyle(
                          color: selectedIndexList.contains(index)
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      onTap: () {
                        if (!selectedIndexList.contains(index)) {
                          selectedIndexList.add(index);
                          Provider.of<SignUpModel>(context, listen: false)
                              .addTopic(topics[index]);
                        } else {
                          selectedIndexList.remove(index);
                          Provider.of<SignUpModel>(context, listen: false)
                              .removeTopic(topics[index]);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // sign up/next button
          selectedIndexList.isNotEmpty
              ? SafeArea(
                  child: GradientButton(
                    label: provider.signingUpAsMember ? 'Sign Up' : 'Next',
                    onPressed: () {
                      provider.signingUpAsMember
                          ? _validateAndSignUp()
                          : Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ReferrerPage(),
                              ));
                    },
                  ),
                )
              : SafeArea(
                  child: DeadButton(
                    label: provider.signingUpAsMember ? 'Sign Up' : 'Next',
                  ),
                ),
        ],
      ),
    );
  }

  // upload the image to firebase storage and get the download link of the image
  Future<String> uploadImage() async {
    String imageName = provider.email.split('@').first;
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('Profiles/$imageName');
    final UploadTask uploadTask =
        storageReference.putFile(provider.profileImage);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    var url = downloadUrl.toString();
    return url;
  }

  void _validateAndSignUp() async {
    EasyLoading.show(
        status: 'Creating account',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    String profileUrl =
        provider.profileImage != null ? await uploadImage() : null;

    // create the user's account
    dynamic result = await _authService.signUpWithEmailAndPassword(
      email: provider.email.trim(),
      password: provider.password,
      firstName: provider.firstName.trim(),
      lastName: provider.lastName.trim(),
      phone: provider.phone,
      community: provider.community,
      subCommunity: provider.subCommunity,
      gender: provider.gender,
      occupation:
          provider.occupation != null ? provider.occupation.trim() : null,
      canPost: provider.signingUpAsMember ? true : false,
      dob: provider.dob,
      interests: provider.interests,
      profilePhoto: profileUrl,
      referrer: null,
    );

    // Get all posts that have a topic contained in the user's interests
    // Then set the initial timeline for the user with these posts
    provider.interests.forEach((interest) {
      FirestoreService.postsCollection
          .where('topic', isEqualTo: interest)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((queryDocumentSnapshot) {
          FirestoreService.timelineCollection
              .doc(result.id)
              .collection('feed')
              .doc(queryDocumentSnapshot.id)
              .set({
            'topic': queryDocumentSnapshot.data()['topic'],
            'timeOfUpload': queryDocumentSnapshot.data()['timeOfUpload'],
            'isLeaderPost': queryDocumentSnapshot.data()['isLeaderPost'],
          });
        });
      });
    });

    if (result.toString().contains('null')) {
      setState(() {
        String error = result.toString().split('-').first;
        EasyLoading.showError(
          error,
          dismissOnTap: true,
          duration: Duration(seconds: 5),
          maskType: EasyLoadingMaskType.black,
        );
      });
    } else {
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 4;
      });

      EasyLoading.showSuccess('Account created. Please sign in to continue',
          dismissOnTap: true, duration: Duration(seconds: 5));
    }

    EasyLoading.dismiss();
  }
}
