# SPEC — Pepita 💗

> App Android pessoal para a minha namorada. Versão 1.0 = projeto completo (não é MVP). Versão de PC fica para depois, no mesmo código Flutter.

## 1. Contexto e propósito

Ela trabalha CLT das 8h às 17h30 e, como renda extra, mantém o grupo de ofertas **Garimpô** no WhatsApp: ela acha promoções em outros grupos, troca o link pelo link de afiliado dela e posta no grupo dela, tudo manualmente.

O app serve para **uma coisa só**: lembrar, com carinho, dos 3 momentos do dia em que ela pode postar promoções, e deixar ela anotar (se quiser) o que fez. Vídeos, carrosséis e qualquer outra tarefa ficaram de fora de propósito.

### Princípios (inegociáveis)
1. **Acolher, nunca cobrar.** Postar 3 promoções está ótimo. Postar 0 também está tudo bem.
2. **Lazer em primeiro lugar.** O app nunca pede nada fora dos 3 momentos e nunca insiste.
3. **Registro opcional.** Ela pode registrar, pular ou simplesmente ignorar. Quantidade também é opcional.
4. **Fofura é a funcionalidade principal.** O orçamento técnico vai para o visual, as animações e a sensação de usar o app.

Ver a lista de "nunca fazer" no `CLAUDE.md` (streaks, metas, vermelho, linguagem de culpa etc.).

## 2. Os 3 momentos

| id | Nome padrão | Emoji | Início | Fim |
|---|---|---|---|---|
| 0 | Garimpo da manhã | ☀️ | 07:00 | 08:00 |
| 1 | Garimpo do almoço | 🍙 | 12:00 | 13:00 |
| 2 | Garimpo da volta | 🌙 | 17:30 | 18:30 |

- Ela pode mudar nome, emoji, início, fim e ligar/desligar o lembrete de cada momento (tela Ajustes).
- Sempre são exatamente 3 momentos (sem adicionar ou remover — mantém simples).
- Estados de um momento em relação ao horário atual: `antes` · `agora` · `depois`.
- Ela pode registrar um momento a qualquer hora do dia (inclusive depois que passou) — nunca bloquear.

## 3. Telas

Navegação: barra inferior flutuante arredondada (pílula creme com sombra rosa) com 4 abas e ícones fofos: **Hoje** · **Cantinho** · **Caderninho** · **Ajustes**. Troca de aba com transição suave (fade + leve slide) e o ícone ativo dá um "pulinho".

### 3.1 Hoje (tela principal)
De cima para baixo:
1. **Saudação** de acordo com a hora ("Bom dia, linda ☀️" / "Boa tarde, linda" / "Boa noite, linda 🌙"), com uma frase do banco `saudacao` embaixo, em texto menor.
2. **Pepita** grande (~180dp) no centro, em cima de uma "nuvem/almofada" creme, com o estado adequado (ver §5). Tocar na Pepita: ela dá um pulinho, solta 3–5 corações e diz uma frase do banco `carinho` num balãozinho que some em 3s.
3. **Os 3 cards de momento**, empilhados verticalmente:
   - Fundo: `antes` = creme; `agora` = rosa-bebê com **brilho pulsante suave** na borda (glow animado em loop lento, 2,5s); `depois` sem registro = creme com opacidade levemente menor (nunca cinza triste).
   - Conteúdo: emoji grande, nome, faixa de horário ("07:00 – 08:00") e, à direita, o estado do registro:
     - sem registro + `agora`: botão pílula "Bora garimpar 💎"
     - sem registro + `antes`: texto suave "mais tarde" com reloginho
     - sem registro + `depois`: botão discreto "anotar" (sem destaque, sem cobrança)
     - `postei` com quantidade: selinho menta com "✨ 7 achados"
     - `postei` sem quantidade: selinho menta "✨ passei por aqui"
     - `descanso`: selinho lavanda "☁️ descansei"
   - Tocar no card abre a **sheet de registro** (§3.2). Já registrado → abre a sheet com os valores atuais para editar ou apagar.
