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


/*--------------------------------------------------------------------------------------------
Exercício 7 — Ajuste de custo para produtos vendidos a clientes do estado de SP

Enunciado:
A tabela de dados está desatualizada e os produtos vendidos para clientes
do estado de São Paulo (SP) tiveram aumento de custo de 10%.
Como demonstrar esse ajuste no relatório sem modificar os dados na tabela?

Interpretação Analítica:
- Os dados originais não devem ser alterados (sem UPDATE)
- O ajuste de custo deve ser aplicado apenas no momento da consulta
- A regra de negócio depende da localização do cliente (estado = 'SP')
- O cálculo deve refletir um aumento de 10% no custo dos produtos vendidos
--------------------------------------------------------------------------------------------*/
SELECT
    -- Estado do cliente.
    -- Define o nível de agregação da análise (granularidade geográfica).
    tabela_cliente.estado_cliente,
    -- Cálculo do custo total dos produtos por estado.
    -- A função SUM realiza a agregação dos custos dos produtos.
    -- O CASE aplica uma regra condicional antes da agregação:
    --  - Se o estado do cliente for 'SP', o custo do produto recebe um acréscimo de 10%.
    --  - Caso contrário, o custo original do produto é mantido.
    -- O ROUND é aplicado ao resultado final da soma para limitar o valor
    -- a duas casas decimais, padrão comum em relatórios financeiros.
    ROUND(SUM(
            CASE
                WHEN tabela_cliente.estado_cliente = 'SP' THEN tabela_produto.custo * 1.10
                ELSE tabela_produto.custo
            END
        ),2) AS custo_total
FROM cap10.clientes AS tabela_cliente
    -- Tabela base da consulta (dimensão clientes).
    -- Contém a informação de estado, usada para o agrupamento.
INNER JOIN cap10.pedidos AS tabela_pedido
    -- INNER JOIN garante que apenas clientes que realizaram pedidos
    -- sejam considerados na análise.
    -- Relaciona clientes aos seus respectivos pedidos.
    ON tabela_cliente.id_cli = tabela_pedido.id_cliente
INNER JOIN cap10.produtos AS tabela_produto
    -- INNER JOIN conecta os pedidos aos produtos comprados.
    -- Permite acessar o custo de cada produto para o cálculo do total.
    ON tabela_pedido.id_produto = tabela_produto.id_prod
GROUP BY
    -- Agrupamento por estado do cliente.
    -- Necessário porque a query utiliza função de agregação (SUM).
    tabela_cliente.estado_cliente
ORDER BY
    -- Ordena o resultado pelo custo total em ordem decrescente.
    -- Facilita a identificação dos estados com maior impacto de custo.
    custo_total DESC;

/*--------------------------------------------------------------------------------------------
Exercício 8 — Custo total dos pedidos por estado com produtos específicos

Enunciado:
Qual é o custo total dos pedidos por estado considerando apenas
produtos cujo título contenha as palavras 'Análise' ou 'Apache'?

Interpretação Analítica:
- Pedidos são a tabela fato da análise
- Estado do cliente é a dimensão de agrupamento
- Produtos devem ser filtrados pelo nome (título)
- A filtragem deve considerar títulos que contenham:
  - 'Análise'
  - 'Apache'
- Métrica principal: soma do custo/valor dos pedidos
- A lógica de filtro deve ser aplicada via WHERE
--------------------------------------------------------------------------------------------*/

-- Seleciona o estado do cliente e o nome do produto,
-- que serão as dimensões da análise
select    
    tabela_cliente.estado_cliente,
    -- Soma o custo dos produtos vendidos,
    -- gerando a métrica analítica de custo total
    sum(tabela_produto.custo) as custo_total
-- Define a tabela de clientes como ponto de partida da análise
-- Clientes representam a dimensão geográfica (estado)
from cap10.clientes as tabela_cliente
-- Realiza o relacionamento entre clientes e pedidos
-- Garante que apenas clientes com pedidos sejam considerados
-- Relação típica N:1 (muitos pedidos para um cliente)
inner join cap10.pedidos as tabela_pedido
    on tabela_cliente.id_cli = tabela_pedido.id_cliente
