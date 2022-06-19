import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';



class UrlHandler {
  /// Attempts to open the given [url] in in-app browser. Returns `true` after successful opening, `false` otherwise.
  static Future<bool> open(String url) async {
    try {
      // ignore: deprecated_member_use
      await launch(
        url,
      );
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }
}
