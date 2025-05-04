import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldPhone extends StatelessWidget {
  final TextEditingController textController;
  final bool obscure_text;
  final String hint_text_value;
  final Icon iconSuffix;
  final Icon iconPrefix;

  const TextFieldPhone(
      {super.key,
      required this.textController,
      required this.obscure_text,
      required this.hint_text_value,
      required this.iconPrefix,
      required this.iconSuffix});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: TextField(
            controller: textController,
            obscureText: obscure_text,
            maxLength: 11,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              suffixIcon: iconSuffix,
              prefixIcon: iconPrefix,
              counterText: '',
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
    );
  }
}
