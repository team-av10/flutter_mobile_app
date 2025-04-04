import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';

class SshTerminalPage extends StatefulWidget {
  const SshTerminalPage({super.key});

  @override
  _SshTerminalPageState createState() => _SshTerminalPageState();
}

class _SshTerminalPageState extends State<SshTerminalPage> {
  SSHClient? _client;
  SSHSession? _session;
  TextEditingController _commandController = TextEditingController();
  String _output = "Press connect to establish SSH connection.";
  bool _isConnected = false;

  /// Connects to SSH and starts an interactive bash session
  Future<void> _connectSSH() async {
    try {
      final socket = await SSHSocket.connect('192.168.1.102', 22);
      _client = SSHClient(
        socket,
        username: 'av10',
        onPasswordRequest: () => 'harappo', // Use password authentication
      );

      // Start an interactive shell session
      _session = await _client!.execute('bash -l'); // Starts a persistent shell

      setState(() {
        _output = "Connected to SSH Server\n";
        _isConnected = true;
      });

      // Listen for real-time SSH output
    _session!.stdout.transform(StreamTransformer.fromHandlers(
  handleData: (Uint8List data, EventSink<String> sink) {
    sink.add(utf8.decode(data));
  },
)).listen((data) {
  setState(() {
    _output += data;
  });
});

    } catch (e) {
      setState(() {
        _output = "Connection Error: $e";
      });
    }
  }

  /// Sends a command to the interactive shell session
  Future<void> _sendCommand() async {
    if (_session == null || !_isConnected) return;

    try {
      String command = _commandController.text.trim();
      if (command.isEmpty) return;

      _session!.write('$command\n' as Uint8List); // Send command to SSH shell

      setState(() {
        _output += "\n\$ $command\n"; // Display command in UI
      });

      _commandController.clear();
    } catch (e) {
      setState(() {
        _output += "\nError: $e";
      });
    }
  }

  @override
  void dispose() {
    _session?.close();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SSH Terminal")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Text(
                _output,
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    decoration: InputDecoration(
                      hintText: "Enter command",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendCommand,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.wifi, color: Colors.white),
                    onPressed: _connectSSH,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
