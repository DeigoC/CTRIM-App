part of 'gallery_bloc.dart';

abstract class GalleryEvent extends Equatable {
   @override
  List<Object> get props => [];
  const GalleryEvent();
}

class GallerySelectPictureEvent extends GalleryEvent{
  final Color selectedColor;
  GallerySelectPictureEvent(this.selectedColor);
}

class GalleryDeselectPictureEvent extends GalleryEvent{
  final Color deselectColor;
  GalleryDeselectPictureEvent(this.deselectColor);
}

