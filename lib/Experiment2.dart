import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

//void main() => runApp(Example2());

final circlesCount = 3;

class Example2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.black.withOpacity(0.2),
          scaffoldBackgroundColor: Colors.blueGrey.withOpacity(1)),
      home: ImageContainer(),
    );
  }
}

class ImageContainer extends StatefulWidget {
  ImageContainer({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final imageSize = screenWidth / (circlesCount + 1);

    final row1 = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          circlesCount,
          (index) => Padding(
                padding: const EdgeInsets.all(14.0),
                child: RandomedImageWithRipple(
                  width: imageSize,
                  height: imageSize,
                ),
              )),
    );
    final row2 = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          circlesCount,
          (index) => Padding(
                padding: const EdgeInsets.all(14.0),
                child: RandomedImage(
                  width: imageSize,
                  height: imageSize,
                ),
              )),
    );

    final scaffold =
        ScopedModelDescendant<ImageModel>(builder: (builder, child, model) {
      return Scaffold(
        appBar: AppBar(
          title: Text("title"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RandomedImageWithRipple(width: 220, height: 220.0),
              row1,
              row2,
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {model.setRandomBorderAndCorners()},
          tooltip: 'Increment ${model.imageData.radius}',
          child: Icon(Icons.add),
        ),
      );
    });

    final model = ScopedModel<ImageModel>(
      model: ImageModel(),
      child: ScopedModel<ImageModelDesc>(
        model: ImageModelDesc(),
        child: scaffold,
      ),
    );

    return model;
  }
}

class RandomedImageWithRipple extends StatefulWidget {
  RandomedImageWithRipple({Key key, this.title, this.width, this.height})
      : super(key: key);

  final String title;
  final double width;
  final double height;

  @override
  _RandomedImageWithRippleState createState() =>
      _RandomedImageWithRippleState();
}

class _RandomedImageWithRippleState extends State<RandomedImageWithRipple> {
  @override
  Widget build(BuildContext context) {
    final imageScopedModel = ScopedModelDescendant<ImageModel>(
      builder: (context, parentWidget, _imageModel) {
        return Material(
          color: Colors.amberAccent,
          shadowColor: Colors.purple,
          elevation: _imageModel.imageData.elevation,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: _imageModel.imageData.color,
                  width: _imageModel.imageData.width),
              borderRadius: BorderRadius.all(
                  Radius.circular(_imageModel.imageData.radius))),
          child: Container(
            width: widget.width,
            height: widget.height,
            child: FlatButton(
              onPressed: () => print('test'),
              child: null,
              highlightColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(_imageModel.imageData.radius))),
              splashColor: Color(0x88898bff),
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(
                  Radius.circular(_imageModel.imageData.radius)),
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.pexels.com/photos/406014/pexels-photo-406014.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );

    return imageScopedModel;
  }
}

class RandomedImage extends StatefulWidget {
  RandomedImage({Key key, this.title, this.width, this.height})
      : super(key: key);

  final String title;
  final double width;
  final double height;

  @override
  _RandomedImageState createState() => _RandomedImageState();
}

class _RandomedImageState extends State<RandomedImage> {
  @override
  Widget build(BuildContext context) {
    // Ripple effect is not working here
    // https://github.com/flutter/flutter/issues/30193
    final image = Image.network(
      "https://flutter.dev/images/cookbook/network-image.png",
      fit: BoxFit.cover,
      width: widget.width,
      height: widget.height,
    );
    final imageScopedModel = ScopedModelDescendant<ImageModel>(
      builder: (context, parentWidget, _imageModel) {
        return Material(
          color: Colors.amberAccent,
          shadowColor: Colors.purple,
          elevation: _imageModel.imageData.elevation,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: _imageModel.imageData.color,
                  width: _imageModel.imageData.width),
              borderRadius: BorderRadius.all(
                  Radius.circular(_imageModel.imageData.radius))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_imageModel.imageData.radius),
            child: image,
          ),
        );
      },
    );

    return imageScopedModel;
  }
}

class ImageRepo {
  final _randomGenerator = Random();

  ImageData getRandomBorderAndCorners() {
    return ImageData(
        radius: _randomGenerator.nextInt(120) + 10.0,
        width: _randomGenerator.nextInt(20) + 2.0,
        elevation: _randomGenerator.nextInt(10) + 2.0,
        color: (_randomGenerator.nextInt(10) + 2.0) < 7
            ? Colors.black
            : Colors.amber);
  }
}

class ImageModel extends Model {
  final modelDesc = ImageModelDesc();
  final _repo = ImageRepo();
  var imageData = ImageData();

  setRandomBorderAndCorners() {
    imageData = _repo.getRandomBorderAndCorners();
    modelDesc.setRandomBorderAndCorners();
    notifyListeners();
  }
}

class ImageModelDesc extends Model {
  final _repo = ImageRepo();
  var imageData = ImageData();

  setRandomBorderAndCorners() {
    imageData = _repo.getRandomBorderAndCorners();
//    notifyListeners();
  }
}

class ImageData {
  double radius;
  double width;
  double elevation;
  Color color;

  ImageData(
      {this.radius: 90.0,
      this.width: 6.0,
      this.elevation: 5.0,
      this.color: Colors.black});
}
