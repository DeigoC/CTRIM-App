part of 'gallery_bloc.dart';

abstract class GalleryState extends Equatable {
   @override
  List<Object> get props => [];
  const GalleryState();
}

class GalleryInitial extends GalleryState {}

class GalleryPictureSelectedState extends GalleryState{
  final Color selectedPicture;
  GalleryPictureSelectedState(this.selectedPicture);
}

class GalleryPictureDeselectedState extends GalleryState{
  final Color deselectedPicture;
  GalleryPictureDeselectedState(this.deselectedPicture);
}
