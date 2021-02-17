import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class GenderPicker extends StatefulWidget {
  @override
  _GenderPickerState createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {
  List<String> categories = ['Male', 'Female', 'Other'];
  TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return // gender
        DropdownButtonFormField(
      validator: (value) =>
          _controller.text.isEmpty ? 'Please select a gender' : null,
      items: categories.map((String category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (newValue) {
        _controller.text = newValue;
        // add to provider
        Provider.of<SignUpModel>(context, listen: false).gender = newValue;
      },
      decoration: textInputDecoration.copyWith(hintText: 'Gender'),
    );
  }
}
