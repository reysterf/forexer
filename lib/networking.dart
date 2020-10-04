import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

String apiURL = 'https://api.exchangeratesapi.io';

class NetworkHelper {
  Future<bool> isPhoneConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<dynamic> getData({String base}) async{
    print('Making request');
    try{
      http.Response response = await http.get('$apiURL/latest?base=$base');
      if(response != null){
        print('Got response');
        if(response.statusCode == 200){
          print('Response is valid');
          dynamic data = response.body;
          return jsonDecode(data);
        }
        else {
          print(response.statusCode);
          //TODO: Handle no return
          return null;
        }
      }
      else{
        //TODO: Handle null response
        print('null');
        return null;
      }
    }
    catch(e){
      //TODO: Handle request exception
      print('Request exception');
      print(e);
    }
  }
}