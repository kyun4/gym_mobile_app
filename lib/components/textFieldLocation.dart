import 'package:flutter/material.dart';

class TextFieldLocationCustom extends StatelessWidget {
  final TextEditingController textController;
  final bool obscure_text;
  final String hint_text_value;

  const TextFieldLocationCustom({
    super.key,
    required this.textController,
    required this.obscure_text,
    required this.hint_text_value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.77,
      child: TextField(
          controller: textController,
          obscureText: obscure_text,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(248, 231, 224, 231),
              hintText: hint_text_value,
              hintStyle: const TextStyle(
                  color: Color.fromARGB(102, 41, 33, 41),
                  fontWeight: FontWeight.w300),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 217, 211, 217))))),
    );
  }
}
