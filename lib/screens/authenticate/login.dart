import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'Login',
          onPressed: () => Navigator.pop(context)),
      body: ListView(
        padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 30.0),
        physics: BouncingScrollPhysics(),
        children: [
          // image
          Image.asset(
            'assets/illustrations/login.png',
            height: MediaQuery.of(context).size.width / 1.7,
          ),

          // SizedBox
          SizedBox(height: 20.0),

          // text fields
          Form(
            key: _formKey,
            child: Column(
              children: [
                // email field
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Email',
                  ),
                  validator: (value) =>
                      value.isEmpty ? 'Email cannot be empty' : null,
                  onChanged: (value) {
                    setState(() => email = value);
                  },
                ),

                SizedBox(height: 20.0),

                // password field
                TextFormField(
                  controller: _passwordController,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Password',
                  ),
                  validator: (value) => value.length < 6
                      ? 'Password must be more than 6 characters long'
                      : null,
                  obscureText: true,
                  onChanged: (value) {
                    setState(() => password = value);
                  },
                ),

                SizedBox(height: 10.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    GestureDetector(
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ResetPassword(),
                            ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // login
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                // login
                GradientButton(
                  label: 'Login',
                  onPressed: () => _validateAndLogin(),
                ),

                // 'Don't have an account?'
                Container(
                    child: Center(
                  child: RichText(
                    text: TextSpan(
                        text: 'Don\'t have an account?',
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                        children: <TextSpan>[
                          TextSpan(
                              text: ' Sign up',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 17),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // navigate to sign up screen
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => GettingStarted(),
                                      ));
                                })
                        ]),
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndLogin() async {
    if (_formKey.currentState.validate()) {
      EasyLoading.show(
        status: 'Signing in',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );

      dynamic result =
          await authService.logInWithEmailAndPassword(email, password);

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
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => PreHome(),
            ));
        EasyLoading.showSuccess('Signed in', dismissOnTap: true);
      }

      EasyLoading.dismiss();
    }
  }
}
