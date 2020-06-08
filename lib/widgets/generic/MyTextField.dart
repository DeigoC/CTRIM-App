import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  
  final String label, hint;
  final TextEditingController controller;
  final Function(String) onTextChange;
  final bool readOnly;
  final int maxLength, maxLines;

  MyTextField({
      @required this.label,
      @required this.controller, 
      this.onTextChange,
      this.hint,
      this.readOnly = false,
      this.maxLength,
      this.maxLines,
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
            maxLength: maxLength,
            maxLines: maxLines ?? 1,
            decoration: InputDecoration(
              hintText: hint??''
            ),
          ),
        ],
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  
  final String label;
  final bool value, leftToRight;
  final Function(bool) onChanged;

  MyCheckBox({
    @required this.label,
    @required this.value,
    @required this.onChanged,
    this.leftToRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: leftToRight ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: leftToRight ? _buildLeftToRight() : _buildRightToLeft(),
    );
  }

  List<Widget> _buildLeftToRight(){
    return [
      Text(label),
      SizedBox(width: 8,),
      Checkbox(value: value, onChanged: onChanged)
    ];
  }
  
  List<Widget> _buildRightToLeft(){
    return [
      Text(label),
      SizedBox(width: 8,),
      Checkbox(value: value, onChanged: onChanged)
    ];
  }

}