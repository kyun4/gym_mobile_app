import 'package:flutter/material.dart';

class TextFieldObscureCustomWithStatus extends StatefulWidget {
  final TextEditingController textController;
  final String hint_text_value;
  final String status_label;
  final Icon iconSuffix;
  final Icon iconPrefix;
  final FocusNode focusNode;

  const TextFieldObscureCustomWithStatus(
      {super.key,
      required this.textController,
      required this.hint_text_value,
      required this.status_label,
      required this.iconPrefix,
      required this.iconSuffix,
      required this.focusNode});

  @override
  State<TextFieldObscureCustomWithStatus> createState() =>
      _textFieldObscureCustomStateWithStatus();
}

class _textFieldObscureCustomStateWithStatus
    extends State<TextFieldObscureCustomWithStatus> {
  bool toggleEye = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: TextField(
              focusNode: widget.focusNode,
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
        ),
        Visibility(
          visible: widget.status_label == '' ? false : true,
          child: Padding(
            padding: const EdgeInsets.only(left: 35.0, bottom: 10),
            child: Text(widget.status_label,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        )
      ],
    );
  }
}
