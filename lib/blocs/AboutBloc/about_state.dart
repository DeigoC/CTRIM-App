part of 'about_bloc.dart';

@immutable
abstract class AboutState {}

class AboutInitial extends AboutState {}

class AboutArticlePastorUIDChangedState extends AboutState{}
class AboutArticleLocationIDChangedState extends AboutState{}
class AboutArticleBodyChangedState extends AboutState{}

class AboutArticleEnableSaveButtonState extends AboutState{}
class AboutArticleDisableSaveButtonState extends AboutState{}

class AboutArticleAttemptingToSaveRecordState extends AboutState{}
class AboutArticleRebuildAboutTabState extends AboutState{}