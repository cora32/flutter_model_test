import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wifi/wifi.dart';

import 'Experiment2.dart';

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
          Center(
              child: Text(
                "immutable text",
                textAlign: TextAlign.center,
              )),
          ScopedModelDescendant<UserModel>(
            child: Text("mutable text ${_userModel._number}"),
            builder: (context, widget, _userModel) {
              return Column(
                children: <Widget>[
                  Text("new mutable text ${_userModel._number}"),
                  Text("user data: ${_userModel._userData}"),
                  Text("ssid: ${_userModel._ssid}",
                      style: Theme
                          .of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.amber, fontSize: 13)),
                  Text("type: ${_userModel._connectivityType}",
                      style: Theme
                          .of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.amber, fontSize: 16)),
                  Text("wifi list: ${_userModel._wifiList}",
                      style: Theme
                          .of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.amber, fontSize: 19))
                ],
              );
            },
          ),
          Card(
            child: InkWell(
              onTap: () {
                _userModel.getUserData();
              },
              child: Text("presss me"),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () {
                _userModel.checkConnection();
              },
              child: Text("Check connection"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
                child: InkWell(
                  child: Text("Next"),
                  onTap: () =>
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Example2()),
                    )
                  },
                )),
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

  Future<String> _getSsid() async {
    String ssid = await Wifi.ssid;
    print(ssid);
    return ssid;
  }

  Future<String> _checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return 'mobile';
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return "wifi";
    } else
      return "unknown";
  }

  _getWifiList() async => await Wifi.list('DataTech_2.4G');
}

class UserModel extends Model {
  final UserRepo _userRepo;

  String _ssid = "none";
  String _wifiList = "empty";

  UserModel(this._userRepo);

  int _number = 0;
  String _userData = "";
  String _connectivityType = "none";

  getUserData() async {
    _ssid = await getSsid();
    _connectivityType = await checkConnection();
    List<WifiResult> list = await _userRepo._getWifiList();
    _wifiList =
        list.map((result) => {"\n${result.ssid} ${result.level}\n"}).toString();

    _number++;
    print("$_number");
    _userData = _userRepo._getUserData(_number);
    notifyListeners();
  }

  Future<String> getSsid() => _userRepo._getSsid();

  Future<String> checkConnection() => _userRepo._checkConnection();
}
