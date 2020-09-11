import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/post_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:zefyr/zefyr.dart';

class MainTabBody extends StatefulWidget {
  MainTabBody();
  @override
  _MainTabBodyState createState() => _MainTabBodyState();
}

class _MainTabBodyState extends State<MainTabBody> {
  TextEditingController _tecBody, _tecSubtitle;

  @override
  void initState() {
    super.initState();
    _tecBody = TextEditingController();
    _tecSubtitle = TextEditingController(
        text: BlocProvider.of<PostBloc>(context).postDescription);
  }

  @override
  void dispose() {
    _tecBody.dispose();
    _tecSubtitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        PostTagsField(),
        SizedBox(height: 10,),
        Divider(),
        SizedBox(height: 10,),
        MyTextField(
          controller: _tecSubtitle,
          label: 'Description',
          hint: 'A summary of the post',
          maxLength: 140,
          maxLines: 5,
          onTextChange: (newSubtitle) => BlocProvider.of<PostBloc>(context)
              .add(PostTextChangeEvent(description: newSubtitle)),
        ),
        SizedBox(height: 10,),
        Divider(),
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Body*',style: TextStyle(fontSize: 18),),
              IconButton(
                icon: Icon(AntDesign.questioncircleo),
                onPressed: (){

                },
              )
            ],
          ),
        ),
        Divider(indent: 10, endIndent: 10,),
        BlocBuilder<PostBloc, PostState>(
            condition: (previousState, currentState) {
          if (currentState is PostUpdateBodyState) return true;
          return false;
        }, builder: (_, state) {
          return Container(
              padding: EdgeInsets.all(8),
              child: ZefyrView(document: BlocProvider.of<PostBloc>(context).getEditorDoc())
            );
        }),
        Container(
          padding: EdgeInsets.all(8),
          child: RaisedButton(
            onPressed: () {
              BlocProvider.of<AppBloc>(context).add(AppToPostBodyEditorEvent(BlocProvider.of<PostBloc>(context)));
            },
            child: Text('Edit Body'),
          ),
        ),
      ],
    );
  }
}
