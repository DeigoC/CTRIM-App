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

  @override
  void initState() {
    _animateSlideShow();
    super.initState();
  }

  @override
  void dispose() { 
    _pageController.dispose();
    super.dispose();
  }

  Future<Null> _animateSlideShow() async{
    await Future.delayed(Duration(seconds: 6,),(){
      try{
        if(mounted){
          if(_pageController.page + 1 < widget.galleryItems.length){
            _pageController.animateToPage(_pageController.page.round() + 1, 
            duration: Duration(seconds: 1), curve: Curves.easeInOut);
            _animateSlideShow();
          }else{
            _pageController.animateToPage(0, duration: Duration(seconds: 1), curve: Curves.easeInOut);
            _animateSlideShow();
          }
        }
      }catch(e){print('-------------SLIDE SHOW ERROR: ' + e.toString());}
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
    
    return AspectRatio(
      aspectRatio: 16/9,
      child: PageView.builder(
        controller: _pageController,
        itemCount: gallery.length,
        itemBuilder: (_,index){
          return GestureDetector(
            onTap: (){
              BlocProvider.of<AppBloc>(context).add(AppToViewImageVideoPageEvent(gallery, index));
            },
            child: Hero(
              tag: gallery[widget.galleryItems.keys.toList()[index]].heroTag,
              child: Image(image: NetworkImageWithRetry(widget.galleryItems.keys.toList()[index]), fit: BoxFit.cover,)
            )
          );
        }
      ),
    );
  }
}