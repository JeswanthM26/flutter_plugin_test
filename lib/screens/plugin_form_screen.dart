import 'dart:async';

import 'package:flutter/material.dart';
import 'package:apz_utils/apz_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../models/plugin_metadata.dart';
import '../widgets/dynamic_form.dart';
import '../services/plugin_launcher.dart';
import 'result_screen.dart';

class PluginFormScreen extends StatefulWidget {
  final PluginMetadata plugin;

  const PluginFormScreen({super.key, required this.plugin});

  @override
  State<PluginFormScreen> createState() => _PluginFormScreenState();
}

class _PluginFormScreenState extends State<PluginFormScreen> {
  Map<String, dynamic> formData = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize form data with default values
    for (final field in widget.plugin.fields) {
      if (field.defaultValue != null) {
        formData[field.key] = field.defaultValue;
      }
    }
  }
void onGenerate() async {
    // Validate required fields
    final missingFields = <String>[];
    final visibleFields = widget.plugin.fields.where((field) {
      if (field.dependsOn == null) {
        return true;
      }
      final dependencyKey = field.dependsOn!['key'];
      final dependencyValue = field.dependsOn!['value'];
      return formData[dependencyKey] == dependencyValue;
    }).toList();

    for (final field in visibleFields) {
      if (field.isRequired) {
        // Get the current value, fallback to default value if not set
        final currentValue = formData[field.key] ?? field.defaultValue;
        
        // Check if the value is null, empty string, or empty list
        bool isEmpty = false;
        if (currentValue == null) {
          isEmpty = true;
        } else if (currentValue is String && currentValue.trim().isEmpty) {
          isEmpty = true;
        } else if (currentValue is List && currentValue.isEmpty) {
          isEmpty = true;
        } else if (currentValue is Map && currentValue.isEmpty) {
          isEmpty = true;
        }
        
        if (isEmpty) {
          missingFields.add(field.label);
        }
      }
    }

    if (missingFields.isNotEmpty) {
      setState(() {
        _errorMessage = 'Please fill in required fields: ${missingFields.join(', ')}';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final stopwatch = Stopwatch()..start();
    final logger = Provider.of<APZLoggerProvider>(context, listen: false);

    try {
      // Merge form data with default values for any missing fields
      final completeFormData = Map<String, dynamic>.from(formData);
      for (final field in widget.plugin.fields) {
        if (!completeFormData.containsKey(field.key) && field.defaultValue != null) {
          completeFormData[field.key] = field.defaultValue;
        }
      }
      
      final result = await PluginLauncher.launch(widget.plugin, completeFormData, context, logger);
      stopwatch.stop();
      
      if (!mounted) return;

      if (result is Map<String, dynamic> && result.containsKey('widget')) {
        final widgetToShow = result['widget'] as Widget;
        final completer = result['completer'] as Completer<Map<String, dynamic>>?;
        
        if (completer != null) {
          final futureResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(widget.plugin.name)),
                body: widgetToShow,
              ),
            ),
          );
          
          final completedResult = await completer.future;

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                plugin: widget.plugin,
                result: completedResult,
                executionTime: stopwatch.elapsed,
              ),
            ),
          );

        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(widget.plugin.name)),
                body: widgetToShow,
              ),
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              plugin: widget.plugin,
              result: result,
              executionTime: stopwatch.elapsed,
            ),
          ),
        );
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      logger.error('[PluginForm] Error launching plugin: $e', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plugin.name.replaceAll('_', ' ').toUpperCase()),
        elevation: 0,
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)],
          ),
        ),
        child: Column(
          children: [
            // Header with plugin info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getPluginIcon(widget.plugin.name),
                    size: 48,
                    color: _getPluginColor(widget.plugin.name),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.plugin.name.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.plugin.fields.length} configuration field${widget.plugin.fields.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('pluginForm_iconButton_closeError'),
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _errorMessage = null),
                      color: Colors.red[600],
                    ),
                  ],
                ),
              ),
            
            // Form content
            Expanded(
              child: widget.plugin.fields.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: DynamicForm(
                          fields: widget.plugin.fields,
                          formData: formData,
                          onChanged: (data) => formData = data,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Configuration Required',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This plugin can be executed directly without any parameters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Generate button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.play_arrow, size: 24),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Generate & Test',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  key: const ValueKey('pluginForm_button_generateAndTest'),
                  onPressed: _isLoading ? null : onGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPluginColor(widget.plugin.name),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPluginIcon(String pluginName) {
    switch (pluginName.toLowerCase()) {
      case 'camera':
        return Icons.camera_alt;
      case 'contact':
      case 'contact_picker':
        return Icons.contacts;
      case 'date_picker':
      case 'custom_datepicker':
        return Icons.calendar_today;
      case 'device_info':
        return Icons.device_hub;
      case 'gps':
        return Icons.location_on;
      case 'in_app_review':
        return Icons.star_rate;
      case 'inapp_update':
        return Icons.system_update;
      case 'network_state':
      case 'network_state_perm':
        return Icons.wifi;
      case 'notification':
        return Icons.notifications;
      case 'pdf_viewer':
        return Icons.picture_as_pdf;
      case 'photopicker':
        return Icons.photo_library;
      case 'qr':
        return Icons.qr_code;
      case 'screenshot':
        return Icons.screenshot;
      case 'send_sms':
        return Icons.sms;
      case 'app_switch':
        return Icons.swap_horiz;
      case 'biometric':
        return Icons.fingerprint;
      case 'deeplink':
        return Icons.link;
      case 'device_fingerprint':
        return Icons.security;
      case 'digi_scan_image':
      case 'digi_scan_pdf':
        return Icons.document_scanner;
      case 'file_operations':
        return Icons.folder_open;
      case 'apz_peripherals':
        return Icons.devices;
      case 'apz_screen_security':
        return Icons.screen_lock_portrait;
      case 'apz_share':
        return Icons.share;
      case 'apz_webview':
        return Icons.web;
      case 'apz_idle_timeout':
        return Icons.timer;
      case 'jailbreak_root_detection':
        return Icons.security;
      case 'apz_universal_linking':
        return Icons.link;
      case 'apz_crypto':
        return Icons.vpn_key;
      case 'apz_auto_read_otp':
        return Icons.sms;
      case 'apz_speech_to_text':
        return Icons.mic;
      case 'apz_text_to_speech':
        return Icons.volume_up;
      case 'apz_audioplayer':
        return Icons.audiotrack;
      case 'apz_charts':
        return Icons.bar_chart;
      case 'apz_app_shortcuts':
        return Icons.app_shortcut;
      case 'apz_call_state':
        return Icons.call;

      default:
        return Icons.extension;
    }
  }

  Color _getPluginColor(String pluginName) {
    switch (pluginName.toLowerCase()) {
      case 'camera':
      case 'photopicker':
        return Colors.blue;
      case 'contact':
      case 'contact_picker':
        return Colors.green;
      case 'date_picker':
      case 'custom_datepicker':
        return Colors.orange;
      case 'device_info':
      case 'device_fingerprint':
        return Colors.purple;
      case 'gps':
        return Colors.red;
      case 'in_app_review':
        return Colors.amber;
      case 'inapp_update':
        return Colors.teal;
      case 'network_state':
      case 'network_state_perm':
        return Colors.indigo;
      case 'notification':
        return Colors.pink;
      case 'pdf_viewer':
        return Colors.brown;
      case 'qr':
        return Colors.cyan;
      case 'screenshot':
        return Colors.grey;
      case 'send_sms':
        return Colors.lightGreen;
      case 'app_switch':
        return Colors.deepPurple;
      case 'biometric':
        return Colors.deepOrange;
      case 'deeplink':
        return Colors.lightBlue;
      case 'digi_scan_image':
      case 'digi_scan_pdf':
        return Colors.blueGrey;
      case 'file_operations':
        return Colors.lime;
      case 'apz_peripherals':
        return Colors.indigo;
      case 'apz_screen_security':
        return Colors.red;
      case 'apz_share':
        return Colors.green;
      case 'apz_webview':
        return Colors.blue;
      case 'apz_idle_timeout':
        return Colors.orange;
      case 'jailbreak_root_detection':
        return Colors.red;
      case 'apz_universal_linking':
        return Colors.blue;
      case 'apz_crypto':
        return Colors.teal;
      case 'apz_auto_read_otp':
        return Colors.lightBlue;
      case 'apz_speech_to_text':
        return Colors.red;
      case 'apz_text_to_speech':
        return Colors.blue;
      case 'apz_audioplayer':
        return Colors.orange;
      case 'apz_charts':
        return Colors.green;
      case 'apz_app_shortcuts':
        return Colors.deepPurpleAccent;
      case 'apz_call_state':
        return Colors.blueAccent;  
      default:
        return Colors.grey;
    }
  }
}
