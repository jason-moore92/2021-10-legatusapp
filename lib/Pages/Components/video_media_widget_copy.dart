// import 'dart:async';
// import 'dart:io';
// import 'dart:math';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:legatus/Models/index.dart';
// import 'package:legatus/Pages/App/index.dart';
// import 'package:legatus/Pages/Dialogs/index.dart';
// import 'package:legatus/Providers/index.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter_video_info/flutter_video_info.dart';

// class VideoMediaWidget extends StatefulWidget {
//   final MediaModel? mediaModel;
//   final int? totalMediaCount;
//   final bool? isSelected;
//   final bool? isUploading;
//   final Function? tapHandler;
//   final Function? longPressHandler;

//   VideoMediaWidget({
//     Key? key,
//     @required this.mediaModel,
//     @required this.totalMediaCount,
//     this.isSelected = false,
//     this.isUploading = false,
//     @required this.tapHandler,
//     @required this.longPressHandler,
//   }) : super(key: key);

//   @override
//   _VideoMediaWidgetState createState() => _VideoMediaWidgetState();
// }

// class _VideoMediaWidgetState extends State<VideoMediaWidget> {
//   double widthDp = ScreenUtil().setWidth(1);
//   double heightDp = ScreenUtil().setWidth(1);
//   double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

//   VideoPlayerController? _videoPlayerController;
//   // VoidCallback? _videoPlayerListener;

//   MediaPlayProvider? _mediaPlayProvider;

//   Timer? _timer;

//   double _maxDuration = 1.0;
//   double _sliderCurrentPosition = 0.0;
//   // String _playerTxt = '00:00:00';

//   Timer? uploadTimer;
//   double angle = 0;

//   FlutterVideoInfo videoInfo = FlutterVideoInfo();
//   VideoData? info;

//   @override
//   void initState() {
//     super.initState();

//     _mediaPlayProvider = MediaPlayProvider.of(context);

//     _mediaPlayProvider!
//         .setMediaPlayState(MediaPlayState.init(), isNotifiable: false);

//     _init();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _mediaPlayProvider!.addListener(_mediaPlayProviderListener);
//     });
//   }

//   void _mediaPlayProviderListener() async {
//     if (_mediaPlayProvider!.mediaPlayState.isNew! &&
//         _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank !=
//             widget.mediaModel!.rank &&
//         _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid !=
//             widget.mediaModel!.uuid) {
//       if (_videoPlayerController!.value.isPlaying) {
//         await _seekToPlayer(0);
//         _sliderCurrentPosition = 0;
//         await _onStopPlay();
//       } else {
//         await _seekToPlayer(0);
//         _sliderCurrentPosition = 0;
//         if (mounted) setState(() {});
//       }
//     }
//   }

//   void _init() async {
//     info = await videoInfo.getVideoInfo(widget.mediaModel!.path!);
//     _videoPlayerController =
//         VideoPlayerController.file(File(widget.mediaModel!.path!))
//           ..initialize().then(
//             (_) {
//               WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//                 _maxDuration = _videoPlayerController!
//                     .value.duration.inMilliseconds
//                     .toDouble();
//                 if (_maxDuration <= 0) _maxDuration = 0.0;
//                 if (mounted) setState(() {});
//               });
//             },
//           ).onError((error, stackTrace) {
//             print(error);
//           });
//   }

//   @override
//   void dispose() {
//     if (uploadTimer != null) uploadTimer!.cancel();
//     _mediaPlayProvider!.removeListener(_mediaPlayProviderListener);
//     _videoPlayerController!.dispose();
//     super.dispose();
//   }

// /*   void _onStartPlay() async {
//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized) return;
//     try {
//       if (_mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank !=
//               widget.mediaModel!.rank &&
//           _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid !=
//               widget.mediaModel!.uuid) {
//         ///
//         _mediaPlayProvider!.setMediaPlayState(
//           _mediaPlayProvider!.mediaPlayState
//               .update(isNew: true, selectedMediaModel: widget.mediaModel),
//         );
//       } else if (_mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank ==
//               widget.mediaModel!.rank &&
//           _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid ==
//               widget.mediaModel!.uuid) {
//         ///
//         _mediaPlayProvider!.setMediaPlayState(
//           _mediaPlayProvider!.mediaPlayState.update(
//             isNew: false,
//           ),
//         );
//       } else {}

