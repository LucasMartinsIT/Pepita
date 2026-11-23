# Pepita — o cantinho de garimpo

App Android (Flutter) pessoal, feito só para a minha namorada. Lembra, com carinho, dos 3 momentos do dia em que ela posta promoções no grupo de ofertas dela (marca **Garimpô**) e deixa ela anotar, se quiser, o que fez. A especificação completa está em `docs/SPEC.md` — leia antes de qualquer tarefa.

## Regra de ouro (vale para código, texto e visual)
Este app **não cobra**. É renda extra e o lazer dela vem primeiro.
- Nada de streak, sequência, meta, porcentagem de "cumprimento", contador regressivo ou ranking.
- Nunca usar vermelho, "atrasado", "pendente", "você esqueceu", "não fez" ou qualquer texto de culpa.
- Dia sem registro = "dia de descanso", sempre mostrado de forma positiva (Pepita dormindo feliz).
- Registrar é sempre opcional; quantidade é sempre opcional.
- No máximo 1 notificação por momento. Nada de lembrete de "você ainda não postou".
- Em caso de dúvida entre funcionalidade e fofura: a fofura ganha. O esforço deste projeto vai para visual e animação, não para complexidade.

## Stack
- Flutter (stable mais recente), Dart 3, Material 3, só Android por agora. Versão de PC (Windows) depois, a partir do mesmo código — não use nada que impeça isso sem isolar atrás de uma interface.
- `flutter_local_notifications` + `timezone` (fuso fixo `America/Sao_Paulo`)
- `shared_preferences` para persistência (dados pequenos, tudo local, sem backend, sem login)
- `google_fonts` (Fredoka para títulos, Quicksand para texto) — ou fontes empacotadas em `assets/fonts` para funcionar offline
- Animações: preferir o que vem no Flutter (`AnimationController`, `AnimatedSwitcher`, `TweenAnimationBuilder`, `CustomPainter`). Pacote extra só se trouxer ganho claro (ex.: `flutter_animate`), e avisar antes.
- Mascote Pepita desenhada em `CustomPainter` (vetorial, animável). Sem imagens de personagens de terceiros.

## Estrutura
```
lib/
  main.dart                 # init (timezone, notificações, store) + MaterialApp
  theme.dart                # paleta, fontes, sombras, raios
  models.dart               # Momento, Registro, helpers de data
  store.dart                # ChangeNotifier + shared_preferences
  notifications.dart        # agendar/cancelar lembretes diários
  frases.dart               # bancos de frases carinhosas (ver SPEC)
  widgets/pepita.dart       # mascote + estados/animações
  widgets/...               # cards, sheets, brilhos, corações
  screens/hoje.dart
  screens/cantinho.dart     # histórico gentil
  screens/ajustes.dart
```

## Convenções
- Código, nomes e comentários em **português**. Textos de UI em pt-BR, tom carinhoso, tratando-a por "você" (nome dela configurável, padrão "linda").
- Cores e estilos só via `theme.dart` — nada de cor solta em widget.
- Toda interação tem resposta visual (escala, brilho, haptic leve `HapticFeedback.lightImpact`).
- Respeitar "reduzir animações" do sistema (`MediaQuery.disableAnimations`).

## Armadilhas Android (já sabidas)
- `flutter_local_notifications` exige **core library desugaring** no `android/app/build.gradle(.kts)`.
- Android 13+: pedir `POST_NOTIFICATIONS` em tempo de execução, com uma tela fofa explicando antes.
- Usar `AndroidScheduleMode.inexactAllowWhileIdle` (não precisa de permissão de alarme exato; alguns minutos de atraso são aceitáveis).
- Declarar os receivers de boot do plugin no `AndroidManifest.xml` para os lembretes sobreviverem a reinício.
- Ícone pequeno da notificação: drawable branco/monocromático (silhueta da Pepita), não o ícone colorido.
- Permissão `INTERNET` no manifest se usar `google_fonts` em tempo de execução.

## Comandos
- `flutter pub get` · `flutter analyze` · `flutter test` · `flutter run` · `flutter build apk --release`

## Fora de escopo (não implementar)
Bot de promoções, automação de link de afiliado, vídeos da Shopee, carrosséis, login, nuvem/sincronização.
