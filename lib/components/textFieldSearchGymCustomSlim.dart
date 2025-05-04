import 'package:flutter/material.dart';

class TextFieldSearchGymCustomSlim extends StatelessWidget {
  final TextEditingController textController;
  final bool obscure_text;
  final FocusNode focusNode;
  final String hint_text_value;
  final String choosen_value;
  final Icon iconSuffix;

  const TextFieldSearchGymCustomSlim(
      {super.key,
      required this.textController,
      required this.obscure_text,
      required this.focusNode,
      required this.hint_text_value,
      required this.choosen_value,
      required this.iconSuffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      obscureText: obscure_text,
      focusNode: focusNode,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () {
            textController.text = "";
          },
          child: Container(
              margin: const EdgeInsets.only(
                  top: 15, left: 15, bottom: 15, right: 25),
              child: Text(choosen_value,
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ),
        filled: true,
        fillColor: const Color.fromARGB(248, 245, 243, 245),
        contentPadding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 35, right: 35),
        hintText: hint_text_value,
        hintStyle: const TextStyle(
            color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(width: 2, color: Colors.white)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(
                width: 2, color: Color.fromARGB(199, 116, 10, 180))),
      ),
    );
  }
}
