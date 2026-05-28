import 'package:flutter/material.dart';
import 'service.dart';

final List<Service> services = [
  Service(
    title: 'Derecho Corporativo',
    description:
        'Asesoría integral en constitución de sociedades, fusiones, adquisiciones y gobierno corporativo para empresas nacionales e internacionales.',
    icon: Icons.business,
    details: [
      'Constitución y reorganización de sociedades',
      'Fusiones y adquisiciones (M&A)',
      'Gobierno corporativo y compliance',
      'Contratos comerciales nacionales e internacionales',
      'Due diligence corporativa',
    ],
  ),
  Service(
    title: 'Litigio y Arbitraje',
    description:
        'Representación en procesos judiciales y arbitrales con un equipo de litigantes de alta experiencia en todas las materias del derecho.',
    icon: Icons.gavel,
    details: [
      'Litigio civil y mercantil',
      'Arbitraje comercial nacional e internacional',
      'Litigio administrativo y constitucional',
      'Procesos ante el Poder Judicial del Perú',
      'Medios alternativos de solución de controversias',
    ],
  ),
  Service(
    title: 'Derecho Tributario',
    description:
        'Planificación tributaria estratégica, defensa ante la SUNAT y cumplimiento normativo para optimizar la carga fiscal.',
    icon: Icons.account_balance,
    details: [
      'Planificación tributaria corporativa',
      'Defensa ante SUNAT y juicio contencioso',
      'Dictámenes y opiniones tributarias',
      'Comercio exterior y aduanas',
      'Cumplimiento de obligaciones tributarias',
    ],
  ),
  Service(
    title: 'Derecho Laboral',
    description:
        'Asesoría en relaciones laborales individuales y colectivas, defensa en procesos laborales y planeación de estrategias de capital humano.',
    icon: Icons.people,
    details: [
      'Relaciones laborales individuales y colectivas',
      'Procesos laborales y conciliación',
      'Planeación de compensaciones y beneficios',
      'Migración laboral y visados corporativos',
      'Cumplimiento de normativa laboral peruana',
    ],
  ),
  Service(
    title: 'Propiedad Intelectual',
    description:
        'Protección y defensa de marcas, patentes, derechos de autor y secretos industriales en el Perú y el extranjero.',
    icon: Icons.copyright,
    details: [
      'Registro de marcas y patentes ante INDECOPI',
      'Protección de derechos de autor',
      'Litigio en propiedad intelectual',
      'Contratos de licencia y transferencia de tecnología',
      'Defensa contra piratería y falsificación',
    ],
  ),
  Service(
    title: 'Derecho Inmobiliario',
    description:
        'Asesoría en transacciones inmobiliarias, desarrollo de proyectos, financiamiento y due diligence de propiedades en todo el Perú.',
    icon: Icons.home_work,
    details: [
      'Compraventa y arrendamiento de inmuebles',
      'Desarrollos inmobiliarios y fideicomisos',
      'Due diligence inmobiliario',
      'Financiamiento hipotecario',
      'Regularización de propiedades y titulación',
    ],
  ),
  Service(
    title: 'Banca y Finanzas',
    description:
        'Estructuración de financiamientos, operaciones bancarias, mercado de valores y cumplimiento regulatorio financiero supervisado por la SBS.',
    icon: Icons.account_balance_wallet,
    details: [
      'Estructuración de financiamientos',
      'Operaciones bancarias y crediticias',
      'Mercado de valores',
      'Cumplimiento regulatorio financiero SBS',
      'Fintech y banca digital',
    ],
  ),
  Service(
    title: 'Derecho de Familia',
    description:
        'Asesoría sensible y profesional en divorcios, sucesiones, custodias y planeación patrimonial familiar.',
    icon: Icons.family_restroom,
    details: [
      'Divorcios y separaciones',
      'Tenencia y régimen de visitas',
      'Sucesiones y testamentos',
      'Pensiones alimenticias',
      'Planeación patrimonial familiar',
    ],
  ),
  Service(
    title: 'Derecho Regulatorio',
    description:
        'Asesoría en cumplimiento normativo ante organismos reguladores peruanos: OSIPTEL, OSINERGMIN, SUNASS y otros.',
    icon: Icons.verified_user,
    details: [
      'Regulación de servicios públicos',
      'Defensa ante organismos reguladores',
      'Procedimientos administrativos',
      'Cumplimiento normativo sectorial',
      'Recursos de apelación y reconsideración',
    ],
  ),
];
