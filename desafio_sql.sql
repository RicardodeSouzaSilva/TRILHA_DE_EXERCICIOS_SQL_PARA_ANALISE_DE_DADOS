/**********************************************************************************************
🎯 TRILHA DE EXERCÍCIOS — SQL PARA ANÁLISE DE DADOS
  - Criação de tabelas, integridade referencial e junções
  - Operadores UNION, JOIN, LEFT/RIGHT/FULL/CROSS JOIN
  - Filtros, agrupamentos, CTEs e subconsultas
**********************************************************************************************/

-- ============================================================================================
-- 🧩 NÍVEL 1 — FUNDAMENTOS E RECUPERAÇÃO DE DADOS
-- ============================================================================================

-- 1️ [BÁSICO] Exiba todos os produtos cadastrados.
-- Mostre as colunas: nome, categoria e preço.
-- Ordene pelo nome do produto em ordem alfabética.
select * from cap08.produtos;

-- 2️ [BÁSICO] Liste apenas os clientes do estado de "SP" que sejam do tipo "pessoa jurídica".
-- Mostre nome, sobrenome e tipo do cliente.
-- Ordene pelo nome do cliente.

SELECT *                                    -- Traz todas as colunas da tabela (avalie se precisa mesmo de todas)
FROM cap08.clientes                         -- Fonte: tabela de clientes
WHERE estado = 'SP'                         -- Filtro 1: apenas clientes do estado de São Paulo
  AND tipo = 'pessoa jurídica';             -- Filtro 2: apenas clientes cujo tipo é 'pessoa jurídica'


-- 3️ [BÁSICO] Exiba todos os nomes dos estudantes do ensino médio e da universidade, sem duplicar registros.
-- Use o operador UNION.

SELECT nome                               -- 1) Pega os nomes do ensino médio
FROM cap08.estudantes_ensino_medio
UNION                                     -- 2) UNION remove duplicados automaticamente
                                          --    (diferente de UNION ALL, que mantém duplicados)
SELECT nome                               -- 3) Pega os nomes da universidade
FROM cap08.estudantes_universidade
ORDER BY nome;                            -- 4) Ordena o resultado final já unificado por 'nome'

 

-- 4️ [BÁSICO] Exiba todos os nomes dos estudantes, incluindo duplicatas.
-- Use o operador UNION ALL.
SELECT nome                                   -- 1) Nomes dos alunos do ensino médio
FROM cap08.estudantes_ensino_medio
UNION ALL                                     -- 2) Junta resultados SEM remover duplicados
                                              --    (se o mesmo nome existir nas duas tabelas, aparecerá 2x)
SELECT nome                                   -- 3) Nomes dos alunos da universidade
FROM cap08.estudantes_universidade
ORDER BY nome;                                -- 4) Ordena o RESULTADO FINAL (após o UNION ALL) por 'nome'

-- 5️ [BÁSICO] Una as tabelas de estudantes mostrando duas colunas:
-- nome e especialidade.
-- Para estudantes do ensino médio, exiba "Não se aplica" na coluna especialidade.
SELECT 
    nome,                                -- 1) Nome do aluno do ensino médio
    'Não se aplica' AS especialidade     -- 2) Literal para preencher a 2ª coluna, padronizando o esquema
FROM cap08.estudantes_ensino_medio       -- 3) Fonte: estudantes do ensino médio
UNION                                    -- 4) UNION remove duplicatas (DISTINCT) considerando *ambas* as colunas
                                         --    (diferente de UNION ALL, que manteria duplicadas)
SELECT 
    nome,                                -- 5) Nome do aluno da universidade
    especialidade                        -- 6) Especialidade do aluno (curso/área)
FROM cap08.estudantes_universidade       -- 7) Fonte: estudantes da universidade
ORDER BY nome;                           -- 8) Ordena o resultado final unificado pelo nome


-- ============================================================================================
-- ⚙️ NÍVEL 2 — JUNÇÕES E INTEGRIDADE REFERENCIAL
-- ============================================================================================