//       await _videoPlayerController!.play();
//       _timer = Timer.periodic(Duration(milliseconds: 1), (timer) async {
//         if ((await _videoPlayerController!.position) == null) return;
//         _sliderCurrentPosition =
//             (await _videoPlayerController!.position)!.inMilliseconds.toDouble();
//         if (_sliderCurrentPosition >= _maxDuration) {
//           _onStopPlay();
//         } else {
//           if (mounted) setState(() {});
//         }
//       });
//     } catch (e) {}
//   } */

//   Future<void> _seekToPlayer(int milliSecs) async {
//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized) return;
//     try {
//       await _videoPlayerController!.seekTo(Duration(milliseconds: milliSecs));
//       if (_timer != null) _timer!.cancel();
//       _timer = Timer.periodic(Duration(milliseconds: 1), (timer) async {
//         Duration? duration = await _videoPlayerController!.position;
//         if (duration == null) return;
//         _sliderCurrentPosition = duration.inMilliseconds.toDouble();
//         if (_sliderCurrentPosition >= _maxDuration) {
//           _onStopPlay();
//         } else {
//           if (mounted) setState(() {});
//         }
//       });
//     } on Exception catch (err) {
//       print('error: $err');
//     }
//     if (mounted) setState(() {});
//   }

//   Future<void> _onStopPlay() async {
//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized) return;
//     if (_timer != null) _timer!.cancel();
//     _videoPlayerController!.seekTo(Duration(milliseconds: 0));
//     await _videoPlayerController!.pause();
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String responsiveStyle = "";
//     if (MediaQuery.of(context).size.width >=
//         ResponsiveDesignSettings.tableteMaxWidth) {
//       responsiveStyle = "desktop";
//     } else if (MediaQuery.of(context).size.width >=
//             ResponsiveDesignSettings.mobileMaxWidth &&
//         MediaQuery.of(context).size.width <
//             ResponsiveDesignSettings.tableteMaxWidth) {
//       responsiveStyle = "tablet";
//     } else if (MediaQuery.of(context).size.width <
//         ResponsiveDesignSettings.mobileMaxWidth) {
//       responsiveStyle = "mobile";
//     }

//     double iconSize = heightDp * 20;
//     // double iconPadding = widthDp * 10;
//     // TextStyle? textStyle = Theme.of(context).textTheme.overline;

//     if (responsiveStyle != "mobile") {
//       iconSize = heightDp * 35;
//       // iconPadding = widthDp * 20;
//       // textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
//     }

//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized) {
//       return Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         direction: ShimmerDirection.ltr,
//         enabled: true,
//         period: Duration(milliseconds: 1000),
//         child: Container(
//           width: (MediaQuery.of(context).size.width - widthDp * 20),
//           height: heightDp * 200,
//           margin: EdgeInsets.symmetric(vertical: heightDp * 5),
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(heightDp * 0),
//           ),
//         ),
//       );
//     }

//     var maxTime =
//         DateTime.fromMillisecondsSinceEpoch(_maxDuration.toInt(), isUtc: true);
//     var maxTimeString = DateFormat('mm:ss').format(maxTime);
// /*     var currentTime = DateTime.fromMillisecondsSinceEpoch(
//         _sliderCurrentPosition.toInt(),
//         isUtc: true); */
//     // var currentTimeString = DateFormat('mm:ss').format(currentTime);

//     if (widget.isUploading!) {
//       if (uploadTimer != null) uploadTimer!.cancel();
//       uploadTimer = Timer.periodic(Duration(milliseconds: 10), (uploadTimer) {
//         angle += 10;
//         setState(() {});
//       });
//     } else {
//       angle = 0;
//     }

