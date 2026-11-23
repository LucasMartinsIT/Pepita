import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'frases.dart';
import 'models.dart';
import 'theme.dart';

/// Lembretes diários: no máximo 1 por momento, no horário de início.
/// Nunca há notificação de "você não registrou" ou resumo cobrando.
class Notificacoes {
  Notificacoes._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _iniciado = false;

  /// Quando ela toca numa notificação, o id do momento chega aqui
  /// e a tela Hoje abre a sheet de registro correspondente.
  static final ValueNotifier<int?> pedidoAbrirMomento = ValueNotifier(null);

  static const _canalId = 'garimpo';
  static const _canalNome = 'Momentos de garimpo';
  static const _canalDescricao = 'Lembretes carinhosos dos seus momentos de garimpo';

  static Future<void> iniciar() async {
    // Só Android por enquanto; a versão de PC (Windows) entra depois.
    if (_iniciado || defaultTargetPlatform != TargetPlatform.android) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_pepita'),
      ),
      onDidReceiveNotificationResponse: (r) => _aoTocar(r.payload),
    );
    _iniciado = true;

    // App aberto a partir de uma notificação (estava fechado).
    final detalhes = await _plugin.getNotificationAppLaunchDetails();
    if (detalhes?.didNotificationLaunchApp ?? false) {
      _aoTocar(detalhes!.notificationResponse?.payload);
    }
  }

  static void _aoTocar(String? payload) {
    final id = int.tryParse(payload ?? '');
    if (id != null) pedidoAbrirMomento.value = id;
  }

  /// Pede a permissão do sistema (Android 13+). Retorna se foi concedida.
  static Future<bool> pedirPermissao() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  static Future<bool> permissaoConcedida() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? false;
  }

  static NotificationDetails _detalhes(String corpo) => NotificationDetails(
        android: AndroidNotificationDetails(
          _canalId,
          _canalNome,
          channelDescription: _canalDescricao,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: 'ic_pepita',
          color: Paleta.rosaForte,
          largeIcon: const DrawableResourceAndroidBitmap('pepita_grande'),
          styleInformation: BigTextStyleInformation(corpo),
        ),
      );

  /// Cancela tudo e agenda de novo. Chamado ao abrir o app e a cada ajuste —
  /// assim as frases sorteadas variam ao longo dos dias.
  static Future<void> reagendar(List<Momento> momentos, String nome) async {
    if (!_iniciado) return;
    await _plugin.cancelAll();
    for (final m in momentos) {
      if (!m.lembrete) continue;
      final titulo = Frases.sortear(Frases.notifTitulo, nome: nome, momento: m.nome);
      final corpo = Frases.sortear(Frases.notifCorpo, nome: nome, momento: m.nome);
      try {
        await _plugin.zonedSchedule(
          id: m.id,
          title: titulo,
          body: corpo,
          scheduledDate: _proximaOcorrencia(m.ini),
          notificationDetails: _detalhes(corpo),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: '${m.id}',
        );
      } catch (e) {
        debugPrint('Não consegui agendar o lembrete ${m.id}: $e');
      }
    }
  }

  static tz.TZDateTime _proximaOcorrencia(int minutos) {
    final agora = tz.TZDateTime.now(tz.local);
    var quando = tz.TZDateTime(tz.local, agora.year, agora.month, agora.day,
        minutos ~/ 60, minutos % 60);
    if (!quando.isAfter(agora)) {
      quando = tz.TZDateTime(tz.local, agora.year, agora.month, agora.day + 1,
          minutos ~/ 60, minutos % 60);
    }
    return quando;
  }

  /// "Testar lembrete": dispara uma notificação de exemplo na hora.
  static Future<void> testar(String nome) async {
    if (!_iniciado) return;
    final titulo = Frases.sortear(Frases.notifTitulo, nome: nome, momento: 'Garimpo');
    final corpo = Frases.sortear(Frases.notifCorpo, nome: nome, momento: 'Garimpo');
    await _plugin.show(
      id: 99,
      title: titulo,
      body: corpo,
      notificationDetails: _detalhes(corpo),
    );
  }
}
