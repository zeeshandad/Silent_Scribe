import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transcription_entry.dart';
import '../repository/transcription_repository.dart';
import '../services/llm_service.dart';
import '../services/sharing_service.dart';

class TranscriptionDetailScreen extends StatefulWidget {
  final TranscriptionEntry entry;

  const TranscriptionDetailScreen({super.key, required this.entry});

  @override
  State<TranscriptionDetailScreen> createState() => _TranscriptionDetailScreenState();
}

class _TranscriptionDetailScreenState extends State<TranscriptionDetailScreen> {
  late TextEditingController _formattedTextController;
  final TranscriptionRepository _repository = TranscriptionRepository();
  final LLMService _llmService = LLMService();
  bool _isSaving = false;
  bool _isReProcessing = false;
  String _selectedFormat = 'Polished Writing';
  
  final List<String> _formats = [
    'Polished Writing',
    'Meeting Minutes',
    'Executive Summary',
    'Email Draft',
    'Bullet Points',
  ];

  @override
  void initState() {
    super.initState();
    _formattedTextController = TextEditingController(text: widget.entry.formattedText);
    _selectedFormat = widget.entry.selectedStyle;
  }

  @override
  void dispose() {
    _formattedTextController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    widget.entry.formattedText = _formattedTextController.text;
    widget.entry.selectedStyle = _selectedFormat;
    await _repository.saveEntry(widget.entry);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved')),
      );
    }
  }

  Future<void> _reProcess() async {
    setState(() {
      _isReProcessing = true;
      _formattedTextController.text = 'Re-processing with $_selectedFormat...';
    });

    try {
      String newText = '';
      await for (final token in _llmService.generateFormattedTextStream(widget.entry.rawTranscript, _selectedFormat)) {
        newText += token;
        if (mounted) {
          setState(() {
            _formattedTextController.text = newText;
          });
        }
      }
      // Save automatically after re-processing
      await _saveChanges();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error re-processing: $e')),
        );
      }
    } finally {
      await _llmService.unloadModel();
      if (mounted) {
        setState(() => _isReProcessing = false);
      }
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Share as Plain Text'),
              onTap: () {
                Navigator.pop(context);
                SharingService.shareAsPlainText(_formattedTextController.text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Share as PDF Report'),
              onTap: () {
                Navigator.pop(context);
                SharingService.shareAsPdf('SilentScribe - ${widget.entry.selectedStyle}', _formattedTextController.text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Share as Quote Card'),
              onTap: () {
                Navigator.pop(context);
                SharingService.shareAsImage(context, _formattedTextController.text, widget.entry.selectedStyle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to Clipboard'),
              onTap: () {
                Navigator.pop(context);
                SharingService.copyToClipboard(context, _formattedTextController.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(widget.entry.timestamp);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit Transcription'),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveChanges,
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _showShareOptions,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'Formatted'),
                Tab(text: 'Original'),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Formatted View (Editable)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedFormat,
                                    items: _formats.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                                    onChanged: _isReProcessing ? null : (val) {
                                      if (val != null) setState(() => _selectedFormat = val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _isReProcessing ? null : _reProcess,
                              icon: _isReProcessing 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : Icon(_formattedTextController.text.isEmpty ? Icons.auto_awesome : Icons.refresh),
                              label: Text(_isReProcessing 
                                ? 'Processing...' 
                                : (_formattedTextController.text.isEmpty ? 'Format with AI' : 'Re-process')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Stack(
                            children: [
                              TextField(
                                controller: _formattedTextController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'LLM generated text will appear here...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceContainer,
                                ),
                                style: const TextStyle(fontSize: 16, height: 1.5),
                              ),
                              if (_formattedTextController.text.isEmpty && !_isReProcessing)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 48,
                                        color: theme.colorScheme.primary.withOpacity(0.2),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No formatted text yet',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Select a style and tap "Format with AI"',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Original View (Read-only)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recorded on $dateStr',
                            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.entry.rawTranscript,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