//     return Consumer<MediaPlayProvider>(
//         builder: (context, mediaPlayProvider, _) {
//       int quarterTurns = 0;
//       if (info!.orientation == 0 && Platform.isAndroid) {
//         quarterTurns = 2;
//       }
//       return GestureDetector(
//         onTap: () {
//           if (widget.tapHandler != null) {
//             widget.tapHandler!();
//           }
//         },
//         onLongPress: () {
//           if (widget.longPressHandler != null) {
//             widget.longPressHandler!();
//           }
//         },
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: heightDp * 5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(heightDp * 0),
//             border: Border.all(
//               color: widget.isSelected! ? AppColors.yello : Colors.transparent,
//               width: widget.isSelected! ? 3 : 0,
//             ),
//           ),
//           child: Stack(
//             children: [
//               Container(
//                 width: (MediaQuery.of(context).size.width - widthDp * 20),
//                 height: _videoPlayerController!.value.aspectRatio < 1
//                     ? (MediaQuery.of(context).size.width - widthDp * 20) *
//                         _videoPlayerController!.value.aspectRatio
//                     : (MediaQuery.of(context).size.width - widthDp * 20) /
//                         _videoPlayerController!.value.aspectRatio,
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(heightDp * 0),
//                 ),
//                 child: Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(heightDp * 0),
//                     child: RotatedBox(
//                       quarterTurns: quarterTurns,
//                       child: AspectRatio(
//                         // aspectRatio: (MediaQuery.of(context).size.width - widthDp * 20) / heightDp * 200,
//                         aspectRatio: _videoPlayerController!.value.aspectRatio,
//                         child: VideoPlayer(_videoPlayerController!),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: heightDp * 5,
//                 right: 0,
//                 child: GestureDetector(
//                   onTap: () {
//                     MediaInfoDialog.show(
//                       context,
//                       mediaModel: widget.mediaModel,
//                       totalMediaCount: widget.totalMediaCount,
//                     );
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(heightDp * 5),
//                     color: Colors.transparent,
//                     child: Stack(
//                       children: [
//                         Icon(
//                           Icons.info_outline,
//                           size: iconSize,
//                           color: Colors.white,
//                         ),
//                         Icon(
//                           Icons.info,
//                           size: iconSize,
//                           color: AppColors.yello,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: heightDp * 5,
//                 child: Container(
//                   width: (MediaQuery.of(context).size.width - widthDp * 20),
//                   color: Colors.black.withOpacity(0.3),
//                   padding: EdgeInsets.symmetric(horizontal: widthDp * 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Stack(
//                         children: [
//                           Icon(
//                             widget.mediaModel!.state == "error"
//                                 ? Icons.report_problem_outlined
//                                 : widget.mediaModel!.state == "uploaded"
//                                     ? Icons.cloud_done_outlined
//                                     : Icons.cloud_off_outlined,
//                             size: iconSize,
//                             color: widget.mediaModel!.state == "error" ||
//                                     widget.mediaModel!.state == "uploaded"
//                                 ? Colors.white
//                                 : Colors.transparent,
//                           ),
//                           Icon(
//                             widget.mediaModel!.state == "error"
//                                 ? Icons.report_problem
//                                 : widget.mediaModel!.state == "uploaded"
//                                     ? Icons.cloud_done
//                                     : Icons.cloud_off,
//                             size: iconSize,
//                             color: widget.mediaModel!.state == "error"
//                                 ? AppColors.red
//                                 : widget.mediaModel!.state == "uploaded"
//                                     ? AppColors.green
//                                     : AppColors.red.withOpacity(0.6),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         "$maxTimeString",
//                         style: Theme.of(context)
//                             .textTheme
//                             .overline!
//                             .copyWith(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (!widget.isUploading!)
//                 Container(
//                   width: (MediaQuery.of(context).size.width - widthDp * 20),
//                   height: _videoPlayerController!.value.aspectRatio < 1
//                       ? (MediaQuery.of(context).size.width - widthDp * 20) *
//                           _videoPlayerController!.value.aspectRatio
//                       : (MediaQuery.of(context).size.width - widthDp * 20) /
//                           _videoPlayerController!.value.aspectRatio,
//                   child: GestureDetector(
//                     onTap: () {
//                       pushNewScreen(
//                         context,
//                         screen: VideoPlayFullScreen(
//                           mediaModel: widget.mediaModel!,
//                         ),
//                         withNavBar: false,
//                         pageTransitionAnimation: PageTransitionAnimation.fade,
//                       );
//                     },
//                     child: Center(
//                       child: Icon(Icons.play_arrow_rounded,
//                           size: heightDp * 100,
//                           color: Colors.white.withOpacity(0.8)),
//                     ),
//                   ),
//                 ),
//               if (widget.isUploading!)
//                 Container(
//                   width: (MediaQuery.of(context).size.width - widthDp * 20),
//                   height: _videoPlayerController!.value.aspectRatio < 1
//                       ? (MediaQuery.of(context).size.width - widthDp * 20) *
//                           _videoPlayerController!.value.aspectRatio
//                       : (MediaQuery.of(context).size.width - widthDp * 20) /
//                           _videoPlayerController!.value.aspectRatio,
//                   decoration:
//                       BoxDecoration(color: Colors.black.withOpacity(0.5)),
//                   child: Center(
//                     child: Transform.rotate(
//                       angle: angle / 180 * pi,
//                       child: Icon(Icons.autorenew,
//                           size: heightDp * 50, color: Colors.white),
//                     ),
//                   ),
//                 )
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

