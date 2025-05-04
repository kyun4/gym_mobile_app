import 'package:flutter/material.dart';

class TextFieldWithStatus extends StatelessWidget {
  final TextEditingController textController;
  final bool obscure_text;
  final String hint_text_value;
  final String status_label;
  final Icon iconSuffix;
  final Icon iconPrefix;
  final FocusNode focusNode;

  const TextFieldWithStatus(
      {super.key,
      required this.textController,
      required this.obscure_text,
      required this.hint_text_value,
      required this.status_label,
      required this.iconPrefix,
      required this.iconSuffix,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: TextField(
              focusNode: focusNode,
              controller: textController,
              obscureText: obscure_text,
              decoration: InputDecoration(
                suffixIcon: iconSuffix,
                prefixIcon: iconPrefix,
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
        ),
        Visibility(
          visible: status_label == '' ? false : true,
          child: Padding(
            padding: const EdgeInsets.only(left: 35.0, bottom: 10),
            child: Text(status_label,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        )
      ],
    );
  }
}
