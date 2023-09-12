import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/models/models.dart';

import '../../../generated/l10n.dart';

class SelectAssignee extends StatefulWidget {
  const SelectAssignee({
    Key? key,
    this.assignees,
    this.onAddOrRemoveAssignee
  }) : super(key: key);

  final assignees;
  final onAddOrRemoveAssignee;

  @override
  State<SelectAssignee> createState() => _SelectAssigneeState();
}

class _SelectAssigneeState extends State<SelectAssignee> {
  @override
  Widget build(BuildContext context) {
    List channelMembers = Provider.of<Channels>(context, listen: true).channelMember;
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      height: MediaQuery.of(context).size.height - 48,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(PhosphorIcons.arrowLeft, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), size: 20)
                ),
                Text(S.current.members, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D))),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(S.current.done, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF), fontWeight: FontWeight.w400))
                )
              ]
            )
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoTextField(
              placeholder: S.current.search,
              style: TextStyle(fontSize: 14, color: Palette.defaultTextDark),
              padding: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB),
                borderRadius: BorderRadius.circular(16)
              ),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(PhosphorIcons.magnifyingGlass, size: 18)
              )
            )
          ),
          SizedBox(height: 12),
          Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), height: 1, thickness: 1),
          Column(
            children: channelMembers.map<Widget>((e) {
              return InkWell(
                onTap: () {
                  this.setState(() {
                    widget.onAddOrRemoveAssignee(e);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)
                      )
                    )
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CachedAvatar(e["avatar_url"], name: e["full_name"], width: 24, height: 24),
                          SizedBox(width: 12),
                          Text(e["full_name"] ?? "", style: TextStyle(fontSize: 14))
                        ]
                      ),
                      widget.assignees.contains(e["id"]) ? Icon(PhosphorIcons.checkCircle, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF), size: 18) : SizedBox()
                    ]
                  )
                )
              );
            }).toList()
          )
        ]
      )
    );
  }
}