# SQL — Checklist de Habilidades (com Docker)

Repositório para **estudo amplo de SQL**, organizado por níveis do seu checklist. Foco em prática, portabilidade (Postgres/MySQL/SQLite) e execução reprodutível via **Docker**.

---

## 🎯 Objetivo

Cobrir, com exemplos práticos, de **fundamentos a tópicos profissionais**: consultas, joins, agregações, janela, CTEs, DDL, performance, transações, segurança e modelagem.

---

## 🧩 Escopo por Nível

### 🔹 Nível 1 — Básico (Fundamentos)

SELECT / FROM • projeção de colunas • DISTINCT • WHERE • AND/OR/NOT • ORDER BY • INSERT • UPDATE • DELETE • NULL (IS/IS NOT) • LIMIT/TOP

### 🔹 Nível 2 — Intermediário (Agregações e Filtros)

Agregações (COUNT/SUM/AVG/MIN/MAX) • GROUP BY • HAVING • LIKE (%/_) • BETWEEN/IN • aliases (AS) • `CASE WHEN`

### 🔹 Nível 3 — Joins e Subconsultas

INNER/LEFT/RIGHT/FULL/SELF • UNION/UNION ALL • subconsultas em SELECT/FROM/WHERE • comparações com subquery • EXISTS/ANY/ALL

### 🔹 Nível 4 — Avançado (Otimização e Datas)

CREATE/DROP DATABASE • CREATE/ALTER TABLE • constraints (NOT NULL, UNIQUE, PK, FK, CHECK, DEFAULT) • índices e performance • datas (DATE/DATETIME, EXTRACT/DATE_PART/AGE) • VIEW • `INSERT INTO ... SELECT` • funções janela (ROW_NUMBER/RANK/LAG/LEAD com OVER/PARTITION BY) • CTEs (`WITH ... AS`)

### 🔹 Nível 5 — Ultra-Avançado (Profissional e Otimização)

Stored Procedures/Functions • Triggers • Transações (BEGIN/COMMIT/ROLLBACK) • concorrência/LOCK/níveis de isolamento • segurança (GRANT/REVOKE) • SQL Injection (prevenção) • EXPLAIN/ANALYZE • índices compostos/particionamento • data types específicos do SGBD • modelagem (1FN/2FN/3FN) e desnormalização (BI)

---

## 🔁 Portabilidade rápida (Postgres ↔ MySQL)

* **Datas**: `DATE_TRUNC` (PG) ↔ `DATE_FORMAT` (MySQL).
* **FULL OUTER JOIN**: nativo no PG; no MySQL, simule com `LEFT JOIN ... UNION ... RIGHT JOIN` (excluindo duplicatas).
* **Funções janela**: OK em ambos (MySQL 8+).
* **JSON**: `->/->>` e `jsonb_*` (PG) ↔ `JSON_EXTRACT/JSON_OBJECT` (MySQL).
* **AUTO INCREMENT**: `SERIAL/IDENTITY` (PG) ↔ `AUTO_INCREMENT` (MySQL).

---

## ✅ Boas práticas (para todo o repositório)

* Evite `SELECT *` em produção; nomeie colunas.
* Indices em colunas de **JOIN**/**WHERE** frequentes; teste com `EXPLAIN`.
* Comente consultas complexas; separe **DDL/DML**; versionamento de schema.
* Use **transações** para cargas/alterações críticas; **prepared statements** para evitar SQL Injection.

---

## 📄 Licença

MIT — use e adapte livremente.
