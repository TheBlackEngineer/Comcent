import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Terms of Service',
              ),
              Tab(
                text: 'Privacy Policy',
              ),
            ],
          ),
          title: Text('Comcent Limited'),
        ),
        body: TabBarView(
          children: [
            // terms of service
            SingleChildScrollView(
              child: Text(
                termsOfService,
                style: TextStyle(fontSize: 15.0),
              ),
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),

            // privacy policy
            SingleChildScrollView(
              child: Text(
                privacyPolicy,
                style: TextStyle(fontSize: 15.0),
              ),
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}
