import 'package:flutter/material.dart';



class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRecording = false;
  final List<String> _attachedPhotos = []; // Placeholder for photo paths/URIs

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // TODO: Integrate actual audio recording package (e.g., record, flutter_sound)
  }

  void _addPhoto() {
    // Simulated photo attachment
    setState(() {
      _attachedPhotos.add('photo_${_attachedPhotos.length + 1}.jpg');
    });
    // TODO: Integrate image_picker package for real gallery/camera capture
  }

  void _removePhoto(int index) {
    setState(() {
      _attachedPhotos.removeAt(index);
    });
  }

  void _sendEmergencyAlert() {
    final message = _messageController.text;
    // TODO: Implement emergency broadcast logic (API call, SMS, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Emergency Alert Sent Successfully!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMERGENCY ASSISTANCE'),
        backgroundColor: Colors.red.shade900,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use this screen only in case of emergency to alert contacts or services.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Text Message Section
            const Text(
              'Describe the Emergency:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your message or details here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 20),

            // 2. Vocal Record Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Voice Note:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.green : Colors.grey.shade800,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop Recording' : 'Record Audio'),
                ),
              ],
            ),
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(
                  color: Colors.redAccent,
                  backgroundColor: Colors.grey.shade800,
                ),
              ),
            const SizedBox(height: 20),

            // 3. Send Photos Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attach Photos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                OutlinedButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Add Photo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: _attachedPhotos.isEmpty
                  ? Center(
                      child: Text(
                        'No photos attached yet',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachedPhotos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade600),
                                ),
                                child: const Icon(Icons.image, size: 40, color: Colors.white54),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Spacer(),

            // Emergency SOS Send Button
            ElevatedButton(
              onPressed: _sendEmergencyAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SEND EMERGENCY SOS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}