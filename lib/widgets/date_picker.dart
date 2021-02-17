import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class BasicDateField extends StatefulWidget {
  @override
  _BasicDateFieldState createState() => _BasicDateFieldState();
}

class _BasicDateFieldState extends State<BasicDateField> {
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final format = DateFormat("yyyy-MM-dd");

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      format: format,
      controller: _controller,
      decoration: textInputDecoration.copyWith(hintText: 'Date of birth'),
      onShowPicker: (BuildContext context, DateTime currentValue) {
        return showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          initialDate: currentValue ?? DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 1),
        );
      },
      onChanged: (newValue) {
        _controller.text = DateFormat.yMMMd().format(newValue);
        // add to provider
        Provider.of<SignUpModel>(context, listen: false).dob =
            Timestamp.fromDate(newValue);
      },
      validator: (value) =>
          _controller.text.isEmpty ? 'Provide a valid date of birth' : null,
    );
  }
}

class BasicDateField1 extends StatefulWidget {
  final hintText;

  const BasicDateField1({Key key, this.hintText}) : super(key: key);
  @override
  _BasicDateFieldState1 createState() => _BasicDateFieldState1();
}

class _BasicDateFieldState1 extends State<BasicDateField1> {
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final format = DateFormat("yyyy-MM-dd");

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      format: format,
      controller: _controller,
      decoration: textInputDecoration.copyWith(hintText: widget.hintText),
      onShowPicker: (BuildContext context, DateTime currentValue) {
        return showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          initialDate: currentValue ?? DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 1),
        );
      },
      onChanged: (newValue) {
        _controller.text = DateFormat.yMMMd().format(newValue);
        // add to provider
        Provider.of<SignUpModel>(context, listen: false).dob =
            Timestamp.fromDate(newValue);
      },
    );
  }
}
