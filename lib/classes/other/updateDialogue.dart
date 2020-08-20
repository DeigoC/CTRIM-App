import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateLogDialogue extends StatefulWidget {
  final PostBloc postBloc;
  UpdateLogDialogue(this.postBloc);
  @override
  _UpdateLogDialogueState createState() => _UpdateLogDialogueState();
}

class _UpdateLogDialogueState extends State<UpdateLogDialogue> {
  TextEditingController _tecUpdateLog;
  bool _hasText = false;

  @override
  void initState() {
    _tecUpdateLog = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _tecUpdateLog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * 0.3,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextField(
                controller: _tecUpdateLog,
                label: 'Update Log',
                maxLength: 90,
                onTextChange: (newString) {
                  if (_tecUpdateLog.text.trim().isEmpty) {
                    setState(() {
                      _hasText = false;
                    });
                  } else {
                    if (!_hasText)
                      setState(() {
                        _hasText = true;
                      });
                  }
                },
                hint: 'e.g. Changed location and time',
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: MyRaisedButton(
                  label: 'Update Post',
                  onPressed: _hasText
                      ? () {
                          String userID =BlocProvider.of<AppBloc>(context).currentUser.id;
                          BlocProvider.of<TimelineBloc>(context).add(TimelineUpdatePostEvent(
                            post: widget.postBloc.newPost, 
                            uid: userID, 
                            updateLog:_tecUpdateLog.text)
                          );

                           widget.postBloc.add(PostLocationCheckReferenceEvent());
                        }
                      : null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
