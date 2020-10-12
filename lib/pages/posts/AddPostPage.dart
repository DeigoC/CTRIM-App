import 'dart:io';

import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/post_tabs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_compress/video_compress.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _tecTitle;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tecTitle = TextEditingController();
    _postBloc = PostBloc();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tecTitle.dispose();
    _postBloc.close();
    
    FilePicker.platform.clearTemporaryFiles();
    VideoCompress.deleteAllCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return ConfirmationDialogue().leaveEditPage(context: context,creatingRecord: true);
      },
      child: BlocProvider(
        create: (_) => _postBloc,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              bool hasImage = _postBloc.newPost.firstFileImage != null;
              return [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.33,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    background: hasImage ? Image.file(File(_postBloc.newPost.firstFileImage), fit: BoxFit.cover,):null,
                  ),
                  actions: [_buildAppBarActions(),],
                ),
                SliverPadding(
                  padding: EdgeInsets.only(top: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      MyTextField(
                        label: 'Title',
                        hint: 'Keep it concise',
                        helpText: 'Headline for the post. Try to keep it concise as there is a 60 character word limit',
                        maxLength: 60,
                        controller: _tecTitle,
                        onTextChange: (newTitle) => _postBloc.add(PostTextChangeEvent(title: newTitle)),
                      ),
                      TabBar(
                        labelColor: BlocProvider.of<AppBloc>(context).onDarkTheme?null:Colors.black87,
                        controller: _tabController,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.info_outline),
                            text: 'About',
                          ),
                          Tab(
                            icon: Icon(Icons.calendar_today),
                            text: 'Details',
                          ),
                          Tab(
                            icon: Icon(Icons.photo_library),
                            text: 'Gallery',
                          ),
                        ],
                        onTap: (newIndex) {
                          _postBloc.add(PostTabClickEvent(newIndex));
                        },
                      ),
                    ]),
                  ),
                )
              ];
            },
            body: BlocListener<TimelineBloc,TimelineState>(
              condition: (_,state){
                if(state is TimelineNewPostUploadedState||
                state is TimelineAttemptingToUploadNewPostState) return true;
                return false;
              },
              listener: (_,state){
                 if(state is TimelineNewPostUploadedState){
                   Navigator.of(context).pop();
                   Navigator.of(context).pop();
                 }else if(state is TimelineAttemptingToUploadNewPostState){
                   ConfirmationDialogue().uploadTaskStarted(context: context);
                 }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  AboutTabBody(),
                  PostDetailsTabBody(),
                  GalleryTabBody(gallerySrc: {},),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  BlocBuilder _buildAppBarActions() {
    return BlocBuilder<PostBloc, PostState>(
      condition: (previousState, currentState) {
        if (currentState is PostButtonChangeState) return true;
        return false;
      },
      builder: (_, state) {
        return MyRaisedButton(
          externalPadding: EdgeInsets.all(8),
          label: 'Save',
          onPressed: (state is PostEnableSaveButtonState)? (){
            _confirmSave().then((confirmation) {
              if (confirmation) {
                BlocProvider.of<TimelineBloc>(context).add(TimelineAddNewPostEvent(
                  _postBloc.newPost,
                  BlocProvider.of<AppBloc>(context).currentUser.id,
                ));
                
                _postBloc.add(PostLocationAddReferenceEvent());
              }
            });
          }
        : null,
        );
      },
    );
  }

  Future<bool> _confirmSave() async {
    bool result = false;
    await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Post Confirmation'),
            content: Text('Are you sure you want to save this post?'),
            actions: [
              MyFlatButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              MyFlatButton(
                label: 'Post',
                onPressed: () {
                  result = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    return result;
  }
}
