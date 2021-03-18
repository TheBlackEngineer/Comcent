import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class PDFScreen extends StatelessWidget {
  final String url;
  PDFScreen(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 0.0,
        title: Text("Document", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<PDFDocument>(
          future: PDFDocument.fromURL(url),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            return PDFViewer(document: snapshot.data);
          }),
    );
  }
}
