/**********************************************************************************************
🎯 TRILHA DE EXERCÍCIOS — SQL PARA ANÁLISE (PostgreSQL)

Objetivo:
Praticar SQL com foco em Analytics e Business Intelligence,
trabalhando com agregações, JOINs e interpretação de problemas de negócio.

Tabelas:
- clientes (dimensão)
- pedidos  (fato)

Aliases padrão:
- clientes → tabela_cliente
- pedidos  → tabela_pedido
**********************************************************************************************/

-- ============================================================================================
-- 🧩 NÍVEL 2 — AGREGAÇÕES E ANÁLISE GEOGRÁFICA
-- ============================================================================================

/*--------------------------------------------------------------------------------------------
Exercício 1 — Soma (total) do valor dos pedidos por cidade

Enunciado:
Calcular o valor total dos pedidos agrupados por cidade do cliente.

Interpretação Analítica:
- Pedidos são a tabela fato
- Cidade é a dimensão de agrupamento
- Métrica principal: soma do valor dos pedidos
--------------------------------------------------------------------------------------------*/

select 
    tabela_cliente.cidade_cliente,
    -- Soma o valor de todos os pedidos associados aos clientes daquela cidade
    -- Essa soma gera uma métrica analítica clássica: faturamento total por cidade
    sum(tabela_pedido.valor_pedido) as valor_total_por_cidade
-- Define a tabela de pedidos como tabela fato principal da análise
-- Pedidos representam eventos transacionais (grão: 1 pedido)
from cap10.pedidos as tabela_pedido
-- Realiza um INNER JOIN com a tabela de clientes
-- Esse join garante que apenas pedidos com cliente válido sejam considerados
-- Relação: muitos pedidos para um cliente (N:1)
inner join cap10.clientes as tabela_cliente
    on tabela_pedido.id_cliente = tabela_cliente.id_cli
-- Agrupa os dados por cidade do cliente
-- Isso transforma linhas transacionais em um resumo analítico por dimensão geográfica
group by tabela_cliente.cidade_cliente
-- Ordena o resultado pelo valor total faturado por cidade
-- Importante para análises de ranking (ex: cidades que mais geram receita)
order by valor_total_por_cidade desc;
 


/*--------------------------------------------------------------------------------------------
Exercício 2 — Soma (total) do valor dos pedidos por estado e cidade (com a cláusula WHERE)

Enunciado:
Calcular o valor total dos pedidos por estado e cidade,
utilizando a cláusula WHERE para relacionar clientes e pedidos.

Interpretação Analítica:
- Agregação por duas dimensões geográficas
- Uso de sintaxe de relacionamento via WHERE
- Métrica de faturamento por localidade
--------------------------------------------------------------------------------------------*/
-- Seleciona as dimensões geográficas do cliente (estado e cidade)
-- e calcula o valor total de pedidos para cada combinação estado + cidade
SELECT 
    estado_cliente, 
    cidade_cliente, 
    -- Soma o valor dos pedidos associados a cada cidade dentro de cada estado
    -- Gera a métrica analítica: faturamento total por cidade e estado
    SUM(valor_pedido) AS total
-- Define as tabelas envolvidas na análise
-- dsa_pedidos: tabela fato (eventos de venda / pedidos)
-- dsa_clientes: tabela dimensão (informações do cliente)
FROM cap10.pedidos P, cap10.clientes C
-- Condição de relacionamento entre pedidos e clientes
-- Essa cláusula substitui o INNER JOIN na sintaxe antiga
-- Garante que cada pedido seja associado ao cliente correto
WHERE P.id_cliente = C.id_cli
-- Agrupa os dados pelas dimensões geográficas
-- Cada linha do resultado representa:
-- um estado + uma cidade
GROUP BY
    cidade_cliente, 
    estado_cliente
-- Ordena o resultado do maior para o menor faturamento
-- Muito utilizado para análises de ranking e dashboards
ORDER BY total DESC;



/*--------------------------------------------------------------------------------------------
Exercício 3 — Soma (total) do valor dos pedidos por estado e cidade (com a cláusula JOIN)

Enunciado:
Calcular o valor total dos pedidos por estado e cidade,
utilizando JOIN explícito entre clientes e pedidos.

Interpretação Analítica:
- Uso de INNER JOIN (sintaxe moderna)
- Agrupamento por estado e cidade
- Query preparada para BI
--------------------------------------------------------------------------------------------*/
-- Seleciona as dimensões geográficas do cliente:
-- estado e cidade, que serão usadas para análise regional
select
    tabela_cliente.estado_cliente,
    tabela_cliente.cidade_cliente,
    -- Soma o valor de todos os pedidos associados
    -- a cada combinação de estado + cidade
    -- Essa coluna representa a métrica analítica principal:
    -- faturamento total por localidade
    sum(tabela_pedido.valor_pedido) as total_pedidos
