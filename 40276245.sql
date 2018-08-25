-- Author: 		40276245 (Alex McGill)
-- Content:		SECTION 1 > Answers to questions 6,7,8,10 and 11
-- 				SECTION 2 > An ERD + SQL statements to modify the database

----- SECTION 1 -----

/* QUESTION 6 */
SELECT company_name,
       COUNT(company_name) AS cc
FROM Issue
JOIN Caller ON (Issue.Caller_id=Caller.Caller_id)
JOIN Customer ON (Caller.Company_ref=Customer.Company_ref)
GROUP BY company_name
HAVING (COUNT(company_name) > 18);

/* QUESTION 6 - RESULT
+------------------+----+
| company_name     | cc |
+------------------+----+
| Gimmick Inc.     | 22 |
| Hamming Services | 19 |
| High and Co.     | 20 |
+------------------+----+ */


/* QUESTION 7 */
SELECT first_name,
       last_name
FROM Caller
LEFT JOIN Issue ON (Caller.Caller_id=Issue.Caller_id)
WHERE Issue.Caller_id IS NULL;

/* QUESTION 7 - RESULT
+------------+-----------+
| first_name | last_name |
+------------+-----------+
| David      | Jackson   |
| Ethan      | Phillips  |
+------------+-----------+ */


/* QUESTION 8 */
SELECT company_name,
	   (SELECT first_name FROM Caller WHERE caller_id=contact_id) AS first_name,
	   (SELECT last_name FROM Caller WHERE caller_id=contact_id) AS last_name,
       COUNT(Issue.caller_id) AS nc
FROM Customer
JOIN Caller ON (Customer.company_ref=Caller.company_ref)
JOIN Issue ON (Issue.caller_id=Caller.caller_id)
GROUP BY company_name,
		 contact_id
HAVING (COUNT(company_name) < 5);

/* QUESTION 8 - RESULT
+--------------------+------------+-----------+----+
| company_name       | first_name | last_name | nc |
+--------------------+------------+-----------+----+
| Pitiable Shipping  | Ethan      | McConnell |  4 |
| Rajab Group        | Emily      | Cooper    |  4 |
| Somebody Logistics | Ethan      | Phillips  |  2 |
+--------------------+------------+-----------+----+ */


/* QUESTION 10 */
SELECT Staff.first_name,
       Staff.last_name,
       call_date
FROM Caller
JOIN Issue ON (Caller.caller_id=Issue.Caller_id)
JOIN Staff ON (Issue.Taken_by=Staff.Staff_code)
WHERE Caller.First_name='Harry'
ORDER BY call_date DESC
LIMIT 1;

/* QUESTION 10 - RESULT
+--------------------+------------+-----------+----+
| company_name       | first_name | last_name | nc |
+--------------------+------------+-----------+----+
| Pitiable Shipping  | Ethan      | McConnell |  4 |
| Rajab Group        | Emily      | Cooper    |  4 |
| Somebody Logistics | Ethan      | Phillips  |  2 |
+--------------------+------------+-----------+----+ */


/* QUESTION 11 */
SELECT Shift.manager AS Manager,
       DATE_FORMAT(call_date, '%Y-%m-%d %H') AS Hr,
       COUNT(*) AS cc
FROM Issue
JOIN Shift ON (CAST(Shift.shift_date AS DATE) = CAST(Issue.call_date AS DATE))
JOIN Shift_type ON (Shift_type.shift_type = Shift.shift_type
                    AND DATE_FORMAT(Issue.call_date, '%H:%M') BETWEEN Shift_type.start_time AND Shift_type.end_time)
WHERE Shift.shift_date = '2017-08-12'
GROUP BY Shift.manager,
         Hr
ORDER BY Hr;

/* QUESTION 11 - RESULT
+---------+---------------+----+
| Manager | Hr            | cc |
+---------+---------------+----+
| LB1     | 2017-08-12 08 |  6 |
| LB1     | 2017-08-12 09 | 16 |
| LB1     | 2017-08-12 10 | 11 |
| LB1     | 2017-08-12 11 |  6 |
| LB1     | 2017-08-12 12 |  8 |
| LB1     | 2017-08-12 13 |  4 |
| AE1     | 2017-08-12 14 | 12 |
| AE1     | 2017-08-12 15 |  8 |
| AE1     | 2017-08-12 16 |  8 |
| AE1     | 2017-08-12 17 |  7 |
| AE1     | 2017-08-12 19 |  5 |
+---------+---------------+----+ */

----- SECTION 2 -----

-- Alterations to the database
ALTER TABLE Issue ADD rating INT NOT NULL;
ALTER TABLE Issue ADD CONSTRAINT rating CHECK (rating >= 0 AND rating <= 5);
ALTER TABLE Issue CHANGE Assigned_to Initial_assignment VARCHAR(6) NOT NULL;

CREATE TABLE Reassignment(
	Call_ref INT NOT NULL,
	Reassignment_date_time DATETIME NOT NULL,
	Reassigned_to VARCHAR(6) NOT NULL,
	Reassigned_by VARCHAR(6) NOT NULL,
	FOREIGN KEY (Call_ref) REFERENCES Issue(Call_ref),
	FOREIGN KEY (Reassigned_to) REFERENCES Staff(Staff_code),
	FOREIGN KEY (Reassigned_by) REFERENCES Staff(Staff_code),
	PRIMARY KEY (Reassignment_date_time,Call_ref)
);

-- Inserting the data into the database
UPDATE Issue
SET rating = 5
WHERE call_ref = 1530;

UPDATE Issue
SET rating = 1
WHERE call_ref = 1531;

INSERT INTO Reassignment (call_ref, Reassignment_date_time, Reassigned_to, Reassigned_by) VALUES (1707, '2017-08-16 15:50:00', 'AL1', 'DJ1');
INSERT INTO Reassignment (call_ref, Reassignment_date_time, Reassigned_to, Reassigned_by) VALUES (1707, '2017-08-17 08:00:00', 'DJ1', 'AL1');