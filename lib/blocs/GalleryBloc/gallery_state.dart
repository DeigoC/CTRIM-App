part of 'gallery_bloc.dart';

abstract class GalleryState extends Equatable {
   @override
  List<Object> get props => [];
  const GalleryState();
}

class GalleryInitial extends GalleryState {}

class GalleryPictureSelected extends GalleryState{
  final Color selectedPicture;
  GalleryPictureSelected(this.selectedPicture);
}

class GalleryPictureDeselected extends GalleryState{
  final Color deselectedPicture;
  GalleryPictureDeselected(this.deselectedPicture);
}
