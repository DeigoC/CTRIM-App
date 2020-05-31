part of 'gallery_bloc.dart';

abstract class GalleryState extends Equatable {
  const GalleryState();
}

class GalleryInitial extends GalleryState {
  @override
  List<Object> get props => [];
}
