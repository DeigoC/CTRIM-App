import 'package:ctrim_app_v1/widgets/posts_widgets/post_fields.dart';
import 'package:flutter/material.dart';

class PostDetailsTabBody extends StatefulWidget {
  @override
  _PostDetailsTabBodyState createState() => _PostDetailsTabBodyState();
}

class _PostDetailsTabBodyState extends State<PostDetailsTabBody> {
  TextEditingController _tecDuration;

  @override
  void initState() {
    _tecDuration = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _tecDuration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        PostLocationField(),
        SizedBox(height: 10,),
        Divider(),
        SizedBox(height: 10,),
        PostDateTimeField(),
        SizedBox(height: 10,),
        Divider(),
        SizedBox(height: 10,),
        DetailTable(),
      ],
    );
  }
}
