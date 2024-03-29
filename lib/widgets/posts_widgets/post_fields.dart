import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/classes/models/location.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:ctrim_app_v1/widgets/MyInputs.dart';
import 'package:ctrim_app_v1/widgets/my_outputs/helpDialogTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

class PostDateTimeField extends StatefulWidget {
  @override
  _PostDateTimeFieldState createState() => _PostDateTimeFieldState();
}

class _PostDateTimeFieldState extends State<PostDateTimeField> {
  
  PostBloc _postBloc;

  @override
  void initState() {
    _postBloc = BlocProvider.of<PostBloc>(context);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      cubit: _postBloc,
      listenWhen: (_,state){
        if(state is PostEndDateNotAcceptedState) return true;
        return false;
      },
      listener: (_,state){
        if(state is PostEndDateNotAcceptedState){
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('End Date MUST be set after Start Date!'),
          ));
        }
      },
      buildWhen: (_,state){
        if(state is PostScheduleState) return true;
        return false;
      },
      builder:(_,state)=> Container(
        padding: EdgeInsets.symmetric(horizontal:8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date & Time*',style: TextStyle(fontSize: 18),),
                IconButton(
                  icon: Icon(AntDesign.questioncircleo),
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (_){
                        return HelpDialogTile(
                          title: 'Date & Time (Required)',
                          subtitle:'• Finish DateTime must be set after Start DateTime.' +
                          "\n\n• Can be set to 'N/A' when this doesn't apply. \n\n• 'All Day' needs a Start DateTime",
                        );
                      }
                    );
                  },
                )
              ],
            ),
            Text('Start',style: TextStyle(fontSize: 14),),
            Wrap(
              spacing: 8,
              children: [
                MyFlatButton(
                  label: _postBloc.selectedStartDateString,
                  border: true,
                  onPressed: ()=>_selectStartDate(),
                ),
                MyFlatButton(
                  label: _postBloc.selectedStartTimeString,
                  border: true,
                  onPressed: ()=> _selectStartTime(),
                ),
              ],
            ),
            SizedBox(height: 8,),
            Text('Finish',style: TextStyle(fontSize: 14), ),
            Wrap(
              spacing: 8,
              children: [
                MyFlatButton(
                  border: true,
                  label: _postBloc.selectedEndDateString,
                  onPressed:_postBloc.isEndDateButtonEnabled ? ()=> _selectEndDate():null,
                ),
                MyFlatButton(
                  border: true,
                  label: _postBloc.selectedEndTimeString,
                  onPressed:_postBloc.isEndDateButtonEnabled? ()=> _selectEndTime():null,
                ),
              ],
            ),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow(){
    return  Row(
      children: [
        MyCheckBox(
          boxLeftToRight: true,
          label: 'Not Applicable',
          onChanged: (_)=>_postBloc.add(PostDateNotApplicableClickEvent()),
          value: _postBloc.isPostDateNotApplicable,
        ),
        MyCheckBox(
          boxLeftToRight: true,
          label: 'All Day',
          onChanged: (_)=>_postBloc.add(PostAllDayDateClickEvent()),
          value: _postBloc.isEventAllDay,
        ),
      ],
    );
  }

  Future<Null> _selectStartDate() async{
     DateTime pickedDate = _postBloc.selectedStartDate;
    pickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime.now().subtract(Duration(days: 1000)),
      lastDate: DateTime.now().add(Duration(days: 1000)),
    );
    _postBloc.add(PostSetStartPostDateEvent(pickedDate));
  }

  Future<Null> _selectEndDate() async{
     DateTime pickedDate = _postBloc.selectedEndDate;
    pickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime.now().subtract(Duration(days: 1000)),
      lastDate: DateTime.now().add(Duration(days: 1000)),
    );
    _postBloc.add(PostSetEndPostDateEvent(pickedDate));
  }

  Future<Null> _selectStartTime() async{
    TimeOfDay pickedTime = TimeOfDay.fromDateTime(_postBloc.selectedStartDate);
    pickedTime =await showTimePicker(context: context, initialTime: pickedTime);
    _postBloc.add(PostSetStartPostTimeEvent(pickedTime));
  }

  Future<Null> _selectEndTime() async{
    TimeOfDay pickedTime = TimeOfDay.fromDateTime(_postBloc.selectedEndDate);
    pickedTime =await showTimePicker(context: context, initialTime: pickedTime);
    _postBloc.add(PostSetEndPostTimeEvent(pickedTime));
  }
}

