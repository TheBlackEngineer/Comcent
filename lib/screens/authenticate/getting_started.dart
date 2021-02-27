import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class GettingStarted extends StatefulWidget {
  @override
  _GettingStartedState createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  final TextEditingController controller = TextEditingController();

  String searchText = '';
  List<SubCommunity> searchList = [];
  SubCommunity community;
  Color radioColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    CommunityProvider provider =
        Provider.of<CommunityProvider>(context, listen: false);
    searchList = provider.communities
        .where((community) => community.name.toLowerCase().contains(searchText))
        .toList();
    return Scaffold(
      appBar: appBar(
          context: context,
          title: 'Getting started',
          onPressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                // image
                Image.asset('assets/illustrations/people.png'),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // enter your community name
                      Text(
                        searchText.isNotEmpty && searchList.isNotEmpty
                            ? "${searchList.length} results found for ' ${controller.text} '"
                            : 'Enter your community name',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18.0),
                      ),

                      SizedBox(height: 15.0),

                      // textfield
                      TextField(
                        controller: controller,
                        onChanged: (value) {
                          setState(() {
                            searchText = value.toLowerCase();
                          });
                        },
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Search communities'),
                      ),

                      // search results
                      searchText.isNotEmpty
                          ? searchList.isNotEmpty
                              ? ListView.builder(
                                  itemCount: searchList.length,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    SubCommunity subCommunity =
                                        searchList[index];
                                    return GestureDetector(
                                        onTap: () {
                                          print(subCommunity.members.length);
                                        },
                                        child: Card(
                                          elevation: 3.0,
                                          shadowColor: Colors.grey[200],
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 18.0),
                                                title: Text(subCommunity.name),
                                                subtitle: Text(
                                                    "in ${subCommunity.master} community"),
                                                trailing:
                                                    CircularPercentIndicator(
                                                  radius: 19.0,
                                                  lineWidth: 7.0,
                                                  percent: 1.0,
                                                  center: CircleAvatar(
                                                    radius: 6.0,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: CircleAvatar(
                                                      radius: 4.0,
                                                      backgroundColor:
                                                          radioColor,
                                                    ),
                                                  ),
                                                  progressColor: Colors.blue,
                                                ),
                                                onTap: () {
                                                  CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.info,
                                                      confirmBtnText: 'Okay',
                                                      cancelBtnText: 'Cancel',
                                                      showCancelBtn: true,
                                                      onConfirmBtnTap: () {
                                                        searchText = '';
                                                        Navigator.pop(context);
                                                        controller.text =
                                                            subCommunity.name;

                                                        setState(() {
                                                          radioColor =
                                                              Colors.red;
                                                          community =
                                                              subCommunity;
                                                          radioColor =
                                                              Colors.blue;
                                                        });

                                                        Provider.of<SignUpModel>(
                                                                    context,
                                                                    listen: false)
                                                                .community =
                                                            community.master;

                                                        Provider.of<SignUpModel>(
                                                                    context,
                                                                    listen: false)
                                                                .subCommunity =
                                                            community.name;
                                                      },
                                                      text:
                                                          'You have selected ${subCommunity.name}. You will be grouped under the community ${subCommunity.name} belongs to.');
                                                },
                                              ),
                                            ],
                                          ),
                                        ));
                                  })
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                      "Sorry, '${controller.text}' has not been launched yet 😢",
                                      style: TextStyle(fontSize: 18.0)),
                                )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            ),
          ),

          // next
          this.community != null && controller.text.isNotEmpty
              ? SafeArea(
                child: GradientButton(
                    label: 'Next',
                    onPressed: () {
                      // go to forms
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SignUp(),
                          ));
                    },
                  ),
              )
              : SafeArea(child: DeadButton(label: 'Next'))
        ],
      ),
    );
  }
}
