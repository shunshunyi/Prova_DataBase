## SGBD
As propriedas ACID são essenciais para os sistemas acadêmicos, pois garantem a atomicidade e consistência, evitando perda e duplicidade dos dados.

## Organização
Com o uso de schemas podemos garantir segurança isolando permissões. Além disso, a gestão das tabelas é mais fácil se agrupadas por contexto, schemas simplificam a governança dos dados.

## Modelo Lógico

    alunos (id_aluno, nome, email, endereco, data_ingresso, ativo)

    professores (id_professor, nome, email, ativo)

    disciplinas (id_disciplina, nome, carga_horaria, ativo)

    turmas (id_turma, id_disciplina, id_professor, ciclo, ativo)

    matriculas (id_matricula, id_aluno, id_turma, data_matricula, matricula_operador, situacao, ativo)

    notas (id_nota, id_matricula, valor_nota, tipo_avaliacao, data_registro, ativo)

## Transações e Concorrência

No cenário de dois operadores editando a mesma nota simultaneamente:

    Locks (Bloqueios): O SGBD aplica um Row-Level Lock (bloqueio na linha) assim que o primeiro operador inicia o comando de UPDATE.

    Isolamento: Graças ao isolamento do ACID, a segunda transação fica em espera até que a primeira seja finalizada com COMMIT ou ROLLBACK. Isso evita o conflito de "Lost Update", garantindo que a base de dados permaneça consistente e o dado final não seja corrompido. 