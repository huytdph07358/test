import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class Pagination extends StatefulWidget {
  Pagination({Key? key, this.channelId, this.issueClosedTab, this.filters, this.sortBy, this.text}) : super(key: key);

  final channelId;
  final issueClosedTab;
  final filters;
  final sortBy;
  final text;
  
  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  var currentPage;

  @override
  void initState() {    
    super.initState();
    currentPage = 1;
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.channelId != widget.channelId || oldWidget.issueClosedTab != widget.issueClosedTab) {
      currentPage = 1;
    }
  }

  _previous(isClosedTab) {
    setState(() {
      currentPage -= 1;
    });
    goToPage(currentPage, isClosedTab);
  }

  _next(isClosedTab) {
    setState(() {
      currentPage += 1;
    });
    goToPage(currentPage, isClosedTab);
  }

  goToPage(int page, isClosedTab) async{
    final token = Provider.of<Auth>(context, listen: false).token;
    final workspaceId = Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"];
    final channelId = Provider.of<Channels>(context, listen: false).currentChannel["id"];
    final issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;

    await Provider.of<Channels>(context, listen: false).getListIssue(token, workspaceId, channelId, page, issueClosedTab, widget.filters, widget.sortBy, widget.text);
  }
  
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final issueClosedTab = Provider.of<Work>(context, listen: true).issueClosedTab;
    var totalPage = currentChannel["totalPage"];

    return totalPage == null || totalPage <= 1 ? Container() : Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: currentPage <= 1 ? null : () { 
              _previous(issueClosedTab);
            },
            child: Row(
              children: [
                Icon(CupertinoIcons.chevron_back, size: 22,color: currentPage > 1 ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : (isDark ? Color(0xffD9D9D9) : Colors.black45)),
                SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text("Previous", style: TextStyle(color: currentPage > 1 ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : (isDark ? Color(0xffD9D9D9) : Colors.black45), fontSize: 14, fontWeight: FontWeight.w400)),
                ),
              ],
            )
          ),
          SizedBox(width: 16),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: currentPage == 1 ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
              child: Text("1", style: TextStyle(color: !isDark && currentPage == 1 ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65) , fontSize: 14, fontWeight: FontWeight.w400))
            ),
            onTap: () {
              setState(() {
                currentPage = 1;
              });
              goToPage(1, issueClosedTab);
            },
          ),
          SizedBox(width: 8),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: currentPage == 2 ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
              child: Text("2", style: TextStyle(color: !isDark && currentPage == 2 ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w400))
            ),
            onTap: () {
              setState(() {
                currentPage = 2;
              });
              goToPage(2, issueClosedTab);
            },
          ),
          SizedBox(width: totalPage > 2 ? 8: 0),
          totalPage >= 10 ? Row(
            children: [
              SizedBox(width: 8),
              Text("..."),
              SizedBox(width: 16,),
            ],
          ) : Container(),
          totalPage <= 6 ? Container() : Row(
            children: [
              InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: currentPage <= 2 || currentPage >= totalPage - 1 || currentPage == totalPage -2 || currentPage == totalPage -3 ? Colors.white : (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)),
                  ),
                  padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
                  child: Text(currentPage <= 2 || currentPage >= totalPage - 1 || totalPage < 8 ?"${(totalPage / 2).round() - 1}" : (currentPage >= totalPage - 4) ? "${totalPage - 4}" : "$currentPage", style: TextStyle(color: (currentPage <= 2 || currentPage >= totalPage - 1 || currentPage == totalPage -2 || currentPage == totalPage -3) ? Color.fromRGBO(0, 0, 0, 0.65) : Colors.white, fontSize: 14, fontWeight: FontWeight.w400))
                ),
                onTap: () {
                  if(currentPage <= 2 || currentPage >= totalPage - 1 || totalPage < 8) {
                    setState(() {
                      currentPage = (totalPage / 2).round() - 1;
                    });
                    goToPage((totalPage / 2).round() - 1, issueClosedTab);
                  } else if(currentPage >= totalPage - 4) {
                    setState(() {
                      currentPage = totalPage - 4;
                    });
                    goToPage(totalPage - 3, issueClosedTab);
                  } else {
                    setState(() {
                      currentPage = currentPage;
                    });
                    goToPage(currentPage, issueClosedTab);
                  }
                },
              ),
              SizedBox(width: 8,),
            ],
          ),
          totalPage <= 4 ? Container() : InkWell(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: (totalPage >= 8 && currentPage == totalPage - 3) || (totalPage < 8 && currentPage == (totalPage / 2).round())? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
              child: Text(currentPage <= 2 || currentPage >= totalPage - 1 || totalPage < 8 ? "${(totalPage / 2).round()}" : (currentPage + 1 >= totalPage - 3) ? "${totalPage - 3}" : "${currentPage + 1}", style: TextStyle(color: !isDark && (totalPage >= 8 && currentPage == totalPage - 3) || (totalPage < 8 && currentPage == (totalPage / 2).round()) ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w400))
            ),
            onTap: () {
              if(currentPage <= 2 || currentPage >= totalPage - 1 || totalPage < 8) {
                setState(() {
                  currentPage = (totalPage / 2).round();
                });
                goToPage((totalPage / 2).round(), issueClosedTab);
              } else if(currentPage + 1 >= totalPage - 3) {
                setState(() {
                  currentPage = totalPage - 3;
                });
                goToPage(totalPage - 3, issueClosedTab);
              } else {
                setState(() {
                  currentPage = currentPage + 1;
                });
                goToPage(currentPage + 1, issueClosedTab);
              }
            },
          ),
          totalPage <= 5 ? Container() : Row(
            children: [
              SizedBox(width: 8,),
              InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: currentPage == totalPage - 2 ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
                  child: Text((currentPage <= 2 || currentPage >= totalPage - 1 ) ?"${(totalPage / 2).round() + 1}" : (currentPage + 2 >= totalPage - 2) ? "${totalPage - 2}" : "${currentPage +2}", style: TextStyle(color: !isDark && currentPage == totalPage - 2 ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w400))
                ),
                onTap: () {
                  if(currentPage <= 2 || currentPage >= totalPage - 1) {
                    setState(() {
                      currentPage = (totalPage / 2).round() + 1;
                    });
                    goToPage((totalPage / 2).round() + 1, issueClosedTab);
                  } else if(currentPage + 2 >= totalPage - 2) {
                    setState(() {
                      currentPage = totalPage - 2;
                    });
                    goToPage(totalPage - 2, issueClosedTab);
                  } else {
                    setState(() {
                      currentPage = currentPage + 2;
                    });
                    goToPage(currentPage + 2, issueClosedTab);
                  }
                },
              ),
            ],
          ),
          totalPage >=10 ? Row(
            children: [
              SizedBox(width: 16),
              Text("..."),
              SizedBox(width: 8,),
            ],
          ) : Container(),
          SizedBox(width: totalPage > 4 ? 8 : 0),
          totalPage >= 4 ?
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: currentPage == (totalPage - 1) ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
              child: Text("${totalPage -1}", style: TextStyle(color: !isDark && currentPage == totalPage -1 ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w400))
            ),
            onTap: () {
              setState(() {
                currentPage = totalPage -1;
              });
              goToPage(totalPage - 1, issueClosedTab);
            },
          ) : Container(),
          SizedBox(width: totalPage >= 4 ? 8 : 0),
          totalPage >= 3 ?
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: currentPage == totalPage ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical:6, horizontal: 10),
              child: Text("$totalPage", style: TextStyle(color: !isDark && currentPage == totalPage ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w400))
            ),
            onTap: () {
              setState(() {
                currentPage = totalPage;
              });
              goToPage(totalPage, issueClosedTab);
            },
          ) : Container(),
          SizedBox(width: 16,),
          InkWell(
            onTap: currentPage >= totalPage ? null : () {
              _next(issueClosedTab);
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Next", style: TextStyle(color: currentPage < totalPage ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : (isDark ? Color(0xffD9D9D9) : Colors.black45), fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                SizedBox(width: 8),
                Icon(CupertinoIcons.chevron_forward, size: 22, color: currentPage < totalPage ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : (isDark ? Color(0xffD9D9D9) : Colors.black45),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}