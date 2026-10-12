import 'support/fixture_contract.dart';
import 'support/fakes.dart';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/core/network/api_client.dart';
import 'package:bilanqo/core/error/app_exception.dart';

import 'package:bilanqo/features/transactions/data/finance_repository.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';
import 'package:bilanqo/core/utils/money.dart';

class TokenAuth extends DemoAuthRepository {
  @override
  Future<String?> token({bool refresh = false}) async => 'test-token';
}

class MockAdapter implements HttpClientAdapter {
  MockAdapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  test('HTTP bearer authentication and account parsing', () async {
    final auth = TokenAuth();
    final client = ApiClient(
      'https://api.example.test',
      auth,
      adapter: MockAdapter((o) {
        expect(o.headers['Authorization'], 'Bearer test-token');
        expect(o.path, '/api/v1/accounts');
        return ResponseBody.fromString(
          '[{"id":"a1","name":"Main","type":"bank","balance":"10.00"}]',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }),
    );
    expect(
      (await HttpFinanceRepository(
        client,
        const FixtureContract(),
      ).accounts()).single.name,
      'Main',
    );
    client.close();
    auth.dispose();
  });
  test('HTTP status converted to application failure', () async {
    for (final entry in {
      401: Failure.unauthorized,
      403: Failure.forbidden,
      422: Failure.validation,
      503: Failure.server,
    }.entries) {
      final auth = TokenAuth();
      final client = ApiClient(
        'https://api.example.test',
        auth,
        adapter: MockAdapter((o) => ResponseBody.fromString('', entry.key)),
      );
      await expectLater(
        client.get('/api/v1/me'),
        throwsA(isA<AppException>().having((e) => e.kind, 'kind', entry.value)),
      );
      client.close();
      auth.dispose();
    }
  });
  test('Connection timeout becomes network failure', () async {
    final auth = TokenAuth();
    final client = ApiClient(
      'https://api.example.test',
      auth,
      adapter: MockAdapter(
        (o) => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionTimeout,
        ),
      ),
    );
    await expectLater(
      client.get('/api/v1/dashboard'),
      throwsA(
        isA<AppException>().having((e) => e.kind, 'kind', Failure.network),
      ),
    );
    client.close();
    auth.dispose();
  });
  test('Transaction POST contains decimal string and calendar date', () async {
    final auth = TokenAuth();
    final client = ApiClient(
      'https://api.example.test',
      auth,
      adapter: MockAdapter((o) {
        expect(o.method, 'POST');
        expect(o.path, '/api/v1/transactions');
        expect(o.data['amount'], '12.30');
        expect(o.data['date'], '2026-10-10');
        return ResponseBody.fromString('', 201);
      }),
    );
    await HttpFinanceRepository(
      client,
      const FixtureContract(),
    ).createTransaction(
      NewMovement(
        accountId: 'a1',
        categoryId: 'c2',
        type: MovementType.expense,
        amount: Money.parse('12.30'),
        description: 'Lunch',
        date: DateTime(2026, 10, 10),
      ),
    );
    client.close();
    auth.dispose();
  });
}
