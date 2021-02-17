import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String email = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          title: 'Reset password',
          context: context,
          onPressed: () => Navigator.of(context).pop()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
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
            ),

            SizedBox(height: 20.0),

            // submit
            ArgonButton(
              height: 50.0,
              width: MediaQuery.of(context).size.width / 2,
              borderRadius: 5.0,
              child: GradientButton(
                elevated: false,
                borderRadius: 5.0,
                label: 'Email me a reset link',
                width: MediaQuery.of(context).size.width / 2,
              ),
              onTap: (startLoading, stopLoading, btnState) async {
                if (btnState == ButtonState.Idle &&
                    _formKey.currentState.validate()) {
                  startLoading();
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);
                  stopLoading();
                  showSnackBar(
                    message: 'A password reset link has been sent to $email',
                    context: context,
                  );
                }
              },
              loader: Container(
                padding: EdgeInsets.all(10),
                child: SpinKitRing(
                  color: Colors.white,
                  lineWidth: 2.0,
                ),
              ),
            ),

            // back to login
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Back to login'))
          ],
        ),
      ),
    );
  }
}
