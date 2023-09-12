import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/components/attachment_card_desktop.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

class OrderAttachment extends StatefulWidget {
  final att;
  final id;
  OrderAttachment({Key? key, this.att, this.id}) : super(key: key);

  @override
  State<OrderAttachment> createState() => _OrderAttachmentState();
}

class _OrderAttachmentState extends State<OrderAttachment> {

  handleOrderToPos(key, orderId, shopId, messageId) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    String url = "${Utils.apiUrl}business/handle_order_to_pos?token=$token";
    try {
      var response  =  await Dio().post(url, data: {
        "messageId": messageId,
        "id": orderId,
        "shopId": shopId,
        "leveraPay": {"status": key}
      });
      var resData = response.data;

      if(resData["success"] == false) {}
    } catch (e) {
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }
  _createDirectMessageToSupportLeveraPay(String token) async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final data = {
      "users": ["0402cd81-7a28-48ce-bdf3-76335f7a138f"],
      "name": "Levera Pay Support"
    };
    await Provider.of<DirectMessage>(context, listen: false).createDirectMessage(token, data, context, userId);
  }

  @override
  Widget build(BuildContext context) {
    final att = widget.att;
    final id = widget.id;
    final token  =  Provider.of<Auth>(context, listen: false).token;

    return Container(
      width: 400,
      margin: EdgeInsets.only(top: 10),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Color(0xffE4E7EB),
            width: 1,
          ),
        ),
        color: Color(0xffF5F7FA),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                'ORDER CONFIRMATION (ID: ${att['data']['order_id']})',
                style: TextStyle(
                  fontWeight: FontWeight.w600
                ),
              ),
              // subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${att['data']['elements'].length} items/${NumberFormat.simpleCurrency(locale: 'vi').format(att["data"]["summary"]["total_cost"])}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ordered on: ${DateFormatter().renderTime(DateTime.parse(att["data"]["timestamp"]), type: 'kk:mm dd/MM')}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Phone number: ${att["data"]["phone_number"]}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Paid with: ${att["data"]["payment_method"]}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ship to: ${att["data"]["address"]}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {_showAlert(context, att["data"]);},
                    child: Text(
                      'Chi tiết đơn hàng',
                      style: TextStyle(fontSize: 14, color: Colors.blueAccent, decoration: TextDecoration.underline),
                    ),
                  ),
                  SizedBox(height: att['data']['levera_pay']['status'] == 'pending' ? 5 : 0),
                  att['data']['levera_pay']['status'] == 'pending' ? Divider() : SizedBox(),
                  SizedBox(height: att['data']['levera_pay']['status'] == 'pending' ? 5 : 0),
                  att['data']['levera_pay']['status'] == 'pending'
                      ? Row(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text('Áp dụng'),
                            ),
                            style: TextButton.styleFrom(
                              // primary: Colors.white,
                              backgroundColor: Color(0xff2A5298),
                              textStyle: TextStyle(
                                  color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              handleOrderToPos("apply", att["data"]["order_id"], att["data"]["shop_id"], id);
                            },
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text('Bỏ qua'),
                            ),
                            style: TextButton.styleFrom(
                              // primary: Colors.white,
                              backgroundColor: Colors.red[500],
                              textStyle: TextStyle(
                                  color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              handleOrderToPos("ignore", att["data"]["order_id"], att["data"]["shop_id"], widget.id);
                            },
                          ),
                        ],
                      ) : Container(),
                  SizedBox(height: 5),
                  Divider(),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      TextButton(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(CupertinoIcons.ellipses_bubble, size: 16, color: Color(0xff616E7C)),
                              SizedBox(width: 8),
                              Text('Liên hệ hỗ trợ', style: TextStyle(color: Color(0xff616E7C), fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                              side: BorderSide(color: Color(0xff7B8794))
                            )
                          )
                        ),
                        onPressed: () {_createDirectMessageToSupportLeveraPay(token);},
                      ),
                      SizedBox(width: 5),
                      TextButton(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(CupertinoIcons.star, size: 16, color: Color(0xff616E7C)),
                              SizedBox(width: 5),
                              Text('Tìm hiểu dịch vụ', style: TextStyle(color: Color(0xff616E7C), fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                              side: BorderSide(color: Color(0xff7B8794))
                            )
                          )
                        ),
                        onPressed: () {},
                      ),
                    ]
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlert(BuildContext context, order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32)
        ),
        content: ShowInfomationOrder(
          order: order
        )
      )
    );
  }
}