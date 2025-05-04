import 'package:flutter/material.dart';

class DigitCustom extends StatelessWidget {
  final TextEditingController textDigitController;

  const DigitCustom({super.key, required this.textDigitController});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 55,
        width: 45,
        margin: const EdgeInsets.all(5),
        child: TextField(
            controller: textDigitController,
            obscureText: false,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                hintText: "",
                hintStyle: TextStyle(),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 239, 235, 240))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.black45)))));
  }
}
