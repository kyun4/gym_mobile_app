import 'package:flutter/material.dart';

class InstructorInboxMode extends StatefulWidget {
  final String inboxModeLabel;
  final bool clientRequestMode;
  const InstructorInboxMode(
      {super.key,
      required this.inboxModeLabel,
      required this.clientRequestMode});
  @override
  State<InstructorInboxMode> createState() => _instructorInboxModeState();
}

class _instructorInboxModeState extends State<InstructorInboxMode> {
  @override
  Widget build(BuildContext context) {
    return widget.clientRequestMode == true &&
            widget.inboxModeLabel == "Your Clients"
        ? Container(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 25, left: 25),
            width: 140,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
            child: Text(widget.inboxModeLabel,
                style: TextStyle(fontSize: 12), textAlign: TextAlign.center))
        : widget.inboxModeLabel == "Your Clients"
            ? Container(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 25, left: 25),
                width: 140,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(199, 167, 10, 180),
                        Color.fromARGB(198, 244, 202, 248),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(30))),
                child: Text(widget.inboxModeLabel,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                    textAlign: TextAlign.center))
            : widget.clientRequestMode == false
                ? Container(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, right: 25, left: 25),
                    width: 140,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        )),
                    child: Text(widget.inboxModeLabel,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center))
                : Container(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, right: 25, left: 25),
                    width: 140,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(199, 167, 10, 180),
                            Color.fromARGB(198, 244, 202, 248),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(30))),
                    child: Text(widget.inboxModeLabel,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center));
  }
}
