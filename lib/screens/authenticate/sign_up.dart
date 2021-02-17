import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';
import 'package:validated/validated.dart' as validator;

final _memberFormKey = GlobalKey<FormState>();
final _leaderFormKey = GlobalKey<FormState>();
String firstName = '';
String lastName = '';
String phone = '';
String email = '';
String password = '';
String confirmPassword = '';
String occupation;

// valid phone number checker
String _phoneNumberValidator(String value) {
  Pattern pattern = r'^(?:[+0])?[0-9]{10}$'; // Optionally match a + or 0
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Enter a valid phone Number';
  else
    return null;
}

// used by leader class
String _fileName = 'no file picked';
String _path = '...';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int currentTab = 0;
  bool showMemberScreen = true;

  List<String> tabs = ['Member', 'Leader'];

  BoxDecoration unselectedDecoration = BoxDecoration(
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'Sign up',
          onPressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
              physics: BouncingScrollPhysics(),
              children: [
                // sign up as a community
                Text(
                  'Sign up as a Community',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                  ),
                ),

                // member-leader toggle
                Container(
                  height: 60.0,
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // member
                      GestureDetector(
                        child: Material(
                          elevation: showMemberScreen ? 8.0 : 0.0,
                          color: Colors.transparent,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            decoration: showMemberScreen
                                ? BoxDecoration(
                                    color: Theme.of(context).primaryColor)
                                : unselectedDecoration,
                            child: Center(
                              child: Text(
                                tabs[0],
                                style: TextStyle(
                                    color: showMemberScreen
                                        ? Colors.white
                                        : Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          showMemberScreen
                              ? nothing()
                              : setState(() {
                                  showMemberScreen = !showMemberScreen;
                                });
                        },
                      ),

                      // leader
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            showMemberScreen
                                ? setState(() {
                                    showMemberScreen = !showMemberScreen;
                                  })
                                : nothing();
                          },
                          child: Material(
                            elevation: showMemberScreen ? 0.0 : 8.0,
                            color: Colors.transparent,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              decoration: !showMemberScreen
                                  ? BoxDecoration(
                                      color: Theme.of(context).primaryColor)
                                  : unselectedDecoration,
                              child: Center(
                                child: Text(
                                  tabs[1],
                                  style: TextStyle(
                                      color: showMemberScreen
                                          ? Colors.grey
                                          : Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // text fields
                showMemberScreen ? MemberForm() : LeaderForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void nothing() {}
}

class MemberForm extends StatefulWidget {
  @override
  _MemberFormState createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SignUpModel provider = Provider.of<SignUpModel>(context, listen: false);
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Form(
          key: _memberFormKey,
          child: Column(
            children: [
              // first name
              TextFormField(
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: textInputDecoration.copyWith(
                  hintText: 'First name*',
                ),
                validator: (value) =>
                    value.isEmpty ? 'First name cannot be empty' : null,
                onChanged: (value) {
                  setState(() => firstName = value);
                },
              ),

              SizedBox(height: 20.0),

              // last name
              TextFormField(
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Last name*',
                ),
                validator: (value) =>
                    value.isEmpty ? 'Last name cannot be empty' : null,
                onChanged: (value) {
                  setState(() => lastName = value);
                },
              ),

              SizedBox(height: 20.0),

              // phone
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Phone*',
                ),
                validator: (value) => _phoneNumberValidator(value),
                onChanged: (value) {
                  setState(() => phone = value);
                },
              ),

              SizedBox(height: 20.0),

              // email field
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Email*',
                ),
                validator: (value) =>
                    !validator.isEmail(value) ? 'Enter a valid email' : null,
                onChanged: (value) {
                  setState(() => email = value);
                },
              ),

              SizedBox(height: 20.0),

              // password field
              TextFormField(
                controller: _passwordController,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Password*',
                ),
                validator: (value) => value.length < 6
                    ? 'Password must be more than 6 characters long'
                    : null,
                obscureText: true,
                onChanged: (value) {
                  setState(() => password = value);
                },
              ),

              SizedBox(height: 20.0),

              // confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Confirm password*',
                ),
                validator: (value) {
                  if (value.length < 6)
                    return 'Password must be more than 6 characters long';
                  if (value != password) return 'Passwords do not match';
                  return null;
                },
                obscureText: true,
                onChanged: (value) {
                  setState(() => confirmPassword = value);
                },
              ),

              SizedBox(height: 20.0),

              // dob
              BasicDateField(),

              SizedBox(height: 20.0),

              // occupation
              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Occupation',
                ),
                validator: (value) =>
                    value.isEmpty ? 'Occupation cannot be empty' : null,
                onChanged: (value) {
                  setState(() => occupation = value);
                },
              ),

              SizedBox(height: 20.0),

              // gender
              GenderPicker(),

              // continue
              GradientButton(
                  label: 'Continue',
                  onPressed: () {
                    if (_memberFormKey.currentState.validate()) {
                      // go to profile
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => AddProfileImage(),
                          ));

                      // assignments
                      provider.firstName = firstName;
                      provider.lastName = lastName;
                      provider.phone = phone;
                      provider.email = email;
                      provider.password = confirmPassword;
                      provider.occupation = occupation;
                      provider.documentPath = _path;
                      provider.signingUpAsMember = true;
                    }
                  }),
            ],
          ),
        ));
  }
}

