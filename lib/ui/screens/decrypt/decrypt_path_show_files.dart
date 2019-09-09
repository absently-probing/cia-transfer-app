import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';

import 'dart:io';

import '../../../data/path.dart';
import '../../../data/constants.dart';
import '../../../data/strings.dart';

class DecryptShowFiles extends StatefulWidget {
  final List<String> list;
  final String prefix;
  DecryptShowFiles(this.list, this.prefix, {Key key}) : super(key: key);

  @override
  _DecryptShowFiles createState() => _DecryptShowFiles(list, prefix);
}

class _DecryptShowFiles extends State<DecryptShowFiles> {
  final List<String> files;
  final String prefix;

  Map<String, bool> _saved = {};

  _DecryptShowFiles(this.files, this.prefix) {
    for (String file in files) {
      _saved[file] = false;
    }
  }

  void _callProgramForFile(String file) {
    OpenFile.open(file);
  }

  // use new BuildContext to call Scaffold.of(_context), you cannot use
  // Scaffold.of(context) if Scaffold has the same context
  void _saveFile(BuildContext _context, String file, int index) {
    _saved[file] = true;
    var tmpFile = File(file);
    var filename = p.basename(file);

    tmpFile.copy(Path.getExternalDir() + '/' + filename);

    final snackBar = SnackBar(
      duration: Duration(milliseconds: 100),
      content:
          Text('saved $filename', style: Theme.of(_context).textTheme.title),
      backgroundColor: Theme.of(_context).colorScheme.primary,
    );

    // Find the Scaffold in the widget tree and use
    // it to show a SnackBar.
    Scaffold.of(_context).showSnackBar(snackBar);
    //_scaffoldKey.currentState.showSnackBar(snackBar);
    setState(() {
      var item = files[index];
      files.removeAt(index);
      files.add(item);
    });
  }

  void _finishButton(BuildContext context) {
    try {
      Directory(Path.getDocDir() + '/' + Consts.decryptExtractDir)
          .deleteSync(recursive: true);
    } catch (e) {}

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/root', (Route<dynamic> route) => false);
  }

  ListView _showFiles(BuildContext _context) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 10.0),
        itemCount: files.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final item = files[index];
          //final filename = p.basename(files[index]);
          final filename = files[index].replaceFirst(prefix, "");

          if (!_saved[files[index]]) {
            return Card(
              key: Key(item),
              child: ListTile(
                trailing: IconButton(
                  icon: Icon(
                    Icons.file_download,
                    color: Colors.blue,
                  ),
                  onPressed: () => _saveFile(_context, files[index], index),
                ),
                onTap: () => _callProgramForFile(files[index]),
                title:
                    Text(filename, style: Theme.of(_context).textTheme.body1),
              ),
            );
          }

          return Card(
            key: Key(item),
            child: ListTile(
              onTap: () => _callProgramForFile(files[index]),
              title: Text(filename, style: Theme.of(_context).textTheme.body1),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _finishButton(context);
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.decryptShowFilesLabel),
      ),
      body: Builder(
        builder: (BuildContext _context) {
          return Container(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  child: Text(
                    Strings.decryptShowFilesInfoText,
                    style: Theme.of(_context).textTheme.body1,
                  ),
                ),
                Expanded(
                  child: _showFiles(_context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
