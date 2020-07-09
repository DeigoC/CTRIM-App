part of 'about_bloc.dart';

@immutable
abstract class AboutEvent {}

class AboutArticleEditEvent extends AboutEvent{}

class AboutPastorUIDChangeEvent extends AboutArticleEditEvent{
  final String pastorUID;
  AboutPastorUIDChangeEvent(this.pastorUID);
}

class AboutLocationIDChangeEvent extends AboutArticleEditEvent{
  final String locationID;
  AboutLocationIDChangeEvent(this.locationID);
}

class AboutArticleTextChangeEvent extends AboutArticleEditEvent{
  final String title, serviceTime;
  AboutArticleTextChangeEvent({this.title,this.serviceTime});
}

class AboutArticleSaveBodyEvent extends AboutArticleEditEvent{
  final String body;
  AboutArticleSaveBodyEvent(this.body);
}

