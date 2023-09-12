import 'package:fluro/fluro.dart';
import 'package:workcake/screens/dashboard.dart';
import 'package:workcake/screens/home_screen/login_pancake_id.dart';
import 'package:workcake/screens/profile_screen/index.dart';

import 'screens/home_screen/welcome_app.dart';
import 'screens/main_screen/index.dart';

class AppRoutes {
  // static final users = '/';
  // static final userDetails = '/details';
  static FluroRouter router = FluroRouter();

  // static Handler _home = Handler(
  //   handlerFunc: (context, Map<String, dynamic> params) => Home(),
  // );

  static Handler _welcomeApp = Handler(
      handlerFunc: (context, Map<String, dynamic> params) => WelcomeApp());

  static Handler _loginScreen = Handler(
      handlerFunc: (context, Map<String, dynamic> params) => LoginScreen());

  static Handler _dashboardScreen = Handler(
      handlerFunc: (context, Map<String, dynamic> params) => DashboardScreen());

  static Handler _mainScreen = Handler(
      handlerFunc: (context, Map<String, dynamic> params) => MainScreen());

  static Handler _profile = Handler(
      handlerFunc: (context, Map<String, dynamic> params) => Profile());

  // static Handler _createAppView = Handler(
  //     handlerFunc: (context, Map<String, dynamic> params) => CreateAppView());

  // static Handler _exampleParams = Handler(
  //   handlerFunc: (context, Map<String, dynamic> params) => ExampleParams(
  //     params['params1'][0],
  //     params['params2'][0]
  //   ),
  // );

  // static Handler _exampleParams = Handler(
  //   handlerFunc: (context, Map<String, dynamic> params) => ExampleParams(
  //     params['params1'][0],
  //     params['params1'][1],
  //     params['params2'][0]
  //   ),
  // );

  static void setupRouter() {
    // router.define('/', handler: _home);
    router.define('/welcome-app', handler: _welcomeApp, transitionType: TransitionType.inFromRight);
    router.define('/login-screen', handler: _loginScreen);
    router.define('/dashboard-screen', handler: _dashboardScreen, transitionType: TransitionType.inFromRight);
    router.define('/main-screen', handler: _mainScreen, transitionType: TransitionType.inFromRight);
    router.define('/profile', handler: _profile, transitionType: TransitionType.inFromRight);
    // router.define(
    //   '/example-params/:params1/:params2/',
    //   handler: _exampleParams,
    //   transitionType: TransitionType.inFromBottom //or inFromLeft or inFromTop
    // );

    // router.define(
    //   '/example-params', // example-params?a=123&b=zxc
    //   handler: _exampleParams,
    //   transitionType: TransitionType.inFromBottom //or inFromLeft or inFromTop
    // );
  }

  // Usage push router
  // Navigator.pushNamed(context, '/example-params/$params1/$params2');
}
