import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'game_board_screen.dart';

class IntroVideoScreen extends StatefulWidget {
  final List<String> playerNames;
  const IntroVideoScreen({super.key, required this.playerNames});

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  late VideoPlayerController _controller;
  bool _isVideoEnded = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/jeopardy_intro.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          !_isVideoEnded) {
        setState(() {
          _isVideoEnded = true;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                GameBoardScreen(playerNames: widget.playerNames),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  void _skipVideo() {
    // Optionally allow users to skip the video
    if (!_isVideoEnded) {
      _controller.pause();
      setState(() {
        _isVideoEnded = true;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              GameBoardScreen(playerNames: widget.playerNames),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _skipVideo,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}
