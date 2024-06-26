import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File?> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      // Handle the case where getExternalStorageDirectory() returns null
      return null; // or throw an exception, depending on your use case
    }
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
