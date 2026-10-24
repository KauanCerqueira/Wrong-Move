# Direção de interface

Registro: produto. Cena de uso: alguém segura o celular em pé numa pausa, às vezes com uma só mão e iluminação variável, e precisa ler cartas e valores imediatamente. Mesa verde-escura e cartas marfim seguem a direção aprovada; o contraste precisa funcionar também em ambiente claro.

Mundo visual implementado: **clube de cartas impresso** — papel marfim, feltro profundo, filetes de cobre e vermelho de lacre. Nada de cenário 3D, personagens grandes ou sala de cassino. A referência de ritmo é Balatro; a de progressão é Angry Birds. Implementação em `scripts/presentation/`; capturas de todas as telas em `prints/`.

## Tipografia

- Marca e números: **Noto Serif** (600/700), com tracking amplo na marca.
- UI e termos técnicos: **Noto Sans** (500/600); capitulares de seção em caixa alta com tracking 2.
- Escala: marca 44, título de tela 22, número principal 24–29, ação 16–18, termo técnico 11–13, capitular 9–11.
- Termos técnicos ficam na **segunda linha** do botão, menores, nunca abreviados de forma ambígua: `Pagar 40` / `call`.

## Paleta (sRGB, Godot)

| Uso | Cor |
|---|---|
| Tinta / fundo profundo | `#08160f` |
| Superfície elevada | `#132c25` |
| Feltro | `#194334` |
| Papel / cartas / texto | `#f3e9d6` |
| Papel sombreado | `#dbcbb0` |
| Texto secundário | `#bcc6b2` |
| Cobre (filetes, capitulares) | `#c3a578` |
| Latão (foco, destaque) | `#e6c98f` |
| Vermelho de ação | `#ba363b` |
| Vinho (desistir) | `#6e2226` |
| Linha | `#64755b` |

Cor nunca é o único indicador: estados também mudam texto, posição e forma. Quatro cores de naipes é opção em Ajustes.

## Métricas

- Base lógica 360×800, margem segura 12/8.
- Ritmo 4/8/12/16/24; alvo de toque mínimo 48×48.
- Baralho desenhado por código: índice duplicado (canto superior esquerdo e inferior direito invertido), pips clássicos para 2–10, cartouche gravado para J/Q/K, ás com guillochê.
- Feltro: rail escuro com filete de cobre, costura pontilhada e monograma em relevo seco. O raio do stadium fica sempre abaixo de metade da largura: em `r = w/2` o Godot desenha uma costura vertical no centro da mesa.
- Mesa: assentos no rail, board central, pote com pilha de fichas, mão do jogador apoiada no feltro e o ledger de fichas à direita.
- Botões de decisão desenham o próprio texto e reduzem a fonte para caber; nunca quebram em três linhas.

## Estados

Normal, hover (filete latão), pressionado (afunda, sem sombra), foco (contorno de papel 2 px), indisponível (texto `#7d8d77`, superfície apagada) e processamento (ação do bot).

## Movimento

- Transição de tela: fade em cascata, 18 ms por seção, 200 ms cada.
- Carta distribuída: 340 ms vindas do ponto do dealer, com rotação curta e overshoot.
- Carta na mão: pode ser **pega e arrastada** (sobe 12%, inclina 3°, sombra própria) e volta ao lugar com mola de 340 ms. Toque sem arrasto amplia.
- Pote e suas fichas: contagem crescente em 340 ms com pulso de 8%; fichas empilhadas por denominação.
- Suas fichas: contagem em 300 ms a cada aposta.
- Assento com a vez: anel respirando (1,15 s por ciclo) e pulso único ao entrar na vez.
- Mesa vencida: chuva de fichas no feltro vazio, 1,8 s, atrás do conteúdo.
- Nada bloqueia o estado. `Reduzir movimento` corta tudo para troca instantânea.

## Layout de tela

- **Início**: capitular, marca em duas linhas, arco de letra com a arte original das cartas, filete, legenda, ações em tickets (papel = ação principal), ledger dos dois saldos, rodapé Regras/Ajustes.
- **Campanha**: carteira no cabeçalho, mapa com selos de cera (vencida = marfim em relevo, liberada = cera vermelha, bloqueada = chumbo) e ficha da mesa fixa no rodapé.
- **Mesa**: quatro zonas. (A) cabeçalho compacto com menu, mesa, blinds/mão e pausa; (B) assentos no topo do feltro com avatar, fichas e cartas fechadas inclinadas; (C) feltro com pote, fichas e cinco posições de board grandes; (D) carta do jogador em leque, barra do jogador (regras, “Você”, fichas, dica) e painel de aposta com status, slider com −/+, cinco atalhos de porcentagem e as três decisões.
- **Resultado da mão**: o mesmo painel vira ficha de resumo com combinação, cartas, pote, fichas e “Próxima mão”, sem trocar de tela.

## Pendências

Conferência física em aparelho (dp × px), contraste medido em ambiente claro e revisão de copy. Fluxos em `docs/MOBILE_UX.md`.
