import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class AddProfileImage extends StatefulWidget {
  @override
  _AddProfileImageState createState() => _AddProfileImageState();
}

class _AddProfileImageState extends State<AddProfileImage> {
  File sampleImage;

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

  // show bottom sheet for user to pick profile
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'Add profile photo',
          onPressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          Expanded(
              child: Center(
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // placeholder
                sampleImage == null
                    ? Container(
                        height: MediaQuery.of(context).size.height / 3.2,
                        child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.person,
                              size: 150.0,
                              color: Colors.white,
                            )))
                    : CircularProfileAvatar(
                        '',
                        borderColor: Colors.transparent,
                        borderWidth: 5,
                        radius: MediaQuery.of(context).size.width / 3.2,
                        child: Image.file(
                          sampleImage,
                          fit: BoxFit.cover,
                        ),
                      ),

                // choose/change profile picture
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Center(
                    child: GestureDetector(
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            sampleImage == null
                                ? 'Upload profile picture'
                                : 'Change',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                      ),
                      onTap: openBottomSheet,
                    ),
                  ),
                )
              ],
            ),
          )),
          SafeArea(
            child: GradientButton(
                label: 'Continue',
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => InterestsPage(),
                      ));
                  Provider.of<SignUpModel>(context, listen: false)
                      .profileImage = sampleImage;
                }),
          )
        ],
      ),
    );
  }
}
