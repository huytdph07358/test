import 'package:flutter/material.dart';
import 'package:workcake/common/route_animation.dart';
import 'package:workcake/components/workspace/create_workspace.dart';

class ActionsWorkspace extends StatelessWidget {
  final actionsWorkspace = ['Sign in to another workspace', 'Join another workspace', 'Create a new workspace'];
  final actionsIcon = [Icons.apps, Icons.person_add, Icons.add];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add workspaces'),
      ),
      body: ListView.builder(
        itemCount: actionsWorkspace.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(actionsIcon[index]),
              title: Text(actionsWorkspace[index]),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(createRoute(CreateWorkspaceScreen(index: index)));
              },
            )
          );
        },
      ),
    );
  }
}