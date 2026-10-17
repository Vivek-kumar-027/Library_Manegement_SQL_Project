-- Library Management System: schema
-- Works on SQLite; for MySQL/PostgreSQL swap AUTOINCREMENT for AUTO_INCREMENT / SERIAL.

PRAGMA foreign_keys = ON;

DROP VIEW  IF EXISTS v_active_loans;
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS members;

CREATE TABLE members (
    member_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name    TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE,
    member_type  TEXT NOT NULL CHECK (member_type IN ('student','teacher','public')),
    joined_on    DATE NOT NULL
);

CREATE TABLE categories (
    category_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT NOT NULL UNIQUE
);

CREATE TABLE authors (
    author_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name    TEXT NOT NULL,
    country      TEXT
);

CREATE TABLE books (
    book_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    title            TEXT NOT NULL,
    category_id      INTEGER NOT NULL REFERENCES categories(category_id),
    published_year   INTEGER CHECK (published_year BETWEEN 1400 AND 2100),
    copies_total     INTEGER NOT NULL DEFAULT 1 CHECK (copies_total >= 0)
);

CREATE TABLE book_authors (
    book_id    INTEGER NOT NULL REFERENCES books(book_id),
    author_id  INTEGER NOT NULL REFERENCES authors(author_id),
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE loans (
    loan_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id       INTEGER NOT NULL REFERENCES books(book_id),
    member_id     INTEGER NOT NULL REFERENCES members(member_id),
    borrowed_on   DATE NOT NULL,
    due_on        DATE NOT NULL,
    returned_on   DATE,                       -- NULL = still out
    CHECK (due_on >= borrowed_on),
    CHECK (returned_on IS NULL OR returned_on >= borrowed_on)
);

CREATE TABLE fines (
    fine_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    loan_id    INTEGER NOT NULL UNIQUE REFERENCES loans(loan_id),
    amount     REAL NOT NULL CHECK (amount >= 0),
    paid       INTEGER NOT NULL DEFAULT 0 CHECK (paid IN (0,1))
);

CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_book   ON loans(book_id);
CREATE INDEX idx_books_cat    ON books(category_id);

CREATE VIEW v_active_loans AS
SELECT l.loan_id, m.full_name AS member, b.title, l.borrowed_on, l.due_on
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books   b ON b.book_id   = l.book_id
WHERE l.returned_on IS NULL;
