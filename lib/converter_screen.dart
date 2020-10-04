import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:forexer/constants.dart';
import 'constants.dart';
import 'networking.dart';
import 'conversion.dart';

class ConverterScreen extends StatefulWidget {
  ConverterScreen({this.converter});

  final Converter converter;
  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  int value;
  String sourceCurrency = 'USD';
  String targetCurrency = 'USD';
  List<String> currencies;

  bool isConnected = false;
  bool unknownConversion = true;

  Converter c;
  NetworkHelper nh = NetworkHelper();

  var textControllerSource = TextEditingController();
  var textControllerTarget = TextEditingController();

  Color invalidInputColor = kColorTransparent;
  Color invalidOutputColor = kColorTransparent;

  bool offstageInputError = true;
  bool offstageOutputError = true;
  bool loading = false;

  void setCurrencies() {
    setState(() {
      currencies = widget.converter.getCurrencies();
    });
    print(currencies);
  }

  void isConnectedCheck() async{
    isConnected = await nh.isPhoneConnected();
  }

  @override
  void initState() {
    super.initState();

    isConnectedCheck();
    try{
      setCurrencies();
    }
    catch(e){
      print('initState exception');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    c = widget.converter;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kColorDarkBlue,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'FOREXER',
                  style: TextStyle(
                    color: kColorWhite,
                    fontSize: 64,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: EdgeInsets.all(15),
                color: kColorLightBlue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            flex: 5,
                            fit: FlexFit.tight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: textControllerSource,
                                    onChanged: (input) {
                                      try{
                                        double.parse(input);
                                        setState(() {
                                          offstageInputError = true;
                                        });
                                      }
                                      catch(e){
                                        setState(() {
                                          offstageInputError = false;
                                        });
                                      }
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    child: Offstage(
                                      offstage: offstageInputError,
                                      child: Text(
                                          'Invalid input',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: kColorRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: CurrencyDropdown(
                              selectedCurrency: sourceCurrency,
                              currencies: currencies ?? <String>['USD'],
                              callback: (value){
                                print(value);
                                setState(() {
                                  sourceCurrency = value;
                                  c.setBase(sourceCurrency);
                                  unknownConversion = true;
                                  textControllerTarget.text = '???';
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Center(
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: kColorWhite,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: loading
                                ? SpinKitRotatingCircle(color: kColorDarkBlue, size: 20,)
                                :Text(
                                  'is equal to',
                                  textAlign: TextAlign.center,
                                  ),
                        )
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            flex: 5,
                            fit: FlexFit.tight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    controller: textControllerTarget,
                                    readOnly: true,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    child: Offstage(
                                      offstage: offstageOutputError,
                                      child: Text(
                                          'An error occurred during conversion',
                                        style: TextStyle(
                                          color: kColorRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: CurrencyDropdown(
                              selectedCurrency: targetCurrency,
                              currencies: currencies ?? <String>['USD'],
                              callback: (value){
                                print(value);
                                setState(() {
                                  targetCurrency = value;
                                  if(unknownConversion){
                                    textControllerTarget.text = '???';
                                  }
                                  else if(textControllerSource.text != '' || !c.isConversionDataNull()){
                                    if(c.getCurrentBase() == c.getPrevRequestedBase()){
                                      textControllerTarget.text = c.getCachedConvertedAmount(targetCurrency, double.parse(textControllerSource.text)).toString();
                                    }
                                  }
                                  else{
                                    print('Unhandled exception');
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
                child: FlatButton(
                  onPressed: () async{
                    // c.setBase(sourceCurrency);
                    try{
                      setState(() {
                        loading = true;
                      });
                      double convertedAmount = await c.getConvertedAmount(sourceCurrency, targetCurrency, double.parse(textControllerSource.text));
                      setState(() {
                        loading = false;
                      });
                      if(convertedAmount != null){
                        setState(() {
                          textControllerTarget.text = convertedAmount.toString();
                          unknownConversion = false;
                          offstageOutputError = true;
                        });
                      }
                      else{
                        setState(() {
                          offstageOutputError = false;
                        });
                      }
                    }
                    on FormatException catch(e){
                      setState(() {
                        offstageInputError = false;
                        loading = false;
                      });
                      print('Parsing error');
                      print(e);
                    }

                  },
                  child: Center(
                    child: Text(
                        'Convert',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kColorWhite,
                        fontSize: 24,
                      ),
                    ),
                  ),
                )
            )
          ],
        )
      ),
    );
  }
}

class CurrencyDropdown extends StatelessWidget {
  CurrencyDropdown({this.selectedCurrency, this.callback, this.currencies});

  final String selectedCurrency;
  final Function callback;
  final List<String> currencies;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      padding: EdgeInsets.only(left: 15, right: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            hint: Text('USD'),
            value: selectedCurrency,
            items: currencies.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value){
              callback(value);
            },
        ),
      ),
    );
  }
}
