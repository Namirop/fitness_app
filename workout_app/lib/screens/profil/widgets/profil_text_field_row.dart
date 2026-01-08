import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workout_app/core/constants/app_constants.dart';

class ProfilTextFieldRow extends StatefulWidget {
  final String rowLabel;
  final IconData icon;
  final String displayText;
  final bool isLoading;
  final ValueChanged<String> onTextFieldChanged;
  const ProfilTextFieldRow({
    super.key,
    required this.rowLabel,
    required this.icon,
    required this.displayText,
    this.isLoading = false,
    required this.onTextFieldChanged,
  });

  @override
  State<ProfilTextFieldRow> createState() => _ProfilTextFieldRowState();
}

class _ProfilTextFieldRowState extends State<ProfilTextFieldRow> {
  Timer? _debounceTextField;

  @override
  void dispose() {
    super.dispose();
    _debounceTextField?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FaIcon((widget.icon), size: 20),
            SizedBox(width: 15),
            Text("${widget.rowLabel} :", style: TextStyle(fontSize: 20)),
            Spacer(),
            widget.isLoading
                ? Shimmer.fromColors(
                    baseColor: AppColors.widgetBackground,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : Expanded(
                    child: TextField(
                      textAlign: TextAlign.end,
                      cursorColor: Colors.black,
                      cursorWidth: 1.0,
                      cursorHeight: 15.0,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.displayText,
                        isDense: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZÀ-ÿ\s]'),
                        ),
                      ],
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      onChanged: (value) {
                        _debounceTextField?.cancel();
                        _debounceTextField = Timer(
                          Duration(milliseconds: 600),
                          () {
                            widget.onTextFieldChanged(value);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
