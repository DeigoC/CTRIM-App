import 'package:ctrim_app_v1/blocs/PostBloc/post_bloc.dart';
import 'package:ctrim_app_v1/widgets/events/event_fields.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';

class ScheduleTabBody extends StatefulWidget {
  
  final PostBloc _eventBloc;
  ScheduleTabBody(this._eventBloc);

  @override
  _ScheduleTabBodyState createState() => _ScheduleTabBodyState();
}

class _ScheduleTabBodyState extends State<ScheduleTabBody> {
 
  List<int> _numbersTestData = [1,2,3,4,5]; 
  TextEditingController _tecDuration;

  @override
  void initState() {
    _tecDuration = TextEditingController();
    super.initState();
  }

  @override
  void dispose() { 
    _tecDuration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        EventLocationField(),
        EventDateTimeField(widget._eventBloc),
      MyTextField(
        controller: _tecDuration,
        label: 'Duration',
        hint: '(Optional) e.g. 2-3 Hours, Whole Day, Pending',
        onTextChange: (newDuration) => null,
      ),
      SizedBox(height: 16,),
      Divider(thickness: 2,),
      SizedBox(height: 8,),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          height: MediaQuery.of(context).size.height * 0.6,
          child: ReorderableListView(
            header: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Optional Schedule-like table'),
                FlatButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Item'),
                  onPressed: () => null,
                ),
              ],
            ),
            onReorder: (oldIndex, newIndex){
              setState(() {
                int temp = _numbersTestData.removeAt(oldIndex);
                if(newIndex > _numbersTestData.length - 1) newIndex = _numbersTestData.length;
                _numbersTestData.insert(newIndex, temp);
              });
            },
            children: _numbersTestData.map((item){
              return _createReorderableItem(item);
            }).toList(),
          ),
        ),
      )
      ],
    );
  }

  Widget _createReorderableItem(int item){
    return Dismissible(
      onDismissed: (_){
         setState(() {
          _numbersTestData.remove(item);
        });
      },
      background: Container(color: Colors.red,),
      key: ValueKey(item),
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text('This is a really long text of the ages yeah yeah yeah!'),
              ),
            ),
             Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text('Item: $item'),
            ),
             ),
          ],
        ),
      ),
    );
  }
}