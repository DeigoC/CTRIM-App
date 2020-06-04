import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  
  final String label, hint;
  final TextEditingController controller;
  final Function(String) onTextChange;

  MyTextField({
      @required this.label,
      @required this.controller, 
      this.onTextChange,
      this.hint
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
            decoration: InputDecoration(
              hintText: hint??''
            ),
          ),
        ],
      ),
    );
  }
}