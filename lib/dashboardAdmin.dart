import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swms_user_auth_module/analyticsAdmin.dart';
import 'package:swms_user_auth_module/premise.dart';
import 'package:swms_user_auth_module/profileAdmin.dart';
import 'package:swms_user_auth_module/showAlert.dart';

class DashboardAdmin extends StatefulWidget {
  @override
  _DashboardAdminState createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  ShowAlert showAlert = new ShowAlert();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: GestureDetector(
                onTap: () {
                  _handleLogout(context);
                },
                child: Icon(
                  Icons.exit_to_app_rounded,
                  size: 20.0,
                ),
              ))
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: FutureBuilder(
                      future: getCre(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          );
                        } else {
                          return Text('');
                        }
                      },
                    ),
                  ),
                  Container(
                    alignment: FractionalOffset.topRight,
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 25.0),
                    child: Icon(
                      Icons.face_sharp,
                      size: 100.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/profileAdmin');
                },
                icon: Icon(Icons.person),
                label: Text('Profile'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[400],
                  elevation: 5.0,
                  textStyle: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/premise');
                },
                icon: Icon(Icons.home_filled),
                label: Text('Premise'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[400],
                  elevation: 5.0,
                  textStyle: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/analyticsAdmin');
                },
                icon: Icon(Icons.analytics_outlined),
                label: Text('Analytics'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[400],
                  elevation: 5.0,
                  textStyle: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCre() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    return username;
  }

  //logout confirmation
  void _handleLogout(BuildContext context) {
    //show confirmation dialog
    AlertDialog alert = AlertDialog(
      title: Text('Logout'),
      //actions of the dialog box
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _logout(context);
          },
          child: Text('Confirm'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text('Cancel'),
        ),
      ],
      backgroundColor: Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      content: new Row(
        children: [
          Icon(
            Icons.exit_to_app,
            color: Colors.grey[600],
            size: 40.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text('Logout from the app?'),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //handle logout logic
  void _logout(BuildContext context) async {
    //clear sharedpreferences before logging out
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    //check if sharedpreferences cleared
    String username = prefs.getString('username');
    print(username);
    if (username == null) {
      //show loading dialog
      showAlert.showLoadingDialog(context);
      //back to login screen
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      //debug purpose
      print('something wrong');
    }
  }
}
