import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  bool _loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _description = "";
  String _location = "ALU Hub";
  DateTime _dateTime = DateTime.now();
  String _selectedRoom = rooms.first; // Initialize with the first room in the list.

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2021),
        lastDate: DateTime(2100));
    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
            picked.hour, picked.minute);
      });
    }
  }


  void _submitForm() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      setState(() {
        _loading = true; // Set loading state to true
      });
      try {
        final docRef = await FirebaseFirestore.instance.collection("events").add({});
        await docRef.update({
          "description": _description,
          "location": _location,
          "dateTime": _dateTime.toIso8601String(),
          "room": _selectedRoom,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Event created successfully!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating event: $e")),
        );
      } finally {
        setState(() {
          _loading = false; // Set loading state to false
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Event"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

          TextFormField(
          decoration: InputDecoration(
          labelText: "Event Description",
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description for the event';
            }
            return null;
          },
          onSaved: (value) {
            _description = value!;
          },
        ),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Location",
          ),
          value: _location,
          onChanged: (value) {
            setState(() {
              _location = value!;
            });
          },
          items: <String>['ALU Hub', 'ALU Campus']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select a location';
            }
            return null;
          },
          onSaved: (value) {
            _location = value!;
          },
        ),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Room",
          ),
          value: _selectedRoom,
          onChanged: (value) {
            setState(() {
              _selectedRoom = value!;
            });
          },
          items: rooms
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select a room';
            }
            return null;
          },
          onSaved: (value) {
            _selectedRoom = value!;
          },
        ),








              SizedBox(height: 16.0),
          Row(
              children: [
          Expanded(
          child: InkWell(
          onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${_dateTime.day}/${_dateTime.month}/${_dateTime.year}",
              style: TextStyle(fontSize: 16.0),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),

      ),

    ),
    ),
    SizedBox(width: 16.0),
    Expanded(
    child: InkWell(
    onTap: () => _selectTime(context),
    child: InputDecorator(
    decoration: InputDecoration(
    labelText: 'Time',),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${_dateTime.hour}:${_dateTime.minute.toString().padLeft(2, '0')}",
            style: TextStyle(fontSize: 16.0),
          ),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    ),
    ),
    ),
              ],
          ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text("Create Event"),
                ),
              ],
            ),
          ),
      ),
    );
  }
}


