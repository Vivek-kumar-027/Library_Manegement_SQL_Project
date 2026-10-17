# Library Management System: SQL Project

A portfolio project that models a small library and answers real business questions with SQL: popularity, overdue loans, fines, borrowing trends and member behaviour.

## Database design

| Table | Purpose |
|---|---|
| `members` | Library members (student / teacher / public) |
| `categories` | Book genres |
| `authors` | Authors and their country |
| `books` | Titles, category, year, number of copies |
| `book_authors` | Many-to-many bridge between books and authors |
| `loans` | Each borrowing; `returned_on IS NULL` means still out |
| `fines` | One fine per late loan, with paid flag |

Also includes a view `v_active_loans`, indexes on the foreign keys, and `CHECK` constraints for data integrity (valid dates, non-negative amounts, allowed member types).

**Seed data:** 25 members, 30 books, 15 authors, 8 categories, 220 loans (Jan to Oct 2026), 64 fines. Generated with a fixed random seed (`gen_seed.py`), so results are reproducible.

## Files

1. `01_schema.sql`: tables, indexes, view
2. `02_seed_data.sql`: sample data
3. `03_analysis_queries.sql`: 13 analysis queries
4. `gen_seed.py`: script that generated the seed data

## How to run (SQLite)

```bash
sqlite3 library.db < 01_schema.sql
sqlite3 library.db < 02_seed_data.sql
sqlite3 -header -column library.db < 03_analysis_queries.sql
```

No sqlite3 CLI? Use Python:

```python
import sqlite3
db = sqlite3.connect("library.db")
db.executescript(open("01_schema.sql").read())
db.executescript(open("02_seed_data.sql").read())
```

Or paste the files into [DB Fiddle](https://www.db-fiddle.com) or [SQLite Online](https://sqliteonline.com).

## SQL skills demonstrated

- Multi-table `JOIN`s (inner and left) and a many-to-many bridge
- Aggregation with `GROUP BY` / `HAVING`
- Window functions: `RANK()`, `LAG()`, `SUM() OVER ()`
- CTEs, subqueries, `NOT EXISTS`
- Date arithmetic (`julianday`, `strftime`)
- Views, constraints, indexes

## Sample findings

- *Atomic Habits* is the most borrowed book (24 loans); Fiction makes up about a third of all loans.
- *Contact* has no copies available and two overdue loans.
- Students account for the largest share of fines, but nearly half of the amount is still unpaid.
- Brandon Sanderson is the most borrowed author.

## Ideas to extend

- Add a reservations table and a waiting-list query
- Write a stored procedure / trigger that auto-creates fines on return
- Build a dashboard (Power BI / Tableau) on top of the queries
- Port to MySQL or PostgreSQL
