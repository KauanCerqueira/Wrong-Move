# Changelog

##0.1.0-dev —24/10/2026

Primeiro jogável local, sem publicação em loja.

- Motor Texas Hold'em no-limit para2–6, avaliação de mãos, side pots, all-ins e torneio até vencer ou ser eliminado.
- Campanhas Normal/Hardcore com saldos separados, progressão linear, mesas geradas, acesso permanente comprado uma vez e tentativas grátis.
- Bots com informação limitada à observação autorizada; cronômetro e reserva no Hardcore.
- Tutorial guiado de cinco lições, regras gratuitas, dica paga Normal após8 s e revisão da última mão.
- Save A/B, checksum, retomada pausada, preferências, controles de apostas e apresentação portrait provisória.
- Fontes Noto licenciadas, efeitos originais e loop ambiente.
- 19 suítes automatizadas passando no host; primeiro APK debug ARM64 gerado e inspecionado.

### Interface ui-v3

- Sistema visual "clube impresso": tokens, tickets, placas, capitulares e filetes em `club_skin.gd`.
- Baralho desenhado por código com índice duplicado, pips clássicos, cartouche de figuras e verso com monograma.
- Mesa reconstruída a partir do mockup aprovado: cabeçalho compacto, assentos com avatar e cartas fechadas inclinadas, pote com fichas, board grande, mão em leque, barra do jogador e painel único que vira resumo ao fim da mão.
- Aposta com slider horizontal e cinco atalhos de porcentagem (25/50/75/100/all-in) em vez dos antigos ½ pote/pote.
- **Cartas na mesa podem ser pegas e arrastadas**; toque sem arrasto amplia. Distribuição animada a partir do ponto do dealer.
- Contagem animada de pote e fichas, anel de turno respirando e chuva de fichas na vitória.
- Cluster de decisão com presets, valor da rodada, trilho e botões que desenham o próprio texto sem quebrar linha.
- Início com arco de letra, ledger dos dois saldos e ações em tickets; campanha com selos de cera e ficha fixa da mesa.
- Resultado e pausa com placas de veredito e contexto do torneio; Ajustes com interruptores próprios.
- QA visual em `tools/capture_screens.gd` e capturas de todas as telas em `prints/`.

Limitações: aparência ainda em refinamento; não validado em celulares físicos; balanceamento/duração, acessibilidade completa, testes extensos de bots, recuperação de dois slots inválidos e assinatura/distribuição de produção continuam pendentes. Não equivale ao release1.0.0 planejado.
