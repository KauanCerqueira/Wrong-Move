# Research and decisions

Consulta em24/10/2026. Escolhas fechadas sob delegação do autor; defaults e gates orientam implementação e validação.

## Engine

**Decision**: Godot 4.7.2 estável, GDScript tipado, editor/templates iguais.
**Rationale**: arquivo oficial confirma essa versão estável e 4.8 beta. Escolha verificada independentemente do GDD.
**Alternatives considered**: C# amplia toolchain sem necessidade atual; Android nativo/web complicam reaproveitamento futuro no PC.
**Source**: [Arquivo oficial](https://godotengine.org/download/archive/).

## Android

**Decision**: Compatibility; Android9+ ARM64,3 GB, targetAPI35; JDK17/SDK/templates. APK debug primeiro, APK release assinado+fontes na entrega, sem loja/AAB obrigatório.
**Rationale**: Godot documenta requisitos por renderer e exportação com JDK/SDK. O alvo do produto ainda precisa de validação física.
**Alternatives considered**: Vulkan e plugins não trazem benefício necessário à mesa 2D.
**Sources**: [Exportação](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [requisitos](https://docs.godotengine.org/en/stable/about/system_requirements.html), [Android Developers](https://developer.android.com/games/engines/godot/godot-export).

## Interface

**Decision**: containers/âncoras, safe area e base lógica 360×800, com fixtures de outras proporções.
**Rationale**: documentação suporta adaptação por tamanho-base; dimensões de produto definidas em DESIGN.md, verificadas pelos gates físicos.
**Alternatives considered**: coordenadas fixas e cinco bots em linha sacrificam leitura.
**Source**: [Múltiplas resoluções](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html).

## Save

**Decision**: agregado JSON versionado em slots A/B, checksum/rename atômico; ConfigFile para preferências e clock checkpoint conservador compacto. Protocolo fechado em PERSISTENCIA_RELEASE.md.
**Rationale**: escala pequena/offline; saldo e partida precisam ficar consistentes. Robustez é responsabilidade do protocolo, não garantia automática do formato.
**Alternatives considered**: SQLite/event sourcing completos são complexidade inicial sem necessidade; arquivos independentes por saldo/partida dificultam commit.
**Source**: [Salvando jogos](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html).

## Regras, bots e infinito

**Decision**: regras verificadas com referência TDA; fixtures próprias. Bots locais com observação filtrada e RNG independente; templates de desafio com força/blinds limitados.
**Rationale**: offline e baralho justo; equidade amostrada não pode usar cartas reais ocultas. Mais força muda decisões e chances de vitória, nunca o embaralhamento.
**Alternatives considered**: LLM remoto, solver completo e acesso do agente ao GameState não atendem escopo/custo/isolamento.
**Source para regras**: [Poker TDA](https://www.pokertda.com/view-poker-tda-rules/).

## Conclusão da pesquisa

Engine, versão, renderer, save, testes, Android, arquitetura e entrega têm defaults fechados, sem pergunta bloqueante. Revisão independente apontou isolamento de ocultos, commit econômico e limites da progressão; incorporados nos contratos. Não há execução de exportação/testes do jogo nesta fase. Godot não foi encontrado no PATH da sessão; o marco1 verificará o host de desenvolvimento, sem inferir instalação do editor Windows.

## Fechamento de release

Entrega por APK assinado local+fontes evita depender de conta/postagem externa. Identidade, matriz, defaults, assinatura e R01–R12 estão definidos em RELEASE_ANDROID.md. Pesquisa de assinatura: [Android Developers](https://developer.android.com/studio/publish/app-signing). Conteúdo e fonte: [Noto upstream](https://github.com/notofonts/latin-greek-cyrillic). Abertura curta pós-flop não usa completion de limit: [discussão técnica TDA](https://www.pokertda.com/forum/index.php?topic=842.0). Valores definidos por projeto não são apresentados como padrões oficiais.
