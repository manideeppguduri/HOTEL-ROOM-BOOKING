create database hotel_analysis;
use hotel_analysis;

-- Sprint 2: Database Setup

-- 2.1 Database Design (DDL)

CREATE TABLE hotels (
    hotel_id     VARCHAR(20)    NOT NULL,
    hotel_name   VARCHAR(100)   NOT NULL,
    city         VARCHAR(50)    NOT NULL,
    star_rating  TINYINT        NOT NULL,
    total_rooms  INT            NOT NULL DEFAULT 0,
    opened_date  DATE           NOT NULL,
    PRIMARY KEY (hotel_id),
    CONSTRAINT chk_star_rating CHECK (star_rating BETWEEN 1 AND 5)
) ENGINE = InnoDB;

CREATE TABLE guests (
    guest_id             VARCHAR(20)  NOT NULL,
    guest_name           VARCHAR(100) NOT NULL,
    city                 VARCHAR(50),
    guest_type           ENUM('Individual','Corporate') NOT NULL,
    preferred_room_type  VARCHAR(20),
    loyalty_tier         ENUM('Silver','Gold','Platinum') DEFAULT NULL,
    account_since        DATE         NOT NULL,
    PRIMARY KEY (guest_id)
) ENGINE = InnoDB;

CREATE TABLE staff (
    staff_id     VARCHAR(20)   NOT NULL,
    staff_name   VARCHAR(100)  NOT NULL,
    hire_date    DATE          NOT NULL,
    rating       DECIMAL(3,2)  DEFAULT NULL,
    department   VARCHAR(30)   NOT NULL,
    is_active    ENUM('Yes','No') NOT NULL DEFAULT 'Yes',
    PRIMARY KEY (staff_id),
    CONSTRAINT chk_staff_rating CHECK (rating BETWEEN 0 AND 5)
) ENGINE = InnoDB;


