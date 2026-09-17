# Hotel Room Booking Analysis using MySQL

## Project Overview

This project is based on hotel room booking data and was developed using **MySQL and MySQL Workbench**.

The project involves designing a relational database, importing CSV datasets, and performing SQL analysis to understand booking demand, guest behavior, stay performance, staff performance, room types, and booking-related problems.

---

## Database

Database name:

```sql
hotel_analysis
```

The database contains the following tables:

* `hotels`
* `guests`
* `staff`
* `rooms`
* `bookings`
* `stays`

The tables are connected using primary keys and foreign keys.

---

## Database Structure

### Hotels

Stores information about hotels.

| Column        | Description           |
| ------------- | --------------------- |
| `hotel_id`    | Unique hotel ID       |
| `hotel_name`  | Name of the hotel     |
| `city`        | Hotel city            |
| `star_rating` | Hotel star rating     |
| `total_rooms` | Total number of rooms |
| `opened_date` | Hotel opening date    |

### Guests

Stores guest information.

| Column                | Description               |
| --------------------- | ------------------------- |
| `guest_id`            | Unique guest ID           |
| `guest_name`          | Guest name                |
| `city`                | Guest city                |
| `guest_type`          | Individual or Corporate   |
| `preferred_room_type` | Preferred room type       |
| `loyalty_tier`        | Silver, Gold, or Platinum |
| `account_since`       | Guest account date        |

### Staff

Stores hotel staff information.

| Column       | Description               |
| ------------ | ------------------------- |
| `staff_id`   | Unique staff ID           |
| `staff_name` | Staff name                |
| `hire_date`  | Staff hiring date         |
| `rating`     | Staff rating              |
| `department` | Staff department          |
| `is_active`  | Active or inactive status |

### Rooms

Stores room information.

| Column            | Description                           |
| ----------------- | ------------------------------------- |
| `room_id`         | Unique room ID                        |
| `hotel_id`        | Hotel ID                              |
| `room_type`       | Standard, Deluxe, Executive, or Suite |
| `floor_number`    | Floor number                          |
| `max_occupancy`   | Maximum occupancy                     |
| `price_per_night` | Price per night                       |
| `is_active`       | Active or inactive status             |

### Bookings

Stores booking information.

| Column                | Description             |
| --------------------- | ----------------------- |
| `booking_id`          | Unique booking ID       |
| `guest_id`            | Guest ID                |
| `hotel_id`            | Hotel ID                |
| `booking_date`        | Date of booking         |
| `room_type_requested` | Requested room type     |
| `booking_channel`     | Booking source          |
| `nights_booked`       | Number of nights booked |
| `total_amount`        | Total booking amount    |

### Stays

Stores information about hotel stays.

| Column            | Description                |
| ----------------- | -------------------------- |
| stay_id           | Unique stay ID             |
| booking_id        | Booking ID                 |
| room_id           | Room ID                    |
| staff_id          | Staff ID                   |
| check_in_date     | Check-in date              |
| check_out_date    | Check-out date             |
| status            | Stay status                |
| nights_stayed     | Number of nights stayed    |
| service_requests  | Number of service requests |
| stay_duration_hrs | Stay duration in hours     |

---

## Table Relationships


hotels
   │
   ├── rooms
   │
   └── bookings
          │
          ├── guests
          │
          └── stays
                 │
                 ├── rooms
                 │
                 └── staff


Foreign key relationships:


rooms.hotel_id → hotels.hotel_id

bookings.guest_id → guests.guest_id

bookings.hotel_id → hotels.hotel_id

stays.booking_id → bookings.booking_id

stays.room_id → rooms.room_id

stays.staff_id → staff.staff_id


---

## Repository Structure


Hotel-Room-Booking-Analysis/
│
├── README.md
│
├── HOTEL_ROOM_BOOKING.sql
│
├── dataset/
│   ├── hotels.csv
│   ├── guests.csv
│   ├── staff.csv
│   ├── rooms.csv
│   ├── bookings.csv
│   └── stays.csv
│
└── screenshots/
    └── MySQL Workbench screenshots


---

## How to Set Up the Project

