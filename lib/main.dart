import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wifi/wifi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {

  final UserRepo _userRepo = UserRepo();

  @override
  State<StatefulWidget> createState() => UserState();
}

class UserState extends State<UserPage> {
  UserModel _userModel;

  @override
  void initState() {
    _userModel = UserModel(widget._userRepo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: _userModel,
      child: Column(
        children: <Widget>[
          Text("immutable text"),
          ScopedModelDescendant<UserModel>(
            child: Text("mutable text ${_userModel._number}"),
            builder: (context, widget, _userModel) {
              return Column(
                children: <Widget>[
                  Text("new mutable text ${_userModel._number}"),
                  Text("user data: ${_userModel._userData}"),
                  Text("ssid: ${_userModel._ssid}",
                      style: Theme.of(context).textTheme.body1.copyWith(
                          color: Colors.amber,
                          fontSize: 13
                      )
                  )
                ],
              );
            },
          ),
          Card(
            child: InkWell(
              onTap: () { _userModel.getUserData(); },
              child: Text("presss me"),
            ),
          )
        ],
      ),

    );
  }
}

class UserRepo {
  _getUserData(int number) {
    return "user_data $number";
  }

  _getSsid() async {
    String ssid = await Wifi.ssid;
    print(ssid);
    return ssid;
  }
}

class UserModel extends Model {
  final UserRepo _userRepo;

  String _ssid = "none";
  UserModel(this._userRepo);
  int _number = 0;
  String _userData = "";

  getUserData() async {
    List<WifiResult> list = await Wifi.list('key');
    list.forEach((f) => {
      print(f.level)
    });
//    _ssid = await getSsid();
    _number++;
    print("$_number");
    _userData = _userRepo._getUserData(_number);
    notifyListeners();
  }

  getSsid() async => await _userRepo._getSsid();
}