import 'package:flutter/material.dart';
import 'package:maiden/model.dart';
import 'package:maiden/settings.dart';

class ModelSelectionScreen extends StatefulWidget {
  @override
  _ModelSelectionScreenState createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen> {
  final AppSettingsService _settings = AppSettingsService();
  late TextEditingController _temperatureController;
  late TextEditingController _maxTokensController;
  late TextEditingController _topPController;
  late TextEditingController _topKController;
  late TextEditingController _contextLengthController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSavedSettings();
  }

  void _initializeControllers() {
    _temperatureController = TextEditingController(text: '0.7');
    _maxTokensController = TextEditingController(text: '2048');
    _topPController = TextEditingController(text: '0.9');
    _topKController = TextEditingController(text: '40');
    _contextLengthController = TextEditingController(text: '4096');
  }

  Future<void> _loadSavedSettings() async {
    final settings = _settings.getModelSettings();
    if (settings != null) {
      setState(() {
        _temperatureController.text = settings.temperature.toString();
        _maxTokensController.text = settings.maxTokens.toString();
        _topPController.text = settings.topP.toString();
        _topKController.text = settings.topK.toString();
        _contextLengthController.text = settings.contextLength.toString();
        
        // Update the selected model in your state management
        context.read<ModelProvider>().setModel(settings.modelId);
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final modelId = context.read<ModelProvider>().currentModel.id;
      
      await _settings.saveModelSettings(
        modelId: modelId,
        temperature: double.parse(_temperatureController.text),
        maxTokens: int.parse(_maxTokensController.text),
        topP: double.parse(_topPController.text),
        topK: int.parse(_topKController.text),
        contextLength: int.parse(_contextLengthController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ModelSelector(
            onModelSelected: (Model model) async {
              context.read<ModelProvider>().setModel(model.id);
              await _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          _buildParameterInput(
            controller: _temperatureController,
            label: 'Temperature',
            hint: '0.0 - 1.0',
          ),
          _buildParameterInput(
            controller: _maxTokensController,
            label: 'Max Tokens',
            hint: 'Enter max tokens',
            keyboardType: TextInputType.number,
          ),
          _buildParameterInput(
            controller: _topPController,
            label: 'Top P',
            hint: '0.0 - 1.0',
          ),
          _buildParameterInput(
            controller: _topKController,
            label: 'Top K',
            hint: 'Enter top K value',
            keyboardType: TextInputType.number,
          ),
          _buildParameterInput(
            controller: _contextLengthController,
            label: 'Context Length',
            hint: 'Enter context length',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildParameterInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => _saveSettings(),
      ),
    );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _maxTokensController.dispose();
    _topPController.dispose();
    _topKController.dispose();
    _contextLengthController.dispose();
    super.dispose();
  }
}