CREATE TABLE rooms (
    room_id           VARCHAR(20)  NOT NULL,
    hotel_id          VARCHAR(20)  NOT NULL,
    room_type         ENUM('Standard','Deluxe','Executive','Suite') NOT NULL,
    floor_number      INT          NOT NULL,
    max_occupancy     INT          NOT NULL,
    price_per_night   DECIMAL(10,2) NOT NULL,
    is_active         ENUM('Yes','No') NOT NULL DEFAULT 'Yes',
    PRIMARY KEY (room_id),
    CONSTRAINT fk_rooms_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE = InnoDB;


 
CREATE TABLE bookings(
    booking_id            VARCHAR(20)  NOT NULL,
    guest_id              VARCHAR(20)  NOT NULL,
    hotel_id              VARCHAR(20)  NOT NULL,
    booking_date           DATE         NOT NULL,
    room_type_requested   ENUM('Standard','Deluxe','Executive','Suite') NOT NULL,
    booking_channel       ENUM('Website','Mobile App','Walk-in','Travel Agent','Phone') NOT NULL,
    nights_booked         INT          NOT NULL,
    total_amount          DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (booking_id),
    CONSTRAINT fk_bookings_guest FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    CONSTRAINT fk_bookings_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE = InnoDB;


CREATE TABLE stays (
    stay_id             VARCHAR(20)  NOT NULL,
    booking_id          VARCHAR(20)  NOT NULL,
    room_id             VARCHAR(20)  NOT NULL,
    staff_id            VARCHAR(20)  NOT NULL,
    check_in_date       DATE         NOT NULL,
    check_out_date      DATE,
    status              ENUM('Checked-out','In-progress','No-show','Cancelled') NOT NULL,
    nights_stayed        INT          NOT NULL DEFAULT 0,
    service_requests     INT          NOT NULL DEFAULT 0,
    stay_duration_hrs    INT,
    PRIMARY KEY (stay_id),
    CONSTRAINT fk_stays_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT fk_stays_room    FOREIGN KEY (room_id)    REFERENCES rooms(room_id),
    CONSTRAINT fk_stays_staff   FOREIGN KEY (staff_id)   REFERENCES staff(staff_id)
) ENGINE = InnoDB;

select * from book;
select * from gsts;
select * from hotels;
select * from rooms;
select * from staff;
select * from stay;


-- 2.2 Data import

-- Rows were imported in the same dependency order used to create the tables.
-- Two source files (guests.csv, bookings.csv) store their date columns as DD-MM-YYYY text 
-- rather than ISO format, unlike the other four files — this was caught during a pre-import
-- data-profiling check and handled with STR_TO_DATE() during load, otherwise 
-- MySQL would either reject the rows or silently mis-parse the dates.
-- Tables, Rows Loaded

-- Sprint 3: Basic Analysis / Data Exploration

-- 1. What is the total number of guests?
select count(*) from gsts;

-- 2. What is the total number of bookings?
select count(*) from book;

-- 3. What is the total number of stays?
select count(*) from stay;

-- 4. What are the different room types available?
select distinct room_type from rooms;

-- 5. How many staff members are currently active?
select count(*) from staff
where is_active = 'Yes';

-- 6. What are the different booking channels?
select distinct booking_channel from book;

-- 7. What is the total booking amount across all bookings?
select round(sum(total_amount),4) from book;

-- 8. What is the average nights booked per booking?
select round(avg(nights_booked),2) from book;

-- Sprint 4: Objective - Based Analysis

-- 4.1 Understand Booking Demand
-- Business Objective: The Operations team wants to understand 
-- where and how bookings are being generated.

-- Q1. Which hotels generate the most booking volume and revenue?
SELECT h.hotel_name, h.city, COUNT(*) AS num_bookings,
       ROUND(SUM(b.total_amount), 2) AS total_revenue
FROM book b
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_id, hotel_name, h.city
ORDER BY num_bookings DESC
LIMIT 8;

-- Q2. How do bookings and revenue compare across booking channels?
SELECT booking_channel, COUNT(*) AS num_bookings,
       ROUND(AVG(total_amount), 2) AS avg_amount,
       ROUND(SUM(total_amount), 2) AS total_amount
FROM book
GROUP BY booking_channel
ORDER BY num_bookings DESC;

-- Q3. How does demand differ by room type requested, and does room type drive booking value?
SELECT room_type_requested, count(*) as num_bookings,
       round(avg(total_amount),2) as avg_amount
FROM book
GROUP BY room_type_requested
ORDER BY num_bookings desc;

-- Q4. How has booking volume trended over time?

SELECT DATE_FORMAT(booking_date, '%Y') AS yr, COUNT(*) AS num_bookings,
       ROUND(SUM(total_amount), 2) AS revenue
FROM book
GROUP BY yr
ORDER BY yr;

-- 4.2 Understand Guest Booking Behaviour

-- Q1. How many guests are repeat bookers, and who are the top guests by activity?

SELECT g.guest_id,
       g.guest_name,
       g.guest_type,
       COUNT(*) AS num_book,
       ROUND(SUM(b.total_amount), 2) AS total_spent
FROM book AS b
JOIN gsts AS g
    ON b.guest_id = g.guest_id
GROUP BY g.guest_id, g.guest_name, g.guest_type
ORDER BY num_book DESC
LIMIT 5;

-- Q2. How do Individual and Corporate guests differ in booking behaviour?
SELECT g.guest_type, COUNT(DISTINCT g.guest_id) AS num_guests,
       COUNT(*) AS num_bookings,
       ROUND(1.0 * COUNT(*) / COUNT(DISTINCT g.guest_id), 2) AS avg_bookings_per_guest,
       ROUND(AVG(b.total_amount), 2) AS avg_booking_amount
FROM book b
JOIN gsts g ON b.guest_id = g.guest_id
GROUP BY g.guest_type;

-- Q3. Does loyalty tier correlate with booking activity or spend?
SELECT g.loyalty_tier, COUNT(DISTINCT g.guest_id) AS num_guests,
       COUNT(*) AS num_bookings, ROUND(AVG(b.total_amount), 2) AS avg_amount
FROM book b
JOIN gsts g ON b.guest_id = g.guest_id
GROUP BY g.loyalty_tier
ORDER BY num_bookings DESC;

-- Q4. Which cities generate the most guest activity?
SELECT h.city, COUNT(DISTINCT g.guest_id) AS num_guests, COUNT(*) AS num_bookings
FROM book b
JOIN gsts g ON b.guest_id = g.guest_id
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.city
ORDER BY num_bookings DESC
LIMIT 5;

-- 4.3 Evaluate Stay Performance

-- Q1. What is the overall distribution of stay outcomes?
SELECT status, COUNT(*) AS num_stays,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM stays), 2) AS pct
FROM stay
GROUP BY status
ORDER BY num_stays DESC;

-- Q2. How long do completed stays actually last?
SELECT ROUND(AVG(nights_stayed), 2) AS avg_nights_stayed,
       ROUND(AVG(stay_duration_hrs), 2) AS avg_duration_hrs
