-- Create the database for our library project
CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

-- Created the Books table
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(100)
);

-- Created the Members table
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    join_date DATE NOT NULL
);

-- Created the Loans table to connect Books and Members
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT,
    member_id INT,
    borrow_date DATE NOT NULL,
    return_date DATE, -- Remains null if the book is borrowed but not returned
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- Insert data into the Books table
INSERT INTO Books (title, author, genre) VALUES
('The Hitchhiker''s Guide to the Galaxy', 'Douglas Adams', 'Science Fiction'),
('1984', 'George Orwell', 'Dystopian'),
('To Kill a Mockingbird', 'Harper Lee', 'Fiction'),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction');

-- Insert data into the Members table
INSERT INTO Members (name, join_date) VALUES
('Alice Johnson', '2024-01-15'),
('Bob Williams', '2024-03-22');

-- Insert data into the Loans table
-- ALL THE DIFFERENT CASES WILL RESULT IN DIFFERENT DIFFERENT RECORDS STORAGE
-- Loan 1: Returned book
INSERT INTO Loans (book_id, member_id, borrow_date, return_date) VALUES
(3, 1, '2025-06-01', '2025-06-15');

-- Loan 2: Active loan (not overdue)
INSERT INTO Loans (book_id, member_id, borrow_date, return_date) VALUES
(2, 1, '2025-07-25', NULL);

-- Loan 3: OVERDUE loan (borrowed more than 2 weeks ago and not returned)
INSERT INTO Loans (book_id, member_id, borrow_date, return_date) VALUES
(1, 2, '2025-07-10', NULL);


-- check out a book by a member(borrowing a book)
-- Example: Member Alice Johnson (member_id=1) checks out 'The Great Gatsby' (book_id=4)
INSERT INTO Loans (book_id, member_id, borrow_date, return_date) VALUES
(4, 1, CURDATE(), NULL);

-- List all books currently borrowed by a specific member
-- Example:- Find all books currently borrowed by Alice Johnson (member_id=1)
SELECT
    b.title,
    b.author,
    l.borrow_date
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
WHERE l.member_id = 1 AND l.return_date IS NULL;


-- Find all overdue books (borrowed > 14 days ago and not returned)
SELECT
    m.name AS member_name,
    b.title AS book_title,
    l.borrow_date
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL AND l.borrow_date < DATE_SUB(CURDATE(), INTERVAL 14 DAY);


-- more updates
ALTER TABLE Books
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'available';

-- Find all book_ids that are in a loan with no return_date and update their status
SET SQL_SAFE_UPDATES = 0;
UPDATE Books
SET status = 'on loan'
WHERE book_id IN (SELECT book_id FROM Loans WHERE return_date IS NULL);

-- Task 2: Return a book (e.g., loan_id = 2)

-- Part A: Update the loan record to set the return date.
UPDATE Loans
SET return_date = CURDATE()
WHERE loan_id = 2;

-- Part B: Update the book's status back to 'available'.
-- We need to find which book_id corresponds to loan_id 2.
UPDATE Books
SET status = 'available'
WHERE book_id = (SELECT book_id FROM Loans WHERE loan_id = 2);

-- Task 3: Find the most popular books
SELECT
    b.title,
    b.author,
    COUNT(l.book_id) AS number_of_loans
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
GROUP BY l.book_id
ORDER BY number_of_loans DESC;