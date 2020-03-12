import 'package:bloconotas/model/Note.dart';
import 'package:flutter/material.dart';
import 'helper/AnotacaoHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _titleEditController = TextEditingController();
  TextEditingController _descriptionEditController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Note> _notes = List<Note>();
  int _selectedIndex = 0; //to select bottom navigator item

  _showDialogScreen({Note note}) {
    String saveUpdate = "";

    if (note == null) {
      //save
      _titleEditController.text = "";
      _descriptionEditController.text = "";
      saveUpdate = "Salvar";
    } else {
      //update
      _titleEditController.text = note.title;
      _descriptionEditController.text = note.description;
      saveUpdate = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$saveUpdate Nota"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _titleEditController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título", hintText: "Digite o Título."),
                ),
                TextField(
                  controller: _descriptionEditController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Descrição", hintText: "Digite sua nota."),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    _saveNote(saveOrUpdate: note);
                    Navigator.pop(context);
                  },
                  child: Text("$saveUpdate"))
            ],
          );
        });
  }

  _saveNote({Note saveOrUpdate}) async {
    String title = _titleEditController.text;
    String description = _descriptionEditController.text;

    if (saveOrUpdate == null) {
      //save
      Note note = Note(title, description, DateTime.now().toString());
      await _db.saveNote(note);
    } else {
      //update

      saveOrUpdate.title = title;
      saveOrUpdate.description = description;
      saveOrUpdate.date = DateTime.now().toString();
      await _db.updateNote(saveOrUpdate);
    }
  }

  _getNote() async {
    List recoveredNotes = await _db.getNote();
    List<Note> tempList = List<Note>();

    for (var i in recoveredNotes) {
      Note note = Note.fromMap(i);
      tempList.add(note);
    }
    setState(() {
      _notes = tempList;
    });
    tempList = null;
  }

  _formatDate(String data) {
    //Method to format date and hour
    initializeDateFormatting('pt_BR');

    String formatedDate = DateFormat.yMd("pt_BR").format(DateTime.parse(data));
    return formatedDate;
  }

  _deleteNote(int id) async {
    await _db.removeNote(id);
    _getNote();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override //getting note before create a screen
  void initState() {
    super.initState();
    _getNote();
  }

  @override
  Widget build(BuildContext context) {
    _getNote();

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: Text(
            "Bloco de Notas",
            style: TextStyle(color: Colors.black54),
          ),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];

                return Card(
                  elevation: 5,
                  child: ListTile(
                      title: Text(
                        "${note.title}",
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        "${_formatDate(note.date)} - ${note.description}",
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _showDialogScreen(note: note);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 30),
                              child: Icon(
                                Icons.edit,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _deleteNote(note.id);
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.black38,
                            ),
                          )
                        ],
                      )),
                );
              },
            ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          child: Icon(Icons.add),
          onPressed: () {
            _descriptionEditController.clear();
            _titleEditController.clear();
            _showDialogScreen();
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              title: Text('Notas'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle),
              title: Text('Tarefas'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black54,
          unselectedItemColor: Colors.black38,
          onTap: _onItemTapped,
        ));
  }
}
