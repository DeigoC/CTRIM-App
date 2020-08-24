import 'dart:io';

import 'package:ctrim_app_v1/App.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/classes/other/updateDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/detailsTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/mainTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts_widgets/updatesTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPostPage extends StatefulWidget {
  final String _postID;
  EditPostPage(this._postID);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> with SingleTickerProviderStateMixin {
  PostBloc _postBloc;
  TabController _tabController;
  TextEditingController _tecTitle;
  List<TimelinePost> _allTimelinePosts = [];

  Post _post;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if(_tecTitle!=null) _tecTitle.dispose();
    if(_postBloc!=null) _postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_post!=null){
      return _buildBodyWithData();
    }
    return FutureBuilder<Post>(
      future: BlocProvider.of<TimelineBloc>(context).fetchPostByID(widget._postID),
      builder: (_,snap){
        Widget result;

        if(snap.hasData){
          result = Center(child: CircularProgressIndicator(),);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() { 
            _post = snap.data; 
            _postBloc = PostBloc.editMode(_post);
            _tecTitle = TextEditingController(text: _post.title);
           });
          });
        }else if(snap.hasError){
          result = Center(child: Text('Something went wrong!'),);
        }else{
          result = Center(child: CircularProgressIndicator(),);
        }
        return result;
      },
    );
  }

  Widget _buildBodyWithData(){
    return WillPopScope(
      onWillPop: () async {
        return await ConfirmationDialogue().leaveEditPage(context: context);
      },
      child: BlocProvider(
        create: (_) => _postBloc,
        child: Scaffold(
          // ? Maybe this could be removed?
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              bool hasImage = _postBloc.newPost.firstImageSrc != null;
              Image postImage = hasImage ? Image.network(_postBloc.newPost.firstImageSrc, fit: BoxFit.cover,):null;
              if(!hasImage){
                hasImage = _postBloc.newPost.firstFileImage != null;
                postImage = hasImage ? Image.file( File( _postBloc.newPost.firstFileImage),fit: BoxFit.cover,):null;
              }
              
              return [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height*0.33,
                  flexibleSpace: FlexibleSpaceBar(background: postImage,),
                  actions: [
                    _buildDeleteButton(context),
                    _buildUpdateButton(),
                  ],
                ),
                SliverPadding(
                  padding: EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      MyTextField(
                        maxLength: 60,
                        label: 'Title',
                        hint: 'e.g. Youth Day Out!',
                        controller: _tecTitle,
                        onTextChange: (newTitle) => _postBloc.add(PostTextChangeEvent(title: newTitle)),
                      ),
                      TabBar(
                        labelColor:BlocProvider.of<AppBloc>(context).onDarkTheme?null:Colors.black87,
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
                          Tab(
                            icon: Icon(Icons.track_changes),
                            text: 'Updates',
                          ),
                        ],
                        onTap: (newIndex) {
                          _postBloc.add(PostTabClickEvent(newIndex));
                        },
                      )
                    ]),
                  ),
                )
              ];
            },
            body: BlocListener<TimelineBloc, TimelineState>(
              condition: (_,state){
                if(state is TimelineRebuildMyPostsPageState||
                state is TimelineAttemptingToUploadNewPostState) return true;
                return false;
              },
              listener: (_,state){
                if(state is TimelineRebuildMyPostsPageState){
                  _postBloc.add(PostCheckToDeleteUnusedFilesEvent());
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  if(!state.updatedOriginalTP.postDeleted){
                    Navigator.of(context).pop();
                  }
               }else if(state is TimelineAttemptingToUploadNewPostState){
                 ConfirmationDialogue().uploadTaskStarted(context: context);
               }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  MainTabBody(),
                  PostDetailsTabBody(),
                  GalleryTabBody.edit(
                    thumbnails: _postBloc.newPost.thumbnails,
                    gallerySrc: _postBloc.newPost.gallerySources,
                  ),
                  _buildUpdatesTab(),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    if(_post.deleted) return Container();
    return MyRaisedButton(
      externalPadding: EdgeInsets.all(8),
      label: 'Delete',
      isDestructive: true,
      onPressed: () {
        ConfirmationDialogue().deleteRecord(context: context, record: 'Post').then((confirmation) {
          if(confirmation){
            BlocProvider.of<TimelineBloc>(context).add(
              TimelineDeletePostEvent(post: _post, uid: BlocProvider.of<AppBloc>(context).currentUser.id));
             
             _postBloc.add(PostLocationRemoveReferenceEvent());
          }
        });
      },
    );
  }

  BlocBuilder _buildUpdateButton() {
    return BlocBuilder<PostBloc, PostState>(
      condition: (previousState, currentState) {
        if (currentState is PostButtonChangeState) return true;
        return false;
      },
      builder: (_, state) {
        return MyRaisedButton(
          externalPadding: EdgeInsets.all(8),
          label: 'Update',
          onPressed: (state is PostEnableSaveButtonState)? () { _confirmSave();}: null,
        );
      },
    );
  }
  
  Widget _buildUpdatesTab(){
    if(_allTimelinePosts.length==0){
      BlocProvider.of<TimelineBloc>(context).fetchPostUpdatesData(_post.id).then((timelines){
        setState(() {
          _allTimelinePosts = timelines;
        });
      });
      return Center(child: CircularProgressIndicator());
    }
    return AbsorbPointer(child: PostUpdatesTab(_post, _allTimelinePosts));
  }

  void _confirmSave() async {
    await showDialog(
      context: context,
      builder: (_) {
        return UpdateLogDialogue(_postBloc);
      });
  }
}
