import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class RulesView extends StatefulWidget {
  final Club club;

  RulesView({Key key, @required this.club}) : super(key: key);

  @override
  _RulesViewState createState() => _RulesViewState();
}

class _RulesViewState extends State<RulesView> {
  User user;

  int fieldCount = 0;

  List<String> ruleList = [];

  TextEditingController controller = TextEditingController();
  List<TextEditingController> controllers = <TextEditingController>[];

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
          onChanged: (value) {
            setState(() {});
          },
          decoration: textInputDecoration.copyWith(
              hintText: 'New rule',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_circle,
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
    final List<Widget> textFields = _buildTextFields();
    return Scaffold(
      appBar: appBar(
          title: 'Club rules',
          context: context,
          onPressed: () => Navigator.pop(context)),
      body: StreamBuilder(
          stream:
              FirestoreService.clubsCollection.doc(widget.club.id).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List rules = snapshot.data['clubRules'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    // rules
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: rules.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                padding: EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (index + 1).toString() +
                                          '.  ' +
                                          rules[index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),

                                    // delete button
                                    IconButton(
                                      icon: Icon(Icons.remove_circle),
                                      color: Colors.red,
                                      onPressed: () {
                                        FirestoreService.clubsCollection
                                            .doc(widget.club.id)
                                            .update({
                                          'clubRules': FieldValue.arrayRemove(
                                              [widget.club.clubRules[index]])
                                        });
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                          ),

                          // subsequent new club rules
                          textFields.isNotEmpty
                              ? ListView(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  children: textFields,
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),

                    // add rule and save buttons
                    widget.club.administrators.contains(user.uid)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // add text field
                              OutlineButton(
                                  shape: StadiumBorder(),
                                  borderSide: BorderSide(color: Colors.blue),
                                  child: Text('Add',
                                      style: TextStyle(color: Colors.blue)),
                                  onPressed: () {
                                    setState(() {
                                      fieldCount++;
                                    });
                                  }),

                              // save new rules
                              textFields.isNotEmpty &&
                                      controllers[0].text.isNotEmpty
                                  ? GradientButton(
                                      label: 'Save',
                                      width: MediaQuery.of(context).size.width /
                                          4.5,
                                      height: 40.0,
                                      onPressed: () async {
                                        EasyLoading.show(
                                            status: 'Updating...',
                                            maskType: EasyLoadingMaskType.black,
                                            dismissOnTap: true);

                                        controllers.forEach((controller) {
                                          ruleList.add(controller.text);
                                        });

                                        await FirestoreService.clubsCollection
                                            .doc(widget.club.id)
                                            .update({
                                          'clubRules':
                                              FieldValue.arrayUnion(ruleList),
                                        }).whenComplete(() {
                                          setState(() {
                                            textFields.clear();
                                          });
                                          EasyLoading.dismiss();
                                        });
                                      })
                                  : DeadButton(
                                      label: 'Save',
                                      width: MediaQuery.of(context).size.width /
                                          4.5,
                                      height: 40.0,
                                    )
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
