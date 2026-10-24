# Wrong Move

Texas Hold'em offline, gratuito e pensado para Android em pé. Em desenvolvimento; não é release1.0.0.

## Executar

Abra `project.godot` no Godot4.7.2 padrão (GDScript), renderer Compatibility, e pressione F6 na cena app ou F5 no projeto.

```bash
godot --headless --path . --editor --import
bash tools/run_tests.sh
godot --path .
```

Selecionar um grupo: `bash tools/run_tests.sh --suite=domain` (também integration/simulation). O wrapper também rejeita erros de script que a engine pode registrar sem alterar o código de saída. Para indicar outro executável: `WRONG_MOVE_GODOT=/caminho/godot bash tools/run_tests.sh`. A primeira importação cria `.godot/`, não versionada.

O executável baixado nesta sessão está fora do repositório em `/root/.local/share/wrong-move/tools/Godot_v4.7.2-stable_linux.x86_64`. No Windows, use o editor Godot para Windows. Não é necessário usar esse caminho Linux para abrir o projeto.

QA visual: `godot --path . -s tools/capture_screens.gd -- --capture-dir=<pasta> --scale=1.0` renderiza início, campanha, mesa, pausa, tutorial, resultado, regras e ajustes em 360×800. Use `--scale=1.5` para o tamanho de texto ampliado. As capturas de referência de todas as telas ficam em [`prints/`](prints/).

## Produto e entrega

Pacote do Spec Kit: [especificação](specs/001-mobile-poker/README.md). Acompanhe [tarefas](specs/001-mobile-poker/tasks.md) e [validação real](docs/VALIDACAO_ANDROID.md). O GDD original é referência de visão; as decisões da especificação prevalecem.

Os gates de release requerem aparelhos físicos, assinatura sob custódia do autor e playtest com iniciantes; não confundir compilação headless ou um APK de desenvolvimento com release aceito.

## Primeiro jogável

APK de desenvolvimento: [builds/android/wrong-move-debug.apk](builds/android/wrong-move-debug.apk). Android9+/ARM64, instalação manual; dados separados do futuro release. Não é publicado nem enviado a lojas. A pasta builds é ignorada pelo Git; gere novamente com [instruções de build](docs/BUILD_ANDROID.md).

Implementados: torneios Hold'em2–6, Normal/Hardcore, mapa e desbloqueios, bots, save A/B, tutorial guiado, dicas pagas e revisão da última mão. Interface e balanceamento ainda precisam de refinamento e validação em aparelhos.
