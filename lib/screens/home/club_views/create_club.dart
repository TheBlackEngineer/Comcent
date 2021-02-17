import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class CreateAClub extends StatefulWidget {
  @override
  _CreateAClubState createState() => _CreateAClubState();
}

class _CreateAClubState extends State<CreateAClub> {
  File sampleImage;
  String clubName = '';
  String clubDescription = '';
  final _formKey = GlobalKey<FormState>();
  List<String> ruleList = [];
  int fieldCount = 0;
  User user;
  CommunityProvider signedInUser;

  // you must keep track of the TextEditingControllers if you want the values
  // to persist correctly
  List<TextEditingController> controllers = <TextEditingController>[];
  TextEditingController controller = TextEditingController();

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
        return Column(
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
        );
      },
    );
  }

  // upload the image to firebase storage and get the download link of the image
  Future<String> uploadImage(String id) async {
    String imageName = id;
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child('ClubProfiles/$imageName');
    final StorageUploadTask uploadTask = storageReference.putFile(sampleImage);
    var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downloadUrl.toString();
    return url;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    controllers.forEach((controller) {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    signedInUser = Provider.of<CommunityProvider>(context);
    final List<Widget> textFields = _buildTextFields();
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'Create club',
          onPressed: () => Navigator.pop(context)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        physics: BouncingScrollPhysics(),
        children: [
          // placeholder
          sampleImage == null
              ? Container(
                  height: MediaQuery.of(context).size.height / 4.8,
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
                  child: GestureDetector(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add_a_photo,
                        size: 100.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: openBottomSheet,
                  ),
                )
              : GestureDetector(
                  child: Container(
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
                    child: CircularProfileAvatar(
                      '',
                      borderColor: Colors.transparent,
                      borderWidth: 5,
                      radius: MediaQuery.of(context).size.width / 4.8,
                      child: Image.file(
                        sampleImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: openBottomSheet,
                ),

          // text fields
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // club name
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Club Name',
                    ),
                    validator: (value) =>
                        value.isEmpty ? 'This field cannot be empty' : null,
                    onChanged: (value) {
                      setState(() => clubName = value);
                    },
                  ),

                  SizedBox(height: 30.0),

                  // club description
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Club Description',
                    ),
                    maxLines: null,
                    validator: (value) =>
                        value.isEmpty ? 'This field cannot be empty' : null,
                    onChanged: (value) {
                      setState(() => clubDescription = value);
                    },
                  ),

                  SizedBox(height: 30.0),

                  // first club rule
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Club Rules and Regulations',
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                fieldCount++;
                              });
                            },
                          )),
                    ),
                  ),

                  // subsequent club rules
                  textFields.isNotEmpty
                      ? Column(
                          children: textFields,
                        )
                      : SizedBox.shrink(),

                  SizedBox(height: 50.0),
                ],
              ),
            ),
          ),

          // create and cancel buttons
          Column(
            children: [
              // create group
              Container(
                width: double.infinity,
                height: 50.0,
                child: FlatButton(
                  child: Text(
                    'Create',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: () async {
                    String id = Uuid().v4();
                    if (_formKey.currentState.validate()) {
                      await EasyLoading.show(
                          status: 'Please wait',
                          maskType: EasyLoadingMaskType.black,
                          dismissOnTap: true);

                      // validate and add the rules to the rule list
                      if (controller.text.isNotEmpty)
                        ruleList.add(controller.text);
                      controllers.forEach((controller) {
                        if (controller.text.isNotEmpty)
                          ruleList.add(controller.text);
                      });

                      String imageUrl =
                          sampleImage != null ? await uploadImage(id) : null;

                      // create a club object
                      Club club = Club(
                        id: id,
                        name: clubName.toLowerCase().endsWith('club')
                            ? clubName
                            : (clubName + ' Club'),
                        description: clubDescription,
                        creator: user.uid,
                        clubPhoto: imageUrl,
                        master: signedInUser.person.community,
                        removedMembers: [],
                        membershipRequests: [],
                        clubRules: ruleList,
                      );

                      // create document in database
                      String response = await FirestoreService.createClub(club);

                      response != null
                          ? EasyLoading.showSuccess('Club created 🎉',
                              dismissOnTap: true)
                          : EasyLoading.showError('Unable to create club',
                              dismissOnTap: true);

                      EasyLoading.dismiss();

                      Navigator.pop(context);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),

              SizedBox(height: 15.0),

              // cancel
              GradientButton(
                label: 'Cancel',
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ],
      ),
    );
  }

  // create the list of TextFields, based off the list of TextControllers
  List<Widget> _buildTextFields() {
    int i;

    // fill in keys if the list is not long enough (in case we added one)
    if (controllers.length < fieldCount) {
      for (i = controllers.length; i < fieldCount; i++) {
        controllers.add(TextEditingController());
      }
    }

    i = 0;

    // cycle through the controllers, and recreate each, one per available controller
    return controllers.map<Widget>((TextEditingController controller) {
      i++;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: controller,
          decoration: textInputDecoration.copyWith(
              hintText: 'Rule #${i + 1}',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
                onPressed: () {
                  // when removing a TextField, you must do two things:
                  // 1. decrement the number of controllers you should have (fieldCount)
                  // 2. actually remove this field's controller from the list of controllers
                  setState(() {
                    fieldCount--;
                    controllers.remove(controller);
                  });
                },
              )),
        ),
      );
    }).toList(); // convert to a list
  }
}
