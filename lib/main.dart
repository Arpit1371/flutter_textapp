import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _notesController = TextEditingController();
  List<Map<String, dynamic>> _notesList = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _saveNotes();
    _notesController.dispose();
    super.dispose();
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notesString = prefs.getString('notes');
    if (notesString != null) {
      List<dynamic> notesJson = jsonDecode(notesString);
      _notesList = notesJson.map((note) => Map<String, dynamic>.from(note)).toList();
      setState(() {});
    }
  }

  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String notesString = jsonEncode(_notesList);
    prefs.setString('notes', notesString);
  }

  void _addNote() {
    String note = _notesController.text;
    if (note.isNotEmpty) {
      _notesList.add({
        'date': DateTime.now().toString(),
        'note': note,
      });
      _notesController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notesList.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> note = _notesList[index];
                return ListTile(
                  title: Text(note['note']),
                  subtitle: Text(note['date']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Type your message here',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ),
              onSubmitted: (value) => _addNote(),
            ),
          ),
        ],
      ),
    );
  }
}



class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  int? _age;
  String? _gender;
  String? _country;
  String? _hobbies;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name');
      _age = prefs.getInt('age');
      _gender = prefs.getString('gender');
      _country = prefs.getString('country');
      _hobbies = prefs.getString('hobbies');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${_name ?? ''}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Age: ${_age?.toString() ?? ''}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Gender: ${_gender ?? ''}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Country: ${_country ?? ''}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Hobbies: ${_hobbies ?? ''}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late String _gender;
  late TextEditingController _countryController;
  late TextEditingController _hobbiesController;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController = TextEditingController(text: prefs.getString('name'));
      _ageController = TextEditingController(text: prefs.getInt('age').toString());
      _gender = prefs.getString('gender') ?? 'Male';
      _countryController = TextEditingController(text: prefs.getString('country'));
      _hobbiesController = TextEditingController(text: prefs.getString('hobbies'));
    });
  }

  void _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _nameController.text);
    prefs.setInt('age', int.tryParse(_ageController.text) ?? 0);
    prefs.setString('gender', _gender);
    prefs.setString('country', _countryController.text);
    prefs.setString('hobbies', _hobbiesController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              ))
                  .toList(),
              decoration: InputDecoration(labelText: 'Gender'),
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                });
              },
            ),
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(labelText: 'Country'),
            ),
            TextFormField(
              controller: _hobbiesController,
              decoration: InputDecoration(labelText: 'Hobbies'),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                _saveProfileData();


              },
            ),
          ],
        ),
      ),
    );
  }
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ProfilePage(),
    ProfileEditPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Edit',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}


