import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:instagram_basic_display_api_flutter/constants.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:simple_auth_flutter/simple_auth_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IG Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _errorMsg;
  Map _userData;

  final simpleAuth.InstagramApi _igApi = simpleAuth.InstagramApi(
    "instagram",
    Constants.igClientId,
    Constants.igClientSecret,
    Constants.igRedirectURI,
    scopes: [
      'user_profile', // For getting username, account type, etc.
      'user_media', // For accessing media count & data like posts, videos etc.
    ],
  );

  @override
  void initState() {
    super.initState();
    SimpleAuthFlutter.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram Basic Display API Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: _userData != null,
              child: Text(
                _userData.keys.fold(
                    '', (kvText, key) => kvText + "$key: ${_userData[key]} \n"),
                textAlign: TextAlign.center,
              ),
              replacement:
                  Text("Click the button below to get Instagram Login."),
            ),
            Visibility(
              visible: _errorMsg != null,
              child: Text("Error occured: $_errorMsg"),
            ),
            FlatButton.icon(
              icon: Icon(Icons.input),
              label: Text("Get Profile Data", ),
              onPressed: _loginAndGetData,
              color: Colors.pink.shade400,
            ),
          ],
        ),
      ),
    );
  }

  _loginAndGetData() {
    _igApi.authenticate().then(
      (simpleAuth.Account _user) async {
        simpleAuth.OAuthAccount user = _user;

        var igUserResponse =
            await Dio(BaseOptions(baseUrl: 'https://graph.instagram.com')).get(
          '/me',
          queryParameters: {
            // Get the fields you need.
            // https://developers.facebook.com/docs/instagram-basic-display-api/reference/user
            "fields": "username,id,account_type,media_count",
            "access_token": user.token,
          },
        );

        setState(() {
          _userData = igUserResponse.data;
          _errorMsg = null;
        });
      },
    ).catchError(
      (Object e) {
        setState(() => _errorMsg = e.toString());
      },
    );
  }
}
