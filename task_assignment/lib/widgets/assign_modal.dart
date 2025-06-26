// widgets/share_user_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/task_view_model.dart';

class ShareUserModal extends StatefulWidget {
  final String taskId;
  const ShareUserModal({required this.taskId, super.key});

  @override
  State<ShareUserModal> createState() => _ShareUserModalState();
}

class _ShareUserModalState extends State<ShareUserModal> {
  final TextEditingController _emailC = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final email = _emailC.text.trim();
    if (email.isEmpty) {
      setState(() => _error = "Email can't be empty");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vm = Provider.of<TaskViewModel>(context, listen: false);
      await vm.shareWithUserEmail(widget.taskId, email);
      if (mounted) Navigator.pop(context); // Close modal on success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User assigned successfully")),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Share Task with User",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailC,
              decoration: InputDecoration(
                labelText: "User Email",
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _share,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Share"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