class PostLocationField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<PostBloc, PostState>(
        buildWhen: (_, currentState) {
            if (currentState is PostLocationSelectedState) return true;
            return false;
        }, 
        builder: (_, state) {
            String addressLine = BlocProvider.of<PostBloc>(context).addressLine;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Location*',style: TextStyle(fontSize: 18),),
                      IconButton(
                        icon: Icon(AntDesign.questioncircleo),
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (_){
                              return HelpDialogTile(
                                title: 'Location (Required)',
                                subtitle: "Address of the event. Can be set to 'N/A' if this doesn't apply or 'Online'" + 
                                " when it's set online.",
                              );
                            }
                          );
                        },
                      )
                    ],
                  ),
                ),
                MyFlatButton(
                  externalPadding: EdgeInsets.symmetric(horizontal: 8),
                  border: true,
                  label: addressLine,
                  onPressed: () => BlocProvider.of<AppBloc>(context).add(AppToSearchLocationEvent(
                          BlocProvider.of<PostBloc>(context))),
                ),
                Row(
                  children: [
                    MyCheckBox(
                      label: 'Not Applicable',
                      value: BlocProvider.of<PostBloc>(context).newPost.locationID == '0',
                      onChanged: (newValue){
                        if(newValue){
                          BlocProvider.of<PostBloc>(context).add(PostSelectedLocationEvent(
                            location: Location(id: '0'),
                            addressLine: 'Location Not Applicable'
                          ));
                        }else{
                          BlocProvider.of<PostBloc>(context).add(PostSelectedLocationEvent(
                            location: null,
                            addressLine: 'PENDING'
                          ));
                        }
                      },
                    ),

                    MyCheckBox(
                      label: 'Online',
                      value: BlocProvider.of<PostBloc>(context).newPost.locationID == '-1',
                      onChanged: (newValue){
                        if(newValue){
                          BlocProvider.of<PostBloc>(context).add(PostSelectedLocationEvent(
                            location: Location(id: '-1'),
                            addressLine: 'Online'
                          ));
                        }else{
                          BlocProvider.of<PostBloc>(context).add(PostSelectedLocationEvent(
                            location: null,
                            addressLine: 'PENDING'
                          ));
                        }
                      },
                    ),


                  ],
                ),
              ],
            );
          }),
    );
  }
}