-- Realiza o relacionamento entre pedidos e produtos
-- Associa cada pedido ao produto correspondente
inner join cap10.produtos as tabela_produto
    on tabela_pedido.id_produto = tabela_produto.id_prod
-- Aplica filtro textual nos produtos
-- O operador ~ indica correspondência por expressão regular (PostgreSQL)
-- Serão considerados apenas produtos cujo nome contenha:
-- 'Apache' OU 'Análise'
where
    tabela_produto.nome_produto ~ 'Apache'
    or tabela_produto.nome_produto ~ 'Análise'
-- Agrupa os dados pelas dimensões selecionadas
-- Cada linha do resultado representa:
-- um estado + um produto
group by
    tabela_cliente.estado_cliente
-- Ordena o resultado pelo custo total em ordem decrescente
-- Facilita análises de ranking e priorização de custos
order by
    custo_total desc;

/*--------------------------------------------------------------------------------------------
Exercício 9 — Custo total dos pedidos por estado com regras de negócio

Enunciado:
Qual é o custo total dos pedidos por estado considerando apenas
produtos cujo título contenha as palavras 'Análise' ou 'Apache',
somente quando o custo total for menor que 120.000?
Além disso, como demonstrar no relatório um aumento de 10% no custo
para pedidos realizados por clientes do estado de São Paulo (SP),
sem modificar os dados na tabela?

Interpretação Analítica:
- Pedidos são a tabela fato da análise
- Estado do cliente é a dimensão de agrupamento
- Produtos devem ser filtrados pelo nome (título)
- Considerar apenas produtos cujo título contenha 'Análise' ou 'Apache'
- A condição de custo total (< 120000) deve ser aplicada após a agregação
- O aumento de 10% no custo deve ser calculado somente no momento da consulta
- Os dados físicos da tabela não devem ser alterados
--------------------------------------------------------------------------------------------*/

SELECT
    -- Estado do cliente.
    -- Representa a localização geográfica do cliente
    -- e define o nível de agregação dos dados apresentados no resultado.
    tabela_cliente.estado_cliente,
    -- Cálculo do custo total dos produtos por estado.
    -- A função SUM agrega os custos dos produtos associados aos pedidos.
    -- O CASE WHEN aplica uma regra condicional antes da agregação:
    --   • Para clientes do estado 'SP', o custo do produto recebe um acréscimo de 10%.
    --   • Para os demais estados, o custo permanece inalterado.
    -- O ROUND é utilizado para arredondar o valor final
    -- para duas casas decimais, padrão comum em relatórios financeiros.
    ROUND(
        SUM(
            CASE
                WHEN tabela_cliente.estado_cliente = 'SP'
                    THEN tabela_produto.custo * 1.10
                ELSE
                    tabela_produto.custo
            END
        ),
        2
    ) AS custo_total
FROM cap10.clientes AS tabela_cliente
    -- Tabela de clientes.
    -- Fornece os dados cadastrais dos clientes,
    -- incluindo o estado utilizado na agregação.
INNER JOIN cap10.pedidos AS tabela_pedido
    -- Junção entre clientes e pedidos.
    -- O INNER JOIN garante que apenas clientes
    -- que possuem pedidos sejam considerados.
    ON tabela_cliente.id_cli = tabela_pedido.id_cliente
INNER JOIN cap10.produtos AS tabela_produto
    -- Junção entre pedidos e produtos.
    -- Permite acessar os dados dos produtos,
    -- especialmente o custo utilizado no cálculo da soma.
    ON tabela_pedido.id_produto = tabela_produto.id_prod
WHERE
    -- Filtro aplicado sobre o nome dos produtos.
    -- O operador LIKE com '%' permite buscar ocorrências parciais
    -- dentro do texto do nome do produto.
    -- Serão considerados apenas produtos cujo nome contenha
    -- 'Apache' ou 'Análise'.
    tabela_produto.nome_produto LIKE '%Apache%'
    OR tabela_produto.nome_produto LIKE '%Análise%'
