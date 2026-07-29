// ignore_for_file: unawaited_futures

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart' show ShareResult, ShareResultStatus;
import 'package:daily_stanza/features/share_poem/data/service/share_plus_poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';

void main() {
  group('SharePlusPoemShareService', () {
    test('forwards text to ShareParams', () async {
      String? capturedText;
      final service = SharePlusPoemShareService(
        shareInvoker: (params) async {
          capturedText = params.text;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      await service.shareText(text: 'test text', subject: 'test subject');

      expect(capturedText, 'test text');
    });

    test('forwards subject to ShareParams', () async {
      String? capturedSubject;
      final service = SharePlusPoemShareService(
        shareInvoker: (params) async {
          capturedSubject = params.subject;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      await service.shareText(text: 'test text', subject: 'test subject');

      expect(capturedSubject, 'test subject');
    });

    test('forwards title to ShareParams using subject', () async {
      String? capturedTitle;
      final service = SharePlusPoemShareService(
        shareInvoker: (params) async {
          capturedTitle = params.title;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      await service.shareText(text: 'test text', subject: 'test subject');

      expect(capturedTitle, 'test subject');
    });

    test('forwards sharePositionOrigin to ShareParams', () async {
      Rect? capturedOrigin;
      final service = SharePlusPoemShareService(
        shareInvoker: (params) async {
          capturedOrigin = params.sharePositionOrigin;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      const origin = Rect.fromLTWH(10, 20, 40, 30);
      await service.shareText(
        text: 'test text',
        subject: 'test subject',
        sharePositionOrigin: origin,
      );

      expect(capturedOrigin, origin);
    });

    test('handles null origin', () async {
      Rect? capturedOrigin;
      final service = SharePlusPoemShareService(
        shareInvoker: (params) async {
          capturedOrigin = params.sharePositionOrigin;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      await service.shareText(text: 'test text', subject: 'test subject');

      expect(capturedOrigin, isNull);
    });

    test('success maps to completed', () async {
      final service = SharePlusPoemShareService(
        shareInvoker: (_) async =>
            const ShareResult('', ShareResultStatus.success),
      );

      final result = await service.shareText(
        text: 'test text',
        subject: 'test subject',
      );

      expect(result, PoemShareResult.completed);
    });

    test('dismissed maps to dismissed', () async {
      final service = SharePlusPoemShareService(
        shareInvoker: (_) async =>
            const ShareResult('', ShareResultStatus.dismissed),
      );

      final result = await service.shareText(
        text: 'test text',
        subject: 'test subject',
      );

      expect(result, PoemShareResult.dismissed);
    });

    test('unavailable maps to unavailable', () async {
      final service = SharePlusPoemShareService(
        shareInvoker: (_) async =>
            const ShareResult('', ShareResultStatus.unavailable),
      );

      final result = await service.shareText(
        text: 'test text',
        subject: 'test subject',
      );

      expect(result, PoemShareResult.unavailable);
    });

    test('thrown error propagates without exposing raw values', () async {
      final service = SharePlusPoemShareService(
        shareInvoker: (_) async => throw Exception('hidden'),
      );

      expect(
        () => service.shareText(text: 'test text', subject: 'test subject'),
        throwsException,
      );
    });
  });
}
