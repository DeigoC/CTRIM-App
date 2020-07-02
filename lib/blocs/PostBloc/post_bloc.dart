import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:ctrim_app_v1/classes/models/post.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zefyr/zefyr.dart';
import 'package:collection/collection.dart';
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  Post _post = Post(
    selectedTags: [],
    temporaryFiles: {},
    detailTable: [],
    gallerySources: {},
  );

  Post _originalPost;
  Post get newPost => _post;
  bool _editMode = false;

  // ! Post Fields - About Tab
  String get eventTitle => _post.title;
  String get postDescription => _post.description;
  String _addressLine = 'PENDING';
  String get addressLine => _addressLine;
  NotusDocument getEditorDoc() {
    if (_post.body == '') {
      List<dynamic> initialWords = [
        {"insert": "Body Starts Here\n"}
      ];
      return NotusDocument.fromJson(initialWords);
    }
    var jsonDecoded = jsonDecode(_post.body);
    return NotusDocument.fromJson(jsonDecoded);
  }

  Map<PostTag, bool> selectedTags = {
    PostTag.CHURCH: false,
    PostTag.YOUTH: false,
    PostTag.WOMEN: false,
  };

  // ! Post Fields - Details Tab
  DateTime get getSelectedDate => _post.eventDate;
  String get getSelectedDateString => _post.eventDate == null
      ? 'Pending'
      : DateFormat('EEE, dd MMM yyyy').format(_post.eventDate);
  bool get getIsDateNotApplicable => _post.isDateNotApplicable;
  String get getSelectedTimeString => _post.eventDate == null
      ? 'Pending'
      : DateFormat('h:mm a').format(_post.eventDate);

  // ! Post Fields - Details Tab - Detail Table
  List<List<String>> get detailTable => _post.detailTable;
  String get detailTableHeader => _post.detailTableHeader;
  String _leadingDetailItem = '', _trailingDetailItem = '';
  void prepareNewDetailListItem() {
    _leadingDetailItem = '';
    _trailingDetailItem = '';
  }

  void prepareDetailItemEdit(List<String> item) {
    _leadingDetailItem = item[0];
    _trailingDetailItem = item[1];
  }

  // ! Post Fields - Gallery Tab
  Map<File, String> get files => _post.temporaryFiles;
  Map<String, String> get gallerySrc => _post.gallerySources;
  bool get hasAlbumChanged {
    List<String> originalSrc = _originalPost.gallerySources.keys.toList();
    List<String> newSrc = _post.gallerySources.keys.toList();
    if (!DeepCollectionEquality().equals(originalSrc, newSrc)) {
      return true;
    } else if (_post.temporaryFiles.length != 0) return true;
    return false;
  }

  // ! Mapping events to states

  PostBloc();
  PostBloc.editMode(Post postToEdit) {
    _editMode = true;

    // ? Testing this
    _post = Post(
        id: postToEdit.id,
        title: postToEdit.title,
        body: postToEdit.body,
        selectedTags: List<PostTag>.from(postToEdit.selectedTags),
        description: postToEdit.description,
        detailTable: List<List<String>>.from(postToEdit.detailTable),
        detailTableHeader: postToEdit.detailTableHeader,
        locationID: postToEdit.locationID,
        eventDate: postToEdit.eventDate,
        isDateNotApplicable: postToEdit.isDateNotApplicable,
        gallerySources: Map.from(postToEdit.gallerySources),
        temporaryFiles: {});

    _originalPost = Post(
      title: _post.title,
      body: _post.body,
      selectedTags: List<PostTag>.from(postToEdit.selectedTags),
      description: _post.description,
      detailTable: List<List<String>>.from(postToEdit.detailTable),
      detailTableHeader: _post.detailTableHeader,
      locationID: _post.locationID,
      eventDate: _post.eventDate,
      isDateNotApplicable: _post.isDateNotApplicable,
      gallerySources: Map.from(_post.gallerySources),
      temporaryFiles: {},
    );

    _post.selectedTags.forEach((tag) {
      selectedTags[tag] = true;
    });
  }

  @override
  PostState get initialState => PostInitial();

  @override
  Stream<PostState> mapEventToState(
    PostEvent event,
  ) async* {
    if (event is PostTabClickEvent)
      yield* _mapTabClickEventToState(event);
    else if (event is PostTextChangeEvent)
      yield* _mapTextChangeToState(event);
    else if (event is PostDepartmentClickEvent)
      yield* _mapDepartmentClickToState(event);
    else if (event is PostScheduleTabEvent)
      yield* _mapScheduleTabEventsToState(event);
    else if (event is PostSaveBodyDocumentEvent) {
      _post.body = event.bodyContent;
      yield PostUpdateBodyState();
      yield* _canEnableSaveButton();
    } else if (event is PostDetailListEvent)
      yield* _mapDetailListEventToState(event);
    else if (event is PostGalleryEvent) yield* _mapGalleryEventsToState(event);
  }

  Stream<PostState> _mapGalleryEventsToState(PostGalleryEvent event) async* {
    if (event is PostFilesReceivedEvent)
      yield PostFilesReceivedState();
    else if (event is PostFilesRemoveSelectedEvent) {
      event.selectedFiles.forEach((file) {
        _post.temporaryFiles.remove(file);
      });
      yield PostFilesReceivedState(); // TODO may have to change this
    } else if (event is PostRemoveSelectedFilesAndSrcEvent) {
      event.selectedFilesAndSrcs.forEach((src) {
        if (_post.gallerySources.keys.contains(src)) {
          _post.gallerySources.remove(src);
        } else {
          _post.temporaryFiles.removeWhere((key, value) => key.path.compareTo(src) == 0);
        }
      });
      yield PostFilesReceivedState();
    }else if(event is PostDiscardGalleryChnagesEvent){
      _post.gallerySources = Map.from(_originalPost.gallerySources);
    }
  }

  Stream<PostState> _mapDetailListEventToState(PostDetailListEvent event) async* {
    if (event is PostDetailListReorderEvent) {
      int newIndex = event.newIndex;
      if (newIndex >= _post.detailTable.length)
        newIndex = _post.detailTable.length - 1;
      var temp = _post.detailTable.removeAt(event.oldIndex);
      _post.detailTable.insert(newIndex, temp);
      yield PostDetailListReorderState();
      yield PostDetailListState();
    } else if (event is PostDetailListTextChangeEvent) {
      _leadingDetailItem = event.leading ?? _leadingDetailItem;
      _trailingDetailItem = event.trailing ?? _trailingDetailItem;
      if (_leadingDetailItem.isNotEmpty || _trailingDetailItem.isNotEmpty)
        yield PostDetailListSaveEnabledState();
      else
        yield PostDetailListSaveDisabledState();
    } else if (event is PostDetailListItemRemovedEvent) {
      _post.detailTable.remove(event.item);
      yield PostDetailListReorderState();
    } else if (event is PostDetailListAddItemEvent) {
      _post.detailTable.add([_leadingDetailItem, _trailingDetailItem]);
      yield PostDetailListReorderState();
    } else if (event is PostDetailListSaveEditEvent) {
      _post.detailTable[event.itemIndex] = [
        _leadingDetailItem,
        _trailingDetailItem
      ];
    }
  }

  Stream<PostState> _mapScheduleTabEventsToState(PostScheduleTabEvent event) async* {
    if (event is PostSelectPostDateEvent) {
      yield PostSelectDateState();
    } else if (event is PostSelectPostTimeEvent) {
      yield PostSelectTimeState();
    } else if (event is PostSetPostDateEvent) {
      if (event.selectedDate != null) _post.setEventDate(event.selectedDate);
      yield PostDateSelectedState();
    } else if (event is PostSetPostTimeEvent) {
      _post.setTimeOfDay(event.selectedTOD);
      yield PostDateSelectedState(); // ? Need to change this name perhaps
    } else if (event is PostDateNotApplicableClick) {
      if (_post.isDateNotApplicable) {
        _post.isDateNotApplicable = false;
        yield PostDateIsNOTApplicableState();
      } else {
        _post.isDateNotApplicable = true;
        yield PostDateIsApplicableState();
      }
    } else if (event is PostSelectedLocationEvent) {
      _post.locationID = event.locationID;
      _addressLine = event.addressLine;
      yield PostLocationSelectedState();
    }
    yield* _canEnableSaveButton();
  }

  Stream<PostState> _mapDepartmentClickToState(PostDepartmentClickEvent event) async* {
    if (event.selected) {
      _post.selectedTags.add(event.department);
    } else {
      _post.selectedTags.remove(event.department);
    }
    selectedTags[event.department] = event.selected;
    bool selected = event.selected;
    switch (event.department) {
      case PostTag.CHURCH:
        if (selected) yield PostDepartmentChurchEnabledState();
        else yield PostDepartmentChurchDisabledState();
        break;

      case PostTag.YOUTH:
        if (selected) yield PostDepartmentYouthEnabledState();
        else yield PostDepartmentYouthDisabledState();
        break;

      case PostTag.WOMEN:
        if (selected) yield PostDepartmentWomenEnabledState();
        else yield PostDepartmentWomenDisabledState();
        break;
    }
    yield* _canEnableSaveButton();
  }

  Stream<PostState> _mapTextChangeToState(PostTextChangeEvent event) async* {
    _post.title = event.title ?? _post.title;
    _post.description = event.description ?? _post.description;
    yield* _canEnableSaveButton();
  }

  Stream<PostState> _canEnableSaveButton() async* {
    if (_editMode) {
      if (_haveAnyChangedFields()) {
        yield PostEnableSaveButtonState();
      } else
        yield PostDisableSaveButtonState();
    } else {
      if (_haveAnyEmptyFields()) {
        yield PostDisableSaveButtonState();
      } else {
        yield PostEnableSaveButtonState();
      }
    }
  }

  bool _haveAnyChangedFields() {
    if (_originalPost.title.compareTo(_post.title) != 0) return true;
    else if (_originalPost.body.compareTo(_post.body) != 0) return true;
    else if (_originalPost.description.compareTo(_post.description) != 0) return true;
    else if (_originalPost.detailTableHeader.compareTo(_post.detailTableHeader) !=0) return true;
    else if (!DeepCollectionEquality().equals(_originalPost.detailTable, _post.detailTable)) return true;
    else if (!DeepCollectionEquality.unordered().equals(_originalPost.selectedTags, _post.selectedTags))return true;
    else if (_originalPost.locationID.compareTo(_post.locationID) != 0)return true;
    // TODO Check the one below
    else if (_originalPost.eventDate.compareTo(_post.eventDate) != 0 &&!_post.isDateNotApplicable)return true;
    else if (_originalPost.isDateNotApplicable != _post.isDateNotApplicable)return true;
    else if(hasAlbumChanged) return true;
    return false;
  }

  bool _haveAnyEmptyFields() {
    if (_post.title.trim().isEmpty ||
        _post.description.trim().isEmpty ||
        _post.selectedTags.length == 0 ||
        !_isDateFieldValid() ||
        _post.body.isEmpty ||
        _post.locationID.trim().isEmpty) return true;
    return false;
  }

  bool _isDateFieldValid() {
    if (_post.eventDate != null || _post.isDateNotApplicable) return true;
    return false;
  }

  Stream<PostState> _mapTabClickEventToState(PostTabClickEvent event) async* {
    switch (event.selectedIndex) {
      case 0:
        yield PostAboutTabClickState();
        break;
      case 1:
        yield PostDetailsTabClickState();
        break;
      case 2:
        yield PostGalleryTabClickState();
        break;
      case 3:
        yield PostUpdatesTabClickState();
        break;
    }
  }
}
