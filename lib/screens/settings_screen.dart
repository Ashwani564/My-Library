import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../models/reading_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Bookerly',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Display'),
              _buildSettingTile(
                title: 'Show Estimated Reading Time',
                subtitle: 'Display time estimates for chapters and book',
                trailing: Switch(
                  value: settings.showEstimatedReadingTime,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateEstimatedReadingTimeVisibility(value),
                    );
                  },
                  activeColor: Colors.white,
                ),
              ),
              _buildSettingTile(
                title: 'Show Reading Timer',
                subtitle: 'Display current reading session timer',
                trailing: Switch(
                  value: settings.showReadingTimer,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateReadingTimerVisibility(value),
                    );
                  },
                  activeColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Text'),
              _buildSliderTile(
                title: 'Font Size',
                value: settings.fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 12,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(UpdateFontSize(value));
                },
                valueLabel: '${settings.fontSize.toInt()}pt',
              ),
              _buildSliderTile(
                title: 'Line Height',
                value: settings.lineHeight,
                min: 1.0,
                max: 2.0,
                divisions: 10,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(UpdateLineHeight(value));
                },
                valueLabel: '${settings.lineHeight.toStringAsFixed(1)}x',
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Reading'),
              _buildSliderTile(
                title: 'Words Per Minute',
                subtitle: 'Used for calculating estimated reading time',
                value: settings.wordsPerMinute.toDouble(),
                min: 100.0,
                max: 400.0,
                divisions: 30,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(UpdateWordsPerMinute(value.toInt()));
                },
                valueLabel: '${settings.wordsPerMinute} wpm',
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('About'),
              _buildInfoTile(
                title: 'Font',
                subtitle: 'Bookerly (Amazon Kindle font)',
              ),
              _buildInfoTile(
                title: 'Background',
                subtitle: 'Pure black for OLED displays',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Bookerly',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Bookerly',
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Bookerly',
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    String? subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Bookerly',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  valueLabel,
                  style: TextStyle(
                    fontFamily: 'Bookerly',
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Bookerly',
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: Colors.white,
              inactiveColor: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Bookerly',
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Bookerly',
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