GROUP BY
    -- Agrupamento dos registros por estado do cliente.
    -- Necessário para o uso da função de agregação SUM
    -- na coluna de custo.
    tabela_cliente.estado_cliente
HAVING
    -- Filtro aplicado após a agregação.
    -- Mantém apenas os grupos (estados)
    -- cujo custo total agregado dos produtos
    -- seja inferior a 120000.
    SUM(tabela_produto.custo) < 120000
ORDER BY
    -- Ordena o resultado final pelo custo total calculado,
    -- do maior para o menor valor.
    custo_total DESC;
	
/*--------------------------------------------------------------------------------------------
Exercício 10 — Custo total dos pedidos por estado com filtros e regra de negócio

Enunciado:
Qual é o custo total dos pedidos por estado considerando apenas
produtos cujo título contenha as palavras 'Análise' ou 'Apache',
somente quando o custo total estiver entre 150.000 e 250.000.
Além disso, como demonstrar no relatório um aumento de 10% no custo
para pedidos realizados por clientes do estado de São Paulo (SP),
sem modificar os dados na tabela.

Interpretação Analítica:
- Pedidos são a tabela fato da análise
- Estado do cliente é a dimensão de agrupamento
- Produtos devem ser filtrados pelo nome (título)
- Considerar apenas produtos cujo título contenha 'Análise' ou 'Apache'
- O intervalo de custo total (150.000 a 250.000) deve ser aplicado após a agregação
- O aumento de 10% no custo deve ser calculado apenas na consulta (sem UPDATE)
- A regra de negócio depende do estado do cliente (SP)
--------------------------------------------------------------------------------------------*/


SELECT
    -- Estado do cliente.
    -- Representa a localização geográfica do cliente
    -- e define o nível de agregação dos dados apresentados no resultado.
    tabela_cliente.estado_cliente,
    -- Cálculo do custo total dos produtos por estado.
    -- A função SUM agrega os custos dos produtos associados aos pedidos.
    -- O CASE WHEN aplica uma regra condicional antes da agregação:
    --   • Para clientes do estado 'SP', o custo do produto recebe um acréscimo de 10%.
    --   • Para os demais estados, o custo permanece inalterado.
    -- O ROUND é utilizado para arredondar o valor final
    -- para duas casas decimais, padrão comum em relatórios financeiros.
    ROUND(
        SUM(
            CASE
                WHEN tabela_cliente.estado_cliente = 'SP'
                    THEN tabela_produto.custo * 1.10
                ELSE
                    tabela_produto.custo
            END
        ),
        2
    ) AS custo_total
FROM cap10.clientes AS tabela_cliente
    -- Tabela de clientes.
    -- Fornece os dados cadastrais dos clientes,
    -- incluindo o estado utilizado na agregação.
INNER JOIN cap10.pedidos AS tabela_pedido
    -- Junção entre clientes e pedidos.
    -- O INNER JOIN garante que apenas clientes
    -- que possuem pedidos sejam considerados.
    ON tabela_cliente.id_cli = tabela_pedido.id_cliente
INNER JOIN cap10.produtos AS tabela_produto
    -- Junção entre pedidos e produtos.
    -- Permite acessar os dados dos produtos,
    -- especialmente o custo utilizado no cálculo da soma.
    ON tabela_pedido.id_produto = tabela_produto.id_prod
WHERE
    -- Filtro aplicado sobre o nome dos produtos.
    -- O operador LIKE com '%' permite buscar ocorrências parciais
    -- dentro do texto do nome do produto.
    -- Serão considerados apenas produtos cujo nome contenha
    -- 'Apache' ou 'Análise'.
    tabela_produto.nome_produto LIKE '%Apache%'
    OR tabela_produto.nome_produto LIKE '%Análise%'
GROUP BY
    -- Agrupamento dos registros por estado do cliente.
    -- Necessário para o uso da função de agregação SUM
    -- na coluna de custo.
    tabela_cliente.estado_cliente
HAVING
    -- Filtro aplicado após a agregação.
    -- Mantém apenas os grupos (estados)
    -- cujo custo total agregado dos produtos
    -- seja inferior a 120000.
    SUM(tabela_produto.custo) > 150000 and SUM(tabela_produto.custo)< 250000
