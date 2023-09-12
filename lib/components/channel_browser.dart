import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/route_animation.dart';
import 'package:workcake/components/create_channels.dart';
import 'package:workcake/models/models.dart';

class ChannelBrowser extends StatefulWidget {
  @override
  _ChannelBrowserState createState() => _ChannelBrowserState();
}

class _ChannelBrowserState extends State<ChannelBrowser> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Channels>(context, listen: false).data;

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            child: Container(
              color: Colors.grey[200],
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(1.0)),
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          'Channels',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(createRoute(CreateChannel()));
            },
            child: Center(
              child: Text(
                'Create',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white
                ),
              ),
            )
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {},
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  // border: OutlineInputBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(25.0)))
                ),
              ),
            ),
            Expanded(
              child: data.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          children: [
                            Icon(
                                data[index]['is_private']
                                    ? Icons.lock
                                    : CupertinoIcons.number,
                                size: 16.0,
                                color: Colors.black87),
                            SizedBox(width: 5.0),
                            Text('${data[index]['name']}'),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                  child: 	ElevatedButton(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Create New Channel',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(createRoute(CreateChannel()));
                    },
                  ))),
          ],
        ),
      ),
    );
  }
}
