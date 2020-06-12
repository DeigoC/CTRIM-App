import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:ctrim_app_v1/models/timelinePost.dart';
import 'package:ctrim_app_v1/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  
  List<Post> _testPosts =[
    Post(
      id: '1',
      title: 'Title here',
      description: 'This is the first test of so many to come',
      gallerySources: {'https://i.ytimg.com/vi/mwux1_CNdxU/maxresdefault.jpg':'img',
      'https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F38%2F2016%2F05%2F12214218%2Fsimple_bites_family_backyard.jpg&q=85':'img',
      'https://www.lakedistrict.gov.uk/__data/assets/image/0018/123390/families-and-children.jpg':'img',},
      selectedTags: [Department.YOUTH],
      body: '[{"insert":"This is a test"},{"insert":"\n","attributes":{"heading":1}},{"insert":"\nitem 1"},{"insert":"\n","attributes":{"block":"ol"}},{"insert":"item 2"},{"insert":"\n","attributes":{"block":"ol"}},{"insert":"another item"},{"insert":"\n","attributes":{"block":"ol"}}]'
    ),
    Post(
      id: '2',
      title: 'Title Post #2',
      description: '',
      selectedTags: [Department.YOUTH, Department.CHURCH],
      gallerySources: {'https://i.ytimg.com/vi/mwux1_CNdxU/maxresdefault.jpg':'img',
      'https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F38%2F2016%2F05%2F12214218%2Fsimple_bites_family_backyard.jpg&q=85':'img',
      }
    ),
    Post(
      id: '3',
      title: 'Title Post #3 and this one will be the long title',
      description: 'The big image',
      selectedTags: [Department.YOUTH, Department.CHURCH],
      gallerySources: {'https://i.ytimg.com/vi/mwux1_CNdxU/maxresdefault.jpg':'img',}
    ),
  ];

  List<TimelinePost> _testTimelinePosts = [
    TimelinePost(
      postID: '1',
      postType: 'original',
      authorID: '1',
      postDate: DateTime.now().subtract(Duration(days: 2))
    ),
    TimelinePost(
      postID: '2',
      postType: 'original',
      authorID: '2',
      postDate: DateTime.now().subtract(Duration(days: 14))
    ),
    TimelinePost(
      postID: '3',
      postType: 'original',
      authorID: '1',
      postDate: DateTime.now().subtract(Duration(days: 30))
    ),
  ];

  List<User> _testUsers =[
    User(
      id: '1',
      forename: 'Diego',
      surname: 'Collado'
    ),

    User(
      id: '2',
      forename: 'Dana',
      surname: 'Collado'
    ),
  ];

  
  @override
  TimelineState get initialState => TimelineInitial();

  @override
  Stream<TimelineState> mapEventToState(
    TimelineEvent event,
  ) async* {
    if(event is TimelineFetchAllPostsEvent){
      yield TimelineDisplayFeedState(
        users: _testUsers,
        posts: _testPosts,
        timelines: _testTimelinePosts,
      );
    }
  }
}
