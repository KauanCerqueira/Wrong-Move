# WRONG MOVE — Astra redesign: auditoria e entrega

## Auditoria técnica

- Engine confirmada: Godot 4.7, GDScript, renderer Compatibility, viewport vertical 360×800.
- O domínio de Texas Hold'em, IA, campanha, Hardcore, tutorial, persistência e feedback sonoro ficam fora da camada de apresentação e foram preservados.
- A mesa antiga já possuía animações de distribuição e pote, mas a hierarquia visual era dominada pelo oval e pelo painel de apostas.
- Os assentos recebiam nomes genéricos (`Bot N`) e os perfis de estilo não chegavam à interface.
- O slider e cinco presets ocupavam permanentemente o rodapé, contrariando a prioridade de rapidez e foco.

## Direção aplicada

Tokens mantidos e consolidados na camada `ClubInk`:

- verde profundo / feltro: `#0C211B`, `#174535`, `#285341`
- marfim: `#F5E9D4`
- vermelho de ação: `#B82E32`
- dourado de detalhe: `#D6AC62`
- texto secundário: `#A1B2A6`
- Noto Serif para marca, títulos e valores; Noto Sans para leitura e ações

## Entregue nesta etapa

### Mesa e apostas

- O jogador vê apenas `Desistir`, `Passar/Pagar` e `Aumentar`.
- `Aumentar` abre um painel compacto sob demanda.
- O painel mostra o valor em tempo real, slider de valor inteiro, limites mínimo/máximo, cancelar e confirmar.
- Os presets 25/50/75/100% e ALL IN não são mais renderizados.
- As regras continuam vindo de `legal_actions`; mínimo, máximo, call, all-in e no-limit permanecem sob responsabilidade do domínio.

### Adversários

- `Bot 1` foi substituído por Nico; os assentos seguintes usam Mara, Otto e Dante.
- Cada perfil tem nome, arquétipo, paleta, monograma e retrato vetorial compacto.
- O destaque de turno continua sendo apenas um sinal de ação legítima; não revela informação privada.

### Baralho

- Ás ganhou um selo central próprio.
- J/Q/K passaram a usar retratos geométricos compactos, mantendo índices e naipes legíveis.
- O verso continua simétrico, verde e marfim, com marca WM.
- Distribuição, flip/revelação, escala e movimento reduzido continuam usando os componentes existentes.

## Pipeline de assets finais

Os retratos vetoriais e as figuras desenhadas em GDScript são placeholders de produção, não ilustrações finais pintadas. O pipeline recomendado para a próxima rodada é:

1. Criar quatro retratos 256×256 em Aseprite, com estados neutro, confiante, desconfiado, satisfeito e frustrado.
2. Criar as 52 faces em uma grade fonte e exportar PNG/WebP por carta, mantendo o índice como fallback de acessibilidade.
3. Exportar o verso em 256×360 e uma variante 64×90 para os adversários.
4. Importar os assets em `assets/art/deck/` e `assets/art/characters/`, substituindo apenas a camada de desenho; não alterar o domínio.
5. Validar leitura em 360×800, texto ampliado e modo quatro cores.

## Validação

- `tools/run_tests.sh` com Godot 4.7.2: 19 suítes, 0 falhas.
- Inclui regras, baralho, avaliação, potes, torneios, agentes, progressão, persistência, tutorial e controles de aposta.
- A execução headless do projeto não apresentou erro de compilação.
- A captura visual automatizada completa ficou bloqueada pela sequência de simulação do capturador neste ambiente; deve ser repetida no editor/dispositivo Android antes da aprovação final de arte.

