import 'package:flutter/material.dart';
import 'package:workcake/common/cached_image.dart';

class ListAssignees extends StatefulWidget {
  const ListAssignees({
    Key? key,
    required this.assignees,
    required this.isDark,
  }) : super(key: key);

  final List assignees;
  final bool isDark;

  @override
  _ListAssigneesState createState() => _ListAssigneesState();
}

class _ListAssigneesState extends State<ListAssignees> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          widget.assignees.length == 0 ? Container() :
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(1),
            width: 20,
            height: 20,
            child: CachedImage(
              (widget.assignees[0])["avatar_url"],
              width: 20,
              height: 20,
              isAvatar: true,
              radius: 50,
              name: (widget.assignees[0])["full_name"]
            )
          ),
          widget.assignees.length <= 1 ? Container() : 
          Positioned(
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(1),
              width: 20,
              height: 20,
              child: CachedImage(
                (widget.assignees[1])["avatar_url"],
                width: 20,
                height: 20,
                isAvatar: true,
                radius: 50,
                name: (widget.assignees[1])["full_name"]
              )
            ),
          ),
          widget.assignees.length <= 2 ? Container() : 
          Positioned(
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(1),
              width: 20,
              height: 20,
              child: CachedImage(
                (widget.assignees[2])["avatar_url"],
                width: 20,
                height: 20,
                isAvatar: true,
                radius: 50,
                name: (widget.assignees[2])["full_name"]
              )
            ),
          ),
          widget.assignees.length <= 3 ? Container() : 
          Positioned(
            left: 30,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(1),
              width: 20,
              height: 20,
              child: CachedImage(
                (widget.assignees[3])["avatar_url"],
                width: 20,
                height: 20,
                isAvatar: true,
                radius: 50,
                name: (widget.assignees[3])["full_name"]
              )
            ),
          ),
          widget.assignees.length <= 4 ? Container() : 
          Positioned(
            left: 40,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(1),
              width: 20,
              height: 20,
              child: CachedImage(
                (widget.assignees[4])["avatar_url"],
                width: 20,
                height: 20,
                isAvatar: true,
                radius: 50,
                name: (widget.assignees[4])["full_name"]
              )
            ),
          ),
          widget.assignees.length <= 5 ? Container() :
          Positioned(
            left: 50,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(1),
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDark ? Color(0xff52606D) : Color(0xffE4E7EB),
              ),
                // padding: EdgeInsets.symmetric(vertical: 7, horizontal: widget.assignees.length > 9 ? 2 : 6),
                width: 20,
                height: 20,
                child: Center(child: Text("+${widget.assignees.length - 5}", style: TextStyle(color: widget.isDark ? Colors.white: Color.fromRGBO(0, 0, 0, 0.65), fontSize: 11, fontWeight: FontWeight.w400)))
              ),
            ),
          ),
        ]
      ),
    );
  }
}
