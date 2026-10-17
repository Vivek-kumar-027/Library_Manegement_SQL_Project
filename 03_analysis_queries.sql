-- Library Management System: analysis queries
-- Reference "today" is fixed so results are reproducible.

-- Q1. Most borrowed books (top 10)
SELECT b.title, COUNT(*) AS times_borrowed
FROM loans l
JOIN books b ON b.book_id = l.book_id
GROUP BY b.book_id
ORDER BY times_borrowed DESC, b.title
LIMIT 10;

-- Q2. Loans and share of total by category
SELECT c.name AS category,
       COUNT(*) AS loans,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_loans
FROM loans l
JOIN books b      ON b.book_id = l.book_id
JOIN categories c ON c.category_id = b.category_id
GROUP BY c.category_id
ORDER BY loans DESC;

-- Q3. Currently overdue loans (not returned, past due date)
SELECT m.full_name, b.title, l.due_on,
       CAST(julianday('2026-10-17') - julianday(l.due_on) AS INTEGER) AS days_overdue
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books b   ON b.book_id   = l.book_id
WHERE l.returned_on IS NULL
  AND l.due_on < '2026-10-17'
ORDER BY days_overdue DESC;

-- Q4. Books with no copies currently available
SELECT b.title, b.copies_total, COUNT(l.loan_id) AS currently_out
FROM books b
LEFT JOIN loans l ON l.book_id = b.book_id AND l.returned_on IS NULL
GROUP BY b.book_id
HAVING currently_out >= b.copies_total
ORDER BY b.title;

-- Q5. Top 5 most active members
SELECT m.full_name, m.member_type, COUNT(*) AS loans
FROM loans l
JOIN members m ON m.member_id = l.member_id
GROUP BY m.member_id
ORDER BY loans DESC, m.full_name
LIMIT 5;

-- Q6. Monthly borrowing trend with month-over-month change (window function)
WITH monthly AS (
    SELECT strftime('%Y-%m', borrowed_on) AS month, COUNT(*) AS loans
    FROM loans
    GROUP BY month
)
SELECT month, loans,
       loans - LAG(loans) OVER (ORDER BY month) AS change_vs_prev
FROM monthly
ORDER BY month;

-- Q7. Fines summary by member type
SELECT m.member_type,
       COUNT(f.fine_id)                              AS fines_count,
       ROUND(SUM(f.amount), 2)                       AS total_fines,
       ROUND(SUM(CASE WHEN f.paid = 0 THEN f.amount ELSE 0 END), 2) AS unpaid
FROM fines f
JOIN loans l   ON l.loan_id = f.loan_id
JOIN members m ON m.member_id = l.member_id
GROUP BY m.member_type
ORDER BY total_fines DESC;

-- Q8. Late-return rate per category
SELECT c.name AS category,
       COUNT(*) AS returned_loans,
       ROUND(100.0 * SUM(l.returned_on > l.due_on) / COUNT(*), 1) AS late_pct
FROM loans l
JOIN books b      ON b.book_id = l.book_id
JOIN categories c ON c.category_id = b.category_id
WHERE l.returned_on IS NOT NULL
GROUP BY c.category_id
ORDER BY late_pct DESC;

-- Q9. Rank books within each category by popularity (RANK window)
SELECT category, title, loans, rnk
FROM (
    SELECT c.name AS category, b.title, COUNT(l.loan_id) AS loans,
           RANK() OVER (PARTITION BY c.category_id ORDER BY COUNT(l.loan_id) DESC) AS rnk
    FROM books b
    JOIN categories c ON c.category_id = b.category_id
    LEFT JOIN loans l ON l.book_id = b.book_id
    GROUP BY b.book_id
)
WHERE rnk <= 2
ORDER BY category, rnk, title;

-- Q10. Most borrowed authors (via many-to-many bridge)
SELECT a.full_name, a.country, COUNT(l.loan_id) AS loans
FROM authors a
JOIN book_authors ba ON ba.author_id = a.author_id
JOIN loans l         ON l.book_id = ba.book_id
GROUP BY a.author_id
ORDER BY loans DESC
LIMIT 5;

-- Q11. Members who never borrowed anything
SELECT m.full_name, m.joined_on
FROM members m
WHERE NOT EXISTS (SELECT 1 FROM loans l WHERE l.member_id = m.member_id);

-- Q12. Average loan duration (days) by member type, returned loans only
SELECT m.member_type,
       ROUND(AVG(julianday(l.returned_on) - julianday(l.borrowed_on)), 1) AS avg_days_kept
FROM loans l
JOIN members m ON m.member_id = l.member_id
WHERE l.returned_on IS NOT NULL
GROUP BY m.member_type;

-- Q13. Active loans via the view
SELECT * FROM v_active_loans ORDER BY due_on LIMIT 10;
