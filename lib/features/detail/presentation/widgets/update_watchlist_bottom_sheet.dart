import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../data/models/anime_model.dart';
import '../../../../data/models/watchlist_model.dart';
import '../../../mylist/presentation/mylist_providers.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class UpdateWatchlistBottomSheet extends ConsumerStatefulWidget {
  final AnimeModel anime;

  const UpdateWatchlistBottomSheet({super.key, required this.anime});

  @override
  ConsumerState<UpdateWatchlistBottomSheet> createState() => _UpdateWatchlistBottomSheetState();
}

class _UpdateWatchlistBottomSheetState extends ConsumerState<UpdateWatchlistBottomSheet> {
  String _status = 'following';
  double _score = 0;
  final _episodesController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _episodesController.text = '0';
    // Ở bản nâng cấp, sẽ tìm dữ liệu cũ trong watchlistProvider để fill vào đây
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${AppLocalizations.get(currentLang, 'update_progress')} ${widget.anime.title}', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
              initialValue: _status,
                decoration: InputDecoration(labelText: AppLocalizations.get(currentLang, 'status_label'), border: const OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'watching', child: Text(AppLocalizations.get(currentLang, 'status_watching'))),
                  DropdownMenuItem(value: 'completed', child: Text(AppLocalizations.get(currentLang, 'status_completed'))),
                  DropdownMenuItem(value: 'following', child: Text(AppLocalizations.get(currentLang, 'status_plan'))),
                ],
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _episodesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppLocalizations.get(currentLang, 'episodes_watched_label'), border: const OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return AppLocalizations.get(currentLang, 'invalid_episodes');
                  final num = int.tryParse(val);
                  if (num == null || num < 0) return 'Số tập phải là số dương';
                  if (widget.anime.episodes != null && num > widget.anime.episodes!) {
                    return 'Không thể vượt quá tổng số tập (${widget.anime.episodes})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.get(currentLang, 'rating_label'), style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Center(
                child: RatingBar.builder(
                  initialRating: _score,
                  minRating: 1,
                  maxRating: 10,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 10,
                  itemSize: 28,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() => _score = rating);
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(currentLang, 'personal_note'),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_score == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn điểm đánh giá (từ 1 đến 10)')));
                      return;
                    }
                    
                    final watchItem = WatchlistModel(
                      malId: widget.anime.malId,
                      title: widget.anime.title,
                      posterUrl: widget.anime.imageUrl,
                      status: _status,
                      episodesTotal: widget.anime.episodes,
                      episodesWatched: int.parse(_episodesController.text),
                      scoreUser: _score,
                      addedAt: DateTime.now().toIso8601String(),
                      updatedAt: DateTime.now().toIso8601String(),
                    );
                    
                    ref.read(watchlistProvider.notifier).addOrUpdate(watchItem);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.get(currentLang, 'saved_success'))));
                  }
                },
                child: Text(AppLocalizations.get(currentLang, 'save_info'), style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
