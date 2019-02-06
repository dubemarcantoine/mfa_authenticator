import 'package:authenticator/helpers/BiometricsHelper.dart';
import 'package:authenticator/pages/LoginError.dart';
import 'package:authenticator/pages/OtpList.dart';
import 'package:authenticator/pages/SecurityConfig.dart';
import 'package:authenticator/pages/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new Base());
  });
}

final appKey = new GlobalKey<_AppState>();

class Base extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}

class App extends StatefulWidget {
  App() : super(key: appKey);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  BiometricsHelper _biometricsHelper = BiometricsHelper();
  SharedPreferences _preferences;
  DateTime _lastPause;

  HomeScreenState _homeScreenState = HomeScreenState.SPLASHSCREEN;
  bool _authenticationResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tryAuthenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authenticator',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
        primarySwatch: Colors.blue,
        primaryColorDark: Colors.blue,
        toggleableActiveColor: Colors.blue,
      ),
      home: _getHomeScreen(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        setState(() {
          _homeScreenState = HomeScreenState.SPLASHSCREEN;
        });
        _lastPause = DateTime.now();
        break;
      case AppLifecycleState.suspending:
        break;
      case AppLifecycleState.resumed:
        if (_lastPause != null) {
          Duration timeDifference = DateTime.now().difference(_lastPause);
          _lastPause = null;
          if (timeDifference.inSeconds > 60) {
            tryAuthenticate();
          } else {
            setState(() {
              _setHomeScreenState();
            });
          }
        } else {
          setState(() {
            _setHomeScreenState();
          });
        }
        break;
    }
  }

  void tryAuthenticate() {
    _authenticate().then((res) {
      _authenticationResult = res;
      _setHomeScreenState();
    });
  }

  Widget _getHomeScreen() {
    switch (_homeScreenState) {
      case HomeScreenState.SPLASHSCREEN:
        return SplashScreen();
      case HomeScreenState.ERROR_LOGIN:
        return LoginError();
      case HomeScreenState.SUCCESS_LOGIN:
        return OtpList(title: 'Authenticator');
      default:
        return SplashScreen();
    }
  }

  void _setHomeScreenState() {
    setState(() {
      if (_authenticationResult) {
        _homeScreenState = HomeScreenState.SUCCESS_LOGIN;
      } else {
        _homeScreenState = HomeScreenState.ERROR_LOGIN;
      }
    });
  }

  Future<bool> _authenticate() async {
    _preferences = await SharedPreferences.getInstance();
    bool shouldAuthenticate =
        _preferences.getBool(SecurityConfig.IS_USING_BIOMETRICS_AUTH_KEY) ??
            false;
    if (!shouldAuthenticate) {
      return Future.value(true);
    } else {
      if (await _biometricsHelper.hasBiometrics()) {
        return await _biometricsHelper.localAuthentication
            .authenticateWithBiometrics(
                localizedReason: 'Please authenticate to view your codes');
      }
      // If user activated their authentication, but that there are no
      // biometric sensors available at the moment
      return Future.value(false);
    }
  }
}

enum HomeScreenState {
  SPLASHSCREEN,
  ERROR_LOGIN,
  SUCCESS_LOGIN,
}