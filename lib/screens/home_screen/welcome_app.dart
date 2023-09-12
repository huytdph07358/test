import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workcake/screens/home_screen/signup_app.dart';

class WelcomeApp extends StatefulWidget {
  final title;

  WelcomeApp({Key? key, this.title}) : super(key: key);

  @override
  _WelcomeAppState createState() => _WelcomeAppState();
}

class _WelcomeAppState extends State<WelcomeApp> {
  Widget submitButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'main-screen');
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white12.withAlpha(100),
              offset: Offset(2, 4),
              blurRadius: 8,
              spreadRadius: 2
            )
          ],
          color: Colors.white
        ),
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 20,
            color: Colors.blueAccent,
          )
        ),
      ),
    );
  }

  Widget pancakeIDButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'login-screen');
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white12.withAlpha(100),
              offset: Offset(2, 4),
              blurRadius: 8,
              spreadRadius: 2
            )
          ],
          color: Colors.white
        ),
        child: Text(
          'Log in with PancakeID',
          style: TextStyle(fontSize: 20, color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget signUpButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpApp()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          'Register now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget label() {
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: <Widget>[
          Text(
            'Quick login with Touch ID',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          SizedBox(height: 20),
          Icon(Icons.fingerprint, size: 90, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Touch ID',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              decoration: TextDecoration.underline
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Pancake',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        // children: [
        //   TextSpan(
        //     text: 'Chat',
        //     style: TextStyle(color: Colors.black, fontSize: 30)
        //   )
        // ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2
              )
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff5b86e5), Color(0xff36d1dc)]
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _title(),
              SizedBox(height: 80),
              // _submitButton(),
              SizedBox(height: 20),
              // _pancakeIDButton(),
              SizedBox(height: 20),
              // _label()
            ],
          ),
        )
      )
    );
  }
}