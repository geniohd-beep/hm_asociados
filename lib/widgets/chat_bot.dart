import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/services/ai_service.dart';
import 'package:hm_asociados/services/chat_persistence.dart';

enum _ChatStep { askingName, askingPhone, chatting }

class ChatBot extends StatefulWidget {
  final AIService? aiService;

  const ChatBot({super.key, this.aiService});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  _ChatStep _step = _ChatStep.askingName;
  String _userName = '';
  String _userPhone = '';
  bool _isTyping = false;
  bool _initialized = false;

  late AnimationController _typingDotsController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingDotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingDotsController, curve: Curves.easeInOut),
    );
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final data = await ChatPersistence.loadUserData();
    final savedName = data['name'] as String;
    final savedPhone = data['phone'] as String;
    final savedMessages = await ChatPersistence.loadMessages();

    if (savedName.isNotEmpty && savedPhone.isNotEmpty && savedMessages.isNotEmpty) {
      setState(() {
        _userName = savedName;
        _userPhone = savedPhone;
        _step = _ChatStep.chatting;
        for (final m in savedMessages) {
          _messages.add(_ChatMessage(
            text: m['text'] as String,
            isUser: m['isUser'] as bool,
            timestamp: m['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ));
        }
        _initialized = true;
      });
      _scrollToBottom();
    } else {
      setState(() => _initialized = true);
      _addBotMessage(
        '¡Bienvenido a HM & Asociados! Soy su asistente virtual.\n\n'
        'Antes de brindarle información, ¿podría indicarme su **nombre** por favor?',
      );
    }
  }

  @override
  void dispose() {
    _typingDotsController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    _persistMessages();
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    _persistMessages();
    _scrollToBottom();
  }

  Future<void> _persistMessages() async {
    final data = _messages.map((m) => {
      'text': m.text,
      'isUser': m.isUser,
      'timestamp': m.timestamp,
    }).toList();
    await ChatPersistence.saveMessages(data);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;
    _addUserMessage(text);
    _controller.clear();

    switch (_step) {
      case _ChatStep.askingName:
        _userName = text.trim();
        _step = _ChatStep.askingPhone;
        _addBotMessage(
          'Mucho gusto, $_userName. ¿Podría indicarme su **número de celular** '
          'para que podamos contactarlo directamente por WhatsApp si es necesario?',
        );
        await ChatPersistence.saveUserData(name: _userName, phone: '', step: 1);

      case _ChatStep.askingPhone:
        _userPhone = text.trim();
        _step = _ChatStep.chatting;
        await ChatPersistence.saveUserData(
          name: _userName,
          phone: _userPhone,
          step: 2,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          _addBotMessage(
            '¡Gracias $_userName! Sus datos han sido registrados.\n\n'
            'Ahora, ¿en qué puedo ayudarle? Puede preguntarme sobre:\n'
            '• **Áreas de práctica**: Corporativo, Tributario, Laboral, Familia, etc.\n'
            '• **Agendar una consulta**\n'
            '• **Ubicación y horarios**\n\n'
            'También puede usar el botón **WhatsApp** para contactarnos directamente.',
          );
        });

      case _ChatStep.chatting:
        setState(() => _isTyping = true);
        _scrollToBottom();

        String response;

        if (widget.aiService != null && widget.aiService!.isConfigured) {
          final history = _messages
              .where((m) => _messages.indexOf(m) < _messages.length - 1)
              .map((m) => {
                    'role': m.isUser ? 'user' : 'assistant',
                    'content': m.text,
                  })
              .toList();

          final aiResponse = await widget.aiService!.generateResponse(
            userName: _userName,
            userMessage: text,
            conversationHistory: history,
          );

          response = aiResponse ?? _generateRuleBasedResponse(text);
        } else {
          response = _generateRuleBasedResponse(text);
        }

        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          setState(() => _isTyping = false);
          _addBotMessage('$response\n\n'
              'Si desea que un asesor lo contacte, presione el botón **WhatsApp** abajo.');
        }
    }
  }

  String _generateRuleBasedResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('corporativo') || msg.contains('empresa') || msg.contains('mercantil')) {
      return 'Nuestra práctica de Derecho Corporativo incluye constitución de empresas, '
          'fusiones y adquisiciones, gobierno corporativo y contratos comerciales. '
          'Contamos con amplia experiencia asesorando a empresas nacionales e internacionales en el Perú.';
    }
    if (msg.contains('laboral') || msg.contains('trabajo') || msg.contains('empleado')) {
      return 'En Derecho Laboral ofrecemos asesoría en contratación laboral, '
          'despidos, negociaciones colectivas y cumplimiento de normativas laborales peruanas. '
          'También brindamos defensa en procesos ante el Ministerio de Trabajo.';
    }
    if (msg.contains('fiscal') || msg.contains('tributario') || msg.contains('impuesto') || msg.contains('sunat')) {
      return 'Nuestro equipo de Derecho Tributario lo asesora en planificación fiscal, '
          'defensa ante SUNAT, cumplimiento de obligaciones tributarias y '
          'recursos administrativos y judiciales en materia tributaria.';
    }
    if (msg.contains('familia') || msg.contains('divorcio') || msg.contains('sucesión') || msg.contains('heredero')) {
      return 'En Derecho de Familia brindamos asesoría en divorcios, tenencia, '
          'alimentos, regímenes patrimoniales, sucesiones y testamentos. '
          'Acompañamos a nuestras clientas y clientes con sensibilidad y profesionalismo.';
    }
    if (msg.contains('inmobiliario') || msg.contains('propiedad') || msg.contains('terreno') || msg.contains('alquiler')) {
      return 'Nuestra área de Derecho Inmobiliario cubre compraventa de inmuebles, '
          'arrendamientos, contratos de construcción, due diligence inmobiliario '
          'y regularización de propiedades en todo el Perú.';
    }
    if (msg.contains('propiedad intelectual') || msg.contains('marca') || msg.contains('patente') || msg.contains('indecopi')) {
      return 'En Propiedad Intelectual lo asesoramos en registro de marcas y patentes ante INDECOPI, '
          'protección de derechos de autor, contratos de licencia y defensa contra la piratería.';
    }
    if (msg.contains('arbitraje') || msg.contains('litigio') || msg.contains('juicio') || msg.contains('penal')) {
      return 'Contamos con un equipo de litigantes de primer nivel. Ofrecemos representación '
          'en procesos judiciales y arbitrajes nacionales e internacionales. '
          'Tenemos experiencia en litigios civiles, comerciales, penales y constitucionales.';
    }
    if (msg.contains('banca') || msg.contains('finanza') || msg.contains('fintech') || msg.contains('sbs')) {
      return 'Nuestra área de Banca y Finanzas ofrece estructuración de financiamientos, '
          'operaciones bancarias, mercado de valores y cumplimiento regulatorio ante la SBS. '
          'También asesoramos a empresas fintech y de banca digital.';
    }
    if (msg.contains('regulatorio') || msg.contains('osiptel') || msg.contains('osinergmin') || msg.contains('sunass')) {
      return 'En Derecho Regulatorio brindamos asesoría en cumplimiento normativo ante organismos '
          'reguladores peruanos como OSIPTEL, OSINERGMIN y SUNASS, incluyendo defensa en '
          'procedimientos administrativos sancionadores.';
    }
    if (msg.contains('consulta') || msg.contains('cita') || msg.contains('agendar')) {
      return 'Puede agendar una consulta llamándonos al +51 (1) 555-1234 o escribiéndonos a '
          'contacto@hm-asociados.pe. Nuestro horario de atención es lunes a viernes de 9:00 a 18:00 hrs. '
          'También puede visitarnos en nuestra oficina principal en San Isidro, Lima.';
    }
    if (msg.contains('ubicación') || msg.contains('dirección') || msg.contains('dónde') || msg.contains('oficina')) {
      return 'Nuestra oficina principal está ubicada en:\n'
          'Av. Paseo de la República 3587\n'
          'San Isidro, Lima 15047\n'
          'Perú\n\n'
          'Horario: Lunes a Viernes 9:00 - 18:00 hrs';
    }
    if (msg.contains('hola') || msg.contains('buenas') || msg.contains('saludo')) {
      return '¡Hola! Encantado de saludarle. ¿En qué puedo ayudarle hoy? '
          'Puede consultarme sobre nuestras áreas de práctica, agendar una cita o '
          'preguntar por nuestra ubicación.';
    }
    if (msg.contains('gracias') || msg.contains('muchas gracias') || msg.contains('agradezco')) {
      return '¡Ha sido un placer atenderle! Si tiene más preguntas, no dude en escribirnos. '
          'Que tenga un excelente día.';
    }
    return 'Gracias por su mensaje. Para brindarle una atención más personalizada, '
        'le sugiero contactarnos directamente al +51 (1) 555-1234 o visitar nuestra oficina. '
        '¿Desea preguntar sobre algún área en específico? Puedo ayudarle con información sobre:\n\n'
        '• Derecho Corporativo\n'
        '• Derecho Tributario\n'
        '• Derecho Laboral\n'
        '• Derecho de Familia\n'
        '• Propiedad Intelectual\n'
        '• Litigio y Arbitraje\n'
        '• Derecho Inmobiliario\n'
        '• Banca y Finanzas\n'
        '• Derecho Regulatorio\n'
        '• Derecho Penal\n'
        '• Derecho Civil\n'
        '• Derecho Constitucional';
  }

  Future<void> _openWhatsApp() async {
    final phone = '+51926678446';
    final message = Uri.encodeComponent(
      'Hola, soy $_userName. Me comunico desde la app de HM & Asociados. '
      'Mi celular es $_userPhone. Quisiera recibir más información.',
    );

    try {
      final waUri = Uri.parse('whatsapp://send?phone=$phone&text=$message');
      await launchUrl(waUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        final webUri = Uri.parse('https://wa.me/$phone?text=$message');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        _addBotMessage(
          'No se pudo abrir WhatsApp automáticamente.\n\n'
          'Puede escribirnos manualmente al **+51 926 678 446** '
          'con el mensaje: "Hola, soy $_userName. Celular: $_userPhone. '
          'Quisiera recibir más información."',
        );
      }
    }
  }

  Future<void> _resetChat() async {
    await ChatPersistence.clearAll();
    setState(() {
      _messages.clear();
      _step = _ChatStep.askingName;
      _userName = '';
      _userPhone = '';
    });
    _addBotMessage(
      '¡Bienvenido a HM & Asociados! Soy su asistente virtual.\n\n'
      'Antes de brindarle información, ¿podría indicarme su **nombre** por favor?',
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = ((_typingAnimation.value - delay) % 1.0).clamp(0.0, 1.0);
                final size = 6.0 + (value * 4.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_step == _ChatStep.chatting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: _resetChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, size: 14, color: Colors.redAccent),
                        SizedBox(width: 4),
                        Text(
                          'Nuevo chat',
                          style: TextStyle(fontSize: 11, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _messages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    return _MessageBubble(message: msg);
                  },
                ),
        ),
        if (_step == _ChatStep.chatting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('CONTACTAR POR WHATSAPP'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _step == _ChatStep.askingName
                        ? 'Escriba su nombre...'
                        : _step == _ChatStep.askingPhone
                            ? 'Escriba su celular...'
                            : 'Escriba su mensaje...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: _step == _ChatStep.askingPhone
                      ? TextInputType.phone
                      : TextInputType.text,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _isTyping ? null : _handleSend,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isTyping
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, color: AppTheme.primaryGold),
                onPressed: _isTyping ? null : () => _handleSend(_controller.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final int timestamp;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.timestamp = 0,
  });

  String get formattedTime {
    if (timestamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppTheme.primaryGold.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: message.isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: Border.all(
            color: message.isUser
                ? AppTheme.primaryGold.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: message.isUser ? AppTheme.textLight : AppTheme.primaryDark,
                height: 1.5,
              ),
            ),
            if (message.formattedTime.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                message.formattedTime,
                style: TextStyle(
                  fontSize: 10,
                  color: message.isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