FROM stay
WHERE status = 'Checked-out';

-- Q3. Which hotels have the worst stay-completion rates?
SELECT h.hotel_name, h.city, COUNT(*) AS total_stays,
       ROUND(100.0 * SUM(CASE WHEN s.status IN ('No-show','Cancelled') THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS pct_problem
FROM stay s
JOIN book b ON s.booking_id = b.booking_id
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY pct_problem DESC
LIMIT 6;

-- Q4. Has the non-completion rate changed over time?
SELECT DATE_FORMAT(s.check_in_date, '%Y') AS yr,
       ROUND(100.0 * SUM(CASE WHEN status IN ('No-show','Cancelled') THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS pct_problem,
       COUNT(*) AS total_stays
FROM stay s
GROUP BY yr
ORDER BY yr;


-- 4.4 Understand Staff and Room Performance
-- Q1. Which departments handle the most stays, and how do their ratings compare?
SELECT department, COUNT(DISTINCT st.staff_id) AS num_staff,
       COUNT(s.stay_id) AS total_stays, ROUND(AVG(st.rating), 2) AS avg_rating
FROM staff st
LEFT JOIN stay s ON st.staff_id = s.staff_id
GROUP BY department
ORDER BY total_stays DESC;

-- Q2. Does staff rating relate to stay outcome (does a lower-rated staff member correlate with more no-shows/cancellations)?
SELECT s.status, ROUND(AVG(st.rating), 2) AS avg_staff_rating, COUNT(*) AS n
FROM stay s
JOIN staff st ON s.staff_id = st.staff_id
GROUP BY s.status
ORDER BY n DESC;

-- Q3. Do larger room types see longer stays or more service requests?
SELECT r.room_type, COUNT(*) AS num_stays,
       ROUND(AVG(s.nights_stayed), 2) AS avg_nights,
       ROUND(AVG(s.service_requests), 2) AS avg_service_requests
FROM stay s
JOIN rooms r ON s.room_id = r.room_id
WHERE s.status = 'Checked-out'
GROUP BY r.room_type
ORDER BY avg_nights DESC;

-- Q4. Is there a relationship between room capacity and in-stay service requests?
SELECT r.room_type, ROUND(AVG(r.max_occupancy), 1) AS avg_max_occupancy,
       ROUND(AVG(s.service_requests), 2) AS avg_service_requests
FROM stay s
JOIN rooms r ON s.room_id = r.room_id
GROUP BY r.room_type
ORDER BY avg_max_occupancy DESC;

-- 4.5 Identify Booking and Stay Problems

-- Q1. Which booking channels have the highest non-completion rate?
SELECT b.booking_channel,
       ROUND(100.0 * SUM(CASE WHEN s.status IN ('No-show','Cancelled') THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS pct_problem,
       COUNT(*) AS total_stays
FROM stay s
JOIN book b ON s.booking_id = b.booking_id
GROUP BY b.booking_channel
ORDER BY pct_problem DESC;

-- Q2. Is there a link between in-stay service request volume and stay outcome?
SELECT
  CASE WHEN service_requests >= 2 THEN 'Recorded (2+)' ELSE '0-1 / not applicable' END AS svc_band,
  status, COUNT(*) AS n
FROM stay
GROUP BY svc_band, status
ORDER BY svc_band, n DESC;

-- Q3. Does requested room type affect the likelihood of non-completion?
SELECT b.room_type_requested,
       ROUND(100.0 * SUM(CASE WHEN s.status IN ('No-show','Cancelled') THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS pct_problem,
       COUNT(*) AS n
FROM stay s
JOIN book b ON s.booking_id = b.booking_id
GROUP BY b.room_type_requested
ORDER BY pct_problem DESC;

-- Q4. Are the problem hotels identified in 4.3 concentrated in particular booking channels?
SELECT h.hotel_name,
       ROUND(100.0 * SUM(CASE WHEN s.status IN ('No-show','Cancelled') THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS pct_problem,
       b.booking_channel, COUNT(*) AS n
FROM stay s
JOIN book b ON s.booking_id = b.booking_id
JOIN hotels h ON b.hotel_id = h.hotel_id
WHERE h.hotel_name IN ('StayPoint Kochi Palace','StayPoint Indore Plaza','StayPoint Ahmedabad Plaza')
GROUP BY h.hotel_name, b.booking_channel
ORDER BY h.hotel_name, n DESC;




