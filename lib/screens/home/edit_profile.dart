import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  Person userData;

  File sampleImage;

  String firstName, lastName, bio, phone;

  String userProfileImage;

  CommunityProvider _communityProvider;

  @override
  void initState() {
    super.initState();
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    userData = _communityProvider.person;
    userProfileImage = userData.profilePhoto;
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    Timestamp timestamp = userData.dob;
    DateTime dob = timestamp != null ? timestamp.toDate() : null;

    return Scaffold(
        appBar: appBar(
            title: 'Edit profile',
            context: context,
            onPressed: () => Navigator.pop(context)),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            // profile image
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[350],
                          offset: Offset(0.0, 5.0), //(x,y)
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: sampleImage == null
                        ? userProfileImage == null
                            ? CircleAvatar(
                                radius: MediaQuery.of(context).size.width / 7.5,
                                child: Icon(Icons.person, size: 60.0),
                              )
                            : CircularProfileAvatar(
                                userData.profilePhoto,
                                radius: MediaQuery.of(context).size.width / 7.5,
                              )
                        : CircularProfileAvatar(
                            '',
                            radius: MediaQuery.of(context).size.width / 7.5,
                            child: Image.file(
                              sampleImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),

                  // tap to change
                  GestureDetector(
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          'Change',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15.0),
                        ),
                      ),
                    ),
                    onTap: openBottomSheet,
                  ),
                ],
              ),
            ),

            // text fields showing name, phone, description, and others
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 30.0),

                  // username field
                  Row(
                    children: [
                      // first name
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text('First name'),
                              ),
                              TextFormField(
                                initialValue: userData.firstName,
                                decoration: textInputDecoration.copyWith(
                                    prefixIcon: Icon(Icons.person_outline)),
                                validator: (value) => value.isEmpty
                                    ? 'First name cannot be empty'
                                    : null,
                                onChanged: (value) {
                                  setState(() => firstName = value.trim());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // last name
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text('Last name'),
                              ),
                              TextFormField(
                                initialValue: userData.lastName,
                                decoration: textInputDecoration.copyWith(
                                    prefixIcon: Icon(Icons.person_outline)),
                                validator: (value) => value.isEmpty
                                    ? 'Last name cannot be empty'
                                    : null,
                                onChanged: (value) {
                                  setState(() => lastName = value.trim());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.0),

                  // bio field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Bio'),
                        ),
                        TextFormField(
                          maxLines: null,
                          initialValue: userData.bio,
                          decoration: textInputDecoration.copyWith(
                              prefixIcon: Icon(Icons.info_outline)),
                          onChanged: (value) {
                            setState(() => bio = value.trim());
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.0),

                  // phone field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Phone'),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: userData.phone,
                          decoration: textInputDecoration.copyWith(
                              prefixIcon: Icon(Icons.phone)),
                          onChanged: (value) {
                            setState(() => phone = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.0),

                  // dob
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Date of birth'),
                        ),
                        BasicDateField1(
                          hintText: dob != null
                              ? DateFormat.yMMMd().format(dob)
                              : ' Tap to change',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.0),

                  // save changes button
                  GradientButton(
                    label: 'Save',
                    onPressed: () async {
                      await _validateChangesAndSubmit(user, userData, context);
                    },
                  )
                ],
              ),
            )
          ],
        ));
  }

  Future _validateChangesAndSubmit(
      User user, Person userData, BuildContext context) async {
    if (_formKey.currentState.validate()) {
      await EasyLoading.show(
          status: 'Updating...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: true);

      String imageName = _communityProvider.person.email.split('@')[0];

      if (sampleImage != null || userProfileImage == null) {
        // delete old dp
        await FirestoreService.deleteFile(
            fileName: imageName, fileType: 'Profile');

        // upload new one and get it's url
        if (sampleImage != null) {
          String downloadUrl = await uploadImage(
              imageName: userData.email.split('@')[0], imageFile: sampleImage);
          setState(() {
            userProfileImage = downloadUrl;
          });
        }
      }

      // update the url stored in firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': firstName ?? userData.firstName,
        'lastName': lastName ?? userData.lastName,
        'bio': bio ?? userData.bio,
        'phone': phone ?? userData.phone,
        'dob': Provider.of<SignUpModel>(context, listen: false).dob ??
            userData.dob,
        'profilePhoto': userProfileImage,
      }).then((value) {
        Navigator.pop(context);
        EasyLoading.dismiss();
      });
      showSnackBar(context: context, message: 'Profile updated');
    }
  }

  Future openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // camera image
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take photo'),
                onTap: () {
                  Navigator.pop(context);
                  takePhoto();
                },
              ),

              // gallery image
              ListTile(
                leading: Icon(Icons.image_sharp),
                title: Text('Open gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),

              // remove image
              ListTile(
                leading: Icon(Icons.clear),
                title: Text('Remove'),
                onTap: () {
                  Navigator.pop(context);
                  removePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // pick image from gallery
  Future openGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  // take photo with camera
  Future takePhoto() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      sampleImage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  // remove picture
  removePicture() {
    setState(() {
      sampleImage = null;
      userProfileImage = null;
    });
  }

  // upload image to storage
  // upload the image to firebase storage and get the download link of the image
  Future<String> uploadImage(
      {@required String imageName, @required File imageFile}) async {
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('Profiles/$imageName');
    final UploadTask uploadTask = storageReference.putFile(imageFile);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    var url = downloadUrl.toString();
    return url;
  }
}
