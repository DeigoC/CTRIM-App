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
        return ConfirmationDialogue.leaveEditPage(context: context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Edit About Article'),),
        body: _buildBody(),
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
          padding,
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('Location Address'),
          ),
          _buildSelectLocationID(),
          padding,
          _buildBodyView(),
           FlatButton.icon(
            onPressed: ()=> BlocProvider.of<AppBloc>(context).add(AppToEditAboutBodyEvent()), 
            icon: Icon(Icons.edit, color: Colors.white,), 
            label: Text('Edit Body', style: TextStyle(color: Colors.white),),
            color: Colors.blue,
          ),
          padding,
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
        User pastor = BlocProvider.of<TimelineBloc>(context)
        .allUsers.firstWhere((u) => u.id.compareTo(_aboutBloc.articleToEdit.locationPastorUID)==0);
        return FlatButton(
          color: Colors.blue,
          child: Text(pastor.forename + ' ' + pastor.surname, style: TextStyle(color: Colors.white),),
          onPressed: ()=>_selectNewPastorUID(),
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
        Location l = BlocProvider.of<TimelineBloc>(context).allLocations
        .firstWhere((e) => e.id.compareTo(_aboutBloc.articleToEdit.locationID)==0);
        return FlatButton(
          child: Text(l.addressLine, style: TextStyle(color: Colors.white),),
          color: Colors.blue,
          onPressed: ()=>_selectNewLocationID(),
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
        return RaisedButton(
          child: Text('Save Changes'),
          onPressed: (state is AboutArticleEnableSaveButtonState) ? ()=>null:null,
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
          child: ZefyrView(document: _aboutBloc.getAboutBody(),),
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
        List<Location> allLcoations = List.from(BlocProvider.of<TimelineBloc>(context).allLocations);
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