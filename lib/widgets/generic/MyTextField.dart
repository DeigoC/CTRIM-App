import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  
  final String label, hint;
  final TextEditingController controller;
  final Function(String) onTextChange;
  final bool readOnly;

  MyTextField({
      @required this.label,
      @required this.controller, 
      this.onTextChange,
      this.hint,
      this.readOnly = false,
    });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,),
          TextField(
            controller: controller,
            onChanged: onTextChange,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint??''
            ),
          ),
        ],
      ),
    );
  }
}