ORDER BY
    -- Ordena o resultado final pelo custo total calculado,
    -- do maior para o menor valor.
    custo_total DESC;
 
/*--------------------------------------------------------------------------------------------
Exercício 11 — Custo total dos pedidos por estado com regras condicionais de custo

Enunciado:
Qual é o custo total dos pedidos por estado considerando apenas
produtos cujo título contenha as palavras 'Análise' ou 'Apache',
somente quando o custo total estiver entre 150.000 e 250.000?
Além disso, como demonstrar no relatório, sem modificar os dados da tabela,
um aumento de 10% no custo para pedidos realizados por clientes do estado
de São Paulo (SP)?
Por fim, incluir no relatório uma coluna chamada status_aumento,
exibindo o texto 'Com Aumento de Custo' para o estado de SP
e 'Sem Aumento de Custo' para os demais estados.

Interpretação Analítica:
- Pedidos são a tabela fato da análise
- Estado do cliente é a dimensão de agrupamento
- Produtos devem ser filtrados pelo nome (título)
- Considerar apenas produtos cujo título contenha 'Análise' ou 'Apache'
- O intervalo de custo total (150.000 a 250.000) deve ser aplicado após a agregação
- O aumento de 10% no custo deve ser calculado somente na consulta (sem UPDATE)
- A criação da coluna status_aumento deve ser feita via lógica condicional
- A regra de negócio depende do estado do cliente (SP)
--------------------------------------------------------------------------------------------*/
SELECT
    -- Estado do cliente.
    -- Representa a localização geográfica do cliente
    -- e define a granularidade da análise apresentada no resultado final.
    tabela_cliente.estado_cliente,
    -- Cálculo do custo total dos produtos por estado.
    -- A função SUM realiza a agregação dos custos dos produtos associados aos pedidos.
    -- O CASE WHEN aplica uma regra condicional antes da agregação:
    --   • Para clientes do estado 'SP', o custo do produto recebe um acréscimo de 10%.
    --   • Para os demais estados, o custo do produto permanece inalterado.
    -- O ROUND é utilizado para arredondar o valor final
    -- para duas casas decimais, padrão comum em relatórios financeiros.
    ROUND(
        SUM(
            CASE
                WHEN tabela_cliente.estado_cliente = 'SP'
                    THEN tabela_produto.custo * 1.10
                ELSE
                    tabela_produto.custo
            END
        ),
        2
    ) AS custo_total,
    -- Criação de uma coluna indicativa de regra aplicada.
    -- Este CASE avalia o estado do cliente e classifica o registro como:
    --   • 'Com Aumento de Custo' quando o estado for 'SP'
    --   • 'Sem Aumento de Custo' para os demais estados
    -- A coluna serve como um rótulo descritivo para uso em relatórios ou dashboards.
    CASE
        WHEN tabela_cliente.estado_cliente = 'SP'
            THEN 'Com Aumento de Custo'
        ELSE
            'Sem Aumento de Custo'
    END AS status_aumento
FROM cap10.clientes AS tabela_cliente
    -- Tabela de clientes.
    -- Contém os dados cadastrais dos clientes,
    -- incluindo o estado utilizado na agregação e nas regras condicionais.
INNER JOIN cap10.pedidos AS tabela_pedido
    -- Junção entre clientes e pedidos.
    -- O INNER JOIN garante que apenas clientes
    -- que possuem pedidos registrados
    -- sejam considerados na consulta.
    ON tabela_cliente.id_cli = tabela_pedido.id_cliente
INNER JOIN cap10.produtos AS tabela_produto
    -- Junção entre pedidos e produtos.
    -- Permite acessar as informações dos produtos,
    -- especialmente o custo utilizado no cálculo agregado.
    ON tabela_pedido.id_produto = tabela_produto.id_prod
WHERE
    -- Filtro aplicado sobre o nome dos produtos.
    -- O operador LIKE com o curinga '%' permite
    -- a busca por ocorrências parciais no texto.
    -- Apenas produtos cujo nome contenha
    -- 'Apache' ou 'Análise' serão considerados na análise.
    tabela_produto.nome_produto LIKE '%Apache%'
    OR tabela_produto.nome_produto LIKE '%Análise%'
