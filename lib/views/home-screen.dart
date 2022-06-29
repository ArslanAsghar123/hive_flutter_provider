import 'package:flutter/material.dart';
import 'package:hive_provider/model/get_album_model.dart';
import 'package:hive_provider/provider/get_album_provider.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 List<Album> getAlbum = [];


  Future getAlbumData()async{
   await GetAlbumProvider().getAlbumData(context);

  }
  @override
  void initState() {
    getAlbumData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("sample API test"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Consumer<GetAlbumProvider>(
              builder: (context, albumProvider, child) {
                getAlbum = albumProvider.getAlbum;
                int length = getAlbum.length;
                if (!albumProvider.isLoading) {
                  if (length != 0) {
                    return Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                        itemCount: length,
                        shrinkWrap: false,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, i) {
                          return Card(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  child: Text(
                                    getAlbum[i].userId.toString(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  getAlbum[i].id.toString(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  getAlbum[i].title.toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const Center(child: Text("No DATA"));
                }
                return const Center(child: Text("Post API status Code 404",textAlign: TextAlign.center,));
              },
            ),
          ],
        ),
      ),
    );
  }
}
