import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  String _caseType = '';
  String _caseDescription = '';
  bool _awaitingCaseDescription = false;
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
            '¿Qué **tipo de caso** le gustaría consultar? Por ejemplo:\n'
            '• **Corporativo** (empresas, contratos)\n'
            '• **Tributario** (impuestos, SUNAT)\n'
            '• **Laboral** (trabajo, empleados)\n'
            '• **Familia** (divorcio, sucesiones)\n'
            '• **Penal** (delitos, defensa)\n'
            '• **Civil** (contratos, propiedades)\n'
            '• **Inmobiliario** (terrenos, alquileres)\n'
            '• **Propiedad Intelectual** (marcas, patentes)\n'
            '• **Otro**',
          );
        });

      case _ChatStep.chatting:
        setState(() => _isTyping = true);
        _scrollToBottom();

        String response;

        if (_awaitingCaseDescription) {
          _caseDescription = text;
          await Future.delayed(const Duration(milliseconds: 800));
          response = _generateDetailedResponse(_caseType, text);
          _awaitingCaseDescription = false;
          _caseType = '';
        } else if (widget.aiService != null && widget.aiService!.isConfigured) {
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

        if (mounted) {
          setState(() => _isTyping = false);
          _addBotMessage(response);
        }
    }
  }

  String _detectCaseType(String msg) {
    if (msg.contains('corporativo') || msg.contains('empresa') || msg.contains('mercantil')) return 'corporativo';
    if (msg.contains('laboral') || msg.contains('trabajo') || msg.contains('empleado')) return 'laboral';
    if (msg.contains('tributario') || msg.contains('fiscal') || msg.contains('impuesto') || msg.contains('sunat')) return 'tributario';
    if (msg.contains('familia') || msg.contains('divorcio') || msg.contains('sucesión') || msg.contains('heredero') || msg.contains('alimento')) return 'familia';
    if (msg.contains('inmobiliario') || msg.contains('propiedad') || msg.contains('terreno') || msg.contains('alquiler')) return 'inmobiliario';
    if (msg.contains('propiedad intelectual') || msg.contains('marca') || msg.contains('patente') || msg.contains('indecopi')) return 'propiedad intelectual';
    if (msg.contains('arbitraje') || msg.contains('litigio') || msg.contains('juicio') || msg.contains('penal')) return 'litigio';
    if (msg.contains('banca') || msg.contains('finanza') || msg.contains('fintech') || msg.contains('sbs')) return 'banca';
    if (msg.contains('regulatorio') || msg.contains('osiptel') || msg.contains('osinergmin') || msg.contains('sunass')) return 'regulatorio';
    if (msg.contains('civil') || msg.contains('contrato') || msg.contains('responsabilidad')) return 'civil';
    if (msg.contains('constitucional') || msg.contains('amparo') || msg.contains('habeas')) return 'constitucional';
    return '';
  }

  String _generateRuleBasedResponse(String userMessage) {
    final msg = userMessage.toLowerCase();
    final detectedType = _detectCaseType(msg);

    if (detectedType.isNotEmpty && !_awaitingCaseDescription) {
      _caseType = detectedType;
      _awaitingCaseDescription = true;

      final typeNames = {
        'corporativo': 'Derecho Corporativo',
        'laboral': 'Derecho Laboral',
        'tributario': 'Derecho Tributario',
        'familia': 'Derecho de Familia',
        'inmobiliario': 'Derecho Inmobiliario',
        'propiedad intelectual': 'Propiedad Intelectual',
        'litigio': 'Litigio y Arbitraje',
        'banca': 'Banca y Finanzas',
        'regulatorio': 'Derecho Regulatorio',
        'civil': 'Derecho Civil',
        'constitucional': 'Derecho Constitucional',
      };

      final typeName = typeNames[detectedType] ?? detectedType;
      return 'Entiendo que su consulta está relacionada con **$typeName**.\n\n'
          'Para poder brindarle una orientación más precisa, ¿podría **describirme brevemente su caso**? '
          'Cuénteme qué situación específica está enfrentando y con gusto le daré información relevante.';
    }

    if (msg.contains('consulta') || msg.contains('cita') || msg.contains('agendar')) {
      return 'Puede agendar una consulta llamándonos al +51 (1) 555-1234 o escribiéndonos a '
          'contacto@hm-asociados.pe. Nuestro horario de atención es lunes a viernes de 9:00 a 18:00 hrs. '
          'También puede visitarnos en nuestra oficina principal en San Isidro, Lima.\n\n'
          '¿Quiere que lo contactemos? Use el botón **WhatsApp** abajo.';
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

  String _generateDetailedResponse(String caseType, String description) {
    final desc = description.toLowerCase();

    switch (caseType) {
      case 'corporativo':
        if (desc.contains('constituir') || desc.contains('crear') || desc.contains('formar')) {
          return 'Gracias por compartir los detalles. En HM & Asociados podemos ayudarlo con la **constitución de empresas** en todos los tipos societarios (SA, SAC, SRL). El proceso incluye la elaboración de la minuta, la escritura pública y la inscripción en SUNARP. El plazo aproximado es de 7 a 15 días hábiles.\n\n'
              '¿Desea agendar una consulta para que un abogado corporativo evalúe su caso en detalle?';
        }
        if (desc.contains('contrato') || desc.contains('acuerdo')) {
          return 'Entendemos que requiere asesoría en **contratos comerciales**. Nuestro equipo de Derecho Corporativo tiene amplia experiencia en la redacción, negociación y revisión de contratos de diversa naturaleza: compraventa, prestación de servicios, confidencialidad, joint ventures, entre otros.\n\n'
              'Cada contrato debe adaptarse a las necesidades específicas de su operación. ¿Podría indicarnos qué tipo de contrato necesita?';
        }
        return 'Gracias por contarnos su situación. Nuestra práctica de **Derecho Corporativo** incluye constitución de empresas, fusiones y adquisiciones, gobierno corporativo, contratos comerciales y due diligence. Contamos con amplia experiencia asesorando a empresas nacionales e internacionales en el Perú.\n\n'
            '¿Desea que un abogado especializado se comunique con usted para evaluar su caso? Use el botón **WhatsApp** abajo.';

      case 'laboral':
        if (desc.contains('despido') || desc.contains('despedir') || desc.contains('cesar')) {
          return 'Lamento conocer su situación. En cuanto a **despidos**, la legislación peruana distingue entre despido arbitrario, despido nulo y despido justificado. La indemnización por despido arbitrario es de 1.5 remuneraciones por año de servicios (máximo 12). Si el despido fue nulo (discriminación, represalia), procede la reposición.\n\n'
              'Recomendamos que un abogado laboral revise los detalles específicos de su caso. ¿Desea contactarnos por WhatsApp para una primera orientación?';
        }
        if (desc.contains('contratar') || desc.contains('planilla') || desc.contains('registrar')) {
          return 'En materia de **contratación laboral**, es importante cumplir con todas las obligaciones formales: registro en planilla electrónica (T-Registro y PLAME), afiliación a EsSalud y al sistema de pensiones, y elaboración del contrato de trabajo por escrito cuando la ley lo exige.\n\n'
              'El incumplimiento de estas obligaciones puede generar multas significativas. Lo invitamos a agendar una consulta para revisar su situación particular.';
        }
        return 'Nuestra práctica de **Derecho Laboral** cubre contratación laboral, despidos, negociaciones colectivas, hostilidad laboral, defensa ante el Ministerio de Trabajo y cumplimiento de normativas laborales peruanas. Cada caso es único y merece un análisis personalizado.\n\n'
            '¿Quiere que uno de nuestros abogados laborales evalúe su caso? Use el botón **WhatsApp** para contactarnos.';

      case 'tributario':
        if (desc.contains('sunat') || desc.contains('fiscalización') || desc.contains('multa') || desc.contains('sanción')) {
          return 'Una **fiscalización de SUNAT** puede ser un proceso complejo. Es fundamental contar con asesoría legal especializada para la atención de los requerimientos, la preparación de la documentación y, de ser necesario, la defensa en procedimientos contencioso-tributarios.\n\n'
              'Nuestro equipo tributario tiene experiencia en defensa ante SUNAT y en recursos de reclamación y apelación ante el Tribunal Fiscal. ¿Desea que lo contactemos para evaluar su caso?';
        }
        return 'Nuestro equipo de **Derecho Tributario** lo asesora en planificación fiscal, defensa ante SUNAT, cumplimiento de obligaciones tributarias, devolución de saldos a favor y recursos administrativos y judiciales en materia tributaria.\n\n'
            'La legislación tributaria peruana es compleja y está en constante cambio. Lo invitamos a una consulta para revisar su situación específica.';

      case 'familia':
        if (desc.contains('divorcio') || desc.contains('separación')) {
          return 'En cuanto a **divorcios**, el Código Civil peruano contempla el divorcio por causal y el divorcio por mutuo acuerdo. La separación de hecho por 2 años (o 1 año si hay hijos) es una causal frecuente. El proceso implica la liquidación de la sociedad de gananciales y, de ser el caso, la pensión de alimentos.\n\n'
              'Acompañamos a nuestros clientes con sensibilidad y profesionalismo. ¿Desea agendar una consulta para evaluar su caso?';
        }
        return 'Nuestra práctica de **Derecho de Familia** incluye divorcios, tenencia y régimen de visitas, pensión alimenticia, sucesiones y testamentos, y planeación patrimonial familiar. Entendemos la sensibilidad de estos temas y brindamos un acompañamiento cercano y profesional.\n\n'
            '¿Quiere contarnos más sobre su situación? Estamos para ayudarlo.';

      case 'inmobiliario':
        return 'Nuestra área de **Derecho Inmobiliario** cubre compraventa de inmuebles, arrendamientos, contratos de construcción, due diligence inmobiliario y regularización de propiedades en todo el Perú.\n\n'
            'Las transacciones inmobiliarias requieren una revisión cuidadosa de títulos, cargas y gravámenes. ¿Desea que un especialista revise su caso?';

      case 'litigio':
        return 'Nuestro equipo de **Litigio y Arbitraje** cuenta con amplia experiencia en procesos judiciales y arbitrales en materia civil, comercial, penal y constitucional. Ofrecemos representación en todas las instancias, incluyendo la Corte Suprema.\n\n'
            'Cada caso requiere una estrategia procesal específica. Lo invitamos a una consulta para analizar su situación.';

      case 'propiedad intelectual':
        return 'En **Propiedad Intelectual** lo asesoramos en registro de marcas y patentes ante INDECOPI, protección de derechos de autor, contratos de licencia y defensa contra la piratería. La protección de sus activos intangibles es fundamental para su negocio.\n\n'
            '¿Desea que lo contactemos para evaluar su caso?';

      case 'civil':
        return 'Nuestra práctica de **Derecho Civil** abarca contratos, responsabilidad civil, prescripción, derechos reales (propiedad, posesión), obligaciones y arrendamientos. Brindamos asesoría preventiva y representación en procesos contenciosos.\n\n'
            '¿Quiere contarnos más detalles para poder orientarlo mejor?';

      default:
        return 'Gracias por compartir los detalles de su caso. En HM & Asociados contamos con especialistas en todas las áreas del derecho. Para brindarle una atención más precisa, le sugiero contactarnos directamente.\n\n'
            'Puede comunicarse al **+51 (1) 555-1234** o presionar el botón **WhatsApp** para que un asesor lo contacte a la brevedad.';
    }
  }

  String get caseTypeLabel {
    const labels = {
      'corporativo': 'Corporativo',
      'laboral': 'Laboral',
      'tributario': 'Tributario',
      'familia': 'Familia',
      'inmobiliario': 'Inmobiliario',
      'propiedad intelectual': 'Propiedad Intelectual',
      'litigio': 'Litigio y Arbitraje',
      'banca': 'Banca y Finanzas',
      'regulatorio': 'Regulatorio',
      'civil': 'Civil',
      'constitucional': 'Constitucional',
      'penal': 'Penal',
    };
    final saved = _caseType.isEmpty ? (_messages.length >= 4 ? _detectCaseType(_messages.map((m) => m.text).join(' ')) : '') : _caseType;
    return labels[saved] ?? saved;
  }

  Future<void> _openWhatsApp() async {
    final phone = '+51926678446';
    final caseInfo = _caseDescription.isNotEmpty
        ? '\n\n*Tipo de caso:* $caseTypeLabel\n*Descripción:* $_caseDescription'
        : '';
    final message = Uri.encodeComponent(
      'Hola, soy $_userName. Me comunico desde la app de HM & Asociados. '
      'Mi celular es $_userPhone. Quisiera recibir más información.$caseInfo',
    );

    final webUri = Uri.parse('https://wa.me/$phone?text=$message');

    try {
      if (kIsWeb) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        try {
          final waUri = Uri.parse('whatsapp://send?phone=$phone&text=$message');
          await launchUrl(waUri, mode: LaunchMode.externalApplication);
        } catch (_) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      _addBotMessage(
        'No se pudo abrir WhatsApp automáticamente.\n\n'
        'Puede escribirnos manualmente al **+51 926 678 446** '
        'con el mensaje: "Hola, soy $_userName. Celular: $_userPhone. '
        'Quisiera recibir más información."',
      );
    }
  }

  Future<void> _resetChat() async {
    await ChatPersistence.clearAll();
    setState(() {
      _messages.clear();
      _step = _ChatStep.askingName;
      _userName = '';
      _userPhone = '';
      _caseType = '';
      _caseDescription = '';
      _awaitingCaseDescription = false;
    });
    _addBotMessage(
      '¡Bienvenido a HM & Asociados! Soy su asistente virtual.\n\n'
      'Antes de brindarle información, ¿podría indicarme su **nombre** por favor?',
    );
  }

  String _formatConversation() {
    final buffer = StringBuffer();
    for (final msg in _messages) {
      final role = msg.isUser ? '👤 Cliente' : '⚖️  HM & Asociados';
      final time = msg.formattedTime;
      buffer.writeln('$role ($time):');
      buffer.writeln(msg.text);
      buffer.writeln('');
    }
    return buffer.toString();
  }

  Future<void> _sendAndFinish() async {
    final conversation = _formatConversation();
    final firmPhone = '+51926678446';
    var userPhone = _userPhone.trim();
    if (!userPhone.startsWith('+')) {
      userPhone = '+51$userPhone';
    }

    final caseInfo = _caseDescription.isNotEmpty
        ? '📂 *Tipo de caso:* ${caseTypeLabel}\n📝 *Descripción:* $_caseDescription\n'
        : '';
    final header = '📋 *Resumen de Conversación*\n'
        '👤 Cliente: $_userName\n'
        '📱 Celular: $_userPhone\n'
        '$caseInfo'
        '━━━━━━━━━━━━━━━━━━\n\n';

    final firmMsg = Uri.encodeComponent('$header$conversation');
    final userMsg = Uri.encodeComponent(
      '✅ Gracias por comunicarte con HM & Asociados, $_userName.\n\n'
      'Hemos recibido el resumen de tu consulta y te contactaremos pronto al 📱 $_userPhone.\n\n'
      'Puedes seguir conversando con nosotros aquí cuando lo necesites.',
    );

    final firmUri = Uri.parse('https://wa.me/$firmPhone?text=$firmMsg');
    final userUri = Uri.parse('https://wa.me/$userPhone?text=$userMsg');

    try {
      if (kIsWeb) {
        await launchUrl(firmUri, mode: LaunchMode.externalApplication);
        await Future.delayed(const Duration(seconds: 1));
        try {
          await launchUrl(userUri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      } else {
        try {
          final waFirm = Uri.parse('whatsapp://send?phone=$firmPhone&text=$firmMsg');
          await launchUrl(waFirm, mode: LaunchMode.externalApplication);
        } catch (_) {
          await launchUrl(firmUri, mode: LaunchMode.externalApplication);
        }
        await Future.delayed(const Duration(seconds: 1));
        try {
          final waUser = Uri.parse('whatsapp://send?phone=$userPhone&text=$userMsg');
          await launchUrl(waUser, mode: LaunchMode.externalApplication);
        } catch (_) {
          try {
            await launchUrl(userUri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        }
      }
    } catch (_) {
      _addBotMessage(
        'No se pudo abrir WhatsApp automáticamente.\n\n'
        'Puede contactarnos al **+51 926 678 446** para recibir atención personalizada.',
      );
    }

    await ChatPersistence.clearAll();
    if (mounted) {
      setState(() {
        _messages.clear();
        _step = _ChatStep.askingName;
        _userName = '';
        _userPhone = '';
        _caseType = '';
        _caseDescription = '';
        _awaitingCaseDescription = false;
      });
      _addBotMessage(
        '¡Bienvenido a HM & Asociados! Soy su asistente virtual.\n\n'
        'Antes de brindarle información, ¿podría indicarme su **nombre** por favor?',
      );
    }
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
            child: Column(
              children: [
                SizedBox(
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendAndFinish,
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('TERMINAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
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
