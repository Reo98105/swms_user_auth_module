import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swms_user_auth_module/DAO/accountDAO.dart';
import 'package:swms_user_auth_module/DAO/analyticsDAO.dart';
import 'package:swms_user_auth_module/Model/account.dart';
import 'package:swms_user_auth_module/Model/analytics.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Analytics analytics = new Analytics();
  AccountDAO accountDAO = new AccountDAO();
  AnalyticsDAO analyticsDAO = new AnalyticsDAO();

  Future futureAcc;
  int id;
  var selectedAccount, selectedType;
  List usage, price;

  @override
  void initState() {
    super.initState();
    //call the future list*
    getUserid();
    _getUserid();
    getAcc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Analytics"),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  child: FutureBuilder<List<Account>>(
                    future: getAcc(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done ||
                          snapshot.hasData) {
                        return new StatefulBuilder(
                            builder: (context, _setState) => DropdownButton(
                                  hint: Text(
                                      selectedAccount ?? '-Select account-'),
                                  icon: Icon(Icons.arrow_drop_down_outlined),
                                  elevation: 16,
                                  underline: Container(
                                      height: 2, color: Colors.lightBlueAccent),
                                  items: snapshot.data
                                      .map<DropdownMenuItem>((value) {
                                    return DropdownMenuItem(
                                      value: value.accNumber,
                                      child: Text('${value.accNickname}'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    _setState(() {
                                      selectedAccount = val;
                                    });
                                  },
                                  value: selectedAccount,
                                ));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    child: DropdownButton(
                      hint: Text(selectedType ?? '-Select type-'),
                      icon: Icon(Icons.arrow_drop_down_outlined),
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Colors.lightBlueAccent,
                      ),
                      items: ['Payment', 'Water Usage']
                          .map<DropdownMenuItem>((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedType = val;
                        });
                      },
                    ))
              ],
            ),
            Container(
                padding: EdgeInsets.fromLTRB(0, 0, 12.5, 0),
                child: _renderChart()),
          ],
        )));
  }

  //function to render charts
  _renderChart() {
    if (selectedAccount != null && selectedType == 'Water Usage') {
      return FutureBuilder(
        future: getUsage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return SfCartesianChart(
              title: ChartTitle(text: 'Past Water Usage'),
              primaryYAxis: NumericAxis(title: AxisTitle(text: 'Cubic Metre m\u{00b3}')),
              primaryXAxis: DateTimeAxis(
                title: AxisTitle(text: 'Months'),
                intervalType: DateTimeIntervalType.months,
                interval: 1,
              ),
              series: <ChartSeries>[
                //render line chart
                LineSeries<Analytics, DateTime>(
                  dataSource: snapshot.data,
                  xValueMapper: (analytics, _) => analytics.dateTime,
                  yValueMapper: (analytics, _) => analytics.waterUsage,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } else if (selectedAccount != null && selectedType == 'Payment') {
      return FutureBuilder(
        future: getPayAmount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return SfCartesianChart(
              title: ChartTitle(text: 'Past Paid Amount'),
              primaryYAxis: NumericAxis(title: AxisTitle(text: 'RM')),
              primaryXAxis: DateTimeAxis(
                title: AxisTitle(text: 'Months'),
                intervalType: DateTimeIntervalType.months,
                interval: 1,
              ),
              series: <ChartSeries>[
                //render line chart
                LineSeries<Analytics, DateTime>(
                  dataSource: snapshot.data,
                  xValueMapper: (analytics, _) => analytics.dateTime,
                  yValueMapper: (analytics, _) => analytics.price,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return Center(child: Container(child: Text('No data to display')));
    }
  }

  //get userid
  Future<int> getUserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userid = prefs.getInt('id');
    return userid;
  }

  //get userid from sharepreferences
  int _getUserid() {
    getUserid().then((value) => setState(() {
          id = value;
        }));
    return id;
  }

  //return accounts list
  Future<List<Account>> getAcc() async {
    List account = await accountDAO.getAccList(_getUserid());
    return account;
  }

  //get water usage history
  Future<List> getUsage() async {
    List waterUsage = await analyticsDAO.getWaterUsage(selectedAccount);
    return waterUsage;
  }

  //get pay amount history
  Future<List> getPayAmount() async {
    List payAmount = await analyticsDAO.getPayAmount(selectedAccount);
    return payAmount;
  }
}
