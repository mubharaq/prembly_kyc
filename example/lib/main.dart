import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prembly_kyc/prembly_kyc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Prembly KYC Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  String? _result;
  PremblyResponse? _lastResponse;

  Future<void> _startVerification() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      setState(() {
        _result = 'Camera permission required';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _result = null;
    });
    if (mounted) {
      await PremblyKyc(
        config: const PremblyConfig(
          // Replace with your actual keys
          widgetKey: 'wdgt_xxxxxxx',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          widgetId: 'widgetid_xxxxxxx',
        ),
        onSuccess: (response) {
          setState(() {
            _result =
                'Verification successful!\n\n'
                'Channel: ${response.channel}\n'
                'Message: ${response.message}';
            _lastResponse = response;
          });
        },
        onError: (error) {
          setState(() {
            if (error.isCancelled) {
              _result = 'Verification cancelled by user';
            } else if (error.isPermissionError) {
              _result = 'Camera permission required\n\n${error.message}';
            } else {
              _result =
                  'Verification failed\n\n'
                  'Error: ${error.message}\n'
                  'Code: ${error.code ?? "N/A"}';
            }
          });
        },
        onClose: () {
          setState(() {
            _isLoading = false;
          });
        },
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              'Complete your KYC verification using Prembly IdentityPass',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _isLoading ? null : _startVerification,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(_isLoading ? 'Verifying...' : 'Start Verification'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Result',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_lastResponse?.data != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Verification Data'),
                              content: SingleChildScrollView(
                                child: Text(_lastResponse!.data.toString()),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('View Full Data'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