### 1. Create the Database

Open MySQL Workbench and run:


CREATE DATABASE hotel_analysis;
USE hotel_analysis;


### 2. Create the Tables

Open HOTEL_ROOM_BOOKING.sql and run the table creation queries.

Create the tables in the following order:


hotels
guests
staff
rooms
bookings
stays


This order is used because of the foreign key dependencies between the tables.

---

## Importing the Dataset

The CSV files are available in the dataset folder.

Use the **Table Data Import Wizard** in MySQL Workbench.

For each table:

1. Select the hotel_analysis database.
2. Right-click the table.
3. Select **Table Data Import Wizard**.
4. Select the corresponding CSV file.
5. Check the column mapping.
6. Import the data.

Use the following mapping:


hotels.csv    → hotels
guests.csv    → guests
staff.csv     → staff
rooms.csv     → rooms
bookings.csv  → bookings
stays.csv     → stays


### Date Format

During the data import, the date columns in guests.csv and bookings.csv are stored in `DD-MM-YYYY` format.

These dates need to be converted using STR_TO_DATE() before inserting them into the tables.

Example:


STR_TO_DATE(date_column, '%d-%m-%Y')


This was handled during the data-loading process.

---

## Checking the Imported Data

After importing the datasets, the data can be checked using:


SELECT * FROM hotels;
SELECT * FROM guests;
SELECT * FROM staff;
SELECT * FROM rooms;
SELECT * FROM bookings;
SELECT * FROM stays;


Record counts can also be checked using:

SELECT COUNT(*) FROM hotels;
SELECT COUNT(*) FROM guests;
SELECT COUNT(*) FROM staff;
SELECT COUNT(*) FROM rooms;
SELECT COUNT(*) FROM bookings;
SELECT COUNT(*) FROM stays;


---

## Analysis Performed

### Basic Data Exploration

The initial analysis includes:

* Total number of guests
* Total number of bookings
* Total number of stays
* Available room types
* Number of active staff
* Available booking channels
* Total booking amount
* Average nights booked per booking

### Booking Demand

The project analyzes:

* Booking volume by hotel
* Revenue by hotel
* Booking channels
* Average booking amount by channel
* Room type demand
* Average booking amount by room type
* Booking and revenue trends over time

### Guest Booking Behaviour

The analysis includes:

* Repeat booking activity
* Top guests by booking activity
* Total guest spending
* Individual vs Corporate guests
* Average bookings per guest
* Loyalty tier activity
* Average booking amount by loyalty tier
* Guest activity by city

### Stay Performance

The project analyzes:

* Stay status distribution
* Checked-out stays
* In-progress stays
* No-shows
* Cancelled stays
* Average nights stayed
* Average stay duration
* Hotel non-completion rates
* Non-completion trends over time

### Staff and Room Performance

The analysis includes:

* Stays handled by department
* Number of staff in each department
* Average staff rating
* Staff rating by stay outcome
* Average nights stayed by room type
* Service requests by room type
* Room occupancy and service requests

### Booking and Stay Problems

The project also looks at:

* Non-completion rate by booking channel
* Service requests and stay outcomes
* Non-completion rate by requested room type
* Booking channel patterns for selected hotels

---

## SQL Concepts Used

The project uses the following SQL concepts:

* Database creation
* Table creation
* Primary Keys
* Foreign Keys
* Constraints
* SELECT
* WHERE
* DISTINCT
* COUNT()
* SUM()
* AVG()
* ROUND()
* GROUP BY
* ORDER BY
* LIMIT
* JOIN
* LEFT JOIN
* CASE
* Subqueries
* DATE_FORMAT()
* STR_TO_DATE()

---

## Project File

The main SQL file is:

HOTEL_ROOM_BOOKING.sql


It contains the database setup, table definitions, exploratory queries, and objective-based analysis queries.

---

## How to Run

The recommended order is:


1. Create the database
        ↓
2. Create the tables
        ↓
3. Import the CSV datasets
        ↓
4. Verify the imported data
        ↓
5. Run the basic analysis queries
        ↓
6. Run the objective-based analysis queries
