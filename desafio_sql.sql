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
select * from cap08.clientes
where estado = 'SP' and tipo ='pessoa jurídica'; 

-- 3️ [BÁSICO] Exiba todos os nomes dos estudantes do ensino médio e da universidade, sem duplicar registros.
-- Use o operador UNION.
select nome from cap08.estudantes_ensino_medio
union
select nome from cap08.estudantes_universidade
order by nome;
 

-- 4️ [BÁSICO] Exiba todos os nomes dos estudantes, incluindo duplicatas.
-- Use o operador UNION ALL.
select nome from cap08.estudantes_ensino_medio
union all
select nome from cap08.estudantes_universidade
order by nome;

-- 5️ [BÁSICO] Una as tabelas de estudantes mostrando duas colunas:
-- nome e especialidade.
-- Para estudantes do ensino médio, exiba "Não se aplica" na coluna especialidade.
select 
	nome,
	'Não se aplica' AS especialidade 
from cap08.estudantes_ensino_medio
union
select 
	nome,
	especialidade
from cap08.estudantes_universidade
order by nome;

-- ============================================================================================
-- ⚙️ NÍVEL 2 — JUNÇÕES E INTEGRIDADE REFERENCIAL
-- ============================================================================================

-- 6️ [INTERMEDIÁRIO] Liste o nome do cliente, o produto comprado, a quantidade e a data do pedido.
-- Combine as tabelas de pedidos, clientes e produtos usando INNER JOIN.
select
	cli.nome as nome_cliente,
	prod.nome as nome_produto,
	sum(ped.quantidade) as quantidade_comprada,
	ped.data_pedido as data_pedido
from cap08.clientes as cli
inner join cap08.pedidos as ped
	on cli.id_cliente = ped.id_cliente
inner join cap08.produtos as prod
	on ped.id_produto = prod.id_produto
group by cli.nome, prod.nome, ped.data_pedido
order by nome_cliente;

-- 7️ [INTERMEDIÁRIO] Liste todos os pedidos da tabela pedidos_sem_ir.
-- Mostre o nome do cliente e o nome do produto, mesmo que algum campo esteja ausente (NULL).
-- Use LEFT JOIN.

select
	cli.nome as nome_cliente,
	prod.nome as nome_produto
from cap08.clientes as cli
left join cap08.pedidos_sem_ir as ped
	on cli.id_cliente = ped.id_cliente
left join cap08.produtos as prod
	on ped.id_produto = prod.id_produto
order by nome_cliente;

-- 8️ [INTERMEDIÁRIO] Retorne todos os produtos que nunca foram pedidos.
-- Mostre id_produto, nome e preço.
-- Use RIGHT JOIN e filtre registros sem correspondência.
select
	prod.nome as nome_produto,
	sum(ped.quantidade) as quantidade_comprada
from cap08.clientes as cli
right join cap08.pedidos as ped
	on cli.id_cliente = ped.id_cliente
right join cap08.produtos as prod
	on ped.id_produto = prod.id_produto
group by prod.nome
having sum(ped.quantidade) is null
order by nome_produto;

-- 9️ [INTERMEDIÁRIO] Retorne todos os pedidos que não têm produto associado.
-- Use RIGHT JOIN com a tabela pedidos_sem_ir.
-- Mostre id_pedido, quantidade e data do pedido.
 

-- 10 [INTERMEDIÁRIO] Exiba o resultado de um FULL JOIN entre as tabelas produtos e pedidos.
-- Observe a diferença em relação ao INNER JOIN.


-- 11️ [INTERMEDIÁRIO] Faça um CROSS JOIN entre produtos e pedidos.
-- Quantas combinações são retornadas?
-- (Dica: é o produto cartesiano entre as tabelas.)


-- 12️ [INTERMEDIÁRIO] Use SELF JOIN na tabela pedidos.
-- Liste pares de pedidos realizados pelo mesmo cliente (id_cliente).
-- Evite duplicar pares invertidos.


-- ============================================================================================
-- 📊 NÍVEL 3 — AGREGAÇÕES E FILTROS CONDICIONAIS
-- ============================================================================================

-- 13️ [AVANÇADO] Calcule a média de quantidade pedida por produto.
-- Mostre o nome do produto e a média arredondada para 2 casas decimais.
-- Ordene o resultado pelo nome do produto.


-- 14 [AVANÇADO] Exiba apenas os produtos “Produto D” e “Produto H”.
-- Mostre o nome e a quantidade pedida.
-- Ordene os resultados por nome do produto.


-- 15️ [AVANÇADO] Calcule a média de quantidade dos produtos “Produto D” e “Produto H”,
-- mas exiba apenas aqueles cuja média seja maior que 42.
-- Use GROUP BY, HAVING e ROUND.


-- 16️ [AVANÇADO] Mostre a média de quantidade pedida por cliente e produto.
-- Inclua apenas produtos “Produto D” e “Produto H”.
-- Ordene pelo nome do produto.


-- 17️ [AVANÇADO] Encontre os produtos com maior quantidade pedida em um único pedido.
-- Mostre o nome do produto, nome do cliente e quantidade.
-- Use subconsulta correlacionada.


-- 18️ [AVANÇADO] Crie uma CTE (Common Table Expression) chamada "ProdutosMaisVendidos".
-- Liste os 5 produtos mais vendidos (por soma total de quantidade).
-- Em seguida, exiba para cada um desses produtos:
--   - nome do produto,
--   - categoria,
--   - cliente que fez o maior pedido em quantidade.
-- Utilize JOINs e uma subconsulta para identificar o maior pedido de cada produto.


-- 19️ [AVANÇADO] Calcule o total de vendas por categoria.
-- Mostre: categoria, soma total de quantidades e preço médio.
-- Ordene da categoria mais vendida para a menos vendida.


-- 20️ [AVANÇADO] Crie uma consulta que identifique possíveis falhas de integridade referencial.
-- Retorne pedidos onde id_cliente ou id_produto não possuem correspondência nas tabelas principais.
-- Use LEFT JOIN e filtre registros com valores NULL.
