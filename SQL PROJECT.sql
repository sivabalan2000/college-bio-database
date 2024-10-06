
CREATE TABLE Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL
);

INSERT INTO Department (dept_name) VALUES 
('Computer Science'), 
('Mathematics'), 
('Physics');

SELECT Student.name, Course.course_name, Grades.grade
FROM Grades
JOIN Student ON Grades.student_id = Student.student_id
JOIN Course ON Grades.course_id = Course.course_id
WHERE Student.student_id = 1;

UPDATE Student
SET dept_id = 2
WHERE student_id = 1;
SELECT * FROM Department;

CREATE TABLE Faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

INSERT INTO Faculty (name, dept_id) VALUES 
('Dr. Smith', 1), 
('Dr. Johnson', 2), 
('Dr. Williams', 3);

SELECT Course.course_name, Faculty.name AS faculty_name
FROM Course
JOIN Faculty ON Course.faculty_id = Faculty.faculty_id;


UPDATE Faculty
SET dept_id = 3
WHERE faculty_id = 2;


SELECT * FROM Faculty;



CREATE TABLE Student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dept_id INT,
    enrollment_year YEAR,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

INSERT INTO Student (name, dept_id, enrollment_year) VALUES 
('Alice', 1, 2022), 
('Bob', 2, 2021), 
('Charlie', 3, 2020);

SELECT Student.name, Course.course_name, Grades.grade
FROM Grades
JOIN Student ON Grades.student_id = Student.student_id
JOIN Course ON Grades.course_id = Course.course_id
WHERE Student.student_id = 1

SELECT * FROM Student WHERE dept_id = 1;
select * from student;

CREATE TABLE Course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    credits INT,
    dept_id INT,
    faculty_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id)
);

INSERT INTO Course (course_name, credits, dept_id, faculty_id) VALUES 
('Data Structures', 4, 1, 1), 
('Calculus', 3, 2, 2), 
('Quantum Physics', 4, 3, 3);


SELECT Course.course_name, Faculty.name AS faculty_name
FROM Course
JOIN Faculty ON Course.faculty_id = Faculty.faculty_id;



SELECT * FROM Course;


CREATE TABLE Enrollment (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

INSERT INTO Enrollment (student_id, course_id, enrollment_date) VALUES 
(1, 1, '2023-09-01'), 
(2, 2, '2023-09-02'), 
(3, 3, '2023-09-03');
DELETE FROM Enrollment WHERE student_id = 1 AND course_id = 1;
SELECT * FROM Enrollment;

CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT,
    student_id INT,
    attendance_date DATE,
    status ENUM('Present', 'Absent'),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
);

INSERT INTO Attendance (course_id, student_id, attendance_date, status) VALUES 
(1, 1, '2023-09-05', 'Present'), 
(2, 2, '2023-09-05', 'Absent'), 
(3, 3, '2023-09-05', 'Present');

SELECT Attendance.attendance_date, Attendance.status
FROM Attendance
JOIN Student ON Attendance.student_id = Student.student_id
WHERE Student.student_id = 1 AND Attendance.course_id = 1;

SELECT * FROM Attendance;



CREATE TABLE Grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

INSERT INTO Grades (student_id, course_id, grade) VALUES 
(1, 1, 'A'), 
(2, 2, 'B+'), 
(3, 3, 'A-');

UPDATE Grades
SET grade = 'A+'
WHERE student_id = 1 AND course_id = 1;

SELECT * FROM Grades;

DELETE FROM Course WHERE course_id = 2;

DELIMITER //
CREATE PROCEDURE RegisterCourse(IN student INT, IN course INT)
BEGIN
    DECLARE course_exists INT;
    DECLARE student_enrolled INT;
    
    -- Check if the course exists
    SELECT COUNT(*) INTO course_exists
    FROM Course WHERE course_id = course;
    
    IF course_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course does not exist!';
    END IF;
    
    
    SELECT COUNT(*) INTO student_enrolled
    FROM Enrollment WHERE student_id = student AND course_id = course;
    
    IF student_enrolled > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student is already enrolled in this course!';
    ELSE
        -- If not enrolled, register the student for the course
        INSERT INTO Enrollment (student_id, course_id, enrollment_date)
        VALUES (student, course, CURDATE());
    END IF;
END \\
DELIMITER ;

CREATE TRIGGER prevent_department_delete
BEFORE DELETE ON Department
FOR EACH ROW
BEGIN

DECLARE faculty_count INT;
    
    
    SELECT COUNT(*) INTO faculty_count
    FROM Faculty
    WHERE dept_id = OLD.dept_id;
    
    IF faculty_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete department with active faculty members!';
    END IF;
    
    
END;











