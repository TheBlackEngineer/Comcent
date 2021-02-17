import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class FAQ extends StatefulWidget {
  static List<Item> generateItems(int numberOfItems) {
    return List.generate(numberOfItems, (int index) {
      return Item(
        headerValue: faqQuestions[index],
        expandedValue: faqAnswers[index],
      );
    });
  }

  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  List<Item> faqs = FAQ.generateItems(faqQuestions.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(
            title: 'FAQs',
            context: context,
            onPressed: () => Navigator.pop(context)),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          physics: BouncingScrollPhysics(),
          children: [
            Text(faqHeader,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            SizedBox(height: 25.0),
            ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                Item item = faqs[index];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ExpandablePanel(
                    header: Text(item.headerValue,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                    collapsed: Text(''),
                    expanded: Text(
                      item.expandedValue,
                      style: TextStyle(fontSize: 15.0),
                      softWrap: true,
                    ),
                    // ignore: deprecated_member_use
                    tapBodyToCollapse: true,
                    // ignore: deprecated_member_use
                    tapHeaderToExpand: true,
                    // ignore: deprecated_member_use
                    hasIcon: true,
                  ),
                );
              },
            ),
            //
          ],
        ));
  }
}

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}