class PostTagsField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tags*',style: TextStyle(fontSize: 18),),
              IconButton(
                icon: Icon(AntDesign.questioncircleo),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (_){
                      return HelpDialogTile(
                        title: 'Tags (Required)',
                        subtitle:"Classify the post's type and target audience.",
                      );
                    }
                  );
                },
              )
            ],
          ),
          BlocBuilder<PostBloc, PostState>(
           buildWhen: (_, state) {
            if (state is PostDepartmentClickState) return true;
            return false;
          }, 
          builder: (_, state) {
            return Wrap(
              spacing: 8.0,
              children: BlocProvider.of<PostBloc>(context).selectedTags.keys.map((department) {
                String departmentString = _mapDepartmentToString(department);

                return MyFilterChip(
                  filteringPosts: false,
                  label: departmentString,
                  selected: BlocProvider.of<PostBloc>(context).selectedTags[department],
                  onSelected: (newValue) {
                    BlocProvider.of<PostBloc>(context).add(PostDepartmentClickEvent(department,newValue,));
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  String _mapDepartmentToString(PostTag department) {
    switch (department) {
      case PostTag.YOUTH:return 'Youth';
      case PostTag.WOMEN:return 'Women';
      case PostTag.MEN:return 'Men';
      case PostTag.KIDS:return 'Kids';
      case PostTag.BELFAST:return 'Belfast';
      case PostTag.NORTHCOAST:return 'Northcoast';
      case PostTag.PORTADOWN:return 'Portadown';
      case PostTag.TESTIMONIES:return 'Testimonies';
      case PostTag.EVENTS:return 'Events';
      case PostTag.ONLINE: return 'Online';
    }
    return '';
  }
}

class DetailTable extends StatelessWidget {
  static BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(16)),
        height: MediaQuery.of(context).size.height * 0.6,
        child: BlocBuilder<PostBloc, PostState>(
          buildWhen: (_, currentState) {
          if (currentState is PostDetailListReorderState) return true;
          return false;
        }, builder: (_, state) {
          return ReorderableListView(
            header: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: MyTextField(
                      label: 'Custom List',
                      maxLength: 30,
                      controller: TextEditingController(
                          text: BlocProvider.of<PostBloc>(context)
                              .newPost
                              .detailTableHeader),
                      hint: 'Insert List Header',
                      helpText: "I'm still on the fence about this feature. Not sure what to make of it",
                      optional: true,
                      onTextChange: (newHeader) {
                        BlocProvider.of<PostBloc>(context).newPost.detailTableHeader = newHeader;
                      },
                    ),
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Item'),
                    onPressed: () => _addNewListItem(),
                  ),
                ],
              ),
            ),
            onReorder: (oldIndex, newIndex) {
              BlocProvider.of<PostBloc>(context).add(PostDetailListReorderEvent(
                  newIndex: newIndex, oldIndex: oldIndex));
            },
            children:
                BlocProvider.of<PostBloc>(context).detailTable.map((item) {
              return _createReorderableItem(item);
            }).toList(),
          );
        }),
      ),
    );
  }

  Widget _createReorderableItem(Map<String,String> item) {
    return Dismissible(
      onDismissed: (_) {
        BlocProvider.of<PostBloc>(_context).add(PostDetailListItemRemovedEvent(item));
      },
      background: Container(color: Colors.red,),
      key: ValueKey(item),
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => _editItem(item),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(item['Leading']),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(item['Trailing']),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewListItem() {
    BlocProvider.of<PostBloc>(_context).prepareNewDetailListItem();

    showDialog(
        context: _context,
        builder: (_) {
          int itemNumber = (BlocProvider.of<PostBloc>(_context).detailTable.length +1);
          
          return Dialog(
            shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(8),
              height: MediaQuery.of(_context).size.height * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Item ' +itemNumber.toString(),style: TextStyle(fontSize: 18),),
                    SizedBox(height: 8,),
                    MyTextField(
                      label: 'Leading',
                      optional: true,
                      buildHelpIcon: false,
                      controller:TextEditingController(text: '$itemNumber.'),
                      onTextChange: (newLeading) =>
                          BlocProvider.of<PostBloc>(_context).add(
                              PostDetailListTextChangeEvent(leading: newLeading)),
                    ),
                    SizedBox(height: 8,),
                    MyTextField(
                      label: 'Trailing',
                      controller: null,
                      optional: true,
                      buildHelpIcon: false,
                      onTextChange: (newTrailing) =>
                          BlocProvider.of<PostBloc>(_context).add(
                              PostDetailListTextChangeEvent(
                                  trailing: newTrailing)),
                    ),
                    SizedBox(height: 8,),
                    BlocBuilder(
                      cubit: BlocProvider.of<PostBloc>(_context),
                      buildWhen: (_, state) {
                        if (state is PostDetailListState) return true;
                        return false;
                      },
                      builder: (_, state) => RaisedButton(
                        child: Text('Add Item'),
                        onPressed: (state is PostDetailListSaveEnabledState)
                            ? () {
                                BlocProvider.of<PostBloc>(_context).add(PostDetailListAddItemEvent());
                                Navigator.of(_context).pop();
                              }
                            : null,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _editItem(Map<String,String> item) {
    int itemIndex =BlocProvider.of<PostBloc>(_context).detailTable.indexOf(item);
    BlocProvider.of<PostBloc>(_context).prepareDetailItemEdit(item);

    showDialog(
        context: _context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(8),
              height: MediaQuery.of(_context).size.height * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Item ' + (itemIndex + 1).toString(),style: TextStyle(fontSize: 18),),
                  SizedBox(height: 8,),
                  MyTextField(
                    label: 'Leading',
                    controller: TextEditingController(text: item['Leading']),
                    onTextChange: (newLeading) =>
                        BlocProvider.of<PostBloc>(_context).add(PostDetailListTextChangeEvent(leading: newLeading)),
                  ),
                  SizedBox( height: 8,),
                  MyTextField(
                    label: 'Trailing',
                    controller: TextEditingController(text: item['Trailing']),
                    onTextChange: (newTrailing) =>
                        BlocProvider.of<PostBloc>(_context).add(
                            PostDetailListTextChangeEvent(
                                trailing: newTrailing)),
                  ),
                  SizedBox( height: 8,),
                  BlocBuilder(
                    cubit: BlocProvider.of<PostBloc>(_context),
                    buildWhen: (_, state) {
                      if (state is PostDetailListState) return true;
                      return false;
                    },
                    builder: (_, state) => RaisedButton(
                      child: Text('Save Item'),
                      onPressed: (state is PostDetailListSaveEnabledState)
                          ? () {
                              BlocProvider.of<PostBloc>(_context)
                                  .add(PostDetailListSaveEditEvent(itemIndex));
                              Navigator.of(_context).pop();
                            }
                          : null,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
