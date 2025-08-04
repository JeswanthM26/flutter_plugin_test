import 'dart:async';
import "package:apz_idle_timeout/apz_idle_timeout.dart";
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApzIdleTimeout', () {
    late ApzIdleTimeout idleTimeout;
    late int callbackCount;

    setUp(() {
      idleTimeout = ApzIdleTimeout();
      callbackCount = 0;
    });

    tearDown(() {
      // Ensure we clean up observers and timers.
      idleTimeout.dispose();
    });

    test('invokes callback once after timeout', () {
      fakeAsync((async) {
        idleTimeout.start(() async {
          callbackCount++;
        }, timeout: const Duration(seconds: 1));

        // advance just before timeout → no callback yet
        async.elapse(const Duration(milliseconds: 999));
        expect(callbackCount, 0);

        // advance to timeout
        async.elapse(const Duration(milliseconds: 1));
        expect(callbackCount, 1);
      });
    });

    test('debounces rapid interactions and resets the idle timer', () {
      fakeAsync((async) {
        idleTimeout.start(() async {
          callbackCount++;
        }, timeout: const Duration(seconds: 2));

        // simulate a pointer event at t=1s
        async.elapse(const Duration(seconds: 1));
        GestureBinding.instance.pointerRouter.addGlobalRoute(
          (_) {},
        ); // ensure router is non-null
        // manually call the global handler:
        idleTimeout.debounceUserInteraction();
        // before debounce period ends, elapse 499ms
        async.elapse(const Duration(milliseconds: 499));
        // no timer restart yet, so total elapsed < 2s → no callback
        expect(callbackCount, 0);

        // elapse the remaining debounce
        async.elapse(const Duration(milliseconds: 1));
        // this restarts the idle timer from now (t ≈1s+500ms)
        // advance beyond original timeout
        async.elapse(const Duration(seconds: 2));
        expect(callbackCount, 1);
      });
    });

    test('pause stops callback even after timeout', () {
      fakeAsync((async) {
        idleTimeout.start(() async {
          callbackCount++;
        }, timeout: const Duration(seconds: 1));

        // disable just before timeout
        async.elapse(const Duration(milliseconds: 900));
        idleTimeout.pause();
        async.elapse(const Duration(milliseconds: 200));
        expect(callbackCount, 0);
      });
    });

    test('resume restarts callback after timeout', () {
      fakeAsync((async) {
        idleTimeout.start(() async {
          callbackCount++;
        }, timeout: const Duration(seconds: 1));

        // pause before timeout
        async.elapse(const Duration(milliseconds: 900));
        idleTimeout.pause();
        // resume and elapse full timeout
        idleTimeout.resume();
        async.elapse(const Duration(seconds: 1));
        expect(callbackCount, 1);
      });
    });

    test('reset restarts the timer immediately', () {
      fakeAsync((async) {
        idleTimeout.start(() async {
          callbackCount++;
        }, timeout: const Duration(seconds: 1));

        // elapse halfway, then reset
        async.elapse(const Duration(milliseconds: 500));
        idleTimeout.reset();

        // elapse full timeout from reset (1s) → callback should fire
        async.elapse(const Duration(seconds: 1));
        expect(callbackCount, 1);
      });
    });

    test('lifecycle pause cancels timer, resume restarts timer', () {
      fakeAsync((async) {
        idleTimeout.start(() async {
          callbackCount++;
        }, timeout: const Duration(seconds: 1));

        // go to background at t=0.5s
        async.elapse(const Duration(milliseconds: 500));
        idleTimeout.didChangeAppLifecycleState(AppLifecycleState.paused);
        // elapse beyond the timeout
        async.elapse(const Duration(seconds: 1));
        expect(callbackCount, 0, reason: 'Timer should be canceled on paused');

        // resume lifecycle
        idleTimeout.didChangeAppLifecycleState(AppLifecycleState.resumed);
        async.elapse(const Duration(seconds: 1));
        expect(callbackCount, 1, reason: 'Timer should restart on resumed');
      });
    });

    test('dispose removes observer and cancels timers without error', () {
      fakeAsync((async) {
        // Starting and immediately disposing should not crash
        idleTimeout.start(() async {
          callbackCount++;
        }, timeout: const Duration(seconds: 1));

        expect(() => idleTimeout.dispose(), returnsNormally);
        // Even after original timeout, no callback
        async.elapse(const Duration(seconds: 2));
        expect(callbackCount, 0);
      });
    });
  });
}
