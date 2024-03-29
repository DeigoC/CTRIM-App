import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/timelinePost.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/postArticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ? Do we still need a search posts page?
class SearchPostsPage extends StatefulWidget {
  @override
  _SearchPostsPageState createState() => _SearchPostsPageState();
}

class _SearchPostsPageState extends State<SearchPostsPage> {
  TextEditingController _tecSearch;
  FocusNode _fnSearch;

  @override
  void initState() {
    super.initState();
    _tecSearch = TextEditingController();
    _fnSearch = FocusNode();
  }

  @override
  void dispose() {
    _tecSearch.dispose();
    _fnSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _tecSearch,
          focusNode: _fnSearch,
          autofocus: true,
          /* onChanged: (newString) => BlocProvider.of<TimelineBloc>(context)
              .add(TimelineSearchTextChangeEvent(newString)), */
          onSubmitted:(fullString){
            print('---------Submitted string is ' + fullString);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintText: 'Search Posts by Title',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<TimelineBloc, TimelineState>(
      buildWhen: (_, state) {
        if (state is TimelineSearchState) return true;
        return false;
      },
      builder: (_, state) {
        if (state is TimelineDisplaySearchFeedState) {
          return _buildBodyWithData(state);
        } else if (state is TimelineDisplayEmptyFeedState) {
          return Center(
            child: Text('No Results'),
          );
        }
        return Center(
          child: Text('Waiting for Search'),
        );
      },
    );
  }

  Widget _buildBodyWithData(TimelineDisplaySearchFeedState state) {
    List<TimelinePost> _timelines = state.timelines;
    List<Widget> children = _timelines
        .map((timelinePost) => PostArticle(
              allUsers: state.users,
              timelinePost: timelinePost,
              mode: 'view',
            ))
        .toList();

    return ListView.builder(
        itemCount: children.length,
        itemBuilder: (_, index) {
          return children[index];
        });
  }
}
