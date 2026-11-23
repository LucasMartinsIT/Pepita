<div align="center">

# 💎 Pepita

**O cantinho de garimpo — um app que lembra com carinho, nunca cobra.**

![Flutter](https://img.shields.io/badge/Flutter-Material%203-A9D3F5?logo=flutter&logoColor=white)
![Plataforma](https://img.shields.io/badge/plataforma-Android-D3F2E4)
![Status](https://img.shields.io/badge/status-em%20planejamento-F9C6DA)
![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-E9E0FA)

</div>

---

## 💗 Por que existe

Minha namorada tem um trabalho CLT e, como renda extra, mantém o grupo de ofertas **Garimpô** no WhatsApp: ela procura promoções, troca pelo link de afiliado dela e posta no grupo.

Eu fiz a **Pepita** — uma toupeirinha garimpeira — para ajudar com **uma coisa só**: lembrar, com carinho, dos **3 momentos do dia** em que ela pode postar e deixar ela anotar (se quiser) o que fez.

| Momento | Horário padrão |
|---|---|
| ☀️ Garimpo da manhã | 07:00 – 08:00 |
| 🍙 Garimpo do almoço | 12:00 – 13:00 |
| 🌙 Garimpo da volta | 17:30 – 18:30 |

## 🌷 Regra de ouro

> Este app **não cobra**. É renda extra e o lazer vem primeiro.

- Sem streak, sequência, meta, porcentagem ou ranking.
- Sem vermelho e sem texto de culpa ("atrasado", "pendente", "você esqueceu"…).
- Dia sem registro = **dia de descanso**, sempre mostrado de forma positiva.
- Registrar é opcional. Quantidade também.
- No máximo **1 notificação por momento**, e nenhuma de "você ainda não postou".
- Entre funcionalidade e fofura, **a fofura ganha**.

## ✨ O que vai ter

- **Hoje** — saudação, a Pepita animada e os 3 cards de momento.
- **Registro** — bottom sheet com contador opcional: "Postei! ✨" ou "Hoje não, e tá tudo bem ☁️".
- **Cantinho** — histórico gentil em florzinhas: dias sem registro são botões de flor fechados, descansando.
- **Ajustes** — nome, nome/emoji/horário de cada momento e lembretes ligáveis.
- **Notificações** — uma por momento, com frases carinhosas sorteadas.
- **Pepita** — mascote original desenhada em `CustomPainter`, com 5 estados e comemoração com partículas.

## 🛠️ Stack

- Flutter (Dart 3, Material 3) — Android primeiro, Windows depois a partir do mesmo código
- `flutter_local_notifications` + `timezone` (`America/Sao_Paulo`)
- `shared_preferences` — tudo local, sem backend, sem login
- Fontes **Fredoka** (títulos) e **Quicksand** (texto)
- Animações com o que já vem no Flutter

## 📚 Documentação

| Arquivo | Conteúdo |
|---|---|
| [`docs/SPEC.md`](docs/SPEC.md) | Especificação completa: telas, notificações, visual, frases, dados e critérios de aceite |
| [`CLAUDE.md`](CLAUDE.md) | Diretrizes do projeto para o assistente de código (regra de ouro, stack, convenções, armadilhas do Android) |

## 🗺️ Roteiro

1. [ ] Projeto base, tema, fontes, modelos e store
2. [ ] Tela Hoje + sheet de registro + persistência
3. [ ] Notificações
4. [ ] Ajustes e onboarding
5. [ ] Cantinho
6. [ ] Pepita (painter + estados) e fundo animado
7. [ ] Comemoração, microinterações e ícone
8. [ ] Polimento, acessibilidade, testes e APK release

## 🚫 Fora de escopo

Bot de promoções, automação de link de afiliado, vídeos, carrosséis, login e sincronização na nuvem.

## 🧰 Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

---

<div align="center">

Feito com 💗 pelo Lucas, para a minha namorada.

</div>
