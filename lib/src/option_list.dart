part of flutter_mentions;

class OptionList extends StatelessWidget {
  OptionList({
    required this.data,
    required this.onTap,
    required this.suggestionListHeight,
    this.isDark,
    this.isMentionIssue = false,
  });

  final isDark;

  final List<dynamic> data;

  final Function(Map<String, dynamic>) onTap;

  final double suggestionListHeight;

  final bool isMentionIssue;

  @override
  Widget build(BuildContext context) {

    return data.isNotEmpty 
      ? Container(
        margin: EdgeInsets.only(bottom: 4),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
            color: isDark ? Color(0xff2f3136) : Color(0xFFf0f0f0),
            boxShadow:
            [
              BoxShadow(
                color: isDark  ? Color(0xFF262626).withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
        constraints: BoxConstraints(
          maxHeight: suggestionListHeight,
          minHeight: 0,
        ),
        child: ListView.builder(
          controller: ScrollController(),
          itemCount: data.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                onTap(data[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[500]!, width: 0.2),
                    top: BorderSide(color: Colors.grey[500]!, width: 0.2)
                  )
                ),
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    data[index]['photo'] == "" ? Icon(Icons.campaign, color: Colors.grey[600], size: 24) :
                    isMentionIssue ? Icon(
                      Icons.info_outline,
                      color: !data[index]["is_closed"] ? Colors.green : Colors.redAccent, size: 18
                    ) :CachedImage(
                      data[index]['photo'],
                      width: 24,
                      height: 24,
                      radius: 5,
                      isAvatar: true,
                      name: data[index]["full_name"]
                    ),
                    Container(width: 8),
                    Container(
                      width: isMentionIssue ? 346 : null,
                      child: isMentionIssue ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "#${data[index]['display']} ",
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[800],
                                fontWeight: FontWeight.w300
                              )
                            ),
                            TextSpan(
                              text: "${data[index]["channel_name"]} ",
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[800],
                                fontWeight: FontWeight.w500
                              )
                            ),
                            TextSpan(
                              text: "${data[index]['title']}",
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[800],
                                fontWeight: FontWeight.w300
                              ),
                            ),
                          ]
                        ),
                        overflow: TextOverflow.ellipsis
                      ) : Text(
                        "@" + data[index]['full_name'],
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[800],
                          fontWeight: FontWeight.w300
                        ),
                        overflow: TextOverflow.ellipsis
                      )
                    )
                  ],
                ),
              )
            );
          },
        ),
      )
    : Container();
  }

}