4. **Rodapé do dia**, só se tiver pelo menos 1 registro `postei` com quantidade: "Hoje você garimpou **12** achados 💗" com pequenas joias animadas. Sem registro → frase do banco `semPressao`. Nunca mostrar "0".

### 3.2 Sheet de registro (bottom sheet)
Abre com animação de mola (spring) de baixo para cima; a Pepita aparece pequenininha "espiando" na borda superior da sheet.
- Título: "{emoji} {nome do momento}"
- Pergunta suave: "Como foi esse garimpo?"
- **Contador opcional**: botões grandes redondos `−` e `+` (rosa e azul bebê) com o número no meio em fonte grande. Começa em vazio ("—"), não em 0. Cada toque: número troca com animação de rolagem para cima/baixo + haptic leve. Pressionar e segurar o `+` acelera.
- Atalhos em chips: `1` `3` `5` `10` (só preenche o contador).
- Botões:
  - **"Postei! ✨"** (principal, rosa) → salva `postei` com quantidade (ou sem, se vazio) → fecha a sheet → **comemoração** (§5.3).
  - **"Hoje não, e tá tudo bem ☁️"** (secundário, lavanda) → salva `descanso` → fecha → Pepita boceja/se aconchega + frase do banco `descanso`.
  - Se já existia registro: link "apagar anotação" (sem confirmação assustadora; desfazer via snackbar fofa por 4s).

### 3.3 Cantinho (histórico gentil)
Objetivo: ela ver o que fez com carinho, nunca o que "faltou".
- Topo: "Seu cantinho 💗" + Pepita pequena sentada numa almofada.
- **Semana atual** em 7 "florzinhas" (seg–dom). Cada dia é uma flor:
  - dia com pelo menos 1 `postei`: flor rosa desabrochada, com 1 a 3 pétalas brilhantes conforme o número de momentos com postagem
  - dia sem `postei`: botão de flor fechado em lavanda com "zzz" bem pequeno = **dia de descanso** (bonito, não triste)
  - hoje: contorno pontilhado animado
  - tocar num dia → card abaixo mostra os 3 momentos daquele dia
- Setas para semanas anteriores (sem limite).
- Card "Achados da semana": soma das quantidades registradas, com uma frase do banco `conquista`. Se a soma for 0 ou não houver quantidade, mostrar frase do banco `semPressao` em vez de número.
- **Proibido aqui:** porcentagens, médias, comparação entre semanas, "melhor dia", sequência de dias.

### 3.4 Ajustes
- "Como posso te chamar?" — campo de nome (padrão "linda").
- Os 3 momentos, cada um num card editável: nome, emoji (grade de ~16 emojis fofos para escolher), horário de início e de fim (time picker com o tema do app) e switch "me lembrar" (switch customizado em formato de nuvem/coração).
- Validação gentil: fim depois do início; se ela errar, a Pepita inclina a cabeça e o texto diz "hmm, o fim precisa vir depois do começo 🙈" (nunca vermelho).
- "Testar lembrete" → dispara uma notificação de exemplo na hora.
- "Restaurar horários padrão".
- Rodapé: "feito com 💗 pelo Lucas" (versão do app em texto pequeno).
- Toda alteração de horário/switch **reagenda** as notificações imediatamente.

### 3.5 Caderninho (anotações livres)
Quarta aba, entre Cantinho e Ajustes: um cantinho para anotar coisinhas (ideias, lembretes, rabiscos).
- Fundo de **folha de caderno fofinha**: linhas azul-bebê, margem rosa e furinhos de fichário.
- Cada nota é um papelzinho colado com fitinha, levemente inclinado. Papéis em 6 cores pastel.
- **Fontes fofinhas** à escolha em cada nota: Letrinha (Patrick Hand), Chique (Pacifico), Rabisco (Caveat) e Redondinha (Sniglet).
- Botão "+ nova notinha" abre uma sheet (mesma mola da sheet de registro, com a Pepita espiando): texto, fonte, papel e a chave opcional **"com bolinha de feitinho"**.
- A bolinha de feitinho é só um coração que se preenche ao tocar: **sem prazo, sem contagem, sem lista de "pendentes"**. Nota feita fica um pouco mais clarinha (nunca riscada).
- Tocar na nota edita; "apagar notinha" com desfazer pela snackbar fofa por 4s.
- Dados: `notas` = lista de `{id, texto, fonte, papel, tarefinha, feita}` em `shared_preferences`.

