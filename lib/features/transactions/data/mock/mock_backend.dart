import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/utils/money.dart';
import 'mock_dto.dart';

/// A Dio transport with no network access. All balances are local test data.
/// Recreated for each authenticated session; changes disappear on logout.
class MockBackendAdapter implements HttpClientAdapter {
  MockBackendAdapter({this.email = 'prova@example.com'});
  final String email;
  bool _closed = false;
  int _sequence = 3;
  final _accounts = <Map<String, Object?>>[
    {
      'id': 'a1',
      'name': 'Conto personale',
      'type': 'bank',
      'balance': '2480.00',
    },
    {'id': 'a2', 'name': 'Risparmi', 'type': 'savings', 'balance': '1200.00'},
  ];
  final _categories = <Map<String, Object?>>[
    {'id': 'c1', 'name': 'Stipendio', 'type': 'income'},
    {'id': 'c2', 'name': 'Spesa', 'type': 'expense'},
    {'id': 'c3', 'name': 'Tempo libero', 'type': 'expense'},
  ];
  final _movements = <Map<String, Object?>>[
    {
      'id': 't1',
      'accountId': 'a1',
      'categoryId': 'c2',
      'type': 'expense',
      'amount': '42.80',
      'description': 'Spesa al supermercato',
      'date': MockDto.dateString(DateTime.now()),
    },
    {
      'id': 't2',
      'accountId': 'a1',
      'categoryId': 'c1',
      'type': 'income',
      'amount': '2100.00',
      'description': 'Stipendio',
      'date': MockDto.dateString(DateTime.now()),
    },
  ];

  ResponseBody _response(Object? value, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(value),
        status,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_closed) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
      );
    }
    if (options.headers['Authorization'] == null) return _response(null, 401);
    if (options.method == 'GET') {
      return switch (options.path) {
        '/api/v1/me' => _response({
          'id': 'mock-user',
          'email': email,
          'name': 'Profilo di prova',
        }),
        '/api/v1/accounts' => _response(_accounts),
        '/api/v1/categories' => _response(_categories),
        '/api/v1/transactions' => _response(_movements),
        '/api/v1/dashboard' => _response(_dashboard()),
        _ => _response(null, 404),
      };
    }
    if (options.method != 'POST') return _response(null, 405);
    try {
      final data = MockDto.object(options.data);
      if (options.path == '/api/v1/accounts') {
        final name = MockDto.string(data, 'name').trim();
        final type = MockDto.string(data, 'type');
        final balance = Money.parse(MockDto.string(data, 'initialBalance'));
        if (name.isEmpty ||
            name.length > 80 ||
            !['bank', 'cash', 'savings'].contains(type)) {
          return _response(null, 422);
        }
        _accounts.add({
          'id': 'a${_sequence++}',
          'name': name,
          'type': type,
          'balance': balance.decimal,
        });
        return _response(null, 201);
      }
      if (options.path == '/api/v1/transactions') {
        final movement = MockDto.movement({...data, 'id': 't$_sequence'});
        final account = _accounts
            .where((a) => a['id'] == movement.accountId)
            .firstOrNull;
        final category = _categories
            .where(
              (c) =>
                  c['id'] == movement.categoryId &&
                  c['type'] == movement.type.name,
            )
            .firstOrNull;
        if (account == null ||
            category == null ||
            movement.description.trim().isEmpty ||
            movement.description.length > 200) {
          return _response(null, 422);
        }
        final previous = Money.parse(account['balance']! as String);
        final signed = movement.type.name == 'income'
            ? movement.amount.cents
            : -movement.amount.cents;
        account['balance'] = Money(previous.cents + signed).decimal;
        _movements.insert(0, {...data, 'id': 't${_sequence++}'});
        return _response(null, 201);
      }
      return _response(null, 404);
    } on FormatException {
      return _response(null, 422);
    } on ArgumentError {
      return _response(null, 422);
    }
  }

  // Simulates backend aggregates only. Real financial rules belong to Spring Boot.
  Map<String, Object?> _dashboard() {
    final now = DateTime.now();
    var income = BigInt.zero;
    var expense = BigInt.zero;
    for (final raw in _movements) {
      final movement = MockDto.movement(raw);
      if (movement.date.year == now.year && movement.date.month == now.month) {
        if (movement.type.name == 'income') {
          income += movement.amount.cents;
        } else {
          expense += movement.amount.cents;
        }
      }
    }
    final total = _accounts.fold(
      BigInt.zero,
      (sum, a) => sum + Money.parse(a['balance']! as String).cents,
    );
    return {
      'totalBalance': Money(total).decimal,
      'monthlyIncome': Money(income).decimal,
      'monthlyExpense': Money(expense).decimal,
      'remaining': Money(income - expense).decimal,
      'recentTransactions': _movements.take(5).toList(),
    };
  }

  @override
  void close({bool force = false}) => _closed = true;
}
