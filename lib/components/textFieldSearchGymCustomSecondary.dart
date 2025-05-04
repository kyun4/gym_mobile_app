import 'package:flutter/material.dart';

class TextFieldSearchGymCustomSecondary extends StatelessWidget {
  final TextEditingController textController;
  final bool obscure_text;
  final String hint_text_value;
  final Icon iconSuffix;
  final Icon iconPrefix;

  const TextFieldSearchGymCustomSecondary(
      {super.key,
      required this.textController,
      required this.obscure_text,
      required this.hint_text_value,
      required this.iconPrefix,
      required this.iconSuffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      obscureText: obscure_text,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () {
            textController.text = "";
          },
          child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30)),
              child: iconSuffix),
        ),
        prefixIcon: Container(
            margin: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30)),
            child: iconPrefix),
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
