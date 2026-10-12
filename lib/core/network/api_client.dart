import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/config.dart';
import '../error/app_exception.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/transactions/data/mock/mock_backend.dart';

class ApiClient {
  ApiClient(String baseUrl, AuthRepository auth, {HttpClientAdapter? adapter})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          followRedirects: false,
          headers: {'Accept': 'application/json'},
        ),
      ) {
    if (adapter != null) dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await auth.token();
            if (token == null) throw const AppException(Failure.unauthorized);
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) debugPrint('API ${options.method}');
            handler.next(options);
          } catch (_) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: const AppException(Failure.unauthorized),
              ),
            );
          }
        },
      ),
    );
  }
  final Dio dio;
  Future<Object?> get(String path) => _request(() => dio.get<Object?>(path));
  Future<Object?> post(String path, Map<String, Object?> data) =>
      _request(() => dio.post<Object?>(path, data: data));
  Future<Object?> _request(Future<Response<Object?>> Function() action) async {
    try {
      return (await action()).data;
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw AppException(switch (e.response?.statusCode) {
        401 => Failure.unauthorized,
        403 => Failure.forbidden,
        400 || 409 || 422 => Failure.validation,
        int status when status >= 500 => Failure.server,
        null => Failure.network,
        _ => Failure.contract,
      });
    }
  }

  void close() => dio.close(force: true);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  if (Config.mockConfigurationInvalid) {
    throw const AppException(Failure.configuration);
  }
  final mock = Config.mockApi && Config.mocksAllowed;
  final session = ref.watch(sessionProvider).asData?.value;
  try {
    if (!mock) Config.validateUrl();
  } catch (_) {
    throw const AppException(Failure.configuration);
  }
  final client = ApiClient(
    mock ? 'https://mock.bilanqo.invalid' : Config.baseUrl,
    ref.watch(authRepositoryProvider),
    adapter: mock
        ? MockBackendAdapter(email: session?.email ?? 'prova@example.com')
        : null,
  );
  ref.onDispose(client.close);
  return client;
});
