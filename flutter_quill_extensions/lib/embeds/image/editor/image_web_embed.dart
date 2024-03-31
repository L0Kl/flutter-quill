import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;

import '../../../models/config/image/editor/image_web_configurations.dart';
import '../../../utils/dart_ui/dart_ui_fake.dart'
    if (dart.library.html) '../../../utils/dart_ui/dart_ui_real.dart' as ui;
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

    final (height, width, margin, alignment) = getWebElementAttributes(node);

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

    ui.PlatformViewRegistry().registerViewFactory(imageSource, (viewId) {
      return html.ImageElement()
        ..src = imageSource
        ..style.height = height
        ..style.width = width
        ..style.margin = margin
        ..style.alignSelf = alignment
        ..attributes['loading'] = 'lazy';
    });

    return FutureBuilder<Size>(
      future: loadImageAndGetSize(imageSource),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: snapshot.data!.width, height: snapshot.data!.height),
            child: HtmlElementView(viewType: imageSource),
          );
        } else if (snapshot.hasError) {
          return const Text('Fehler beim Laden des Bildes');
        } else {
          // Während das Bild lädt, könnten Sie einen Platzhalter anzeigen
          return const Text('Bild wird geladen...');
        }
      },
    );
  }

  Future<Size> loadImageAndGetSize(String imageSource) async {
    final completer = Completer<Size>();
    final img = html.ImageElement(src: imageSource);
    img.onLoad.listen((_) {
      completer.complete(
          Size(img.naturalWidth.toDouble(), img.naturalHeight.toDouble()));
    });
    img.onError.listen((_) {
      completer.completeError('Bild konnte nicht geladen werden');
    });
    return completer.future;
  }
}
