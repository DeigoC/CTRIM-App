import 'package:ctrim_app_v1/blocs/AboutBloc/about_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/TimelineBloc/timeline_bloc.dart';
import 'package:ctrim_app_v1/classes/models/aboutArticle.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/user.dart';
import 'package:ctrim_app_v1/classes/other/confirmationDialogue.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:zefyr/zefyr.dart';

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
          bloc: _aboutBloc,
          condition: (_,state){
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
          _buildBodyView(),
          MyRaisedButton(
            externalPadding: EdgeInsets.all(8),
            label: 'Edit Body',
            icon: Icons.edit,
            onPressed: ()=> BlocProvider.of<AppBloc>(context).add(AppToEditAboutBodyEvent()),
          ),
          /*  FlatButton.icon(
            onPressed: ()=> BlocProvider.of<AppBloc>(context).add(AppToEditAboutBodyEvent()), 
            icon: Icon(Icons.edit, color: Colors.white,), 
            label: Text('Edit Body', style: TextStyle(color: Colors.white),),
            color: Colors.blue,
          ), */
          _buildSaveButton(),
          padding,
        ],
      ),
    );
  }

  Widget _buildSelectPastorUID(){
    return BlocBuilder<AboutBloc, AboutState>(
      condition: (_,state){
        if(state is AboutArticlePastorUIDChangedState) return true;
        return false;
      },
      builder: (_,state){
        User pastor = BlocProvider.of<TimelineBloc>(context).allUsers.firstWhere((u) => u.id.compareTo(_aboutBloc.articleToEdit.locationPastorUID)==0);
        
        return MyFlatButton(
          externalPadding: EdgeInsets.all(8),
          label: pastor.forename + ' ' + pastor.surname,
          onPressed:()=>_selectNewPastorUID(),
          icon:Icons.edit,
          border: true,
        );
      },
    );
  }

  Widget _buildSelectLocationID(){
    return BlocBuilder<AboutBloc, AboutState>(
      condition: (_,state){
        if(state is AboutArticleLocationIDChangedState) return true;
        return false;
      },
      builder: (_,state){
        Location l = BlocProvider.of<TimelineBloc>(context).selectableLocations.firstWhere((e) => e.id.compareTo(_aboutBloc.articleToEdit.locationID)==0);
        
        return MyFlatButton(
          label: l.addressLine,
          onPressed:()=>_selectNewLocationID(),
          border: true,
          icon: Icons.edit_location,
        );
      },
    );
  }

  Widget _buildSaveButton(){
    return BlocBuilder<AboutBloc, AboutState>(
      condition: (_,state){
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
      condition: (_,state){
        if(state is AboutArticleBodyChangedState) return true;
        return false;
      },
      builder: (_,state){
        return Container(
          padding: EdgeInsets.all(8),
          child: Text('To be Fixed')
          //ZefyrView(document: _aboutBloc.getAboutBody(),),
        );
      },
    );
  }

  void _selectNewPastorUID() {
     showDialog(
      context: context,
      builder: (_){
        List<User> allUsers = BlocProvider.of<TimelineBloc>(context).allUsers;
        return Dialog(
          child: Container(
            child: ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (_,index){
                return ListTile(
                  title: Text(allUsers[index].forename + ' ' + allUsers[index].surname),
                  subtitle: Text('Admin Level: '+allUsers[index].adminLevel.toString()),
                  onTap: (){
                    _aboutBloc.add(AboutPastorUIDChangeEvent(allUsers[index].id));
                    Navigator.of(context).pop();
                  },
                );
              }
            ),
          ),
        );
      }
    );
  }

  void _selectNewLocationID(){
    showDialog(
      context: context,
      builder: (_){
        List<Location> allLcoations = List.from(BlocProvider.of<TimelineBloc>(context).selectableLocations);
        allLcoations.removeWhere((e) => e.id=='0');
        return Dialog(
          child: Container(
            child: ListView.separated(
              itemCount: allLcoations.length,
              separatorBuilder: (_,index)=> Divider(),
              itemBuilder: (_,index){
                return ListTile(
                  title: Text(allLcoations[index].addressLine),
                  subtitle: Text(allLcoations[index].description),
                  onTap: (){
                    _aboutBloc.add(AboutLocationIDChangeEvent(allLcoations[index].id));
                    Navigator.of(context).pop();
                  },
                );  
              }
            ),
          ),
        );
      },
    );
  }
}