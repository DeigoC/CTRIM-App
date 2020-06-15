import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:ctrim_app_v1/widgets/posts/detailsTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts/galleryTabBody.dart';
import 'package:ctrim_app_v1/widgets/posts/mainTabBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPostPage extends StatefulWidget {
  
  final Post _post;
  EditPostPage(this._post);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> with SingleTickerProviderStateMixin{
  
  PostBloc _postBloc;
  TabController _tabController;
  Orientation _orientation;
  TextEditingController _tecTitle;

  @override
  void initState() {
    _postBloc = PostBloc.editMode(widget._post);
    _tabController = TabController(vsync: this, length: 4);
    _tecTitle = TextEditingController(text: widget._post.title);
    super.initState();
  }

  @override
  void dispose() { 
    _tabController.dispose();
    _tecTitle.dispose();
    _postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        bool result = false;
        await showDialog(
          context: context,
          builder: (_){
            return AlertDialog(
              title: Text('Close Page?'),
              content: Text('Any changes made will be discarded.'),
              actions: [
               FlatButton(child: Text('Cancel'), onPressed: (){
                  Navigator.of(context).pop();
               }),
               FlatButton(child: Text('Discard'), onPressed: (){
                  result = true;
                  Navigator.of(context).pop();
               }),
              ],
            );
          }
        );
        return result;
      },
      child: BlocProvider(
        create: (_) => _postBloc,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (_,__){
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    actions: [
                      _buildUpdateButton(),
                    ],
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(8.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        MyTextField(
                          label: 'Title',
                          hint: 'e.g. Youth Day Out!',
                          controller: _tecTitle,
                          onTextChange: (newTitle) => _postBloc.add(PostTextChangeEvent(title: newTitle)),
                        ),
                        TabBar(
                          labelColor: Colors.black,
                          controller: _tabController,
                          tabs: [
                             Tab(icon: Icon(Icons.info_outline), text: 'About',),
                            Tab(icon: Icon(Icons.calendar_today), text: 'Details',),
                            Tab(icon: Icon(Icons.photo_library), text: 'Gallery',),
                            Tab(icon: Icon(Icons.track_changes), text: 'Updates',),
                          ],
                          onTap: (newIndex){
                            _postBloc.add(PostTabClickEvent(newIndex));
                          },
                        )
                      ]),
                    ),
                  )
                ];
              },
              body: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  BlocBuilder _buildUpdateButton(){
    return BlocBuilder<PostBloc, PostState>(
      condition: (previousState, currentState){
        if(currentState is PostButtonChangeState) return true;
        return false;
      },
      builder: (_,state){
        Widget result = RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0)
          ),
          onPressed: (state is PostEnableSaveButtonState) ? (){
            _confirmSave().then((confirmation){
             if(confirmation){
               BlocProvider.of<TimelineBloc>(context).add(TimelineAddNewPostEvent(
                 _postBloc.newPost
               ));
               Navigator.of(context).pop();
             }
            });
          }:null,
          child: Text('Update',),
        );
        return result;
      },
    );
  }

   OrientationBuilder _buildBody(){
    return OrientationBuilder(
      builder: (_,orientation){
        _orientation = orientation;
        return BlocConsumer<PostBloc, PostState>(
        listener: (_, state){
          //if(state is PostSelectDateState) _selectEventDate();
          //else if(state is PostSelectTimeState) _selectEventTime();
        },
        buildWhen: (previousState, currentState){
        if(currentState is PostTabClickState) return true;
          return false;
        },
        builder: (_,state){
          Widget result = _buildTabBody(0);

          if(state is PostTabClickState){
            int selectedIndex = _getIndexFromState(state);
            result = _buildTabBody(selectedIndex);
          }

          return result;
        },
      );
    });
  }

   int _getIndexFromState(PostTabClickState state){
    if(state is PostAboutTabClickState) return 0;
    else if(state is PostDetailsTabClickState) return 1;
    else if(state is PostGalleryTabClickState) return 2;
    return 3;
  }

   Widget _buildTabBody(int selectedIndex){
    switch(selectedIndex){
      case 0: return MainTabBody();
      case 1: return PostDetailsTabBody();
      case 2: return GalleryTabBody.edit(orientation: _orientation, gallerySrc: widget._post.gallerySources,);
    }
    return Center(child: Text('Index is ' + selectedIndex.toString()),);
  }

  Future<bool> _confirmSave() async{
    bool result = false;
    await showDialog(
      context: context,
      builder: (_){
        return AlertDialog(
          title: Text('Post Update Confirmation'),
          content: Text('Are you sure you want to save the changes to this post?'),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: ()=> Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('Update'),
              onPressed: (){
                result = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
    return result;
  }
}