# Validação real —0.1.0-dev

Data:24/10/2026. Estado: primeiro jogável, **não release1.0.0 aceito**. Nenhum aparelho físico estava conectado (`adb devices -l` sem dispositivos). Testes no host não comprovam desempenho, toque, retomada ou funcionamento offline em Android.

## Executado

Última execução completa: **19 suítes, zero falhas,7.868 ms**, exit code0, no Godot4.7.2. Inclui `test_session_services.gd` (progresso do tutorial, dica indisponível/sem saldo, rollback de débito sob falha de rename, retry e reabertura sem nova cobrança) e `test_release_baseline.gd` (defaults reais versus especificação e configuração comprada imutável). O codec também rejeita torneio com cartas repetidas entre assentos ou conservação de fichas quebrada, mesmo com checksum válido. O teste compara o contrato da recomendação após JSON, não a representação interna int/float das Variants.

- Projeto Godot4.7.2 Compatibility/GDScript importado e executado no host Linux/WSL.
- Runner estrito `tools/run_tests.sh`: domínio, integração e simulação; rejeita também erros de script que não alteram exit code da engine. Resultado final registrado abaixo.
- Ranking: categorias/kickers/A2345/board-only e2.000 mãos aleatórias de sete cartas contra oráculo independente de todas as combinações de cinco.
- Regras: raises curtos, reabertura, BB nominal, side pots, excedentes, empates e transição dead-button. Simulação de120 torneios reproduzíveis, formatos2–6, com conservação de fichas e roundtrip JSON.
- Progressão:10.000 índices em ambos os modos, preços/tetos, hash de estilos, primeiras seis mesas e índices/saldos de100 dígitos.
- Persistência: slots A/B, checksum, versões futuras, falhas de gravação/rename, comandos repetidos e revisão antiga. Relógio testado com tempo controlado, pausa exata e retomada conservadora, incluindo integração com save.
- Tutorial: cinco práticas isoladas, ações esperadas e ausência de prêmio de campanha. Teste adicional de progresso das lições e transações de dicas.
- Smoke visual no host (Mesa llvmpipe/OpenGL, áudio Dummy): início→mapa→mesa, clique real do botão Pagar/Passar chegando ao motor; captura360×800 em `docs/validation/dev-0.1.0/`. Não é teste de Android nem prova de todas as escalas/tamanhos.
- Benchmark de desenvolvimento:18 cenários de decisão, forças0/5/8, boards0/3/5,2/6 participantes; maior amostra aproximadamente65 ms no host após otimizar avaliação de mãos. Uma amostra por cenário, **não p95 nem evidência R08**.
- Exportação Gradle do APK debug; inspeção de assinatura, manifesto e ABI. Identidade `com.wrongmove.game.debug`, versão0.1.0-dev/code1, minAPI28, target35, compile36, ARM64. Assinatura debug v2 válida. Somente permissão VIBRATE; sem INTERNET. Ferramentas em BUILD_ANDROID.md.

Capturas de referência do host: [início](validation/dev-0.1.0/home.png) e [mesa](validation/dev-0.1.0/table.png). São interface provisória em360×800, não screenshots de celular.

## Identificação do APK conferido

- Arquivo: `builds/android/wrong-move-debug.apk`.
- SHA256: `e6ca59ee0f8d312d2248bc77e29b78b76730795853558b837389c62dcd00dc1f`.
- Certificado debug, SHA256 público: `d001348554fcd10ee875e6245a0e7656ab3845a0180666f128b7819203ae442f`.
- `apksigner verify --verbose`: exit0, assinatura v2 válida, um signatário. Não é assinatura de produção.
- `aapt`: ARM64, OpenGL ES3.0, portrait fixo, debuggable=true, allowBackup=false; somente VIBRATE.
- Avisos Godot MIT, inventário de assets e duas licenças SIL OFL presentes no APK. Pastas docs/tests/tools/specs não incluídas.
- Build final exportado com exit0. Nenhum teste de instalação física realizado. Hash muda ao recompilar.

## Pendências para release

- Instalar/atualizar em dois celulares reais; modo avião, recortes, texto ampliado e controles sem cortes.
- Matriz completa de regras10.000 mãos e testes extensos pareados de força/ritmo; as120 simulações não substituem estes gates.
- Testes de interrupção físicos,100 ciclos por tipo,2 h por aparelho, métricas de frames/startup/bots e kill abrupto.
- Revisão de tutorial com cinco iniciantes e ajustes de linguagem/entendimento.
- Acabamento visual/animação/acessibilidade; completar dados de tutorial/glossário, assets e licenças de distribuição.
- Recuperação confirmada quando ambos os slots forem inválidos, upgrade de release e revisão final dos casos de erro.
- Preset1.0.0 de produção, chave dedicada sob custódia do autor, pacote fonte/documentos e hashes finais.

As tarefas parcialmente implementadas permanecem desmarcadas em tasks.md. R01–R12 continuam abertos até cumprir cada requisito integralmente. O APK atual serve para experimentar o primeiro jogável, não para alegar entrega1.0.0.