### 3.6 Primeira abertura (onboarding, 3 telas)
1. Pepita acenando: "Oi, linda! Eu sou a Pepita 💎 Vou te lembrar dos seus momentos de garimpo, sem pressão nenhuma."
2. Os 3 horários padrão em cards: "Esses horários funcionam? Você pode mudar quando quiser."
3. Pedido de notificação: "Posso te mandar um recadinho na hora do garimpo?" → botão abre o pedido de permissão do sistema (Android 13+). Se ela negar: "Tudo bem! Você pode ligar depois nos ajustes 💗" e o app funciona normal.
Paginação com bolinhas que viram coraçõezinhos; transições com parallax leve da Pepita.

## 4. Notificações

- 1 notificação diária por momento com lembrete ligado, no **horário de início**. Repetição diária (`matchDateTimeComponents: DateTimeComponents.time`), `AndroidScheduleMode.inexactAllowWhileIdle`, fuso `America/Sao_Paulo`.
- IDs = id do momento (0, 1, 2). Ao mudar ajustes: cancelar todas e reagendar.
- Canal: id `garimpo`, nome "Momentos de garimpo", importância padrão (som e vibração padrão, **sem** tela cheia, sem persistente).
- Visual: `color` = rosa forte do app, ícone pequeno = silhueta monocromática da Pepita (`res/drawable/ic_pepita`), `largeIcon` = Pepita colorida (PNG gerado a partir do painter ou feito à mão), estilo `BigTextStyle`.
- Texto: título e corpo **sorteados** dos bancos `notifTitulo` e `notifCorpo` (com `{nome}` e `{momento}` substituídos). Como o agendamento é repetido, sortear novas frases toda vez que o app for aberto e reagendar — assim as mensagens variam ao longo dos dias.
- Tocar na notificação abre o app já com a sheet de registro do momento correspondente (payload = id do momento).
- **Nunca** enviar lembrete de "você não registrou", resumo de fim de dia cobrando ou qualquer notificação além dessas 3.

## 5. Visual e animação (onde vai o esforço)

### 5.1 Paleta (definir em `theme.dart`)
| Token | Hex | Uso |
|---|---|---|
| creme | `#FFF8F0` | fundo principal |
| cremeEscuro | `#F8EBDD` | almofadas, divisores |
| rosaBebe | `#FDE4EE` | card "agora", superfícies |
| rosa | `#F9C6DA` | sombras, bordas |
| rosaForte | `#EE8FB4` | botão principal, destaques |
| azulBebe | `#D7ECFF` | botões secundários, céu |
| azul | `#A9D3F5` | detalhes |
| menta | `#D3F2E4` | selo "postei" |
| lavanda | `#E9E0FA` | descanso |
| cacau | `#6E4F5E` | texto principal (nunca preto puro) |
| cacauClaro | `#A88D9A` | texto secundário |
| dourado | `#FFD98A` | joias, brilhos |

- Cantos muito arredondados (cards 28dp, botões em pílula), sombras rosadas suaves e difusas, nada de linhas duras.
- Fontes: **Fredoka** (títulos, números grandes) e **Quicksand** semibold (texto).
- Fundo da tela Hoje: degradê vertical bem sutil creme → rosa-bebê, com 5–8 elementos flutuando devagar em parallax (nuvenzinhas, corações e estrelinhas em opacidade baixa, movimento senoidal lento). O céu muda de leve conforme o momento do dia (manhã mais azulzinho, almoço creme, volta pôr-do-sol rosado/lavanda).

