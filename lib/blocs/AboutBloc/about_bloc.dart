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

  List<AboutArticle> _allArticles = [
    AboutArticle(// ? This can be the MAIN about article, has no other data but the gallery
      id: '0',
      gallerySources: {},
    ),
    AboutArticle(
      id: '1',
      title: 'Belfast',
      serviceTime: 'Belfast Service Time here',
      locationID: '1',
      body: '[{"insert":"Title for About Article\\n"}]',
      locationPastorUID: '1',
      gallerySources: {
        'https://ctrim.co.uk/wp-content/uploads/2020/04/4-768x768.png':'img',
      },
    ),
    AboutArticle(
      id: '2',
      body: '[{"insert":"Title for About Article\\n"}]',
      title: 'Northcoast',
      serviceTime: 'Belfast Service Time here',
      locationID: '1',
      locationPastorUID: '1',
      gallerySources: {
        'https://ctrim.co.uk/wp-content/uploads/2020/05/Untitled-design.png':'img',
      },
    ),
    AboutArticle(
      id: '3',
      body: '[{"insert":"Title for About Article\\n"}]',
      title: 'Portadown',
      serviceTime: 'Belfast Service Time here',
      locationID: '1',
      locationPastorUID: '1',
      gallerySources: {
        'https://ctrim.co.uk/wp-content/uploads/2020/04/2.png':'img',
      },
    ),
  ];

  List<AboutArticle> get allArticles => _allArticles;

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
      gallerySources: articleToEdit.gallerySources
    );

    _originalArticle = AboutArticle(
      id: articleToEdit.id,
      body: articleToEdit.body,
      title: articleToEdit.title,
      serviceTime: articleToEdit.serviceTime,
      locationID: articleToEdit.locationID,
      locationPastorUID: articleToEdit.locationPastorUID,
      gallerySources: articleToEdit.gallerySources
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
      int index = _allArticles.indexWhere((e) => e.id.compareTo(_articleToEdit.id)==0);
      _allArticles[index] = _articleToEdit;
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