GROUP BY
    -- Agrupamento dos registros.
    -- Os dados são agrupados pelo estado do cliente
    -- e pela coluna derivada status_aumento,
    -- conforme definido na cláusula SELECT.
    tabela_cliente.estado_cliente,
    status_aumento
HAVING
    -- Filtro aplicado após a agregação dos dados.
    -- Mantém apenas os grupos cujo custo total agregado dos produtos
    -- esteja dentro do intervalo especificado:
    -- maior que 150000 e menor que 250000.
    SUM(tabela_produto.custo) > 150000
    AND SUM(tabela_produto.custo) < 250000
ORDER BY
    -- Ordena o resultado final com base no custo total calculado,
    -- do maior para o menor valor.
    custo_total DESC;

/*--------------------------------------------------------------------------------------------
Exercício 12 — Faturamento total por ano e total geral

Enunciado:
Qual é o faturamento total por ano e qual é o faturamento total geral,
considerando todos os pedidos registrados na base?

Interpretação Analítica:
- Pedidos são a tabela fato da análise
- A data do pedido define a dimensão temporal (ano)
- A métrica principal é o faturamento total (soma do valor dos pedidos)
- O relatório deve apresentar:
  - o faturamento agregado por ano
  - o faturamento total geral (todos os anos)
- A solução deve ser construída apenas com SQL (sem alterar dados)
--------------------------------------------------------------------------------------------*/

SELECT
    -- A coluna "ano" representa o ano da venda.
    -- A função TO_CHAR converte o valor do ano para texto,
    -- permitindo combinar valores numéricos com texto.
    -- O COALESCE substitui valores NULL pelo texto 'total'.
    -- Esse NULL ocorre na linha de totalização criada pelo ROLLUP.
    COALESCE(TO_CHAR(ano, '9999'), 'total') AS ano,
    -- A função SUM realiza a agregação do faturamento.
    -- Calcula o total de faturamento por ano
    -- e também o total geral (linha criada pelo ROLLUP).
    SUM(faturamento) AS faturamento_total
-- A tabela cap10.vendas contém os registros de vendas
-- com informações de ano e faturamento.
FROM cap10.vendas
-- O GROUP BY com ROLLUP cria múltiplos níveis de agregação:
--  • Total por ano
--  • Total geral (todas as linhas somadas)
-- Na linha de total geral, a coluna "ano" assume valor NULL.
GROUP BY ROLLUP (ano)
-- Ordena o resultado pela coluna "ano".
-- Os anos aparecem ordenados e a linha de total
-- é posicionada conforme a ordenação textual.
ORDER BY ano;
    
/*--------------------------------------------------------------------------------------------
Exercício 12 — Faturamento total por ano, país e total geral (ROLLUP)

Enunciado:
Qual é o faturamento total por ano e por país, e qual é o faturamento
total geral considerando todos os pedidos registrados na base?
O relatório deve apresentar os totais detalhados e os subtotais,
incluindo o total geral, utilizando ROLLUP.

Interpretação Analítica:
- Pedidos são a tabela fato da análise
- A data do pedido define a dimensão temporal (ano)
- O país define a dimensão geográfica
- A métrica principal é o faturamento total (soma do valor dos pedidos)
- O relatório deve conter:
  - faturamento por ano e país
  - subtotais por ano
  - total geral consolidado
- O uso de ROLLUP permite gerar automaticamente os níveis de agregação
- A solução deve ser construída apenas com SQL (sem alterar dados)
--------------------------------------------------------------------------------------------*/