-- 6️ [INTERMEDIÁRIO] Liste o nome do cliente, o produto comprado, a quantidade e a data do pedido.
-- Combine as tabelas de pedidos, clientes e produtos usando INNER JOIN.
SELECT
    cli.nome  AS nome_cliente,             -- Nome do cliente (chave da agregação)
    prod.nome AS nome_produto,             -- Nome do produto (chave da agregação)
    SUM(ped.quantidade) AS quantidade_comprada,  -- Soma das quantidades dentro do grupo
    ped.data_pedido AS data_pedido         -- Data do pedido (entra no GROUP BY → granularidade por data exata)
FROM cap08.clientes AS cli                 -- Tabela de clientes (lado 1 do relacionamento)
INNER JOIN cap08.pedidos AS ped            -- Junta apenas pedidos que têm cliente
    ON cli.id_cliente = ped.id_cliente     -- Regra de junção cliente ↔ pedido
INNER JOIN cap08.produtos AS prod          -- Junta apenas pedidos que têm produto
    ON ped.id_produto = prod.id_produto    -- Regra de junção pedido ↔ produto
GROUP BY
    cli.nome,                              -- Agrupa por cliente
    prod.nome,                             -- Agrupa por produto
    ped.data_pedido                        -- Agrupa por data: cada dia/instante vira uma linha distinta
ORDER BY
    nome_cliente;                          -- Ordena alfabeticamente pelo cliente


-- 7️ [INTERMEDIÁRIO] Liste todos os pedidos da tabela pedidos_sem_ir.
-- Mostre o nome do cliente e o nome do produto, mesmo que algum campo esteja ausente (NULL).
-- Use LEFT JOIN.

SELECT
    cli.nome  AS nome_cliente,      -- Nome do cliente (coluna exibida)
    prod.nome AS nome_produto       -- Nome do produto (pode vir NULL se o cliente não tiver pedidos)
FROM cap08.clientes AS cli          -- Tabela base: lista todos os clientes
LEFT JOIN cap08.pedidos_sem_ir AS ped   -- Mantém o cliente mesmo sem pedido (ped.* vira NULL)
    ON cli.id_cliente = ped.id_cliente   -- Chave cliente → pedido
LEFT JOIN cap08.produtos AS prod        -- Tenta trazer o produto do pedido
    ON ped.id_produto = prod.id_produto  -- Chave pedido → produto (se ped for NULL, prod também ficará NULL)
ORDER BY
    nome_cliente;                    -- Ordena alfabeticamente pelos clientes

-- 8️ [INTERMEDIÁRIO] Retorne todos os produtos que nunca foram pedidos.
-- Mostre id_produto, nome e preço.
-- Use RIGHT JOIN e filtre registros sem correspondência.
SELECT
    prod.nome AS nome_produto,              	-- Alias legível para o nome do produto (será usado no GROUP BY/ORDER BY)
    SUM(ped.quantidade) AS quantidade_comprada -- Soma das quantidades por produto (pode virar NULL se não houver pedidos)
FROM cap08.clientes AS cli                  	-- Tabela de clientes (apenas para ligar com pedidos)
RIGHT JOIN cap08.pedidos AS ped             	-- RIGHT JOIN garante manter todos os pedidos (mesmo sem cliente correspondente)
    ON cli.id_cliente = ped.id_cliente      	-- Chave de junção cliente → pedido
RIGHT JOIN cap08.produtos AS prod           	-- RIGHT JOIN final garante manter TODOS os produtos
    ON ped.id_produto = prod.id_produto     	-- Chave de junção pedido → produto
GROUP BY prod.nome                          	-- Agrega por produto para calcular a soma das quantidades
HAVING SUM(ped.quantidade) IS NULL          	-- Filtro: produtos sem qualquer pedido (SUM sobre só NULLs → NULL)
ORDER BY nome_produto;                      	-- Ordena alfabeticamente a lista de produtos sem compras


