import 'dart:io';

class FileModel {
  late File file;
  late File thumb;
  bool isSelected = false;

  FileModel({required this.file});
}

class PhotoModel {
  Map<int, FileModel> photos = {};
  int photoID = 0;
  List<int> selectedPhotosID = [];
  List<int> unselectedPhotosID = [];
}

class VideoModel {
  int videoID = 0;
  Map<int, FileModel> videos = {};
  List<int> selectedVideosID = [];
  List<int> unselectedVideosID = [];
  List<File> videosThumbs = [];
}

class SaveModel {
  int saveID = 0;
  Map<int, FileModel> saves = {};
  List<int> selectedSavesID = [];
  List<int> unselectedSavesID = [];
  List<File> saveThumbs = [];
}