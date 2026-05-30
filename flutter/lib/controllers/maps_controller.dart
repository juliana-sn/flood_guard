import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class MapsController extends ChangeNotifier {
  double lat = 0.0;
  double long = 0.0;
  String erro = '';

  MapsController(){
    getPosicao();
  }

  getPosicao () async {
    try{
      Position posicao = await _posicaoAtual();
      lat = posicao.latitude;
      long = posicao.longitude;
    } catch(e){
      erro = e.toString();
    }
    notifyListeners();
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;

    bool ativado = await Geolocator.isLocationServiceEnabled();

    if(!ativado){
    return Future.error('Por Favor, habilite a localização no smatphone');
    }

    permissao = await Geolocator.checkPermission();

    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        return Future.error('Por Favor, habilite a localização no smatphone');
      }
    }

    if(permissao == LocationPermission.deniedForever){
      return Future.error('Por Favor, habilite a localização no smatphone');
    }

    return await Geolocator.getCurrentPosition();
  }

}