import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService{
  late StreamSubscription<ConnectivityResult> connectivity;
  late ProductListService productListService;

  Future<bool> isInternetConnectionAvailable() async{
    bool isConnectionAvailable = true;
    var  connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult == ConnectivityResult.none){
      isConnectionAvailable = false;
      //TODO: Alert the Product List Service that no internet connection is available
    }
    return isConnectionAvailable;
  }

  watchConnectivity(){
    //TODO:
  }

  void cancel(){
    //TODO:
  }
}