part of 'gallery_bloc.dart';

abstract class GalleryEvent extends Equatable {
   @override
  List<Object> get props => [];
  const GalleryEvent();
}

class SelectPicture extends GalleryEvent{
  final Color selectedColor;
  SelectPicture(this.selectedColor);
}

class DeselectPicture extends GalleryEvent{
  final Color deselectColor;
  DeselectPicture(this.deselectColor);
}