### 5.2 A mascote Pepita (`widgets/pepita.dart`)
Personagem **original**: uma toupeirinha garimpeira. Desenhada em `CustomPainter`, tudo em formas arredondadas.
- Corpo: gota/bolinha gordinha cor pêssego-rosado claro (`#F6D3C6`), barriguinha creme.
- Olhos: arquinhos fechados felizes (estado padrão) ou pontinhos brilhantes (surpresa/alegria). Bochechas rosadas.
- Focinho: bolinha rosa pequena; patinhas curtinhas com almofadinhas rosa.
- Capacete de garimpeira creme com uma **lanterna em forma de coração** que acende (glow dourado) nas comemorações.
- Segura (ou tem ao lado) uma **pepita/joia dourada** facetada que brilha de tempos em tempos.

Estados (troca com `AnimatedSwitcher`/interpolação, nunca corte seco):
| Estado | Quando | Animação |
|---|---|---|
| `tranquila` | padrão | respiração (escala 1.0↔1.03, 3s), piscar a cada 3–6s aleatório, joia cintila de vez em quando |
| `animada` | algum momento está `agora` | balança de lado a lado devagar, lanterna acesa piscando suave |
| `comemorando` | após "Postei!" | ver §5.3 |
| `aconchegada` | após "descansei" / noite depois do último momento | olhinhos fechados, abraça a joia, "zzz" flutuando, respiração mais lenta |
| `curiosa` | erro de validação, toque longo | inclina a cabeça, "?" pequeno |

Estrutura do código: um único widget `Pepita(estado:, tamanho:)` que controla os `AnimationController`s; o painter recebe parâmetros (abertura dos olhos, inclinação, escala, brilho da lanterna), para que ela possa futuramente trocar o desenho por arte dela sem mexer no resto.

### 5.3 Comemoração ("Postei!")
Sequência (~1,6s, interrompível):
1. Pepita pula (squash & stretch), lanterna acende.
2. Explosão de 12–20 partículas (corações rosa, estrelinhas douradas, joinhas azuis) saindo da Pepita com gravidade leve e fade.
3. O selinho do card aparece com escala elástica (0 → 1.15 → 1).
4. Se tiver quantidade, o número "voa" até o rodapé do dia e o total sobe contando.
5. Balão com frase do banco `comemoracao`.
6. Haptic: `mediumImpact` no pulo.

### 5.4 Microinterações
- Todo botão: escala 0.95 ao pressionar e volta com mola.
- Cards entram em cascata (stagger 80ms) ao abrir a tela.
- Card "agora": glow pulsante + emoji balançando levemente.
- Contador: dígitos rolam; ao passar de 10, 20, 30… surgem brilhinhos extras.
- Pull-to-refresh na tela Hoje: a Pepita desce cavando um buraquinho (só por diversão).
- Snackbar customizada: pílula creme com a Pepita mini à esquerda.
- Respeitar `MediaQuery.disableAnimations`: trocar movimentos por fades simples.

### 5.5 Ícone do app
Rosto da Pepita com o capacete de coração sobre fundo rosa-bebê, em ícone adaptativo (foreground + background). Nome no launcher: **Pepita**.

## 6. Bancos de frases (`frases.dart`)
Sorteio aleatório, sem repetir a última usada. `{nome}` = nome configurado; `{momento}` = nome do momento.

**notifTitulo**
- "Hora do garimpo, {nome}! 💎"
- "Psiu, {nome}… ✨"
- "{momento} chegou 🌸"
- "A Pepita achou um tempinho pra você 💗"
- "Oi, {nome}! ☁️"

**notifCorpo**
- "Se der, posta umas promos. Se não der, tudo bem também 💕"
- "Achou algo legal? Compartilha com a turma. Achou nada? Descansa 🌷"
- "Sem pressa nenhuma: posta quantas você quiser 💎"
- "Uma promo já vale. Nenhuma também vale 🫶"
- "Bora garimpar uns achadinhos? Só se você estiver a fim ✨"
- "Seu tempo é seu. Se quiser, o Garimpô tá te esperando 💗"

**saudacao**
- "Vamos com calma hoje 🌷"
- "Você já faz muita coisa, viu? 💗"
- "Hoje é dia de fazer o que der ✨"
- "Respira, toma uma água e segue no seu ritmo ☁️"

