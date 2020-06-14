import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/models/post.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDateTimeField extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
     return BlocBuilder<PostBloc, PostState>(
         condition: (previousState, currentState){
           if(currentState is PostScheduleState) return true;
           return false;
         },
          builder:(_,state){
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date'),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                       FlatButton(
                        child: Text(BlocProvider.of<PostBloc>(context).getSelectedDateString),
                        onPressed: () => BlocProvider.of<PostBloc>(context).add(PostSelectPostDateEvent()),
                      ),
                        Text(' AT '),
                        FlatButton(
                          child: Text( BlocProvider.of<PostBloc>(context).getSelectedTimeString),
                          onPressed: () =>  BlocProvider.of<PostBloc>(context).add(PostSelectPostTimeEvent()),
                        ),
                         MyCheckBox(
                          label: 'Date Not Applicable',
                          onChanged: (newValue) => BlocProvider.of<PostBloc>(context).add(PostDateNotApplicableClick()) ,
                          value:  BlocProvider.of<PostBloc>(context).getIsDateNotApplicable,
                        )
                    ],
                  ),
              ],),
            );
          } 
       );
  }
}

class PostLocationField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Location'),
            BlocBuilder<PostBloc, PostState>(
              condition: (_,currentState){
                if(currentState is PostLocationSelectedState) return true;
                return false;
              },
              builder:(_,state){
                return FlatButton(
                  child: Text(BlocProvider.of<PostBloc>(context).addressLine),
                  onPressed: () => BlocProvider.of<AppBloc>(context).add(AppToSelectLocationForPostEvent(BlocProvider.of<PostBloc>(context))),
                );
              } 
            ),
        ],
      ),
    );
  }
}

class PostDepartmentField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Departments'),
              BlocBuilder<PostBloc, PostState>(
              condition: (_,state){
                if(state is PostDepartmentClickState) return true;
                return false;
              },
              builder:(_,state){
                return Wrap(
                spacing: 8.0,
                children:  BlocProvider.of<PostBloc>(context).selectedTags.keys.map((department){
                  String departmentString = _mapDepartmentToString(department);
                  return FilterChip(
                    label: Text(departmentString),
                    selected:  BlocProvider.of<PostBloc>(context).selectedTags[department],
                    onSelected: (newValue){
                        BlocProvider.of<PostBloc>(context).add(PostDepartmentClickEvent(department, newValue,));
                    },
                  );
                }).toList(),
                );
              } 
            ),
          ],
        ),
    );
  }
  
   String _mapDepartmentToString(Department department){
    String result;
    switch(department){
      case Department.CHURCH: result = 'Church';
      break;
      case Department.YOUTH: result = 'Youth';
      break;
      case Department.WOMEN: result = 'Women';
      break;
    }
    return result;
  }
}

class DetailTable extends StatelessWidget {
  
  static BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(16)
          ),
          height: MediaQuery.of(context).size.height * 0.6,
          child: BlocBuilder<PostBloc, PostState>(
            condition: (_,currentState){
              if(currentState is PostDetailListReorderState) return true;
              return false;
            },
            builder:(_,state){
              return ReorderableListView(
                header: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: MyTextField(
                          label: 'Table Header', 
                          controller: null,
                          hint: '(Optional table-like thing?)',
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
                onReorder: (oldIndex, newIndex){
                  BlocProvider.of<PostBloc>(context).add(PostDetailListReorderEvent(newIndex: newIndex, oldIndex: oldIndex));
                },
                children: BlocProvider.of<PostBloc>(context).detailTable.map((item){
                  return _createReorderableItem(item);
                }).toList(),
              );
            } 
          ),
        ),
      );
  }

   Widget _createReorderableItem(List<String> item){
    return Dismissible(
      onDismissed: (_){
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
                    child: Text(item[0]),
                  ),
                ),
                 Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Text(item[1]),
                ),
                 ),
              ],
            ),
          ),
      ),
    );
  }

   void _addNewListItem(){
    BlocProvider.of<PostBloc>(_context).prepareNewDetailListItem();
    showDialog(
      context: _context, 
      builder: (_){
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            height: MediaQuery.of(_context).size.height * 0.5,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Item ' + (BlocProvider.of<PostBloc>(_context).detailTable.length + 1).toString()),
                SizedBox(height: 8,),
                MyTextField(
                    label: 'Leading', 
                    controller: null,
                    onTextChange: (newLeading) => BlocProvider.of<PostBloc>(_context).add(PostDetailListTextChangeEvent(leading: newLeading)),
                  ),
                  SizedBox(height: 8,),
                  MyTextField(
                    label: 'Trailing', 
                    controller: null,
                    onTextChange: (newTrailing) => BlocProvider.of<PostBloc>(_context).add(PostDetailListTextChangeEvent(trailing: newTrailing)),
                  ),
                  SizedBox(height: 8,),
                  BlocBuilder(
                    bloc: BlocProvider.of<PostBloc>(_context),
                    condition: (_, state) {
                      if(state is PostDetailListState) return true;
                      return false;
                    },
                    builder:(_, state) => RaisedButton(
                      child: Text('Add Item'),
                      onPressed: (state is PostDetailListSaveEnabledState) ? (){
                        BlocProvider.of<PostBloc>(_context).add(PostDetailListAddItemEvent());
                        Navigator.of(_context).pop();
                      }  : null,
                    ),
                  )
              ],
            ),
          ),
        );
      }
    );
  }

  void _editItem(List<String> item){
    int itemIndex = BlocProvider.of<PostBloc>(_context).detailTable.indexOf(item);
    BlocProvider.of<PostBloc>(_context).prepareDetailItemEdit(item);

    showDialog(
      context: _context,
      builder: (_){
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            height: MediaQuery.of(_context).size.height * 0.5,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Item ' + (itemIndex + 1).toString()),
                SizedBox(height: 8,),
                MyTextField(
                    label: 'Leading', 
                    controller: TextEditingController(text: item[0]),
                    onTextChange: (newLeading) => BlocProvider.of<PostBloc>(_context).add(PostDetailListTextChangeEvent(leading: newLeading)),
                  ),
                  SizedBox(height: 8,),
                  MyTextField(
                    label: 'Trailing', 
                    controller: TextEditingController(text: item[1]),
                    onTextChange: (newTrailing) => BlocProvider.of<PostBloc>(_context).add(PostDetailListTextChangeEvent(trailing: newTrailing)),
                  ),
                  SizedBox(height: 8,),
                  BlocBuilder(
                    bloc: BlocProvider.of<PostBloc>(_context),
                    condition: (_, state) {
                      if(state is PostDetailListState) return true;
                      return false;
                    },
                    builder:(_, state) => RaisedButton(
                      child: Text('Save Item'),
                      onPressed: (state is PostDetailListSaveEnabledState) ? (){
                        BlocProvider.of<PostBloc>(_context).add(PostDetailListSaveEditEvent(itemIndex));
                        Navigator.of(_context).pop();
                      }  : null,
                    ),
                  )
              ],
            ),
          ),
        );
      }
    );
  }
}