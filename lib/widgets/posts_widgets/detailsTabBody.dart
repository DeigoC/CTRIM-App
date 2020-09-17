import 'package:ctrim_app_v1/widgets/posts_widgets/post_fields.dart';
import 'package:flutter/material.dart';

class PostDetailsTabBody extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        PostLocationField(),
        SizedBox(height: 10,),
        Divider(thickness: 1,),
        SizedBox(height: 10,),
        PostDateTimeField(),
        SizedBox(height: 10,),
        Divider(thickness: 1,),
        SizedBox(height: 10,),
        DetailTable(),
      ],
    );
  }
}
