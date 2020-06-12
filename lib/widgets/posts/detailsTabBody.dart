import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/posts/post_fields.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
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
         SizedBox(height: 8,),
        PostDateTimeField(),
         SizedBox(height: 8,),
        MyTextField(
          controller: _tecDuration,
          label: 'Duration',
          hint: '(Optional) e.g. 2-3 Hours, Whole Day, Pending',
          onTextChange: (newDuration) => null,
        ),
      SizedBox(height: 16,),
      Divider(thickness: 2,),
      SizedBox(height: 8,),
      DetailTable(),
      ],
    );
  }
}