import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _defaultEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-4o-mini';

  String? _apiKey;
  String _endpoint;
  String _model;

  AIService({
    String? apiKey,
    String? endpoint,
    String? model,
  })  : _apiKey = apiKey,
        _endpoint = endpoint ?? _defaultEndpoint,
        _model = model ?? _defaultModel;

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  void configure({
    String? apiKey,
    String? endpoint,
    String? model,
  }) {
    if (apiKey != null) _apiKey = apiKey;
    if (endpoint != null) _endpoint = endpoint;
    if (model != null) _model = model;
  }

  Future<String?> generateResponse({
    required String userName,
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
  }) async {
    if (!isConfigured) return null;

    final messages = [
      {
        'role': 'system',
        'content':
            'Eres un asistente virtual del estudio jurídico HM & Asociados. '
            'Te llamas "Asistente HM". Respondes de forma profesional, amable y concisa. '
            'El usuario se llama $userName. '
            'HM & Asociados es un estudio jurídico peruano con más de 30 años de experiencia. '
            'Sus áreas de práctica incluyen: Derecho Corporativo, Litigio y Arbitraje, '
            'Derecho Tributario, Derecho Laboral, Propiedad Intelectual, Derecho Inmobiliario, '
            'Banca y Finanzas, Derecho de Familia, Derecho Regulatorio, Derecho Penal, '
            'Derecho Civil y Derecho Constitucional. '
            'Ubicación: Av. Paseo de la República 3587, San Isidro, Lima 15047, Perú. '
            'Teléfono: +51 (1) 555-1234. Email: contacto@hm-asociados.pe. '
            'Horario: Lunes a Viernes 9:00 - 18:00 hrs. '
            'Siempre ofrece agendar una consulta o contactar por WhatsApp al final de la respuesta.',
      },
      ...conversationHistory.map((m) => {
            'role': m['role'],
            'content': m['content'],
          }),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (_apiKey != null && _apiKey!.isNotEmpty)
            'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
