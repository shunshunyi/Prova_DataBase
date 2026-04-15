-- 1. Criação de schemas
DROP SCHEMA IF EXISTS seguranca CASCADE;
DROP SCHEMA IF EXISTS academico CASCADE;

CREATE SCHEMA seguranca;
CREATE SCHEMA academico;

-- 2. Tabelas do schema academico
CREATE TABLE academico.alunos (
    id_aluno VARCHAR(20) PRIMARY KEY,
    nome TEXT NOT NULL,
    email TEXT NOT NULL,
    endereco TEXT,
    data_ingresso DATE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE academico.professores (
    id_professor VARCHAR(20) PRIMARY KEY,
    nome TEXT NOT NULL,
    email TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE academico.disciplinas (
    id_disciplina VARCHAR(20) PRIMARY KEY,
    nome TEXT NOT NULL,
    carga_horaria INTEGER NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE academico.turmas (
    id_turma INTEGER PRIMARY KEY,
    id_disciplina VARCHAR(20) NOT NULL REFERENCES academico.disciplinas(id_disciplina),
    id_professor VARCHAR(20) NOT NULL REFERENCES academico.professores(id_professor),
    ciclo TEXT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (id_disciplina, id_professor, ciclo)
);

CREATE TABLE academico.matriculas (
    id_matricula SERIAL PRIMARY KEY,
    id_aluno VARCHAR(20) NOT NULL REFERENCES academico.alunos(id_aluno),
    id_turma INTEGER NOT NULL REFERENCES academico.turmas(id_turma),
    data_matricula DATE NOT NULL,
    matricula_operador TEXT,
    situacao TEXT NOT NULL DEFAULT 'matriculado',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (id_aluno, id_turma)
);

CREATE TABLE academico.notas (
    id_nota SERIAL PRIMARY KEY,
    id_matricula INTEGER NOT NULL REFERENCES academico.matriculas(id_matricula),
    valor_nota NUMERIC(4,2) NOT NULL,
    tipo_avaliacao TEXT NOT NULL DEFAULT 'final',
    data_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- Tabela de auditoria em seguranca (esquema criado para governança)
CREATE TABLE seguranca.audit_log (
    id_log SERIAL PRIMARY KEY,
    evento TEXT NOT NULL,
    data_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Governança de permissões
REVOKE ALL ON SCHEMA academico FROM PUBLIC;
REVOKE ALL ON SCHEMA seguranca FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA academico FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA seguranca FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA academico FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA seguranca FROM PUBLIC;

CREATE ROLE IF NOT EXISTS professor_role NOINHERIT;
CREATE ROLE IF NOT EXISTS coordenador_role NOINHERIT;

GRANT USAGE ON SCHEMA academico TO professor_role, coordenador_role;
GRANT USAGE ON SCHEMA seguranca TO coordenador_role;

GRANT SELECT (id_aluno, nome, endereco, data_ingresso, ativo) ON academico.alunos TO professor_role;
GRANT SELECT ON academico.disciplinas TO professor_role;
GRANT SELECT ON academico.turmas TO professor_role;
GRANT SELECT ON academico.matriculas TO professor_role;
GRANT SELECT ON academico.notas TO professor_role;
GRANT UPDATE (valor_nota) ON academico.notas TO professor_role;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA seguranca TO coordenador_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA academico GRANT ALL PRIVILEGES ON TABLES TO coordenador_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA academico GRANT ALL PRIVILEGES ON SEQUENCES TO coordenador_role;

-- 4. População de dados
INSERT INTO academico.alunos (id_aluno, nome, email, endereco, data_ingresso) VALUES
('2026001', 'Ana Beatriz Lima', 'ana.lima@aluno.edu.br', 'Braganca Paulista/SP', '2026-01-20'),
('2026002', 'Bruno Henrique Souza', 'bruno.souza@aluno.edu.br', 'Atibaia/SP', '2026-01-21'),
('2026003', 'Camila Ferreira', 'camila.ferreira@aluno.edu.br', 'Jundiai/SP', '2026-01-22'),
('2026004', 'Diego Martins', 'diego.martins@aluno.edu.br', 'Campinas/SP', '2026-01-23'),
('2026005', 'Eduarda Nunes', 'eduarda.nunes@aluno.edu.br', 'Itatiba/SP', '2026-01-24'),
('2026006', 'Felipe Araujo', 'felipe.araujo@aluno.edu.br', 'Louveira/SP', '2026-01-25'),
('2025010', 'Gabriela Torres', 'gabriela.torres@aluno.edu.br', 'Nazare Paulista/SP', '2025-08-05'),
('2025011', 'Helena Rocha', 'helena.rocha@aluno.edu.br', 'Piracaia/SP', '2025-08-06'),
('2025012', 'Igor Santana', 'igor.santana@aluno.edu.br', 'Jarinu/SP', '2025-08-07');

INSERT INTO academico.professores (id_professor, nome) VALUES
('P001', 'Prof. Carlos Mendes'),
('P002', 'Profa. Juliana Castro'),
('P003', 'Prof. Eduardo Pires'),
('P004', 'Prof. Renato Alves'),
('P005', 'Profa. Marina Lopes'),
('P006', 'Prof. Ricardo Faria');

INSERT INTO academico.disciplinas (id_disciplina, nome, carga_horaria) VALUES
('ADS101', 'Banco de Dados', 80),
('ADS102', 'Engenharia de Software', 80),
('ADS103', 'Algoritmos', 60),
('ADS104', 'Redes de Computadores', 60),
('ADS105', 'Sistemas Operacionais', 60),
('ADS106', 'Estruturas de Dados', 80);

INSERT INTO academico.turmas (id_turma, id_disciplina, id_professor, ciclo) VALUES
(1, 'ADS101', 'P001', '2026/1'),
(2, 'ADS102', 'P002', '2026/1'),
(3, 'ADS105', 'P003', '2026/1'),
(4, 'ADS103', 'P004', '2026/1'),
(5, 'ADS104', 'P005', '2026/1'),
(6, 'ADS106', 'P006', '2026/1'),
(7, 'ADS101', 'P001', '2025/2'),
(8, 'ADS102', 'P002', '2025/2'),
(9, 'ADS103', 'P004', '2025/2'),
(10, 'ADS104', 'P005', '2025/2'),
(11, 'ADS105', 'P003', '2025/2'),
(12, 'ADS106', 'P006', '2025/2');

INSERT INTO academico.matriculas (id_aluno, id_turma, data_matricula, matricula_operador) VALUES
('2026001', 1, '2026-01-20', 'OP9001'),
('2026001', 2, '2026-01-20', 'OP9001'),
('2026001', 3, '2026-01-20', 'OP9001'),
('2026002', 1, '2026-01-21', 'OP9002'),
('2026002', 4, '2026-01-21', 'OP9002'),
('2026002', 5, '2026-01-21', 'OP9002'),
('2026003', 1, '2026-01-22', 'OP9001'),
('2026003', 2, '2026-01-22', 'OP9001'),
('2026003', 6, '2026-01-22', 'OP9001'),
('2026004', 4, '2026-01-23', 'OP9003'),
('2026004', 5, '2026-01-23', 'OP9003'),
('2026004', 3, '2026-01-23', 'OP9003'),
('2026005', 2, '2026-01-24', 'OP9002'),
('2026005', 5, '2026-01-24', 'OP9002'),
('2026005', 6, '2026-01-24', 'OP9002'),
('2026006', 1, '2026-01-25', 'OP9004'),
('2026006', 4, '2026-01-25', 'OP9004'),
('2026006', 3, '2026-01-25', 'OP9004'),
('2025010', 7, '2025-08-05', 'OP8999'),
('2025010', 8, '2025-08-05', 'OP8999'),
('2025011', 9, '2025-08-06', 'OP8999'),
('2025011', 10, '2025-08-06', 'OP8999'),
('2025012', 11, '2025-08-07', 'OP9000'),
('2025012', 12, '2025-08-07', 'OP9000');

INSERT INTO academico.notas (id_matricula, valor_nota) VALUES
(1, 9.1),
(2, 8.4),
(3, 8.9),
(4, 7.3),
(5, 6.8),
(6, 7.0),
(7, 5.9),
(8, 7.5),
(9, 6.1),
(10, 4.7),
(11, 6.2),
(12, 5.8),
(13, 9.5),
(14, 8.1),
(15, 8.7),
(16, 6.4),
(17, 5.6),
(18, 6.9),
(19, 6.4),
(20, 7.1),
(21, 8.8),
(22, 7.9),
(23, 5.5),
(24, 6.3);

-- 5. Consultas exigidas
-- 5.1 Listagem de matriculados para o ciclo 2026/1
SELECT a.nome AS aluno,
       d.nome AS disciplina,
       t.ciclo
FROM academico.matriculas m
JOIN academico.alunos a ON m.id_aluno = a.id_aluno
JOIN academico.turmas t ON m.id_turma = t.id_turma
JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
WHERE t.ciclo = '2026/1'
  AND m.ativo
  AND a.ativo
  AND t.ativo
  AND d.ativo;

-- 5.2 Baixo desempenho por disciplina
SELECT d.nome AS disciplina,
       AVG(n.valor_nota) AS media_geral
FROM academico.notas n
JOIN academico.matriculas m ON n.id_matricula = m.id_matricula
JOIN academico.turmas t ON m.id_turma = t.id_turma
JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
WHERE n.ativo
  AND m.ativo
  AND t.ativo
  AND d.ativo
GROUP BY d.nome
HAVING AVG(n.valor_nota) < 6.0;

-- 5.3 Alocação de docentes, incluindo docentes sem turmas
SELECT p.nome AS docente,
       d.nome AS disciplina
FROM academico.professores p
LEFT JOIN academico.turmas t ON p.id_professor = t.id_professor AND t.ativo
LEFT JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
WHERE p.ativo
ORDER BY p.nome, d.nome;

-- 5.4 Maior desempenho em Banco de Dados
SELECT a.nome AS aluno,
       n.valor_nota
FROM academico.notas n
JOIN academico.matriculas m ON n.id_matricula = m.id_matricula
JOIN academico.alunos a ON m.id_aluno = a.id_aluno
JOIN academico.turmas t ON m.id_turma = t.id_turma
JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
WHERE d.nome = 'Banco de Dados'
  AND n.valor_nota = (
      SELECT MAX(n2.valor_nota)
      FROM academico.notas n2
      JOIN academico.matriculas m2 ON n2.id_matricula = m2.id_matricula
      JOIN academico.turmas t2 ON m2.id_turma = t2.id_turma
      JOIN academico.disciplinas d2 ON t2.id_disciplina = d2.id_disciplina
      WHERE d2.nome = 'Banco de Dados'
  )
ORDER BY a.nome;
