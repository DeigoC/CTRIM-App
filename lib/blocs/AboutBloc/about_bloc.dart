import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/classes/firebase_services/aboutDBManager.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:meta/meta.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:convert';

part 'about_event.dart';
part 'about_state.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {

  final AboutDBManager _aboutDBManager = AboutDBManager();

  List<AboutArticle> get allArticles => AboutDBManager.allAboutArticles;

  AboutArticle _articleToEdit, _originalArticle;
  AboutArticle get articleToEdit => _articleToEdit;

  void setArticleToEdit(AboutArticle articleToEdit){
    _articleToEdit = AboutArticle(
      id: articleToEdit.id,
      body: articleToEdit.body,
      title: articleToEdit.title,
      serviceTime: articleToEdit.serviceTime,
      locationID: articleToEdit.locationID,
      locationPastorUID: articleToEdit.locationPastorUID,
      gallerySources: articleToEdit.gallerySources,
      socialLinks: articleToEdit.socialLinks,
    );

    _originalArticle = AboutArticle(
      id: articleToEdit.id,
      body: articleToEdit.body,
      title: articleToEdit.title,
      serviceTime: articleToEdit.serviceTime,
      locationID: articleToEdit.locationID,
      locationPastorUID: articleToEdit.locationPastorUID,
      gallerySources: articleToEdit.gallerySources,
      socialLinks: articleToEdit.socialLinks,
    );
  }

  NotusDocument getAboutBody(){
    if(_articleToEdit.body==''){
      List<dynamic> initialWords = [
        {"insert": "Body Starts Here\n"}
      ];
      return NotusDocument.fromJson(initialWords);
    }
    var jsonDecoded = jsonDecode(_articleToEdit.body);
    return NotusDocument.fromJson(jsonDecoded);
  }

  @override
  AboutState get initialState => AboutInitial();

  @override
  Stream<AboutState> mapEventToState(AboutEvent event,) async* {
    if(event is AboutArticleEditEvent) yield* _mapEditArticleEventToState(event);
  }

  Stream<AboutState> _mapEditArticleEventToState(AboutArticleEditEvent event) async*{
    if(event is AboutPastorUIDChangeEvent){
      _articleToEdit.locationPastorUID = event.pastorUID;
      yield AboutArticlePastorUIDChangedState();
    }else if(event is AboutLocationIDChangeEvent){
      _articleToEdit.locationID = event.locationID;
      yield AboutArticleLocationIDChangedState();
    }else if(event is AboutArticleTextChangeEvent){
      _articleToEdit.title = event.title??_articleToEdit.title;
      _articleToEdit.serviceTime = event.serviceTime??_articleToEdit.serviceTime;
    }else if(event is AboutArticleSaveBodyEvent){
      _articleToEdit.body = event.body;
      yield AboutArticleBodyChangedState();
    }else if(event is AboutArticleSaveRecordEvent){
      yield AboutArticleAttemptingToSaveRecordState();
      await _aboutDBManager.updateAboutArticle(_articleToEdit);
      yield AboutArticleRebuildAboutTabState();
    }
    yield _canEnableSaveButton();
  }

  AboutState _canEnableSaveButton(){
    if(_hasAnyFieldsChanged() && _hasNoEmptyFields()) return AboutArticleEnableSaveButtonState();
    return AboutArticleDisableSaveButtonState();
  }

  bool _hasNoEmptyFields(){
    if(_articleToEdit.title.trim().isEmpty) return false;
    else if(_articleToEdit.serviceTime.trim().isEmpty) return false;
    return true;
  }

  bool _hasAnyFieldsChanged(){
    if(_originalArticle.title.compareTo(_articleToEdit.title)!=0) return true;
    else if(_originalArticle.body.compareTo(_articleToEdit.body)!=0) return true;
    else if(_originalArticle.serviceTime.compareTo(_articleToEdit.serviceTime)!= 0) return true;
    else if(_originalArticle.locationID.compareTo(_articleToEdit.locationID)!=0) return true;
    else if(_originalArticle.locationPastorUID.compareTo(_articleToEdit.locationPastorUID)!=0) return true;
    return false; 
  }

}
