import 'package:ctrim_app_v1/blocs/AdminBloc/admin_bloc.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialLinksDisplay extends StatelessWidget {
  
  final Map<String,String> socialLinks;

  SocialLinksDisplay(this.socialLinks);
  
  @override
  Widget build(BuildContext context) {
    if(socialLinks.length == 0){
      return Center(child: Text('N/A'));
    }
    return Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 4,
        children: socialLinks.keys.map((type){
          return Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: IconButton(
              tooltip: type + ' link',
              icon: _getIconFromString(type),
              onPressed: () async{
                //AppBloc.openURL(socialLinks[type]);
                if(await canLaunch(socialLinks[type])){
                  await launch(socialLinks[type]);
                }else{
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Couldn't open the link!"),
                    action: SnackBarAction(label: 'Ok',onPressed: (){},),
                  ));
                }
              },
            ),
          );
        }).toList()
      ),
    );
  }

   Icon _getIconFromString(String socialName){
    switch(socialName){
      case 'Youtube':return Icon(AntDesign.youtube,color: Colors.white,);
      case 'Facebook': return Icon(AntDesign.facebook_square,color: Colors.white,);
      case 'Instagram':return Icon(AntDesign.instagram,color: Colors.white,);
      case 'Twitter': return Icon(AntDesign.twitter,color: Colors.white,);
    }
    return null;
  }
}

class SocialLinksEdit extends StatefulWidget {
  final AdminBloc _adminBloc;
  SocialLinksEdit(this._adminBloc);
  @override
  _SocialLinksEditState createState() => _SocialLinksEditState();
}

class _SocialLinksEditState extends State<SocialLinksEdit> {
  
  bool _adding = false, _editing = false, _enableButton = false;
  String _selectedTypeToEdit;
  TextEditingController _tecLinkContact;

  List<String> _availableTypes =[
    'Youtube','Facebook','Instagram'
  ];

  @override
  void initState() {
    _tecLinkContact = TextEditingController();
    super.initState();
  }
  
  @override
  void dispose() { 
    _tecLinkContact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        appBar: AppBar(
          /* shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ), */
          automaticallyImplyLeading: false,
          title:Text('Social Links'),
          actions: [ 
            (_adding||_editing) 
            ? MyRaisedButton(
              externalPadding: EdgeInsets.all(8),
              label: 'Cancel',
              onPressed: (){
                setState(() {
                  _adding = false; 
                  _editing = false;
                });
              },
            ):MyRaisedButton(
              externalPadding: EdgeInsets.all(8),
              label: 'Done',
              onPressed: (){
                widget._adminBloc.add(AdminRebuildSocialLinksEvent());
                Navigator.of(context).pop();
              },
            ) ,
          ]
        ),
        body: _buildBody(),
        floatingActionButton: (_adding||_editing) ? null: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            setState(() {
              _tecLinkContact.clear();
              _enableButton = false;
              _selectedTypeToEdit = null;
              _adding = true;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBody(){
    if(_adding) return _buildAddingLink();
    else if(_editing) return _buildAddingLink();
    return _buildViewing();
  }

  Widget _buildAddingLink(){
    List<String> availableTypes = List.from(_availableTypes);
    availableTypes.removeWhere((e) => widget._adminBloc.selectedUser.socialLinks.containsKey(e));
    if(_editing) availableTypes.add(_selectedTypeToEdit);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MyDropdownList(
            label: 'Type: ',
            disable: _editing,
            items: availableTypes,
            value: _selectedTypeToEdit,
            onChanged: (newValue){
              setState(() {
                _selectedTypeToEdit = newValue;
              });
              _canEnableSaveButton();
            },
          ),
        ),
        MyTextField(
          label: 'Link/Contact',
          controller: _tecLinkContact,
          onTextChange: (_){
            _canEnableSaveButton();
          },
        ),
        MyRaisedButton(
          externalPadding: EdgeInsets.all(8),
          label: 'Save',
          onPressed: _enableButton? (){
            widget._adminBloc.selectedUser.socialLinks[_selectedTypeToEdit] = _tecLinkContact.text.trim();
            _backToViewList();
          }:null,
        ),
      ],
    );
  }

  Widget _buildViewing(){
     Map<String,String> socialLinks = widget._adminBloc.selectedUser.socialLinks;

    return ListView(
      children: socialLinks.keys.map((type){
        return Dismissible(
          key: ValueKey(socialLinks[type]),
          background: Container(color: Colors.red,),
          onDismissed: (_){
            setState(() {
              widget._adminBloc.selectedUser.socialLinks.remove(type);
            });
          },
          child: ListTile(
            leading: _getIconFromLinkType(type),
            title: Text(socialLinks[type]),
            subtitle: Text(type),
            onTap: (){
              _editLinkClick(socialLinks[type], type);
            },
          ),
        );
      }).toList(),
    );
  }

  void _canEnableSaveButton(){
    if(_tecLinkContact.text.trim().isNotEmpty && _selectedTypeToEdit != null && !_enableButton){
      setState(() { _enableButton = !_enableButton;});
    }else if(_enableButton && (_tecLinkContact.text.trim().isEmpty ||_selectedTypeToEdit == null)){
      setState(() { _enableButton = !_enableButton;});
    }
  }

  void _backToViewList(){
    setState(() {
      _adding = false; 
      _editing = false;
    });
  }

  void _editLinkClick(String link, String type){
    setState(() {
      _editing = true;
      _tecLinkContact.text = link;
      _selectedTypeToEdit = type;
    });
  }

  Widget _getIconFromLinkType(String type){
    switch(type){
      case 'Youtube':return Icon(AntDesign.youtube,);
      case 'Facebook': return Icon(AntDesign.facebook_square,);
      case 'Instagram':return Icon(AntDesign.instagram,);
      case 'Twitter': return Icon(AntDesign.twitter,);
    }
    return null;
  }
}