import 'package:ctrim_app_v1/blocs/AboutBloc/about_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zefyr/zefyr.dart';

class EditAboutArticlePage extends StatefulWidget {
  @override
  _EditAboutArticlePageState createState() => _EditAboutArticlePageState();
}

class _EditAboutArticlePageState extends State<EditAboutArticlePage> {

  AboutBloc _aboutBloc;

  @override
  void initState() {
    _aboutBloc = BlocProvider.of<AboutBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return ConfirmationDialogue().leaveEditPage(context: context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Edit About Article'),),
        body: BlocListener(
          cubit: _aboutBloc,
          listenWhen: (_,state){
            if(state is AboutArticleAttemptingToSaveRecordState || 
            state is AboutArticleRebuildAboutTabState) return true;
            return false;
          },
          listener: (_,state){
            if(state is AboutArticleAttemptingToSaveRecordState){
              ConfirmationDialogue().uploadTaskStarted(context: context);
            }else if(state is AboutArticleRebuildAboutTabState){
              BlocProvider.of<TimelineBloc>(context).add(TimelineRebuildAboutTabEvent());
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          child: _buildBody()
        ),
      ),
    );
  }

  Widget _buildBody(){
    SizedBox padding = SizedBox(height: 8,);
    AboutArticle article = _aboutBloc.articleToEdit;
    
    return BlocListener<AboutBloc, AboutState>(
      listener: (_,state){

      },
      child: ListView(
        children: [
          padding,
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('ID: ' + article.id),
          ),
          padding,
          MyTextField(
            controller: TextEditingController(text: _aboutBloc.articleToEdit.title),
            label: 'Title',
            onTextChange: (newString)=>_aboutBloc.add(AboutArticleTextChangeEvent(title: newString)),
          ),
          padding,
          MyTextField(
            controller: TextEditingController(text: _aboutBloc.articleToEdit.serviceTime),
            label: 'Service Time',
            onTextChange: (newString)=>_aboutBloc.add(AboutArticleTextChangeEvent(serviceTime: newString)),
          ),
          padding,
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('Location Pastor'),
          ),
          _buildSelectPastorUID(),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('Location Address'),
          ),
          _buildSelectLocationID(),
          padding,
          Divider(),
          _buildBodyView(),
          MyRaisedButton(
            externalPadding: EdgeInsets.all(8),
            label: 'Edit Body',
            icon: Icons.edit,
            onPressed: ()=> BlocProvider.of<AppBloc>(context).add(AppToEditAboutBodyEvent()),
          ),
          _buildSaveButton(),
          padding,
        ],
      ),
    );
  }

  Widget _buildSelectPastorUID(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Change This at Firebase Console'),
    );
  }

  Widget _buildSelectLocationID(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Change This at Firebase Console'),
    );
  }

  Widget _buildSaveButton(){
    return BlocBuilder<AboutBloc, AboutState>(
      buildWhen: (_,state){
        if(state is AboutArticleEnableSaveButtonState || state is AboutArticleDisableSaveButtonState) return true;
        return false;
      },
      builder: (_,state){
        return MyRaisedButton(
          externalPadding: EdgeInsets.symmetric(horizontal: 8),
          label: 'Save Changes',
          onPressed: (state is AboutArticleEnableSaveButtonState) ? (){
            ConfirmationDialogue().saveRecord(context: context, record: 'About Article',editing: true).then((result){
              if(result){
                _aboutBloc.add(AboutArticleSaveRecordEvent());
              }
            });
          }:null,
        );
      },
    );
  }

  Widget _buildBodyView(){
    return BlocBuilder<AboutBloc, AboutState>(
      buildWhen: (_,state){
        if(state is AboutArticleBodyChangedState) return true;
        return false;
      },
      builder: (_,state){
        return Container(
          padding: EdgeInsets.all(8),
          child: ZefyrView(document: _aboutBloc.getAboutBody(),),
        );
      },
    );
  }
}