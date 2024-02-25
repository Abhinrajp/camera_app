import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  late String myFolder;
  File? image;
  final imagePicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            getImage();
          },
          child: const Icon(Icons.camera_alt_outlined)),
      body: FutureBuilder<List<File>>(
          future: showImage(),
          builder: (context, value) {
            if (value.hasData) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, intex) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        barrierColor: Colors.black,
                        context: context,
                        builder: (context) {
                          return Image.file(value.data![intex]);
                        },
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                      child: Image.file(value.data![intex], fit: BoxFit.fill),
                    ),
                  );
                },
                itemCount: value.data!.length,
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future getImage() async {
    final image1 = await imagePicker.pickImage(source: ImageSource.camera);
    image = File(image1!.path);
    final name = basename(image1.path);
    await image!.copy("$myFolder/$name");
    setState(() {});
  }

  Future<String> createFolder() async {
    final myFolderPath = Directory("storage/emulated/0/MyGalleryApp");
    final status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if (await myFolderPath.exists()) {
      return myFolderPath.path;
    } else {
      myFolderPath.create();
      return myFolderPath.path;
    }
  }

  Future<List<File>> showImage() async {
    myFolder = await createFolder();
    final images = Directory(myFolder).listSync();
    final imageOnly = images.whereType<File>().toList();
    return imageOnly;
  }
}
