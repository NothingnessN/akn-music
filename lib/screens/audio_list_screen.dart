import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/option_modal.dart';
import '../widgets/screen.dart';
import '../widgets/audio_list_item.dart';
import 'dart:io';
import 'package:akn_music/l10n/app_localizations.dart';

class AudioListScreen extends StatelessWidget {
  const AudioListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final audioController = Provider.of<AudioController>(context);
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Screen(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.all_audios,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/theme'),
                        icon: Icon(
                          Icons.color_lens,
                          color: theme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: audioProvider.audioFiles.length,
                  itemBuilder: (context, index) {
                    final audio = audioProvider.audioFiles[index];
                    return AudioListItem(
                      audio: audio,
                      onTap: () async {
                        audioProvider.resetPlaybackState();
                        audioProvider.updateState(
                          currentAudioIndex: index,
                          isPlaying: true,
                        );
                        await audioController.play(audio.uri);
                      },
                      onMoreTap: () => _showOptionsModal(audio, context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsModal(AudioFile audio, BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.playlist_add, color: theme.textColor),
              title: Text(
                localizations.add_to_playlist,
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPlaylistModal(audio, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistModal(AudioFile audio, BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.add_to_playlist,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            ...audioProvider.playlists.map((playlist) => ListTile(
              title: Text(
                playlist['title'],
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () {
                audioProvider.addAudioToPlaylist(playlist['id'], audio);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.added_to_playlist(audio.filename, playlist['title'])
                    ),
                    backgroundColor: theme.accentColor,
                  ),
                );
              },
            )).toList(),
          ],
        ),
      ),
    );
  }
}