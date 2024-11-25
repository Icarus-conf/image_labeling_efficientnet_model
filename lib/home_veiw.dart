import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class HomeVeiw extends StatefulWidget {
  const HomeVeiw({super.key});

  @override
  HomeVeiwState createState() => HomeVeiwState();
}

class HomeVeiwState extends State<HomeVeiw> {
  late ImagePicker imagePicker;
  File? _image;
  String result = '';

  ImageLabeler? imageLabeler;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    createImageLabeling();
  }

  @override
  void dispose() {
    super.dispose();
    imageLabeler?.close();
  }

  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {
        doImageLabeling();
      });
    }
  }

  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);

        doImageLabeling();
      });
    }
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  createImageLabeling() async {
    try {
      final modelPath = await getModelPath('assets/ml/mobilenet.tflite');
      final options = LocalLabelerOptions(
        confidenceThreshold: 0.5,
        modelPath: modelPath,
      );
      imageLabeler = ImageLabeler(options: options);
      log("Image labeler initialized.");
    } catch (e) {
      log("Error initializing image labeler: $e");
    }
  }

  doImageLabeling() async {
    if (_image == null || imageLabeler == null) {
      return;
    }

    result = '';
    final inputImage = InputImage.fromFile(_image!);

    try {
      final List<ImageLabel> labels =
          await imageLabeler!.processImage(inputImage);
      for (ImageLabel label in labels) {
        final String text = label.label;
        final double confidence = label.confidence;

        String confidencePercentage = (confidence * 100).toStringAsFixed(2);

        result += "$text   $confidencePercentage%\n";
      }
    } catch (e) {
      result = "Error processing image: $e";
    }

    setState(() {});

    log(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFF616161),
        Color(0xff9bc5c3),
      ])),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                width: 100,
              ),
              Container(
                margin: const EdgeInsets.only(top: 100),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: _imgFromGallery,
                    onLongPress: _imgFromCamera,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _image!,
                                width: 335,
                                height: 495,
                                fit: BoxFit.fill,
                              ),
                            )
                          : const SizedBox(
                              width: 340,
                              height: 330,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 100,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
