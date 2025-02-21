import 'package:flutter/material.dart'; import 'package:speech_to_text/speech_to_text.dart' as stt; import 'package:flutter_tts/flutter_tts.dart'; import 'package:http/http.dart' as http; import 'dart:convert';

void main() { runApp(ChatbotApp()); }

class ChatbotApp extends StatelessWidget { @override Widget build(BuildContext context) { return MaterialApp( debugShowCheckedModeBanner: false, home: ChatScreen(), ); } }

class ChatScreen extends StatefulWidget { @override _ChatScreenState createState() => _ChatScreenState(); }

class _ChatScreenState extends State<ChatScreen> { stt.SpeechToText _speech; FlutterTts _tts; bool _isListening = false; String _text = ""; List<Map<String, String>> messages = [];

@override void initState() { super.initState(); _speech = stt.SpeechToText(); _tts = FlutterTts(); }

Future<String> getResponse(String query) async { final response = await http.post( Uri.parse('https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill'), headers: {'Authorization': 'Bearer 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'}, body: json.encode({'inputs': query}), ); if (response.statusCode == 200) { var data = json.decode(response.body); return data["generated_text"] ?? "I didn't understand that."; } else { return "Error fetching response."; } }

void _sendMessage(String message) async { setState(() { messages.add({"user": message}); });

String botResponse = await getResponse(message);
setState(() {
  messages.add({"bot": botResponse});
});
_tts.speak(botResponse);

}

void _startListening() async { bool available = await _speech.initialize(); if (available) { setState(() => _isListening = true); _speech.listen(onResult: (result) { setState(() => _text = result.recognizedWords); }); } }

void _stopListening() { _speech.stop(); setState(() { _isListening = false; if (_text.isNotEmpty) { _sendMessage(_text); } }); }

@override Widget build(BuildContext context) { return Scaffold( appBar: AppBar(title: Text('AI Chatbot')), body: Column( children: [ Expanded( child: ListView.builder( itemCount: messages.length, itemBuilder: (context, index) { var message = messages[index]; return ListTile( title: Text(message.keys.first == "user" ? "You" : "Bot"), subtitle: Text(message.values.first), ); }, ), ), Padding( padding: EdgeInsets.all(8.0), child: Row( children: [ Expanded( child: TextField( onSubmitted: _sendMessage, decoration: InputDecoration(labelText: 'Type a message...'), ), ), IconButton( icon: Icon(Icons.mic), onPressed: _isListening ? _stopListening : _startListening, ) ], ), ) ], ), ); } }

