# Persistência e relógio, contrato v1

Substitui o protocolo provisório primary/tmp/bak. Offline, processo único. Preservar último comando confirmado após morte do processo; não prometer recuperação de armazenamento fisicamente destruído ou dados apagados pelo usuário.

## Commit A/B

`user://save/state_a.json` e `state_b.json`: schema, revisão decimal, payload e SHA-256 dos bytes canônicos. Normal, Hardcore, carteiras, partidas e recibos no mesmo agregado. Preferências ConfigFile separadas.

1. Fila serial: atualizar tempo, validar comando e criar estado candidato, sem mutar parcialmente o confirmado.
2. Gravar `{slot_inativo}.tmp`, fechar/flush, reabrir e validar schema, checksum, revisão e invariantes.
3. Substituir slot inativo com rename atômico no mesmo filesystem, mantendo o outro íntegro. Se API não permitir substituição atômica, implementá-la no adaptador e provar com fault injection; copiar não é equivalente.
4. Rename bem-sucedido é o commit. Só depois expor resultado e atualizar memória confirmada. Morte após commit e antes do feedback carrega a revisão nova; recibos impedem nova cobrança/prêmio.
5. Ao abrir, validar A/B e escolher maior revisão válida; temporários nunca são promovidos. Slot corrompido permite recuperar outro com aviso. Corrupção de uma cópia pode recuperar revisão anterior, explicitamente informada; não confundir esse caso com falha normal de commit.

Falha de escrita pausa e bloqueia novos comandos econômicos; retry usa mesmo command_id. Falta de espaço não apaga save. Versão futura é preservada. Ambos inválidos oferecem retry ou novo progresso com duas confirmações; preservar arquivos em pasta local de recuperação antes de reset. Checksum detecta dano acidental, não impede edição intencional do próprio save. Nenhum arquivo é enviado a servidor.

## IDs e tamanho

`attempt_id=mode:counter_decimal`, monotônico. `decision_id=attempt_id:hand_counter:action_counter` só muda quando a decisão de domínio muda. `save_revision` muda por commit; `domain_revision` por jogo/economia, nunca por layout/tick. Dica é associada à decisão, não ao checkpoint.

Guardar recibos completos da tentativa ativa e resultado pendente de apresentação. Compactar os anteriores em marcadores permanentes de passe/conquista e contador de tentativas; rejeitar comando de tentativa encerrada. Configs compradas preservam versão e parâmetros; ranges da mesma versão podem ser compactados mantendo reconstrução exata. Última mão sanitizada por campanha, sem histórico ilimitado.

Wallet, índices, revisões e contadores em decimal canônico arbitrário. RNGs têm algoritmo, versão e estado string. Persistir deck/posição, contribuição e direitos individuais. Não passar snapshots para IA/UI. Schema1 é o formato inicial; atualização1.0.1 deve ler1.0.0 sem reset.

## Hardcore

10.000 ms por decisão e30.000 ms de reserva por tentativa. Relógio monotônico ativo quando controles estão habilitados; pausa durante regras/menu/background/animações sem decisão. Antes de aceitar toque, atualizar tempo: esgotado tudo, timeout vence a corrida e executa um único check/fold por decision_id.

Saída normal/background salva tempo exato. Morte abrupta nunca devolve tempo e pode perder no máximo1.000 ms: checkpoint conservador em slots compactos `clock_a/clock_b`, mesmos princípios A/B. Antes de habilitar cada janela ativa de até1 s, persistir o saldo projetado já debitando a janela. UI usa tempo real contínuo; após kill, saldo durável é limite inferior, não ponto antigo que devolve tempo. Não iniciar janela enquanto seu checkpoint não estiver persistido.

Overlay contém attempt_id, decision_id, domain_revision, sequência e saldos. Aplicar só com IDs/revisão correspondentes. Commit de pausa normal no core tem precedência sobre overlay conservador antigo e preserva o valor exato; não reaplicar débito ao retomar. Checkpoints de decisões anteriores são ignorados. Se persistência falha, pausar.

Testar0/999/1000 ms, transição para reserva, fim dos40 s, toque/timeout/pausa e morte em cada fronteira de commit. A tolerância é perda de até1 s por kill, nunca renovação dos10 s ou30 s. Usar slots compactos evita regravar mapa inteiro por tick. Pensar durante pausa já foi aceito; sem penalidade ou relógio de parede durante ausência.
