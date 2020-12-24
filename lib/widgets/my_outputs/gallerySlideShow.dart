import 'package:ctrim_app_v1/blocs/AboutBloc/about_bloc.dart';
import 'package:ctrim_app_v1/blocs/AppBloc/app_bloc.dart';
import 'package:ctrim_app_v1/classes/other/imageTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';

class GallerySlideShow extends StatefulWidget {
  final Map<String,String> galleryItems, thumbnails;
  GallerySlideShow({
    @required this.galleryItems,
    this.thumbnails,
  });

  @override
  _GallerySlideShowState createState() => _GallerySlideShowState();
}

class _GallerySlideShowState extends State<GallerySlideShow> {
  
  final PageController _pageController = PageController();
  Widget _currentImageWidget;
  AboutBloc _aboutBloc;

  @override
  void initState() {
    _aboutBloc = BlocProvider.of<AboutBloc>(context);
    

    Map<String,ImageTag> gallery = {};
    widget.galleryItems.keys.forEach((src) {
      gallery[src] = ImageTag(
        src: src,
        type: widget.galleryItems[src],
      );
    });

    List<Widget> images = widget.galleryItems.keys.toList().map((src){
      return AspectRatio(
        aspectRatio: 16/9,
        key: ValueKey(src),
        child: GestureDetector(
          onTap: (){
            int index = gallery.keys.toList().indexOf(src);
            BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(gallery, index));
          },
          child: Hero(
            tag: gallery[src].heroTag,
            child: Image(image: NetworkImageWithRetry(src), fit: BoxFit.cover,)
          )
        ),
      ); 
    }).toList();

    _aboutBloc.initialiseSlideshow(images.length);
    _currentImageWidget = images[_aboutBloc.slideShowIndex];
    _animateSlideShow(images);
    super.initState();
  }

  @override
  void dispose() { 
    _pageController.dispose();
    super.dispose();
  }

  Future<Null> _animateSlideShow(List<Widget> images) async{
    await Future.delayed(Duration(seconds: 6,),(){
      
      if(mounted){
        if(_aboutBloc.slideShowIndex < images.length - 1){
          setState(() {
            _aboutBloc.incrementSlideShowIndex();
            _currentImageWidget = images[_aboutBloc.slideShowIndex];
          });
        }else{
          setState(() {
            _aboutBloc.setSlideShowIndex(0);
            _currentImageWidget = images[_aboutBloc.slideShowIndex];
          });
        }
        _animateSlideShow(images);
      }
      
    });
   }

  @override
  Widget build(BuildContext context) {
    Map<String,ImageTag> gallery = {};
    widget.galleryItems.keys.forEach((src) {
      gallery[src] = ImageTag(
        src: src,
        type: widget.galleryItems[src],
      );
    });
     return AnimatedSwitcher(
       duration: const Duration(seconds: 1),
       child: _currentImageWidget,
     );
  }


}