SELECT
    -- A coluna "ano" representa o ano da venda.
    -- A função TO_CHAR converte o valor numérico do ano para texto,
    -- permitindo combinar valores numéricos com textos descritivos.
    -- O COALESCE substitui valores NULL pelo texto
    -- 'Soma Total Faturamento Ano'.
    -- O NULL ocorre nas linhas de subtotal e total criadas pelo ROLLUP.
    COALESCE(TO_CHAR(ano, '9999'),'Soma Total Faturamento Ano') AS ano,
    -- A coluna "pais" representa o país associado à venda.
    -- O COALESCE substitui valores NULL pelo texto
    -- 'Soma Faturamento Paises'.
    -- O NULL aparece nas linhas onde o ROLLUP gera
    -- totais agregados acima do nível de país.
    COALESCE(pais, 'Subtotal Paises') AS pais,
    -- A função SUM agrega o valor de faturamento.
    -- Calcula:
    --   • O faturamento por ano e país
    --   • O faturamento total por ano
    --   • O faturamento total geral
    SUM(faturamento) AS faturamento_total
-- A tabela cap10.vendas contém os registros de vendas,
-- incluindo ano, país e valor de faturamento.
FROM cap10.vendas
-- O GROUP BY com ROLLUP cria múltiplos níveis de agregação:
--   • (ano, pais) → detalhamento por ano e país
--   • (ano)       → subtotal por ano
--   • ()          → total geral
-- Nas linhas de subtotal e total, as colunas "ano" e/ou "pais"
-- assumem valor NULL.
GROUP BY ROLLUP (ano, pais)
-- Ordena o resultado primeiro pelo ano
-- e depois pelo país, mantendo uma hierarquia
-- clara no relatório.
ORDER BY ano, pais;


/*--------------------------------------------------------------------------------------------
Exercício 13 — Faturamento total por ano, país e totais gerais (CUBE)

Enunciado:
Qual é o faturamento total por ano e por país, bem como todos os
totais gerais possíveis considerando essas dimensões?
O relatório deve apresentar:
- faturamento por ano e país
- total por ano (todos os países)
- total por país (todos os anos)
- total geral consolidado
utilizando a cláusula CUBE.

Interpretação Analítica:
- Pedidos são a tabela fato da análise
- A data do pedido define a dimensão temporal (ano)
- O país define a dimensão geográfica
- A métrica principal é o faturamento total (soma do valor dos pedidos)
- O uso de CUBE gera automaticamente todas as combinações de agregação
- O relatório deve conter totais detalhados e consolidados
- A solução deve ser construída apenas com SQL (sem alterar os dados)
--------------------------------------------------------------------------------------------*/

SELECT
    -- A coluna "ano" representa o ano da venda.
    -- A função TO_CHAR converte o valor numérico do ano para texto,
    -- permitindo combinar valores numéricos com textos descritivos.
    -- O COALESCE substitui valores NULL pelo texto
    -- 'Soma Total Faturamento Ano'.
    -- O valor NULL ocorre nas linhas de subtotal e total
    -- criadas pelo uso do CUBE.
    COALESCE(TO_CHAR(ano, '9999'), 'Soma Total Faturamento Ano') AS ano,
    -- A coluna "pais" representa o país associado à venda.
    -- O COALESCE substitui valores NULL pelo texto
    -- 'Subtotal Paises'.
    -- O NULL aparece nas linhas onde o CUBE gera
    -- níveis de agregação acima do detalhamento por país.
    COALESCE(pais, 'Subtotal Paises') AS pais,
	-- A função SUM realiza a agregação do faturamento.
    -- Calcula o faturamento considerando todos os níveis
    -- de agregação gerados pelo CUBE.
    SUM(faturamento) AS faturamento_total
-- A tabela cap10.vendas contém os registros de vendas,
-- incluindo informações de ano, país e valor de faturamento.
FROM cap10.vendas
-- O GROUP BY com CUBE cria todas as combinações possíveis
-- de agregação entre as colunas informadas:
--   • (ano, pais) → detalhamento completo
--   • (ano)       → subtotal por ano
--   • (pais)      → subtotal por país
--   • ()          → total geral
-- Nos níveis de subtotal e total, as colunas "ano" e/ou "pais"
-- assumem valor NULL.
GROUP BY CUBE (ano, pais)
-- Ordena o resultado primeiro pelo ano
-- e depois pelo país, mantendo uma organização
-- hierárquica e legível do relatório.
ORDER BY ano, pais;



