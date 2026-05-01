import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/recognition_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecognitionProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Ambient Glow
              _buildAmbientGlow(),

              // Header
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'WhoSingsThis',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ).animate().scaleX(duration: 1000.ms, curve: Curves.easeOut),
                    ],
                  ),
                ),
              ),

              // Main Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusText(provider),
                    const SizedBox(height: 50),
                    _buildListenButton(context, provider),
                    const SizedBox(height: 50),
                    if (provider.isRecording)
                       _buildWaveform().animate().fadeIn(),
                  ],
                ),
              ),

              // Results Card
              if (provider.result != null)
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: _buildResultCard(context, provider),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientGlow() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1,1), end: const Offset(1.5, 1.5), duration: 4000.ms),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          width: 4,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scaleY(
           begin: 0.5, 
           end: 1.5 + (index % 3) * 0.5, 
           duration: (400 + index * 100).ms,
           curve: Curves.easeInOut,
         );
      }),
    );
  }

  Widget _buildListenButton(BuildContext context, RecognitionProvider provider) {
    return GestureDetector(
      onTap: provider.isRecording ? null : () => provider.startListening(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Rings
          if (provider.isRecording)
            ...List.generate(2, (index) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(2.2, 2.2),
                    duration: 2500.ms,
                    delay: (index * 1200).ms,
                  )
                  .fadeOut();
            }),

          // Central Button
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF3F37C9)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              provider.isRecording ? Icons.mic : Icons.music_note,
              size: 70,
              color: Colors.white,
            ),
          ).animate(target: provider.isRecording ? 1 : 0)
           .shimmer(duration: 2000.ms, color: Colors.white30),
        ],
      ),
    );
  }

  Widget _buildStatusText(RecognitionProvider provider) {
    String text = 'Tap to Listen';
    if (provider.status == 'recording') text = 'Listening...';
    if (provider.status == 'processing') text = 'Identifying...';
    if (provider.status == 'success') text = 'Found it!';
    if (provider.status == 'error') {
      if (provider.result != null && provider.result!['error_detail'] != null) {
        text = provider.result!['error_detail'];
      } else {
        text = provider.result == null ? 'Song not found' : 'Try again later';
      }
    }

    return Column(
      children: [
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 4,
          ),
        ).animate(key: ValueKey(text)).fadeIn().slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, RecognitionProvider provider) {
    final result = provider.result!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.album, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'] ?? 'Unknown Track',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  result['artist'] ?? 'Unknown Artist',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text('PLAY ON SPOTIFY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOutBack).fadeIn();
  }
}
