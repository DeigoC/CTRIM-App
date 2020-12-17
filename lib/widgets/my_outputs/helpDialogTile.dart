import 'package:flutter/material.dart';

class HelpDialogTile extends StatelessWidget {
  
  final String title, subtitle;

  HelpDialogTile({@required this.title, @required this.subtitle});
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyText2.color),
          ),
        ),
      ),
    );
  }
}