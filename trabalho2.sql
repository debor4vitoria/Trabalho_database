WITH ranked_clients AS (
    SELECT 
        YEAR(m.data_hora_entrada) AS ano,
        c.id_cliente,
        c.nome_cliente,
        COUNT(p.codigo_prato) AS total_pedidos,
        ROW_NUMBER() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(p.codigo_prato) DESC) AS rn
    FROM 
        tb_pedido p
    JOIN 
        tb_mesa m ON p.codigo_mesa = m.codigo_mesa
    JOIN 
        tb_cliente c ON m.id_cliente = c.id_cliente
    GROUP BY 
        ano, c.id_cliente
)
SELECT 
    ano, id_cliente, nome_cliente, total_pedidos
FROM 
    ranked_clients
WHERE 
    rn = 1;


SELECT 
    c.id_cliente,
    c.nome_cliente,
    SUM(p.quantidade_pedido * pr.preco_unitario_prato) AS total_gasto
FROM 
    tb_pedido p
JOIN 
    tb_mesa m ON p.codigo_mesa = m.codigo_mesa
JOIN 
    tb_cliente c ON m.id_cliente = c.id_cliente
JOIN 
    tb_prato pr ON p.codigo_prato = pr.codigo_prato
GROUP BY 
    c.id_cliente
ORDER BY 
    total_gasto DESC
LIMIT 1;



WITH total_pessoas_por_cliente AS (
    SELECT 
        YEAR(m.data_hora_entrada) AS ano,
        c.id_cliente,
        c.nome_cliente,
        SUM(m.num_pessoa_mesa) AS total_pessoas
    FROM 
        tb_mesa m
    JOIN 
        tb_cliente c ON m.id_cliente = c.id_cliente
    GROUP BY 
        YEAR(m.data_hora_entrada), c.id_cliente, c.nome_cliente
),
ranked_clients AS (
    SELECT 
        ano,
        id_cliente,
        nome_cliente,
        total_pessoas,
        ROW_NUMBER() OVER (PARTITION BY ano ORDER BY total_pessoas DESC) AS rn
    FROM 
        total_pessoas_por_cliente
)
SELECT 
    ano, 
    id_cliente, 
    nome_cliente, 
    total_pessoas
FROM 
    ranked_clients
WHERE 
    rn = 1;


SELECT subquery.ano, subquery.nome_empresa, subquery.total_funcionarios_sobremesa
FROM (
    SELECT YEAR(m.data_hora_entrada) AS ano,
           e.nome_empresa,
           COUNT(DISTINCT b.codigo_funcionario) AS total_funcionarios_sobremesa,
           RANK() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(DISTINCT b.codigo_funcionario) DESC) AS rank_funcionarios_sobremesa
    FROM tb_pedido AS p
    INNER JOIN tb_mesa AS m ON p.codigo_mesa = m.codigo_mesa
    INNER JOIN tb_beneficio AS b ON m.id_cliente = b.codigo_funcionario
    INNER JOIN tb_prato AS pr ON p.codigo_prato = pr.codigo_prato
    INNER JOIN tb_empresa AS e ON b.codigo_empresa = e.codigo_empresa
    INNER JOIN tb_tipo_prato AS tp ON pr.codigo_tipo_prato = tp.codigo_tipo_prato
    WHERE tp.nome_tipo_prato = 'Sobremesa'
    GROUP BY ano, e.nome_empresa
) AS subquery
WHERE subquery.rank_funcionarios_sobremesa = 1;



SELECT 
    subquery.ano, 
    subquery.nome_empresa, 
    subquery.total_funcionarios_sobremesa
FROM (
    SELECT 
        YEAR(m.data_hora_entrada) AS ano,
        e.nome_empresa,
        COUNT(DISTINCT b.codigo_funcionario) AS total_funcionarios_sobremesa,
        RANK() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(DISTINCT b.codigo_funcionario) DESC) AS rank_funcionarios_sobremesa
    FROM 
        tb_pedido AS p
    INNER JOIN 
        tb_mesa AS m ON p.codigo_mesa = m.codigo_mesa
    INNER JOIN 
        tb_beneficio AS b ON m.id_cliente = b.codigo_funcionario
    INNER JOIN 
        tb_prato AS pr ON p.codigo_prato = pr.codigo_prato
    INNER JOIN 
        tb_empresa AS e ON b.codigo_empresa = e.codigo_empresa
    INNER JOIN 
        tb_tipo_prato AS tp ON pr.codigo_tipo_prato = tp.codigo_tipo_prato
    WHERE 
        tp.nome_tipo_prato = 'Sobremesa'
    GROUP BY 
        ano, e.nome_empresa
) AS subquery
WHERE 
    subquery.rank_funcionarios_sobremesa = 1;


