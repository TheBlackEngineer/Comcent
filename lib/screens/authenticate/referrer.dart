import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class ReferrerPage extends StatefulWidget {
  @override
  _ReferrerPageState createState() => _ReferrerPageState();
}

class _ReferrerPageState extends State<ReferrerPage> {
  SignUpModel provider;
  AuthService _authService;
  TextEditingController textEditingController;
  List<String> imageExtensions = ['jpg', 'jpeg', 'png'];

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    textEditingController = TextEditingController();
    provider = Provider.of<SignUpModel>(context, listen: false);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'One last thing..',
          onPressed: () => Navigator.pop(context)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            // descriptive text
            Text(
              'Tell us how you heard about Comcent. If someone referred you, input their name in the text box below. Please note that this step is optional',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, wordSpacing: 2.0),
            ),

            // text field
            Expanded(
              child: Center(
                child: TextField(
                  decoration:
                      textInputDecoration.copyWith(hintText: 'Type here...'),
                  controller: textEditingController,
                  onChanged: (String value) {
                    provider.referrer = textEditingController.text;
                  },
                ),
              ),
            ),

            // sign up button
            GradientButton(
              label: 'Sign Up',
              onPressed: () => _validateAndSignUp(),
            )
          ],
        ),
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

  // upload supporting document to firebase storage
  Future<String> uploadDocument() async {
    String fileName;
    String fileXtension =
        (provider.documentPath.split('/').last.split('.')).last;

    if (imageExtensions.contains(fileXtension)) {
      fileName = provider.email.split('@').first + '.img';
    } else {
      fileName = provider.email.split('@').first + '.doc';
    }
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('Documents/$fileName');

    final UploadTask uploadTask = storageRef.putFile(
      File(provider.documentPath),
    );
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
    String documentUrl =
        provider.signingUpAsMember ? null : await uploadDocument();

    dynamic result = await _authService.signUpWithEmailAndPassword(
      email: provider.email.trim(),
      password: provider.password,
      firstName: provider.firstName.trim(),
      lastName: provider.lastName.trim(),
      phone: provider.phone.trim(),
      community: provider.community,
      subCommunity: provider.subCommunity,
      gender: provider.gender,
      occupation: provider.occupation.trim(),
      canPost: provider.signingUpAsMember ? true : false,
      dob: provider.dob,
      interests: provider.interests,
      profilePhoto: profileUrl,
      referrer: textEditingController.text.trim().isNotEmpty
          ? textEditingController.text.trim()
          : null,
    );

    if (result.toString().contains('null')) {
      setState(() {
        String error = result.toString().split('-')[0];
        EasyLoading.showError(
          error,
          dismissOnTap: true,
          duration: Duration(seconds: 5),
          maskType: EasyLoadingMaskType.black,
        );
      });
    }

    if (!result.toString().contains('null')) {
      // add new user document to firestore
      await FirestoreService.addMember(
        person: Person(
            id: result.id,
            community: provider.community,
            subCommunity: provider.subCommunity),
      );

      // upload user proof of leadership document to firestore if any
      documentUrl != null
          ? FirestoreService.addDocument(Document(
              ownerID: result.id, url: documentUrl, email: provider.email))
          : print(1);

      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 5;
      });

      EasyLoading.showSuccess('Account created. Please sign in to continue',
          dismissOnTap: true, duration: Duration(seconds: 5));
    }

    EasyLoading.dismiss();
  }
}
