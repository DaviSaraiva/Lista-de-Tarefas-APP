import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _tarefaConrtroller= TextEditingController();
  List _listTarefa=[];
  Map<String,dynamic> _ultimoRemovido;
  int _posiUltimoRemovido;


  @override
  void initState() {
    super.initState();
    _lerData().then((data) {
      setState(() {
        _listTarefa=json.decode(data);
      });
    });
  }

  void _addTarefa(){
    if(_tarefaConrtroller.text.isEmpty){
        return null;
    }
    else{
      setState(() {
        Map<String,dynamic> novaTarefa = Map();
        novaTarefa ["title"]= _tarefaConrtroller.text;
        _tarefaConrtroller.text="";
        novaTarefa["ok"]=false;
        _listTarefa.add(novaTarefa);
        _saveData();
      });
    }

  }
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _listTarefa.sort((a, b) {
        if (a["ok"] && !b["ok"]) return 1;
        if (!a["ok"] && b["ok"]) return -1;
        else return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas",
          style:TextStyle(fontSize: 25.0),
        ),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _tarefaConrtroller,
                    decoration: InputDecoration(

                      labelText: "Nova tarefa",
                      labelStyle: TextStyle(color: Colors.black),

                    ),
                  ),
                ),
                RaisedButton(

                  color: Colors.black54,
                  child: Text("Add",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  textColor: Colors.white,
                  onPressed: _addTarefa,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _refresh,
            child: ListView.builder(
                padding: EdgeInsets.only(top:10.0),
                itemCount: _listTarefa.length,
                itemBuilder: buildItem),
            ),
          )
        ],
      ),
    );
  }



  Widget buildItem(BuildContext context, int index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9,0.0),
          child: Icon(Icons.delete,color:Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child:CheckboxListTile(
        title: Text(_listTarefa[index]["title"]),
        value: _listTarefa[index]["ok"],
        secondary: CircleAvatar(child:
        Icon(_listTarefa[index]["ok"]?
        Icons.check:Icons.error),
        ),
        onChanged: (c){
          setState(() {
            _listTarefa[index]["ok"]=c;
            _saveData();
          });
        },
      ),
      onDismissed: (direcao){
        setState(() {
          _ultimoRemovido = Map.from(_listTarefa[index]);
          _posiUltimoRemovido= index;
          _listTarefa.removeAt(index);

          _saveData();
          final snack= SnackBar(
            content: Text("Tarefa ${_ultimoRemovido ["title"]} removida!"),
            action: SnackBarAction(label:"Desfazer",
                onPressed: (){
                  setState(() {
                    _listTarefa.insert(_posiUltimoRemovido, _ultimoRemovido);
                    _saveData();
                  });
                }
            ),
            duration: Duration(
              seconds: 3
            ),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }


  Future<File> _getFile() async{
    final directory=await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }
  Future <File> _saveData() async{
  //transforma minha lista em um json
    String data=json.encode(_listTarefa);
    final file =await _getFile();
    return file.writeAsString(data);
  }
  Future<String> _lerData() async{
    try{
      final file= await _getFile();
      return file.readAsString();
    }
    catch(e){
      return null;
    }
  }
}



