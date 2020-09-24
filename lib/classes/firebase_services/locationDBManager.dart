import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/appStorage.dart';
import 'package:ctrim_app_v1/classes/firebase_services/idTracker.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';

class LocationDBManager{
  final CollectionReference _ref = FirebaseFirestore.instance.collection('locations');
 
  static List<Location> _essentialLocations;
  static List<Location> get essentialLocations{
    _essentialLocations.removeWhere((e) => e.id=='0');
    _essentialLocations.removeWhere((e) => e.id=='-1');
    return _essentialLocations;
  }

  final String _subCollection = 'postsReference', _subCollectionDoc = 'postsUsed', _subCollectionField = 'posts';

  final AppStorage _appStorage;

  LocationDBManager(AppBloc appBloc):_appStorage = AppStorage(appBloc);

  Future<Location> fetchLocationByID(String id) async{
    var doc = await _ref.doc(id).get();
    return Location.fromMap(doc.id, doc.data());
  }

  Future<List<Location>> fetchEssentialLocations() async{
    var collection = await _ref.limit(20).where('Deleted',isEqualTo: false).get();
    _essentialLocations = collection.docs.map((doc) => Location.fromMap(doc.id, doc.data())).toList();
    return _essentialLocations;
  }

  Future<List<Location>> fetchLocationsBySearchString(String searchString, {bool includeDeleted = false}) async{
    List<String> searchArray = searchString.trim().toLowerCase().replaceAll(RegExp(r','), '').split(' ');

    QuerySnapshot collection;
    if(includeDeleted){
      collection = await _ref
      .where('SearchArray',arrayContainsAny: searchArray)
      .limit(10)
      .get(); 
    }else{
      collection = await _ref
      .where('Deleted',isEqualTo: false)
      .where('SearchArray',arrayContainsAny: searchArray)
      .limit(10)
      .get();
    }

    List<Location> results = List.castFrom<dynamic, Location>(collection.docs.map((e) => Location.fromMap(e.id, e.data())).toList());
    return results;
  }

  Future<Null> addLocation(Location location, File file) async{
    location.id = await IDTracker().getAndUpdateNewLocationID();
    if(file != null){
      location.imgSrc = await _appStorage.uploadAndGetLocationImageSrc(location, file);
    }
    await _ref.doc(location.id).set(location.toJson());
    
    _ref.doc(location.id)
    .collection(_subCollection)
    .doc(_subCollectionDoc)
    .set({'posts':[]});
  }
 
  Future<Null> updateLocation(Location location, File file) async{
    if(file != null){
      location.imgSrc = await _appStorage.uploadAndGetLocationImageSrc(location, file);
    }
    await _ref.doc(location.id).set(location.toJson());
  }

  void updateReferenceList(Post newPost, Post oldPost){
    if(oldPost == null){
      _addReferenceToPost(newPost);
    }else if(newPost.deleted){
      _removeReferenceToPost(oldPost);
    }
    else if(newPost.locationID.compareTo(oldPost.locationID)!=0){
      _updateReferenceToPost(newPost, oldPost);
    }
  }

  Future _addReferenceToPost(Post newPost) async{
    List<String> postIDs = await fetchPostReferenceList(newPost.locationID);
    if(!postIDs.contains(newPost.id)){
      postIDs.add(newPost.id);
      await _setNewPostReferenceList(newPost.locationID, postIDs);
    }
  }
  
  Future _updateReferenceToPost(Post newPost, Post oldPost) async{
    _removeReferenceToPost(oldPost);
    _addReferenceToPost(newPost);
  }

  Future _removeReferenceToPost(Post post) async{
    List<String> postIDs =  await fetchPostReferenceList(post.locationID);
    postIDs.removeWhere((e) => e.compareTo(post.id)==0);
    await _setNewPostReferenceList(post.locationID, postIDs);
  }

  Future<List<String>> fetchPostReferenceList(String locationID) async{
    var doc = await _ref.doc(locationID)
      .collection(_subCollection)
      .doc(_subCollectionDoc)
      .get();
    
    return List.from(doc.data()[_subCollectionField], growable: true);
  }

  Future _setNewPostReferenceList(String locationID, List<String> postIDs) async{
    await _ref.doc(locationID)
      .collection(_subCollection)
      .doc(_subCollectionDoc)
      .set({_subCollectionField:postIDs});
  }

}