-- Define a tabela de pedidos como tabela fato
-- Cada linha representa um evento transacional (um pedido)
from cap10.pedidos as tabela_pedido
-- Realiza um INNER JOIN com a tabela de clientes
-- Esse join associa cada pedido ao seu respectivo cliente
-- Relação típica N:1 (muitos pedidos para um cliente)
inner join cap10.clientes as tabela_cliente
    on tabela_pedido.id_cliente = tabela_cliente.id_cli
-- Agrupa os dados pelas dimensões selecionadas
-- O GROUP BY transforma dados transacionais
-- em dados resumidos para análise agregada
group by tabela_cliente.estado_cliente, tabela_cliente.cidade_cliente
-- Ordena o resultado do maior para o menor faturamento
-- Muito usado para análises de ranking e priorização
order by total_pedidos desc;



/*--------------------------------------------------------------------------------------------
Exercício 4 — Soma do valor total dos pedidos por estado e cidade,
incluindo cidades que não possuem pedidos

Enunciado:
Calcular o valor total dos pedidos por estado e cidade,
retornando também cidades sem pedidos.

Interpretação Analítica:
- A dimensão (clientes) é a âncora da análise
- Uso de LEFT JOIN para incluir cidades sem pedidos
- Métrica pode retornar NULL
--------------------------------------------------------------------------------------------*/
select
    tabela_cliente.estado_cliente,
    tabela_cliente.cidade_cliente,
    -- Soma o valor dos pedidos.
    (sum(tabela_pedido.valor_pedido), 0) as total_pedidos
-- A dimensão (clientes) é a tabela principal da análise
from cap10.clientes as tabela_cliente
-- LEFT JOIN garante que todas as cidades apareçam,
-- mesmo quando não há pedidos associados
left join cap10.pedidos as tabela_pedido
    on tabela_pedido.id_cliente = tabela_cliente.id_cli
-- Agrupamento por dimensões geográficas
group by
    tabela_cliente.estado_cliente,
    tabela_cliente.cidade_cliente
-- Ordenação do maior para o menor faturamento
order by
    total_pedidos desc;

/*--------------------------------------------------------------------------------------------
Exercício 5 — Soma (total) do valor dos pedidos por estado e cidade,
mostrando zero quando não houve pedido

Enunciado:
Calcular o valor total dos pedidos por estado e cidade,
exibindo zero para cidades que não possuem pedidos.

Interpretação Analítica:
- LEFT JOIN entre clientes e pedidos
- Uso de COALESCE para tratar valores NULL
- Query pronta para dashboards e relatórios
--------------------------------------------------------------------------------------------*/
select
    tabela_cliente.estado_cliente,
    tabela_cliente.cidade_cliente,
    -- Soma o valor dos pedidos.
    -- COALESCE converte NULL em 0 para cidades sem pedidos
    coalesce(sum(tabela_pedido.valor_pedido), 0) as total_pedidos
-- A dimensão (clientes) é a tabela principal da análise
from cap10.clientes as tabela_cliente
-- LEFT JOIN garante que todas as cidades apareçam,
-- mesmo quando não há pedidos associados
left join cap10.pedidos as tabela_pedido
    on tabela_pedido.id_cliente = tabela_cliente.id_cli
-- Agrupamento por dimensões geográficas
group by
    tabela_cliente.estado_cliente,
    tabela_cliente.cidade_cliente
-- Ordenação do maior para o menor faturamento
order by
    total_pedidos desc;


/*--------------------------------------------------------------------------------------------
Exercício 6 — Custo total dos pedidos por estado

Enunciado:
Qual é o custo total dos pedidos em cada estado?

Interpretação Analítica:
- Pedidos são a tabela fato
- Estado é a dimensão de agrupamento
- Métrica principal: soma do custo/valor dos pedidos
- Análise agregada para comparação regional
--------------------------------------------------------------------------------------------*/
select
    -- Estado do cliente.
    -- Esta coluna define o nível de agregação da análise (granularidade geográfica).
    tabela_cliente.estado_cliente,
    -- Soma do custo dos produtos associados aos pedidos.
    -- A função SUM agrega o custo de todos os produtos vendidos em cada estado.
    sum(tabela_produto.custo) as custo_total
from cap10.clientes as tabela_cliente
    -- Tabela base da análise (dimensão cliente).
    -- Cada cliente está associado a um estado, que será usado para agrupar os dados.
inner join cap10.pedidos as tabela_pedido
    -- INNER JOIN garante que apenas clientes com pedidos sejam considerados.
    -- Relaciona clientes aos seus respectivos pedidos.
    on tabela_cliente.id_cli = tabela_pedido.id_cliente
inner join cap10.produtos as tabela_produto
    -- INNER JOIN conecta os pedidos aos produtos comprados.
    -- Permite acessar o custo do produto para cálculo do total.
    on tabela_pedido.id_produto = tabela_produto.id_prod
group by
    -- Agrupamento por estado do cliente.
    -- Necessário porque estamos usando uma função de agregação (SUM).
    tabela_cliente.estado_cliente
order by
    -- Ordena os resultados do maior para o menor custo total.
    -- Facilita identificar rapidamente os estados com maior impacto de custo.
    custo_total desc;
