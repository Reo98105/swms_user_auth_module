import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Image.asset('assets/swmsword.png'),
          ),
          Container(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
          ),
          Container(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.login),
                    label: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.cyan[400],
                      elevation: 5.0,
                      textStyle: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.app_registration),
                    label: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.cyan[400],
                      elevation: 5.0,
                      textStyle: TextStyle(fontSize: 16.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}