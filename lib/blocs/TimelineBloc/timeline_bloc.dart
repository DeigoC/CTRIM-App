import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/models/location.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:ctrim_app_v1/models/timelinePost.dart';
import 'package:ctrim_app_v1/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  
  static String n = '\\n';
  List<Post> _testPosts =[
    Post(
      id: '1',
      title: 'Title here',
      locationID: '1',
      eventDate: DateTime.now().subtract(Duration(days: 16)),
      description: 'This is the first test of so many to come',
      gallerySources: {
      'https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F38%2F2016%2F05%2F12214218%2Fsimple_bites_family_backyard.jpg&q=85':'img',
      'https://i.ytimg.com/vi/mwux1_CNdxU/maxresdefault.jpg':'img',
      'https://www.lakedistrict.gov.uk/__data/assets/image/0018/123390/families-and-children.jpg':'img',},
      selectedTags: [Department.YOUTH],
      body: '[{"insert":"This is a test"},{"insert":"$n","attributes":{"heading":1}},{"insert": "$n item 1"},{"insert":"$n","attributes":{"block":"ol"}},{"insert":"item 2"},{"insert":"$n","attributes":{"block":"ol"}},{"insert":"another item"},{"insert":"$n","attributes":{"block":"ol"}}]',
      detailTableHeader: 'This is the header for the table',
      detailTable: [
        ['Item 1', 'This is test number 1'],
        ['Really long item 2 which is pretty long', 'This is test number 2'],
        ['','This is the trailing of test 3']
      ]
    ),
    Post(
      id: '2',
      title: 'Title Post #2',
      eventDate: DateTime.now().subtract(Duration(days: 7)),
      description: '',
      locationID: '2',
      selectedTags: [Department.YOUTH, Department.CHURCH],
      gallerySources: {
      'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/screen-shot-2020-04-09-at-12-29-32-pm-1586449781.png?crop=1.00xw:0.985xh;0,0.0151xh&resize=480:*':'img',
      'https://www.netbase.com/wp-content/uploads/Brands%E2%80%99-Meme-Marketing-Makes-Sentiment-Analysis-More-Important-Than-Ever.png':'img',
      }
    ),
    Post(
      id: '3',
      eventDate: DateTime.now().subtract(Duration(days: 5)),
      title: 'Title Post #3 and this one will be the long title',
      description: 'The big image',
      locationID: '2',
      selectedTags: [Department.YOUTH, Department.CHURCH],
      gallerySources: {'https://mamasgeeky.com/wp-content/uploads/2020/03/coronavirus-meme-1.jpg':'img',}
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
  
  List<Location> _testLocations =[
    Location(
      id: '0',
      addressLine: 'Address not Required',
    ),
    Location(
      id: '1',
      addressLine: '48 The Demesne, Carryduff, Belfast, BT8 8GU',
      description: 'Used for events'
    ),
    Location(
      id: '2',
      addressLine: '5-7 Conway St, Belfast BT13 2DE',
      description: 'Church Building #•2'
    ),
  ];

  Map<Department, bool> _selectedTags ={
    Department.YOUTH:false,
    Department.CHURCH:false,
    Department.WOMEN:false,
  };
  Map<String, bool>  getSelectedTags(){
    Map<String, bool> result = {};
    _selectedTags.forEach((key, value) {
      result[_tagToString(key)] = value;
     });
    return result;
  }

  Map<Post, String> getUserPosts(String userID){
    Map<Post, String> results ={};
    _testTimelinePosts.forEach((timelinePost) {
      if(timelinePost.authorID.compareTo(userID) == 0 && timelinePost.postType.compareTo('original') == 0){
        results[(_testPosts.firstWhere((post) => post.id.compareTo(timelinePost.postID)==0))] = timelinePost.getPostDateString();
      }
    });
    return results;
  }

  Map<DateTime, List<Post>> getPostsGroupedByPostDate(){
    Map<DateTime, List<Post>> result = {};
    _testTimelinePosts.sort((a,b) => a.postDate.compareTo(b.postDate));

    _testTimelinePosts.forEach((tPost) {
      if(tPost.postType.compareTo('original')==0){
        Post thisPost = _testPosts.firstWhere((post) => post.id.compareTo(tPost.postID)==0);
        if(thisPost.isDateNotApplicable){
          result[tPost.postDate] =_createList(result[tPost.postDate]);
          result[tPost.postDate].add(thisPost);
        }else{
          result[thisPost.eventDate] =_createList(result[thisPost.eventDate]);
          result[thisPost.eventDate].add(thisPost);
        }
      }
    });

    return result;
  }

  List<Post> _createList(List<Post> list){
    if(list == null) return [];
    return list;
  }

  List<Location> get locations => _testLocations;
  String getLocationAddressLine(String locationID){
    if(locationID.trim().isNotEmpty){
      return _testLocations.firstWhere((location) => location.id.compareTo(locationID) == 0).addressLine;
    }
    return 'Pending';
  }

  @override
  TimelineState get initialState => TimelineInitial();

  @override
  Stream<TimelineState> mapEventToState(
    TimelineEvent event,
  ) async* {
    if(event is TimelineFetchAllPostsEvent){
        yield _displayFeed();
    }
    else if(event is TimelineAddNewPostEvent){
      _insertPostID(event.post);
      TimelinePost timelinePost = _generateTimelinePost(event.post);
      _testPosts.add(event.post);
      _testTimelinePosts.add(timelinePost);
      yield _displayFeed();
    }

    else if(event is TimelineTagClickedEvent) yield* _mapTagChnageToState(event);
  }

  Stream<TimelineState> _mapTagChnageToState(TimelineTagClickedEvent event)async*{
    Department selectedTag = _stringToTag(event.tag);
    _selectedTags[selectedTag] = !_selectedTags[selectedTag];
    
   yield TimelineTagChangedState();
    yield _displayFeed();
  }

  Department _stringToTag(String tag){
    switch(tag){
      case 'Women': return Department.WOMEN;
      case 'Church':return Department.CHURCH;
      case 'Youth':return Department.YOUTH;
    }
    return null;
  }

  String _tagToString(Department tag){
    switch(tag){
      case Department.CHURCH:return 'Church';
      case Department.WOMEN: return 'Women';
      case Department.YOUTH: return 'Youth';
    }
    return '';
  }


  TimelineState _displayFeed(){
    _testTimelinePosts.sort((x,y) => y.postDate.compareTo(x.postDate));
    List<Post> posts = [];
    List<TimelinePost> tPosts = [];
    List<Department> selectedTags = [];

    if(_selectedTags.values.contains(true)){
      _selectedTags.forEach((key, value) {
        if(value) selectedTags.add(key);
       });

  // * Add all posts that contains selected tags
       selectedTags.forEach((selectedTag) { 
         _testPosts.forEach((post) { 
           if(post.selectedTags.contains(selectedTag)&&!posts.contains(post)){
             posts.add(post);
           }
         });
       });

  // * Add all timeline posts that contains the post
    posts.forEach((post) {
      _testTimelinePosts.forEach((tPost) {
        if(tPost.postID.compareTo(post.id)==0 && !tPosts.contains(tPost)){
          tPosts.add(tPost);
        }
      });
    });
    } else{
      posts = _testPosts;
      tPosts = _testTimelinePosts;
    }

    return TimelineDisplayFeedState(
        users: _testUsers,
        posts: posts,
        timelines: tPosts,
      ); 
  }

  void _insertPostID(Post post){
    post.id = (int.parse(_testPosts.last.id) + 1).toString();
  }

  TimelinePost _generateTimelinePost(Post post){
    return TimelinePost(
      postID: post.id,
      postType: 'original',
      authorID: '1',
      postDate: DateTime.now(),
    );
  }
}
