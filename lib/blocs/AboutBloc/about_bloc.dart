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
      gallerySources: {},
    ),
    AboutArticle(
      id: '1',
      title: 'Belfast',
      serviceTime: 'Belfast Service Time here',
      locationID: '1',
      locationPastorUID: '1',
      gallerySources: {
        'https://ctrim.co.uk/wp-content/uploads/2020/04/4-768x768.png':'img',
      },
    ),
    AboutArticle(
      id: '2',
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

  @override
  AboutState get initialState => AboutInitial();

  @override
  Stream<AboutState> mapEventToState(
    AboutEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
