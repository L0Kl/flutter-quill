import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image/image.dart' as img;
import 'package:universal_html/html.dart' as html;

import '../../../models/config/image/editor/image_web_configurations.dart';
import '../../../utils/dart_ui/dart_ui_fake.dart'
    if (dart.library.html) '../../../utils/dart_ui/dart_ui_real.dart' as ui;
import '../../../utils/element_utils/element_utils.dart';
import '../../../utils/element_utils/element_web_utils.dart';
import '../../../utils/utils.dart';

class QuillEditorWebImageEmbedBuilder extends EmbedBuilder {
  const QuillEditorWebImageEmbedBuilder();

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    assert(kIsWeb, 'ImageEmbedBuilderWeb is only for web platform');

    double imageWidth = 200;
    double imageHeight = 200;

    var imageSource = node.value.data.toString();

    // This logic make sure if the image is imageBase64 then
    // it make sure if the pattern is like
    // data:image/png;base64, [base64 encoded image string here]
    // if not then it will add the data:image/png;base64, at the first
    if (isImageBase64(imageSource)) {
      // Sometimes the image base 64 for some reasons
      // doesn't displayed with the 'data:image/png;base64'
      if (!(imageSource.startsWith('data:image/') &&
          imageSource.contains('base64'))) {
        imageSource = 'data:image/png;base64, $imageSource';
      }
    }

    // var imageBytes = base64Decode(imageSource);
    // img.Image? image = img.decodeImage(imageBytes);
    // if (image != null) {
    //   imageWidth = image.width as double;
    //   imageHeight = image.height as double;
    //   print('Breite: ${image.width}, Höhe: ${image.height}');
    // }

    ui.PlatformViewRegistry().registerViewFactory(imageSource, (viewId) {
      return html.ImageElement()
        ..src = imageSource
        ..style.height = 'auto'
        ..style.width = 'auto'
        ..attributes['loading'] = 'lazy';
    });

    return ConstrainedBox(
      constraints:
          BoxConstraints.tightFor(width: imageWidth, height: imageHeight),
      child: HtmlElementView(viewType: imageSource),
    );
  }
}