// class VideoPlayFullScreen extends StatefulWidget {
//   final MediaModel? mediaModel;

//   VideoPlayFullScreen({@required this.mediaModel});

//   @override
//   _VideoPlayFullScreenState createState() => _VideoPlayFullScreenState();
// }

// class _VideoPlayFullScreenState extends State<VideoPlayFullScreen> {
//   VideoPlayerController? _videoPlayerController;

//   Timer? _timer;

//   double _maxDuration = 1.0;
//   double _sliderCurrentPosition = 0.0;
//   // String _playerTxt = '00:00:00';

//   FlutterVideoInfo videoInfo = FlutterVideoInfo();
//   VideoData? info;

//   @override
//   void initState() {
//     super.initState();
//     _init();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//         statusBarColor: Colors.black,
//         statusBarIconBrightness: Brightness.light,
//         statusBarBrightness: Brightness.light, //status bar brigtness
//       ));
//     });
//   }

//   void _init() async {
//     info = await videoInfo.getVideoInfo(widget.mediaModel!.path!);

//     _videoPlayerController =
//         VideoPlayerController.file(File(widget.mediaModel!.path!))
//           ..initialize().then(
//             (_) {
//               WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//                 _maxDuration = _videoPlayerController!
//                     .value.duration.inMilliseconds
//                     .toDouble();
//                 if (_maxDuration <= 0) _maxDuration = 0.0;
//                 if (mounted) setState(() {});
//                 _onStartPlay();
//               });
//             },
//           ).onError((error, stackTrace) {
//             print(error);
//           });
//   }

//   @override
//   void dispose() {
//     _videoPlayerController!.dispose();
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: AppColors.primayColor,
//       statusBarIconBrightness: Brightness.light,
//       statusBarBrightness: Brightness.light, //status bar brigtness
//     ));

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double deviceWidth = 1.sw;
//     double deviceHeight = 1.sh;
//     double widthDp = ScreenUtil().setWidth(1);
//     double heightDp = ScreenUtil().setWidth(1);
//     // double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
//     double statusbarHeight = ScreenUtil().statusBarHeight;

//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized) {
//       return Center(child: CupertinoActivityIndicator());
//     }

//     var maxTime =
//         DateTime.fromMillisecondsSinceEpoch(_maxDuration.toInt(), isUtc: true);
//     var maxTimeString = DateFormat('mm:ss').format(maxTime);
//     var currentTime = DateTime.fromMillisecondsSinceEpoch(
//         _sliderCurrentPosition.toInt(),
//         isUtc: true);
//     var currentTimeString = DateFormat('mm:ss').format(currentTime);

