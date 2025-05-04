import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DigitCustomNumberOnly extends StatelessWidget {
  final TextEditingController textDigitController;
  final FocusNode focusNode;
  final FocusNode focusNextNode;

  const DigitCustomNumberOnly(
      {super.key,
      required this.textDigitController,
      required this.focusNode,
      required this.focusNextNode});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 85,
        width: 45,
        margin: const EdgeInsets.all(5),
        child: TextField(
            onChanged: (textValue) {
              if (textValue.length >= 1) {
                focusNextNode.requestFocus();
              }
            },
            maxLength: 1,
            textAlign: TextAlign.center,
            focusNode: focusNode,
            controller: textDigitController,
            obscureText: false,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                counter: Text(""),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                hintText: "",
                hintStyle: TextStyle(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(199, 160, 80, 118))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.black45)))));
  }
}
