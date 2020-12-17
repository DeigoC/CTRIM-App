import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewMyPostsPage extends StatefulWidget {
  @override
  _ViewMyPostsPageState createState() => _ViewMyPostsPageState();
}

class _ViewMyPostsPageState extends State<ViewMyPostsPage> {
  bool _showDeleted = false;
  List<TimelinePost> _allUserTPs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Posts'),
        actions: [
          FlatButton(
            padding: EdgeInsets.zero,
            child: AbsorbPointer(
              child: Row(
                children: [
                  Icon(Icons.delete,color: Colors.white,),
                  Switch(
                    activeColor: Color(0xff236adb),
                    value: _showDeleted,
                    onChanged: (_){},
                  ),
                ],
              ),
            ),
            onPressed: (){
              setState(() {
                _showDeleted = !_showDeleted;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<TimelineBloc, TimelineState>(
        buildWhen: (_, state) {
        if (state is TimelineRebuildMyPostsPageState) return true;
        return false;
      }, builder: (_, state) {
        if(state is TimelineRebuildMyPostsPageState){
          _allUserTPs.removeWhere((e) => state.updatedOriginalTP.id.compareTo(e.id)==0);
          _allUserTPs.add(state.updatedOriginalTP);
          return _buildBodyWithData(_allUserTPs);
        }
        if(_allUserTPs!=null) return  _buildBodyWithData(_allUserTPs);
        return _buildFB();
      }),
    );
  }

  Widget _buildFB(){
    return FutureBuilder<List<TimelinePost>>(
      future: BlocProvider.of<TimelineBloc>(context).fetchAllUserPosts(BlocProvider.of<AppBloc>(context).currentUser.id),
      builder: (_,snap){
        Widget result;

        if(snap.hasData){
          result = Center(child: CircularProgressIndicator(),);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {_allUserTPs = snap.data;});
          });
        }else if(snap.hasError) result = Center(child: Text('Something went wrong!'),);
        else result = Center(child: CircularProgressIndicator(),);
        return result;
      },
    );
  }

  Widget _buildBodyWithData(List<TimelinePost> data){
    List<TimelinePost> deleted = List.from(data), notDeleted = List.from(data);

    deleted.removeWhere((value) => !value.postDeleted);
    notDeleted.removeWhere((value) => value.postDeleted);
    List<TimelinePost> listToDisplay = _showDeleted ? deleted : notDeleted;
    listToDisplay.sort((a,b)=>b.postDate.compareTo(a.postDate));

    return ListView.builder(
      itemCount: listToDisplay.length,
      itemBuilder: (_,index){
        return PostArticle(
          mode: _showDeleted ? 'view':'edit',
          allUsers: BlocProvider.of<TimelineBloc>(context).mainFeedUsers,
          timelinePost: listToDisplay.elementAt(index),
        );
      }
    );
  }
}
