import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {

  @override
  GalleryState get initialState => GalleryInitial();

  @override
  Stream<GalleryState> mapEventToState(
    GalleryEvent event,
  ) async* {
   
  }
}
