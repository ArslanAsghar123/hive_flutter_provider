import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_provider/model/get_album_model.dart';
import 'package:hive_provider/network/get_request/get_album_network.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class GetAlbumProvider extends ChangeNotifier {
  static final GetAlbumProvider _selfInstance = GetAlbumProvider._internal();

  GetAlbumProvider._internal();

  factory GetAlbumProvider() => _selfInstance;

  List<Album> albumList = [];
  List<dynamic> albumHiveList = [];//use dynamic List because hive data stored in dynamic to required model otherwise it gives you error
  bool isLoading = false;


  Future<void> saveOfflineData(List<Album> album) async {
    try {
      //Flutter Secure storage to generate encryption key
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      var containsEncryptionKey = await secureStorage.containsKey(key: 'album');
      if (!containsEncryptionKey) { // if EncryptionKey is null
        var key = Hive.generateSecureKey();
        await secureStorage.write(key: 'album', value: base64UrlEncode(key));
      }
      var key = await secureStorage.read(key: 'album');
      var encryptionKey = base64Url.decode(key!); // Decode EncryptionKey to be used in encryptionCipher

      var encryptedBox = await Hive.openBox("album",encryptionCipher: HiveAesCipher(encryptionKey));
      albumList = album;

      encryptedBox.put(102, album);
      encryptedBox.close(); //always close box if you don't using it
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> showOfflineList() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    var key = await secureStorage.read(key: 'album');//read EncryptionKey
    var encryptionKey = base64Url.decode(key!);//decode EncryptionKey

    var encryptedBox = await Hive.openBox("album",encryptionCipher: HiveAesCipher(encryptionKey));
    albumHiveList = await encryptedBox.get(102, defaultValue: []);
    if (albumList.isNotEmpty) {
      albumList.clear();
    }//clear list to not duplicate data
    if (albumHiveList.isNotEmpty) {
      for (int i = 0; i < albumHiveList.length; i++) {
        albumList.add(albumHiveList[i]);
      }
    }
    encryptedBox.close();//again always close box after it use
    notifyListeners();
  }

  updateAlbumData(List<Album> album) {
    albumList = album;
    isLoading = false;
    notifyListeners();
  }

  Future<void> getAlbumData(BuildContext context) async {
    isLoading = true;
    if (await InternetConnectionChecker().hasConnection) { // check internet connection for showing online or offline data
      await AlbumNetwork().getAlbum(context);
    } else {
      await showOfflineList();// use await because it is an future call
    }
    isLoading = false;
    notifyListeners();
  }

  List<Album> get getAlbum {
    return albumList;
  }
}
