Set<int> _okStatus = {
  200,
  201,
  202,
  203,
  204,
  205,
  206,
  207,
  208,
  226,
};

class ApiResponse<T> {
  final int? id;
  final int? code;
  final String? error;
  final T? data;
  final bool isNetworkErr;

  bool get isOk => _okStatus.contains(code);

  ApiResponse({
    this.id,
    this.code,
    this.error,
    this.data,
    this.isNetworkErr = false,
  });

  factory ApiResponse.fromMap(Map<String, dynamic> map) {
    return ApiResponse<T>(
      id: map['id'],
      code: map['code'],
      error: map['error'] ?? '',
      data: map['data'] ?? {},
    );
  }

  factory ApiResponse.networkErr() {
    return ApiResponse(
      isNetworkErr: true,
      error: 'Network error',
    );
  }

  @override
  String toString() {
    return 'ApiResponse(id: $id, code: $code, error: $error, data: $data)';
  }

  ApiResponse<K> withData<K>(K data) {
    return ApiResponse<K>(
      id: id,
      code: code,
      error: error,
      data: data,
    );
  }
}