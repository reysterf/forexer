import 'dart:io';

import 'package:flutter/material.dart';
import 'constants.dart';
import 'converter_screen.dart';
import 'conversion.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Converter c = Converter();
  String loadingTextString = ' loading...';
  bool offstageAnimation = false;
  bool offstageRetry = true;

  void initialize() async {
    try{
      var _ = await c.setCurrencies();
      Future.delayed(Duration(seconds: 3), (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ConverterScreen(converter: c);
        }));
      });
    }
    catch(e){
      print('Initialize Exception');
      setState(() {
        offstageAnimation = true;
        offstageRetry = false;
        loadingTextString = 'cannot connect to the internet';
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    try{
      print('Calling initialize');
      initialize();
      print('After initialize');
    }
    catch (e){
      print('Exception in initState');
      setState(() {
        loadingTextString = 'cannot connect to the internet';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kColorDarkBlue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FOREXER',
                style: TextStyle(
                  fontSize: 48,
                  color: kColorWhite,
                ),
              ),
              SizedBox(height: 50),
              Offstage(
                offstage: offstageAnimation,
                child: SpinKitRotatingCircle(
                  color: kColorLightBlue,
                  size: 50,
                ),
              ),
              SizedBox(height: 30),
              Text(
                  loadingTextString,
                style: TextStyle(
                  color: kColorWhite,
                  fontSize: 18,
                ),
              ),
              Offstage(
                offstage: offstageRetry,
                child: TextButton(
                    onPressed: () async {
                      setState(() {
                        offstageAnimation = false;
                        offstageRetry = true;
                        loadingTextString = 'connecting...';
                      });
                      Future.delayed(Duration(seconds: 2), (){
                        initialize();
                      });
                    },
                    child: Text(
                        'Retry',
                      style: TextStyle(
                        color: kColorDarkBlue,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(kColorLightBlue),
                    ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
