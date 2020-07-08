import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:meta/meta.dart';

part 'about_event.dart';
part 'about_state.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {

  List<AboutArticle> _allArticles = [
    AboutArticle(// ? This can be the MAIN about article, has no other data but the gallery
      id: '0',
      gallerySources: {}
    ),
    AboutArticle(
      id: '1',
      title: 'Belfast Church',
      serviceTime: 'Belfast Service Time here',
      locationID: '1',
      locationPastorUID: '1',
      gallerySources: {},
    ),
    AboutArticle(
      id: '2',
      title: 'Lisburn',
      serviceTime: 'Belfast Service Time here',
      locationID: '1',
      locationPastorUID: '1',
      gallerySources: {},
    ),
    AboutArticle(
      id: '3',
      title: 'North Coast',
      serviceTime: 'Belfast Service Time here',
      locationID: '1',
      locationPastorUID: '1',
      gallerySources: {},
    ),
  ];

  
  @override
  AboutState get initialState => AboutInitial();

  @override
  Stream<AboutState> mapEventToState(
    AboutEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
