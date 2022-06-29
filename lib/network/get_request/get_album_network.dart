import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_provider/enums.dart';
import 'package:hive_provider/model/get_album_model.dart';
import 'package:hive_provider/network/http_handler.dart';
import 'package:hive_provider/provider/get_album_provider.dart';


class AlbumNetwork {
  Future<bool> getAlbum(BuildContext context) async {
    log("Requesting Album List...");
    String msgListUrl = "https://jsonplaceholder.typicode.com/albums";
    var albumListResponse = await HTTPHandler()
        .httpRequest(url: msgListUrl, method: RequestType.GET);
    if (albumListResponse == false) {
      return false;
    } else {
      log("ALBUM LIST API RESPONSE SUCCESSFUL");
      var data = albumListResponse;
      List<Album> albumList = List<Album>.from(
          data.map((model) => Album.fromJson(model)));
      await GetAlbumProvider().updateAlbumData(albumList);
      await GetAlbumProvider().saveOfflineData(albumList);

      return true;
    }
  }
}
