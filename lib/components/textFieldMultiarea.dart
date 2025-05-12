import 'package:flutter/material.dart';

class TextFieldMultiarea extends StatelessWidget {
  final TextEditingController textController;
  final bool obscure_text;
  final String hint_text_value;
  final int maxLineLength;

  const TextFieldMultiarea({
    super.key,
    required this.textController,
    required this.obscure_text,
    required this.hint_text_value,
    required this.maxLineLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
          controller: textController,
          obscureText: obscure_text,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: maxLineLength,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            filled: true,
            fillColor: const Color.fromARGB(248, 245, 243, 245),
            contentPadding: const EdgeInsets.all(20),
            hintText: hint_text_value,
            hintStyle: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w300),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: Colors.purpleAccent)),
          )),
    );
  }
}