**comemoracao**
- "Que garimpo lindo! 💎"
- "Arrasou, {nome}! ✨"
- "O Garimpô agradece 💗"
- "Achadinhos entregues com carinho 🌸"
- "Olha você brilhando mais que a minha pepita! ✨"

**descanso**
- "Descansar também é produtivo 💤"
- "Tá tudo bem. Amanhã tem mais 🌙"
- "Seu lazer vem primeiro, sempre 💗"
- "Hoje a Pepita guarda as joias pra você ☁️"

**semPressao**
- "Hoje é sobre você, não sobre números 🌷"
- "Nenhuma cobrança aqui, só carinho 💗"
- "O que der, deu ✨"

**conquista**
- "Quantos achadinhos! 💎"
- "Que semana garimpada ✨"
- "A turma do Garimpô tem sorte de ter você 💗"

**carinho** (tocar na Pepita)
- "Oi! 💗" · "Hihi, cócegas!" · "Achei uma joia: você ✨" · "Já bebeu água hoje? 💧" · "Tô orgulhosa de você 🌸"

## 7. Dados

Tudo local em `shared_preferences` (JSON):
- `nome`: string
- `momentos`: lista de 3 `{id, nome, emoji, ini (minutos do dia), fim, lembrete}`
- `registros`: mapa `"AAAA-MM-DD" → { "0": {tipo, qtd?}, "1": …, "2": … }`, com `tipo` ∈ `postei` | `descanso` e `qtd` int opcional (1–999)
- `notas`: lista de notinhas do Caderninho (ver §3.5)
- `onboardingFeito`: bool

`store.dart`: `ChangeNotifier` com `carregar()`, `salvarRegistro(dia, idMomento, registro)`, `apagarRegistro(...)`, `atualizarMomento(...)`, `restaurarPadrao()`. Cada escrita persiste na hora. Mudança em momentos → `Notificacoes.reagendar(momentos, nome)`.

## 8. Pronto quando (critérios de aceite)
- [ ] `flutter analyze` sem avisos; APK release instala num Android 13+ e num Android 10.
- [ ] Notificações chegam nos 3 horários padrão (tolerância de alguns minutos), continuam após reiniciar o celular e abrem a sheet do momento certo.
- [ ] Mudar um horário nos Ajustes reagenda; "Testar lembrete" funciona; negar a permissão não quebra nada.
- [ ] Registrar com quantidade, sem quantidade, "descansei", editar e apagar (com desfazer) funcionam e sobrevivem ao fechar o app.
- [ ] Cantinho mostra semanas passadas corretamente; dias sem registro aparecem como descanso fofo.
- [ ] Nenhum texto do app contém: "atrasad", "pendente", "esqueceu", "meta", "sequência", "streak", "falhou", "não fez" (fazer um teste que verifica isso nos bancos de frases e nos textos da UI).
- [ ] Nenhuma cor vermelha/laranja de alerta em lugar nenhum.
- [ ] Pepita com os 5 estados funcionando; comemoração completa; tudo a 60fps num celular intermediário.
- [ ] Com "reduzir animações" ligado, o app continua bonito e sem movimento forte.

## 9. Ordem de implementação sugerida
1. `flutter create` (org `com.lucas`, nome `pepita`), tema, fontes, modelos, store.
2. Tela Hoje estática + sheet de registro + persistência.
3. Notificações (config Android, permissão, agendamento, payload → abrir sheet).
4. Ajustes + reagendamento. Onboarding.
5. Cantinho.
6. **Pepita** (painter + estados) e fundo animado.
7. Comemoração, microinterações, transições, ícone do app.
8. Polimento visual, passe de acessibilidade, testes, build release.

## 10. Futuro (não fazer agora)
- Versão Windows a partir do mesmo código (notificações via `flutter_local_notifications` no Windows ou bandeja).
- Arte da Pepita refeita por ela mesma (o painter foi pensado para ser trocado).
- Integração com um bot de ofertas próprio (aba de fila para aprovar promoções) — projeto separado.
