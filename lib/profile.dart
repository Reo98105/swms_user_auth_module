import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swms_user_auth_module/DAO/userDAO.dart';
import 'package:swms_user_auth_module/Model/user.dart';
import 'package:swms_user_auth_module/Model/account.dart';
import 'package:swms_user_auth_module/deleteProfile.dart';
import 'package:swms_user_auth_module/showAlert.dart';
import 'package:swms_user_auth_module/updatePassword.dart';
import 'package:swms_user_auth_module/DAO/accountDAO.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AccountDAO accountDAO = new AccountDAO();
  UserDAO userDAO = new UserDAO();
  ShowAlert showAlert = new ShowAlert();
  User user;

  String username = '';
  int id;
  Account account, account2, acc;

  //option and value list
  List optionList = <String>['Update password', 'Delete account'];
  List optValueList = [UpdatePassword(), DeleteAccount()];

  final _formKey = GlobalKey<FormState>();

  TextEditingController newName, password;

  SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    getUserid();
    _getUserid();
    getAcc();

    if (acc == null) account = new Account.def();
    newName = TextEditingController();
    newName.text = account.accNickname;
    password = TextEditingController();
    password.text = account.password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Manage Account'),
                            content: showAccountOptions(),
                          );
                        });
                  },
                  child: Icon(
                    Icons.error_outline_outlined,
                    size: 25.0,
                  )))
        ],
      ),
      body: SafeArea(
          child: Column(children: <Widget>[
        //profile icon
        Container(
          margin: EdgeInsets.fromLTRB(5.0, 50.0, 5.0, 0.0),
          alignment: FractionalOffset.center,
          child: Icon(
            Icons.face_sharp,
            size: 100.0,
          ),
        ),
        //display username
        Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            alignment: FractionalOffset.center,
            child: FutureBuilder(
                future: Future.wait(
                    [getUsername(), userDAO.getEmail(_getUsername())]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(children: <Widget>[
                      Container(
                          child: Text(
                        snapshot.data[0],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      )),
                      Container(
                          padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                          child: Text(
                            snapshot.data[1],
                            style: TextStyle(fontSize: 16.0),
                          ))
                    ]);
                  } else {
                    return Text('Loading..');
                  }
                })),
        //act as seperator
        Divider(
          color: Colors.grey[400],
          thickness: 2,
          height: 0.0,
        ),
        Container(
          decoration: BoxDecoration(color: Colors.grey[350]),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
            left: 10.0,
          ),
          child: Text(
            'Managed Account',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        //display managed accounts
        Container(
          child: FutureBuilder<List>(
              future: getAcc(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done ||
                    snapshot.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      account = snapshot.data[index];
                      //item data here
                      return Container(
                          child: Card(
                              child: Column(children: <Widget>[
                        ListTile(
                            leading: Container(
                                padding: EdgeInsets.only(
                                  top: 5.0,
                                  left: 5.0,
                                ),
                                child: Icon(
                                  Icons.home,
                                  size: 30.0,
                                )),
                            title: Text('${account.accNickname}'),
                            subtitle: Text('${account.accNumber}'),
                            onTap: () {
                              setState(() {
                                account2 = snapshot.data[index];
                              });
                              showAccDetail(context, account.accNickname);
                            })
                      ])));
                    },
                  );
                } else if (snapshot.hasData == null) {
                  return Center(child: Text('No account has been added.'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        )
      ])),
      //add more manage account
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          Navigator.of(context).pushNamed('/addAcc');
        },
        child: Icon(
          Icons.add,
          size: 30.0,
        ),
      ),
    );
  }

  //show account's detail dialog
  showAccDetail(BuildContext context, var accNickname) {
    AlertDialog alert = AlertDialog(
      actions: <Widget>[
        TextButton(
          onPressed: () {
            newName.text = accNickname;
            //update dialog
            showUpdateDialog(context, account2.accNumber);
          },
          child: Text('Update'),
        ),
        TextButton(
          child: Text(
            'Remove',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            showRemoveDialog(context);
          },
        )
      ],
      content: _accDetail(account2.accNumber),
    );
    showDialog(context: context, builder: (context) => alert);
  }

  //show manage account options
  showAccountOptions() {
    return Container(
      width: 200.0,
      height: 125.0,
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: optionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${optionList[index]}'),
            onTap: () {
              //close manage acc option before navigate to other page
              Navigator.of(context).pop(true);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => optValueList[index]));
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }

  //show account's detail, update or delete
  _accDetail(var accNumber) {
    return Container(
      width: 200.0,
      height: 140.0,
      child: FutureBuilder(
        future: getAccDetail(accNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        Account accDetail = snapshot.data[index];
                        //item data here
                        return Container(
                            child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.only(top: 40.0, right: 8.0),
                            child: Icon(
                              Icons.home,
                              size: 45.0,
                            ),
                          ),
                          title: Text(
                            '${accDetail.accNickname}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                          subtitle: Text(
                            '${accDetail.accNumber}' +
                                '\n\n${accDetail.address}, ' +
                                '${accDetail.postCode}, ' +
                                '${accDetail.district}, ' +
                                '${accDetail.city}',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ));
                      })
                ]);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  //show remove dialog
  showRemoveDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove confirmation'),
          content: Text('Remove this account from your managing list?'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  //trigger deletion function
                  _handleDelete(account2.accNumber);
                },
                child: Text('Confirm')),
            TextButton(
                onPressed: () {
                  //pop dialog
                  Navigator.of(context).pop(true);
                },
                child: Text('Cancel'))
          ],
        );
      },
    );
  }

  //show update dialog
  showUpdateDialog(BuildContext context, String accNum) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update account nickname'),
          content: Container(
              height: 165.0,
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: TextFormField(
                            controller: newName,
                            autofocus: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'required*';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'New account nickname',
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            child: TextFormField(
                                controller: password,
                                autofocus: true,
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'required*';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: Icon(Icons.lock),
                                ))),
                      ]))),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  //trigger update function
                  _handleUpdate(context, accNum);
                },
                child: Text('Confirm')),
            TextButton(
                onPressed: () {
                  //pop dialog
                  Navigator.of(context).pop(true);
                },
                child: Text('Cancel'))
          ],
        );
      },
    );
  }

  //handle update event
  Future _handleUpdate(BuildContext context, String accNum) async {
    //check form if there is empty
    if (_formKey.currentState.validate()) {
      showAlert.showLoadingDialog(context);
      String newNickname = newName.text;
      String pass = password.text;
      String userid = _getUserid().toString();
      String accNumber = accNum;

      try {
        showAlert.showLoadingDialog(context);
        account = new Account.update(userid, newNickname, pass, accNumber);
        int result = await accountDAO.updateAcc(account);
        if (result == 1) {
          Navigator.of(_formKey.currentContext, rootNavigator: true).pop();
          showAlert.showUpdateNameSuccess(context);
        } else {
          Navigator.of(_formKey.currentContext, rootNavigator: true).pop();
          showAlert.showGenericFailed(context);
        }
      } catch (e, stacktrace) {
        print(e);
        print(stacktrace);
      }
    }
    return;
  }

  //handle deletion
  Future _handleDelete(var accNumber) async {
    try {
      showAlert.showLoadingDialog(context);
      int result = await accountDAO.removeAcc(accNumber);
      if (result == 1) {
        //pop dialog
        Navigator.of(context).pop(true);
        showAlert.showRemoveSuccess(context);
      } else {
        //pop dialog
        Navigator.of(context).pop(true);
        showAlert.showGenericFailed(context);
      }
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
  }

  //get userid
  Future<int> getUserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userid = prefs.getInt('id');
    return userid;
  }

  //get username
  Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    return username;
  }

  //get username from sharepreferences
  String _getUsername() {
    getUsername().then((value) => setState(() {
          username = value;
        }));
    return username;
  }

  //get userid from sharepreferences
  int _getUserid() {
    getUserid().then((value) => setState(() {
          id = value;
        }));
    return id;
  }

  Future<List> getAcc() async {
    List account = await accountDAO.getAcc(_getUserid());
    return account;
  }

  //get acc details
  Future getAccDetail(var accNumber) async {
    List accountDetail = await accountDAO.getAccDetail(accNumber);
    return accountDetail;
  }
}
