import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/main_menu/task_download_item.dart';
import 'package:workcake/models/models.dart';

class TaskDownload extends StatefulWidget{
  final showDownload;

  TaskDownload({
    Key? key,
    this.showDownload,
  }): super(key: key);
  @override
  _TaskDownload createState() => _TaskDownload();
}

class _TaskDownload extends State<TaskDownload>{

  @override
  Widget build(BuildContext context) {
    List tasks = Provider.of<Work>(context, listen: true).taskDownload;

    return Container(
      // height: MediaQuery.of(context).size.height - 200,
      child: SingleChildScrollView(
        child: Column(
          children: tasks.map((e) {
            return TaskDownloadItem(att: e, showDownload: widget.showDownload == null ? false : widget.showDownload);
          }).toList(),
        ),
      )
    );
  }
}