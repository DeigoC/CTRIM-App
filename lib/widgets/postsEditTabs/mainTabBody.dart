import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/postsEditTabs/post_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        PostDepartmentField(),
        SizedBox(height: 20,),
        MyTextField(
          controller: _tecSubtitle,
          label: 'Description',
          hint: 'Brief summary of the post',
          maxLength: 250,
          maxLines: 5,
          onTextChange: (newSubtitle) => BlocProvider.of<PostBloc>(context)
              .add(PostTextChangeEvent(description: newSubtitle)),
        ),
        SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Body'),
        ),
        Divider(),
        BlocBuilder<PostBloc, PostState>(
            condition: (previousState, currentState) {
          if (currentState is PostUpdateBodyState) return true;
          return false;
        }, builder: (_, state) {
          return Container(
              padding: EdgeInsets.all(8),
              child: ZefyrView(
                  document: BlocProvider.of<PostBloc>(context).getEditorDoc()));
        }),
        Container(
          padding: EdgeInsets.all(8),
          child: RaisedButton(
            onPressed: () {
              BlocProvider.of<AppBloc>(context).add(
                  AppToPostBodyEditorEvent(BlocProvider.of<PostBloc>(context)));
            },
            child: Text('Edit Body'),
          ),
        ),
      ],
    );
  }
}
