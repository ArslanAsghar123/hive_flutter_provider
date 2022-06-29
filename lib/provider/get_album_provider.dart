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
  List<dynamic> albumHiveList = [];
  bool isLoading = false;


  Future<void> saveOfflineData(List<Album> album) async {
    try {
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      var containsEncryptionKey = await secureStorage.containsKey(key: 'album');
      if (!containsEncryptionKey) {
        var key = Hive.generateSecureKey();
        await secureStorage.write(key: 'album', value: base64UrlEncode(key));
      }
      var key = await secureStorage.read(key: 'album');
      var encryptionKey = base64Url.decode(key!);

      var encryptedBox = await Hive.openBox("album",encryptionCipher: HiveAesCipher(encryptionKey));
      albumList = album;

      encryptedBox.put(102, album);
      encryptedBox.close();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> showOfflineList() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    var key = await secureStorage.read(key: 'album');
    var encryptionKey = base64Url.decode(key!);

    var encryptedBox = await Hive.openBox("album",encryptionCipher: HiveAesCipher(encryptionKey));
    albumHiveList = await encryptedBox.get(102, defaultValue: []);
    if (albumList.isNotEmpty) {
      albumList.clear();
    }
    if (albumHiveList.isNotEmpty) {
      for (int i = 0; i < albumHiveList.length; i++) {
        albumList.add(albumHiveList[i]);
      }
    }
    notifyListeners();
  }

  updateAlbumData(List<Album> album) {
    albumList = album;
    isLoading = false;
    notifyListeners();
  }

  Future<void> getAlbumData(BuildContext context) async {
    isLoading = true;
    if (await InternetConnectionChecker().hasConnection) {
      await AlbumNetwork().getAlbum(context);
    } else {
      await showOfflineList();
    }
    isLoading = false;
    notifyListeners();
  }

  List<Album> get getAlbum {
    return albumList;
  }
}
