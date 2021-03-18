import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Authenticate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // welcome image, login, and sign up buttons
          Expanded(
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                // welcome illustration
                Container(
                  child: Image.asset('assets/illustrations/welcome.png',
                      width: double.infinity),
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 5),
                ),

                // login and sign up buttons
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 11),
                  child: Column(
                    children: [
                      // login
                      LoginButton(),

                      // spacer
                      SizedBox(height: 8.0),

                      // sign up
                      GradientButton(
                        label: 'Sign Up',
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => GettingStarted(),
                              ));
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // terms and conditions + privacy policy
          SafeArea(
            child: GestureDetector(
              child: Text(
                'Terms and Conditions | Privacy Policy',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => TermsAndConditions(),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      height: 50.0,
      child: OutlineButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => Login(),
              ));
        },
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        child: Text(
          'Login',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        shape: StadiumBorder(),
      ),
    );
  }
}
