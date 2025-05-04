import 'package:flutter/material.dart';

class TextFieldObscureCustom extends StatefulWidget {
  final TextEditingController textController;
  final String hint_text_value;
  final Icon iconSuffix;
  final Icon iconPrefix;

  const TextFieldObscureCustom(
      {super.key,
      required this.textController,
      required this.hint_text_value,
      required this.iconPrefix,
      required this.iconSuffix});

  @override
  State<TextFieldObscureCustom> createState() => _textFieldObscureCustomState();
}

class _textFieldObscureCustomState extends State<TextFieldObscureCustom> {
  bool toggleEye = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
          controller: widget.textController,
          obscureText: toggleEye ? false : true,
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    toggleEye = !toggleEye;
                  });
                },
                child: Icon(
                    toggleEye
                        ? Icons.visibility_off_outlined
                        : Icons.visibility,
                    color: toggleEye
                        ? Colors.black54
                        : const Color.fromARGB(199, 118, 10, 160))),
            prefixIcon: widget.iconPrefix,
            filled: true,
            fillColor: const Color.fromARGB(248, 245, 243, 245),
            contentPadding: const EdgeInsets.all(20),
            hintText: widget.hint_text_value,
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