class LeaderForm extends StatefulWidget {
  @override
  _LeaderFormState createState() => _LeaderFormState();
}

class _LeaderFormState extends State<LeaderForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _proofDocumentController =
      TextEditingController(text: 'Click here to upload a supporting document');

  @override
  void dispose() {
    _passwordController.dispose();
    _proofDocumentController.dispose();
    super.dispose();
  }

  // pick document or image
  void _openFileExplorer() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'pdf', 'png'],
          );
          _path = result.files.single.path;
    } on PlatformException catch (e) {
      showSnackBar(
          message: "Unsupported operation + ${e.toString()}", context: context);
    }

    if (!mounted) return;
    setState(() {
      _fileName = _path != null
          ? _path.split('/').last
          : 'Click here to upload a supporting document';
      _proofDocumentController.text = _fileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    SignUpModel provider = Provider.of<SignUpModel>(context, listen: false);
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Form(
          key: _leaderFormKey,
          child: Column(
            children: [
              // first name
              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: textInputDecoration.copyWith(
                  hintText: 'First name*',
                ),
                validator: (value) =>
                    value.isEmpty ? 'First name cannot be empty' : null,
                onChanged: (value) {
                  setState(() => firstName = value);
                },
              ),

              SizedBox(height: 20.0),

              // last name
              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Last name*',
                ),
                validator: (value) =>
                    value.isEmpty ? 'Last name cannot be empty' : null,
                onChanged: (value) {
                  setState(() => lastName = value);
                },
              ),

              SizedBox(height: 20.0),

              // phone
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Phone*',
                ),
                validator: (value) => _phoneNumberValidator(value),
                onChanged: (value) {
                  setState(() => phone = value);
                },
              ),

              SizedBox(height: 20.0),

              // email field
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Email*',
                ),
                validator: (value) =>
                    !validator.isEmail(value) ? 'Enter a valid email' : null,
                onChanged: (value) {
                  setState(() => email = value);
                },
              ),

              SizedBox(height: 20.0),

              // password field
              TextFormField(
                controller: _passwordController,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Password*',
                ),
                validator: (value) => value.length < 6
                    ? 'Password must be more than 6 characters long'
                    : null,
                obscureText: true,
                onChanged: (value) {
                  setState(() => password = value);
                },
              ),

              SizedBox(height: 20.0),

              // confirm password field
              TextFormField(
                decoration: textInputDecoration.copyWith(
                  hintText: 'Confirm password*',
                ),
                validator: (value) {
                  if (value.length < 6)
                    return 'Password must be more than 6 characters long';
                  if (value != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
                obscureText: true,
                onChanged: (value) {
                  setState(() => confirmPassword = value);
                },
              ),

              SizedBox(height: 20.0),

              // dob
              BasicDateField(),

              SizedBox(height: 20.0),

              // occupation
              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Occupation',
                ),
                onChanged: (value) {
                  setState(() => occupation = value);
                },
                validator: (value) =>
                    value.isEmpty ? 'Occupation cannot be empty' : null,
              ),

              SizedBox(height: 20.0),

              // gender
              GenderPicker(),

              SizedBox(height: 30.0),

              // Proof of Leadership*
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Proof of Leadership*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // pick document
                  GestureDetector(
                    onTap: _openFileExplorer,
                    child: TextFormField(
                      controller: _proofDocumentController,
                      enabled: false,
                      decoration: textInputDecoration.copyWith(filled: true),
                      validator: (value) => _proofDocumentController.text
                              .contains('Click here to')
                          ? showSnackBar(
                              message: 'Please upload a proof of leadership',
                              context: context)
                          : null,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.0),

              // continue
              GradientButton(
                  label: 'Continue',
                  onPressed: () {
                    if (_leaderFormKey.currentState.validate()) {
                      // go to profile
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => AddProfileImage(),
                          ));

                      // assignments
                      provider.firstName = firstName;
                      provider.lastName = lastName;
                      provider.phone = phone;
                      provider.email = email;
                      provider.password = confirmPassword;
                      provider.occupation = occupation;
                      provider.documentPath = _path;
                      provider.signingUpAsMember = false;
                    }
                  }),
            ],
          ),
        ));
  }
}
