import 'dart:io';
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Ambient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E1E2E),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),

          // Background Ambient Glow
          _buildAmbientGlow(),

          // Discreet Exit Button (Top Right)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white24, size: 24),
              onPressed: () => exit(0),
              tooltip: 'Close App',
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'WhoSingsThis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const Spacer(),
                  
                  _buildStatusText(provider),
                  const SizedBox(height: 50),
                  _buildListenButton(context, provider),
                  const SizedBox(height: 50),
                  if (provider.isRecording)
                    _buildWaveform().animate().fadeIn(),
                  
                  const Spacer(),
                  
                  // Results Card
                  if (provider.result != null)
                    _buildResultCard(context, provider),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
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
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 2,
          ),
        ).animate(key: ValueKey(text)).fadeIn().slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, RecognitionProvider provider) {
    final result = provider.result!;
    if (result['error_detail'] != null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.album, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'] ?? 'Unknown Track',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  result['artist'] ?? 'Unknown Artist',
                  style: const TextStyle(fontSize: 14, color: Colors.white60),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('PLAY ON SPOTIFY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
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
