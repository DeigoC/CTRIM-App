import 'package:ctrim_app_v1/blocs/EventBloc/event_bloc.dart';
import 'package:ctrim_app_v1/widgets/events/event_fields.dart';
import 'package:ctrim_app_v1/widgets/generic/MyTextField.dart';
import 'package:flutter/material.dart';

class ScheduleTabBody extends StatefulWidget {
  
  final EventBloc _eventBloc;
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
      Divider(),
      Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.6,
        child: ReorderableListView(
          header: Text('Actual Schedule'),
          onReorder: (oldIndex, newIndex){
            setState(() {
              int temp = _numbersTestData.removeAt(oldIndex);
              if(newIndex > _numbersTestData.length - 1) newIndex = _numbersTestData.length;
              _numbersTestData.insert(newIndex, temp);
            });
          },
          children: _numbersTestData.map((item){
            return ListTile(
              key: ValueKey(item),
              title: Text('Item: $item'),
            );
          }).toList(),
        ),
      )
      ],
    );
  }
}