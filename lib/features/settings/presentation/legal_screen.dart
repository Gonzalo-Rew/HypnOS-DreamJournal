import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';

enum LegalDocType { privacy, terms }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.type});

  final LegalDocType type;

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final isPrivacy = type == LegalDocType.privacy;

    final title = isPrivacy
        ? (isEs ? 'Política de privacidad' : 'Privacy Policy')
        : (isEs ? 'Términos y condiciones' : 'Terms & Conditions');

    final sections = isPrivacy
        ? (isEs ? _privacyEs : _privacyEn)
        : (isEs ? _termsEs : _termsEn);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                itemCount: sections.length + 1,
                separatorBuilder: (_, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _LastUpdatedChip(isEs: isEs);
                  }
                  final section = sections[i - 1];
                  return _SectionCard(title: section.title, body: section.body);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _Section {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _LastUpdatedChip extends StatelessWidget {
  const _LastUpdatedChip({required this.isEs});
  final bool isEs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        isEs
            ? 'Última actualización: 20 de mayo de 2026'
            : 'Last updated: May 20, 2026',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.accentPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTENIDO EN ESPAÑOL
// ─────────────────────────────────────────────────────────────────────────────

const _privacyEs = [
  _Section(
    title: '1. Quiénes somos',
    body:
        'Hypnos Dream Journal («Hypnos», «nosotros» o «la aplicación») es '
        'un servicio de diario onírico con análisis de inteligencia artificial. '
        'Esta Política de privacidad explica qué datos recopilamos, cómo los '
        'usamos y qué derechos tienes sobre ellos.',
  ),
  _Section(
    title: '2. Datos que recopilamos',
    body:
        '• Datos de cuenta: nombre, dirección de correo electrónico y, opcionalmente, '
        'foto de perfil. Si inicias sesión con Google o Apple, recibimos el correo '
        'y el nombre asociados a esa cuenta.\n\n'
        '• Contenido del diario: títulos, texto y grabaciones de audio de tus sueños. '
        'También almacenamos las etiquetas, puntuaciones emocionales y el análisis '
        'generado por IA.\n\n'
        '• Datos de uso social: relaciones de seguimiento, solicitudes de seguimiento, '
        'comentarios y reacciones en sueños publicados públicamente.\n\n'
        '• Configuración: preferencias de notificación, zona horaria, visibilidad del '
        'perfil y ajustes de privacidad.\n\n'
        '• Token de dispositivo (FCM): identificador técnico del dispositivo necesario '
        'para el envío de notificaciones push.\n\n'
        '• Datos técnicos: registros de error anónimos e identificadores de sesión '
        'gestionados por Firebase (Google LLC).',
  ),
  _Section(
    title: '3. Cómo usamos tus datos',
    body:
        '• Proporcionar y personalizar el servicio, incluyendo el análisis de '
        'tus sueños mediante Gemini (Google AI).\n\n'
        '• Transcribir grabaciones de voz para facilitar la escritura del diario.\n\n'
        '• Mostrarte estadísticas y patrones emocionales en el panel de control.\n\n'
        '• Enviar notificaciones push cuando personas que sigues publican sueños '
        'o cuando recibes solicitudes de seguimiento (solo si lo activas).\n\n'
        '• Mantener la seguridad de tu cuenta y prevenir usos fraudulentos.',
  ),
  _Section(
    title: '4. Almacenamiento y proveedores',
    body:
        'Hypnos usa los siguientes servicios de Google LLC (EE. UU.):\n\n'
        '• Firebase Authentication — gestión segura de credenciales.\n'
        '• Cloud Firestore — base de datos que almacena entradas del diario y perfiles.\n'
        '• Firebase Storage — archivos de audio de tus grabaciones de voz.\n'
        '• Cloud Functions — procesado del análisis IA en servidores (sin almacenar audio).\n'
        '• Firebase Cloud Messaging — envío de notificaciones push.\n\n'
        'Todos los datos se almacenan en centros de datos de Google con cifrado en '
        'tránsito (TLS) y en reposo. Google actúa como encargado del tratamiento bajo '
        'las condiciones de su DPA.',
  ),
  _Section(
    title: '5. Compartición de datos',
    body:
        'No vendemos ni cedemos tus datos personales a terceros. '
        'Compartimos datos únicamente:\n\n'
        '• Con Google LLC como proveedor técnico del servicio, bajo contrato.\n'
        '• Dentro de funciones sociales, cierta información mínima de interacción '
        '(por ejemplo, solicitudes de seguimiento o estados de relación) puede '
        'ser visible para usuarios autenticados de Hypnos.\n'
        '• Cuando publicas un sueño como «público»: su contenido será visible para '
        'otros usuarios autenticados de la aplicación.\n'
        '• Si lo exige la ley o una resolución judicial.',
  ),
  _Section(
    title: '6. Retención de datos',
    body:
        'Conservamos tus datos mientras tu cuenta esté activa. '
        'Al eliminar tu cuenta, todos los datos personales (entradas del diario, '
        'grabaciones de audio, perfil y relaciones sociales) se eliminan en un plazo '
        'máximo de 30 días. Los sueños que hayas publicado públicamente se eliminan '
        'de inmediato al borrar la cuenta.',
  ),
  _Section(
    title: '7. Tus derechos',
    body:
        'Tienes derecho a:\n\n'
        '• Solicitar acceso a tus datos personales escribiéndonos al correo de privacidad.\n'
        '• Rectificar datos incorrectos desde los ajustes de perfil.\n'
        '• Eliminar tu cuenta y todos los datos asociados en Ajustes › Cuenta y seguridad.\n'
        '• Oponerte al tratamiento de datos con fines de notificaciones desactivándolas '
        'en Ajustes › Notificaciones.\n\n'
        'Para cualquier otra solicitud relacionada con tus derechos, escríbenos a '
        'hypnos.privacy@gmail.com.',
  ),
  _Section(
    title: '8. Menores de edad',
    body:
        'Hypnos Dream Journal no está destinado a menores de 13 años '
        '(o la edad mínima de consentimiento digital en tu país). No recopilamos '
        'datos de menores de forma consciente. Si detectamos que un usuario es menor '
        'de la edad permitida, eliminaremos su cuenta.',
  ),
  _Section(
    title: '9. Seguridad',
    body:
        'Aplicamos medidas técnicas y organizativas para proteger tus datos: '
        'comunicaciones cifradas con TLS, reglas de acceso de Firestore que limitan '
        'la lectura/escritura a los propietarios, autenticación multifactor '
        'compatible y autenticación biométrica opcional en el dispositivo.',
  ),
  _Section(
    title: '10. Cambios en esta política',
    body:
        'Podemos actualizar esta política periódicamente. Te notificaremos '
        'cambios significativos mediante una notificación en la aplicación o por '
        'correo electrónico. El uso continuado de la aplicación tras la publicación '
        'de cambios implica su aceptación.',
  ),
  _Section(
    title: '11. Contacto',
    body:
        'Para cualquier consulta sobre privacidad, escríbenos a:\n'
        'hypnos.privacy@gmail.com',
  ),
];

const _termsEs = [
  _Section(
    title: '1. Aceptación de los términos',
    body:
        'Al crear una cuenta o usar Hypnos Dream Journal («el Servicio»), '
        'aceptas estos Términos y condiciones. Si no estás de acuerdo, no uses '
        'la aplicación.\n\n'
        'Para crear una cuenta debes aceptar expresamente estos Términos y '
        'la Política de privacidad durante el registro.',
  ),
  _Section(
    title: '2. Tu cuenta',
    body:
        'Eres responsable de mantener la confidencialidad de tu contraseña y '
        'de todas las actividades realizadas desde tu cuenta. Debes notificarnos '
        'inmediatamente si sospechas un acceso no autorizado. '
        'Nos reservamos el derecho a suspender o eliminar cuentas que infrinjan '
        'estos términos.',
  ),
  _Section(
    title: '3. Uso permitido del Servicio',
    body:
        'Hypnos está diseñado para el registro personal de sueños, el '
        'bienestar emocional y la exploración de patrones oníricos. '
        'Puedes usar la aplicación para:\n\n'
        '• Registrar y explorar tus sueños en formato texto y audio.\n'
        '• Obtener análisis emocional generado por IA como apoyo al autoconocimiento.\n'
        '• Compartir sueños con la comunidad de forma voluntaria.\n'
        '• Seguir a otros usuarios e interactuar con sus sueños publicados.',
  ),
  _Section(
    title: '4. Contenido del usuario',
    body:
        'Eres el propietario de todo el contenido que publicas en Hypnos. '
        'Al publicar un sueño como «público», otorgas a Hypnos una licencia '
        'limitada, no exclusiva y libre de regalías para mostrarlo a otros '
        'usuarios de la plataforma. Puedes revocar esta licencia eliminando o '
        'despublicando el sueño en cualquier momento.\n\n'
        'Eres responsable de que tu contenido no infrinja derechos de terceros '
        'ni vulnere la ley aplicable.',
  ),
  _Section(
    title: '5. Funciones de inteligencia artificial (Morfeo)',
    body:
        'El análisis de sueños generado por Morfeo (impulsado por Google Gemini) '
        'tiene carácter informativo y de apoyo al autoconocimiento. '
        'No constituye diagnóstico médico, psicológico ni terapéutico. '
        'No sustituye la consulta con profesionales de la salud mental.\n\n'
        'Los resultados del análisis pueden variar y no garantizamos su exactitud. '
        'La IA procesa el texto de tu sueño de forma puntual; no almacenamos el '
        'audio en los servidores de análisis.',
  ),
  _Section(
    title: '6. Funciones sociales',
    body:
        'Al publicar un sueño como «público», cualquier usuario autenticado '
        'de Hypnos podrá verlo, comentarlo y reaccionar a él. Puedes cambiar '
        'la visibilidad o eliminar publicaciones en cualquier momento.\n\n'
        'Las solicitudes de seguimiento requieren la aceptación del destinatario. '
        'Puedes eliminar seguidores desde tu perfil.',
  ),
  _Section(
    title: '7. Usos prohibidos',
    body:
        'Está expresamente prohibido:\n\n'
        '• Publicar contenido ilegal, difamatorio, odioso, violento, sexual '
        'explícito o que acose a otras personas.\n'
        '• Usar la aplicación para actividades fraudulentas o suplantación de identidad.\n'
        '• Intentar acceder sin autorización a datos de otros usuarios.\n'
        '• Realizar ingeniería inversa, descompilar o extraer el código fuente.\n'
        '• Usar bots, scrapers u otros medios automatizados para interactuar con el Servicio.',
  ),
  _Section(
    title: '8. Disponibilidad del Servicio',
    body:
        'Nos esforzamos por mantener Hypnos disponible de forma continua, '
        'pero no garantizamos un tiempo de actividad del 100 %. El Servicio '
        'puede interrumpirse temporalmente por mantenimiento, actualizaciones '
        'o causas ajenas a nuestro control.',
  ),
  _Section(
    title: '9. Descargo de responsabilidad',
    body:
        'El Servicio se proporciona «tal cual» y «según disponibilidad», '
        'sin garantías de ningún tipo, expresas o implícitas. En ningún caso '
        'seremos responsables de daños indirectos, incidentales o consecuentes '
        'derivados del uso o la imposibilidad de uso del Servicio.',
  ),
  _Section(
    title: '10. Terminación',
    body:
        'Puedes cancelar tu cuenta en cualquier momento desde '
        'Ajustes › Cuenta y seguridad. Podemos suspender o cancelar tu acceso '
        'si incumples estos términos, con o sin previo aviso dependiendo de la '
        'gravedad de la infracción.',
  ),
  _Section(
    title: '11. Ley aplicable',
    body:
        'Estos términos se rigen por la legislación española, sin perjuicio '
        'de las normas imperativas del país de residencia del usuario. '
        'Para cualquier controversia, las partes intentarán resolverla '
        'amistosamente antes de acudir a los tribunales.',
  ),
  _Section(
    title: '12. Contacto',
    body:
        'Para preguntas sobre estos términos, escríbenos a:\n'
        'hypnos.support@gmail.com',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// ENGLISH CONTENT
// ─────────────────────────────────────────────────────────────────────────────

const _privacyEn = [
  _Section(
    title: '1. Who we are',
    body:
        'Hypnos Dream Journal ("Hypnos", "we", or "the app") is a dream '
        'journaling service with AI-powered analysis. This Privacy Policy '
        'explains what data we collect, how we use it, and your rights over it.',
  ),
  _Section(
    title: '2. Data we collect',
    body:
        '• Account data: name, email address, and optionally a profile photo. '
        'If you sign in with Google or Apple, we receive the email and name '
        'associated with that account.\n\n'
        '• Journal content: dream titles, text entries, and voice recordings. '
        'We also store AI-generated tags, emotional scores, and analyses.\n\n'
        '• Social data: follow relationships, follow requests, comments, and '
        'reactions on publicly shared dreams.\n\n'
        '• Settings: notification preferences, timezone, profile visibility, '
        'and privacy settings.\n\n'
        '• Device token (FCM): a technical device identifier required to deliver '
        'push notifications.\n\n'
        '• Technical data: anonymous error logs and session identifiers managed '
        'by Firebase (Google LLC).',
  ),
  _Section(
    title: '3. How we use your data',
    body:
        '• To provide and personalise the service, including analysing your '
        'dreams using Gemini (Google AI).\n\n'
        '• To transcribe voice recordings to assist with diary entries.\n\n'
        '• To display emotional statistics and patterns in the dashboard.\n\n'
        '• To send push notifications when people you follow publish dreams or '
        'when you receive follow requests (only if enabled by you).\n\n'
        '• To maintain account security and prevent fraudulent use.',
  ),
  _Section(
    title: '4. Storage and providers',
    body:
        'Hypnos uses the following Google LLC (USA) services:\n\n'
        '• Firebase Authentication — secure credential management.\n'
        '• Cloud Firestore — database storing diary entries and profiles.\n'
        '• Firebase Storage — audio files from your voice recordings.\n'
        '• Cloud Functions — AI analysis processing on servers (audio is not stored).\n'
        '• Firebase Cloud Messaging — push notification delivery.\n\n'
        'All data is stored in Google data centres with TLS encryption in transit '
        'and at rest. Google acts as a data processor under its DPA.',
  ),
  _Section(
    title: '5. Data sharing',
    body:
        'We do not sell or transfer your personal data to third parties. '
        'We share data only:\n\n'
        '• With Google LLC as our technical service provider, under contract.\n'
        '• Within social features, limited interaction metadata (for example, '
        'follow requests or relationship states) may be visible to authenticated '
        'Hypnos users.\n'
        '• When you publish a dream as "public": its content will be visible to '
        'other authenticated users of the app.\n'
        '• When required by law or a court order.',
  ),
  _Section(
    title: '6. Data retention',
    body:
        'We retain your data for as long as your account is active. '
        'When you delete your account, all personal data (diary entries, audio '
        'recordings, profile, and social relationships) is deleted within 30 days. '
        'Any publicly published dreams are deleted immediately upon account deletion.',
  ),
  _Section(
    title: '7. Your rights',
    body:
        'You have the right to:\n\n'
        '• Request access to your personal data by contacting our privacy email.\n'
        '• Correct inaccurate data from the profile settings.\n'
        '• Delete your account and all associated data at Settings › Account & Security.\n'
        '• Object to notification-related data processing by disabling them at '
        'Settings › Notifications.\n\n'
        'For any other data rights request, contact us at hypnos.privacy@gmail.com.',
  ),
  _Section(
    title: '8. Children',
    body:
        'Hypnos Dream Journal is not intended for children under 13 '
        '(or the minimum digital consent age in your country). We do not '
        'knowingly collect data from children below the permitted age. '
        'If we detect that a user is underage, we will delete their account.',
  ),
  _Section(
    title: '9. Security',
    body:
        'We apply technical and organisational measures to protect your data: '
        'TLS-encrypted communications, Firestore access rules that restrict '
        'read/write to data owners, multi-factor authentication support, and '
        'optional on-device biometric authentication.',
  ),
  _Section(
    title: '10. Changes to this policy',
    body:
        'We may update this policy periodically. We will notify you of material '
        'changes via an in-app notification or email. Continued use of the app '
        'after changes are published constitutes acceptance.',
  ),
  _Section(
    title: '11. Contact',
    body:
        'For privacy-related enquiries, contact us at:\n'
        'hypnos.privacy@gmail.com',
  ),
];

const _termsEn = [
  _Section(
    title: '1. Acceptance of terms',
    body:
        'By creating an account or using Hypnos Dream Journal ("the Service"), '
        'you agree to these Terms & Conditions. If you do not agree, do not use '
        'the app.\n\n'
        'To create an account, you must explicitly accept these Terms and the '
        'Privacy Policy during registration.',
  ),
  _Section(
    title: '2. Your account',
    body:
        'You are responsible for keeping your password confidential and for '
        'all activities performed from your account. You must notify us immediately '
        'if you suspect unauthorised access. We reserve the right to suspend or '
        'delete accounts that violate these terms.',
  ),
  _Section(
    title: '3. Permitted use of the Service',
    body:
        'Hypnos is designed for personal dream recording, emotional wellbeing, '
        'and exploration of dream patterns. You may use the app to:\n\n'
        '• Record and explore your dreams as text or audio entries.\n'
        '• Receive AI-generated emotional analysis as a self-awareness tool.\n'
        '• Voluntarily share dreams with the community.\n'
        '• Follow other users and interact with their published dreams.',
  ),
  _Section(
    title: '4. User content',
    body:
        'You own all content you post to Hypnos. By publishing a dream as '
        '"public", you grant Hypnos a limited, non-exclusive, royalty-free licence '
        'to display it to other users of the platform. You may revoke this licence '
        'at any time by deleting or unpublishing the dream.\n\n'
        'You are responsible for ensuring your content does not infringe third-party '
        'rights or violate applicable law.',
  ),
  _Section(
    title: '5. AI features (Morpheus)',
    body:
        'The dream analysis generated by Morpheus (powered by Google Gemini) '
        'is for informational and self-awareness purposes only. It does not '
        'constitute medical, psychological, or therapeutic advice and does not '
        'replace consultation with mental health professionals.\n\n'
        'Analysis results may vary and we do not guarantee their accuracy. '
        'AI processes your dream text at the time of analysis; audio is not '
        'stored on analysis servers.',
  ),
  _Section(
    title: '6. Social features',
    body:
        'When you publish a dream as "public", any authenticated Hypnos user '
        'can view, comment, and react to it. You may change visibility or delete '
        'posts at any time.\n\n'
        'Follow requests require the recipient\'s acceptance. You can remove '
        'followers from your profile.',
  ),
  _Section(
    title: '7. Prohibited uses',
    body:
        'The following are expressly prohibited:\n\n'
        '• Posting illegal, defamatory, hateful, violent, sexually explicit, '
        'or harassing content.\n'
        '• Using the app for fraudulent activities or identity impersonation.\n'
        '• Attempting to access other users\' data without authorisation.\n'
        '• Reverse-engineering, decompiling, or extracting source code.\n'
        '• Using bots, scrapers, or other automated means to interact with the Service.',
  ),
  _Section(
    title: '8. Service availability',
    body:
        'We strive to keep Hypnos continuously available but do not guarantee '
        '100% uptime. The Service may be temporarily interrupted for maintenance, '
        'updates, or causes beyond our control.',
  ),
  _Section(
    title: '9. Disclaimer',
    body:
        'The Service is provided "as is" and "as available", without warranties '
        'of any kind, express or implied. In no event shall we be liable for '
        'indirect, incidental, or consequential damages arising from the use or '
        'inability to use the Service.',
  ),
  _Section(
    title: '10. Termination',
    body:
        'You may cancel your account at any time at Settings › Account & Security. '
        'We may suspend or cancel your access if you breach these terms, with or '
        'without prior notice depending on the severity of the breach.',
  ),
  _Section(
    title: '11. Governing law',
    body:
        'These terms are governed by Spanish law, without prejudice to '
        'mandatory rules of the user\'s country of residence. Any dispute shall '
        'first be attempted to be resolved amicably before resorting to courts.',
  ),
  _Section(
    title: '12. Contact',
    body:
        'For questions about these terms, contact us at:\n'
        'hypnos.support@gmail.com',
  ),
];