//     return WillPopScope(
//       onWillPop: () async {
//         await _onStopPlay();
//         Navigator.of(context).pop();
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Container(
//           padding: EdgeInsets.only(top: statusbarHeight),
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(heightDp * 0),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 height: heightDp * 25,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.close,
//                           color: Colors.white, size: heightDp * 25),
//                       onPressed: () async {
//                         await _onStopPlay();
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: RotatedBox(
//                   quarterTurns:
//                       _videoPlayerController!.value.aspectRatio < 1 ? 0 : 1,
//                   child: Stack(
//                     children: [
//                       Center(
//                         child: RotatedBox(
//                           quarterTurns:
//                               info!.orientation == 0 && Platform.isAndroid
//                                   ? 2
//                                   : 0,
//                           child: AspectRatio(
//                             aspectRatio:
//                                 _videoPlayerController!.value.aspectRatio,
//                             child: VideoPlayer(_videoPlayerController!),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: heightDp * 0,
//                         child: Container(
//                           width: _videoPlayerController!.value.aspectRatio < 1
//                               ? deviceWidth
//                               : deviceHeight - statusbarHeight - heightDp * 25,
//                           padding:
//                               EdgeInsets.symmetric(horizontal: widthDp * 5),
//                           color: Colors.black.withOpacity(0.5),
//                           child: Row(
//                             children: [
//                               SizedBox(width: widthDp * 5),
//                               if (!_videoPlayerController!.value.isPlaying)
//                                 GestureDetector(
//                                   onTap: _onStartPlay,
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: widthDp * 3,
//                                         vertical: heightDp * 5),
//                                     child: Icon(Icons.play_arrow,
//                                         size: heightDp * 25,
//                                         color: Colors.white),
//                                   ),
//                                 ),
//                               if (_videoPlayerController!.value.isPlaying)
//                                 GestureDetector(
//                                   onTap: _onStopPlay,
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: widthDp * 5,
//                                         vertical: heightDp * 5),
//                                     child: Icon(Icons.stop,
//                                         size: heightDp * 25,
//                                         color: Colors.white),
//                                   ),
//                                 ),
//                               Expanded(
//                                 child: Container(
//                                   height: heightDp * 20,
//                                   child: Slider(
//                                     value: min(
//                                         _sliderCurrentPosition, _maxDuration),
//                                     min: 0.0,
//                                     max: _maxDuration,
//                                     activeColor: Colors.white,
//                                     inactiveColor: Colors.white,
//                                     onChanged: (value) async {
//                                       await _seekToPlayer(value.toInt());
//                                     },
//                                     divisions: _maxDuration == 0.0
//                                         ? 1
//                                         : _maxDuration.toInt(),
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 "$currentTimeString/$maxTimeString",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .overline!
//                                     .copyWith(color: Colors.white),
//                               ),
//                               SizedBox(width: widthDp * 5),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _onStartPlay() async {
//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized) return;
//     try {
//       await _videoPlayerController!.play();
//       _timer = Timer.periodic(Duration(milliseconds: 1), (timer) async {
//         Duration? duation = (await _videoPlayerController!.position);
//         if (duation == null) return;

//         _sliderCurrentPosition = duation.inMilliseconds.toDouble();
//         if (_sliderCurrentPosition >= _maxDuration) {
//           _onStopPlay();
//         } else {
//           if (mounted) setState(() {});
//         }
//       });
//     } catch (e) {}
//   }

//   Future<void> _seekToPlayer(int milliSecs) async {
//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized ||
//         _timer == null) return;
//     try {
//       await _videoPlayerController!.seekTo(Duration(milliseconds: milliSecs));
//       if (_timer != null) _timer!.cancel();
//       _timer = Timer.periodic(Duration(milliseconds: 1), (timer) async {
//         Duration? duration = await _videoPlayerController!.position;
//         if (duration == null) return;
//         _sliderCurrentPosition = duration.inMilliseconds.toDouble();
//         if (_sliderCurrentPosition >= _maxDuration) {
//           _onStopPlay();
//         } else {
//           if (mounted) setState(() {});
//         }
//       });
//     } on Exception catch (err) {
//       print('error: $err');
//     }
//     if (mounted) setState(() {});
//   }

//   Future<void> _onStopPlay() async {
//     if (_videoPlayerController == null ||
//         !_videoPlayerController!.value.isInitialized) return;
//     if (!_videoPlayerController!.value.isPlaying) return;

//     if (_timer != null) _timer!.cancel();
//     await _videoPlayerController!.pause();
//     if (mounted) setState(() {});
//   }
// }
