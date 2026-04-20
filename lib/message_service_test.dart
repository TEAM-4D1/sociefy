// Quick test to exercise MessageService (create this file and run `dart run` or integrate into your app)
import 'dart:async';
import 'package:sociefy/services/message_service.dart'; // adjust import path if needed

Future<void> main() async {
  final userId = 'user1';
  final svc = MessageService.instance;

  final sub = svc.userChannelsStream(userId).listen((channels) {
    print('User $userId channels: $channels');
  });

  await svc.joinSociety(userId, 'societyA');
  await Future.delayed(const Duration(milliseconds: 300));
  await svc.joinSociety(userId, 'societyB');
  await Future.delayed(const Duration(milliseconds: 300));
  await svc.leaveSociety(userId, 'societyA');
  await Future.delayed(const Duration(milliseconds: 300));

  await sub.cancel();
}
