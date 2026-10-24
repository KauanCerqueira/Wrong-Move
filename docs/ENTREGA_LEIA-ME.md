# Experimentar o primeiro jogável

Esta é uma versão de desenvolvimento0.1.0-dev, não a entrega1.0.0 aceita. O APK fica em `builds/android/wrong-move-debug.apk` e usa assinatura debug. Não foi instalado em aparelho físico nesta sessão.

## Android

Requisitos-alvo: Android9 ou superior, ARM64, OpenGL ES3.0; compatibilidade real ainda a validar. Transfira o APK ao seu aparelho de teste e abra-o. Se o Android solicitar, autorize a instalação por essa fonte. O app aparecerá como **Wrong Move Dev**. Não precisa de conta ou dinheiro real.

O pacote debug mantém dados separados do futuro release. Desinstalar/apagar dados perde o progresso. Atualizações precisam da mesma assinatura; não troque a chave debug se quiser preservar essa instalação.

## Jogar

Comece por Aprender a jogar ou Normal. A mesa1 é grátis. Cada tentativa começa com o mesmo número de fichas para todos. Vença o torneio para ganhar fichas de progressão, depois compre o acesso permanente à próxima mesa no mapa. Repetir uma mesa liberada não custa entrada.

Na mesa, Passar/Pagar acompanha a ação legal; Desistir abandona somente a mão. Presets/slider selecionam o total da rodada; o botão Apostar/Aumentar confirma. Tudo apenas seleciona o all-in, não o executa imediatamente. Pausa permite continuar, consultar regras/revisão, salvar e sair ou abandonar o torneio com confirmação.

Normal oferece dica opcional depois de8 s do seu turno; custa saldo de progressão, não fichas da mesa. A recomendação não garante vitória. Hardcore não oferece dicas:10 s por decisão e reserva30 s por torneio.

## No editor

Abra `project.godot` no Godot4.7.2 e pressione F5. Testes/build: [BUILD_ANDROID.md](BUILD_ANDROID.md). Resultados e pendências reais: [VALIDACAO_ANDROID.md](VALIDACAO_ANDROID.md). Dados locais: [PRIVACIDADE.md](PRIVACIDADE.md).
