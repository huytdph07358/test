import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/models/models.dart';

class CreateWorkspaceScreen extends StatelessWidget {
  final index;
  
  CreateWorkspaceScreen({this.index});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateWorkspace(
        index: index
      ),
    );
  }
}

class CreateWorkspace extends StatefulWidget {
  final index;
  const CreateWorkspace({
    Key? key,
    @required this.index
  }) : super(key: key);

  @override
  _CreateWorkspaceState createState() => _CreateWorkspaceState();
}

class _CreateWorkspaceState extends State<CreateWorkspace> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _workspaceName;
  final TextEditingController _workspaceNameController = TextEditingController();

  Future<void> _submit(token) async {
    // if (!_formkey.currentState.validate()) {
    //   return;
    // }

    // _formkey.currentState.save();

    try {
      await Provider.of<Workspaces>(context, listen: false).createWorkspace(context, token, _workspaceName, "");
      // Navigator.pushNamed(context, 'dashboard-screen');
    } on HttpException catch (error) {
      print("this is http exception $error");
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _workspaceNameController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context).token;

    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.close), onPressed: () {Navigator.pop(context);},)),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'What is the name of your company or team?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 40.0),
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueGrey, width: 2.0),
                      ),
                      labelText: 'Ex. Acme or Acme Marketing',
                      labelStyle: TextStyle(
                        color: Colors.black26
                      )
                    ),
                    controller: _workspaceNameController,
                    onChanged: (value) {
                      _workspaceName = value;
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Create workspace',
                        style: TextStyle(
                          fontSize: 16.0
                        ),
                      ),
                    ),
                    onPressed: () => _submit(token),
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}