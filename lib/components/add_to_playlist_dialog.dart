import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echobeat/models/track.dart';
import 'package:echobeat/providers/library_provider.dart';
import 'package:echobeat/theme.dart';

class AddToPlaylistDialog extends StatefulWidget {
  final Track track;

  const AddToPlaylistDialog({super.key, required this.track});

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  final _controller = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add to Playlist',
              style: context.textStyles.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isCreating) ...[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Playlist Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                autofocus: true,
                onSubmitted: (value) => _createAndAdd(context, libraryProvider),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isCreating = false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => _createAndAdd(context, libraryProvider),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ] else ...[
              Flexible(
                child: libraryProvider.playlists.isEmpty
                    ? Center(
                        child: Text(
                          'No playlists yet',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: libraryProvider.playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = libraryProvider.playlists[index];
                          return ListTile(
                            leading: const Icon(Icons.queue_music),
                            title: Text(playlist.name),
                            subtitle: Text('${playlist.trackIds.length} tracks'),
                            onTap: () async {
                              await libraryProvider.addTrackToPlaylist(
                                playlist.id,
                                widget.track,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to ${playlist.name}'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => setState(() => _isCreating = true),
                icon: const Icon(Icons.add),
                label: const Text('Create New Playlist'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _createAndAdd(BuildContext context, LibraryProvider provider) async {
    if (_controller.text.trim().isEmpty) return;
    
    await provider.createPlaylist(_controller.text.trim());
    final newPlaylist = provider.playlists.last;
    await provider.addTrackToPlaylist(newPlaylist.id, widget.track);
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to ${newPlaylist.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
