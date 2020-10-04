import 'networking.dart';
import 'dart:convert';

class Converter{
  String _base = 'USD';
  String _prevRequestedBase = 'NONE';
  dynamic conversionData;
  dynamic prevConversionData;
  List<String> currencies;

  Future<List<String>> setCurrencies() async {
    try{
      await getConversionData('USD');
      currencies = conversionData['rates'].keys.toList();
      currencies.sort();
      print('Assigned currencies');
    }
    catch(e){
      print('Set Currencies exception');
      print(e);
      throw(e);
    }
    return currencies;
  }

  List<String> getCurrencies(){
    return currencies;
  }

  Future<dynamic> getConversionData(String base) async {
    try{
        var temp = await NetworkHelper().getData(base: base);
        prevConversionData = conversionData;
        conversionData = temp;
        _prevRequestedBase = _base;
        _base = base;
        return conversionData;
    }
    catch(e){
      _prevRequestedBase = 'INVALID';
      print('Exception in getConversionData');
      print(e);
      return null;
    }
    if(conversionData == null){
      conversionData = prevConversionData;
    }
  }

  void setBase(String base){
    _base = base;
  }

  String getCurrentBase(){
    return _base;
  }

  String getPrevRequestedBase(){
    return _prevRequestedBase;
  }

  bool isConversionDataNull(){
    return conversionData == null;
  }

  Future<double> getConversionRate(String base, String target) async{
    print('Getting conversion rate');
    if(base == _prevRequestedBase){
      print('Cached conversion data');
      print('Getting rate for $target');
      print(conversionData['rates']);
      if(base == target){
        return 1;
      }
      return conversionData['rates']['$target'];
    }
    else if(base != _prevRequestedBase){
      print('Requesting conversion data');

      if(await getConversionData(base) == null){
        _prevRequestedBase = 'INVALID';
        print('Conversion data is null');
        return null;
      }
      if(base == target){
        return 1;
      }
      return conversionData['rates']['$target'];
    }
    else{
      print('Something unexpected');
      return null;
    }
  }

  Future<double> getConvertedAmount(String base, String targetCurrency, double amount) async {
    try{
      double conversionRate = await getConversionRate(base, targetCurrency);
      print('Conversion rate is $conversionRate');
      print('Amount to convert is $amount');
      return conversionRate * amount;
    }
    catch(e){
      print('Exception at getConvertedAmount');
      print(e);
      return null;
    }
  }

  double getCachedConvertedAmount(String targetCurrency, double amount){
    return conversionData['rates']['$targetCurrency'] * amount;
  }
}

