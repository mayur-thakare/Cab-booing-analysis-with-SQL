CREATE DATABASE cb;
USE cb;

CREATE TABLE Customers (
 CustomerID INT PRIMARY KEY,
 Name VARCHAR(100),
 Email VARCHAR(100),
 RegistrationDate DATE
);

INSERT INTO Customers (CustomerID, Name, Email, RegistrationDate) VALUES
(1, 'Alice Johnson', 'alice@example.com', '2023-01-15'),
(2, 'Bob Smith', 'bob@example.com', '2023-02-20'),
(3, 'Charlie Brown', 'charlie@example.com', '2023-03-05'),
(4, 'Diana Prince', 'diana@example.com', '2023-04-10');

CREATE TABLE Drivers (
 DriverID INT PRIMARY KEY,
 Name VARCHAR(100),
 JoinDate DATE
);

INSERT INTO Drivers (DriverID, Name, JoinDate) VALUES
(101, 'John Driver', '2022-05-10'),
(102, 'Linda Miles', '2022-07-25'),
(103, 'Kevin Road', '2023-01-01'),
(104, 'Sandra Swift', '2022-11-11');

CREATE TABLE Cabs (
 CabID INT PRIMARY KEY,
 DriverID INT,
 VehicleType VARCHAR(20),
 PlateNumber VARCHAR(20),
 FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

INSERT INTO Cabs (CabID, DriverID, VehicleType, PlateNumber) VALUES
(1001, 101, 'Sedan', 'ABC1234'),
(1002, 102, 'SUV', 'XYZ5678'),
(1003, 103, 'Sedan', 'LMN8901'),
(1004, 104, 'SUV', 'PQR3456');

CREATE TABLE Bookings (
 BookingID INT PRIMARY KEY,
 CustomerID INT,
 CabID INT,
 BookingDate DATETIME,
 Status VARCHAR(20),
 PickupLocation VARCHAR(100),
 DropoffLocation VARCHAR(100),
 FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
 FOREIGN KEY (CabID) REFERENCES Cabs(CabID)
);

INSERT INTO Bookings (BookingID, CustomerID, CabID, BookingDate,
Status, PickupLocation, DropoffLocation) VALUES
(201, 1, 1001, '2024-10-01 08:30:00', 'Completed', 'Downtown',
'Airport'),
(202, 2, 1002, '2024-10-02 09:00:00', 'Completed', 'Mall',
'University'),
(203, 3, 1003, '2024-10-03 10:15:00', 'Canceled', 'Station',
'Downtown'),
(204, 4, 1004, '2024-10-04 14:00:00', 'Completed', 'Suburbs',
'Downtown'),
(205, 1, 1002, '2024-10-05 18:45:00', 'Completed', 'Downtown',
'Airport'),
(206, 2, 1001, '2024-10-06 07:20:00', 'Canceled', 'University',
'Mall');

CREATE TABLE TripDetails (
 TripID INT PRIMARY KEY,
 BookingID INT,
 StartTime DATETIME,
 EndTime DATETIME,
 DistanceKM FLOAT,
 Fare FLOAT,
 FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

INSERT INTO TripDetails (TripID, BookingID, StartTime, EndTime,
DistanceKM, Fare) VALUES
(301, 201, '2024-10-01 08:45:00', '2024-10-01 09:20:00', 18.5,
250.00),
(302, 202, '2024-10-02 09:10:00', '2024-10-02 09:40:00', 12.0,
180.00),
(303, 204, '2024-10-04 14:10:00', '2024-10-04 14:40:00', 10.0,
150.00),
(304, 205, '2024-10-05 18:50:00', '2024-10-05 19:30:00', 20.0,
270.00);

CREATE TABLE Feedback (
 FeedbackID INT PRIMARY KEY,
 BookingID INT,
 Rating FLOAT,
 Comments TEXT,
 FeedbackDate DATE,
 FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

INSERT INTO Feedback (FeedbackID, BookingID, Rating, Comments,
FeedbackDate) VALUES
(401, 201, 4.5, 'Smooth ride', '2024-10-01'),
(402, 202, 3.0, 'Driver was late', '2024-10-02'),
(403, 204, 5.0, 'Excellent service', '2024-10-04'),
(404, 205, 2.5, 'Cab was not clean', '2024-10-05');

select * from Customers;
select * from Drivers;
select * from Cabs;
select * from Bookings;
select * from TripDetails;
select * from Feedback;
use cb;

-- Problem Statement:
-- Customer and Booking Analysis
-- 1. Identify customers who have completed the most bookings. What insights can you draw about their behavior?

select c.CustomerID, c.name, count(b.BookingID) as total_bookings
from Customers c
join  Bookings b on c.CustomerID=b.CUstomerID
where b.status = 'Completed'
group by c.CustomerID, c.name
order by total_bookings desc;
-- insight:- 3 rows returned


-- 2. Find customers who have canceled more than 30% of their total bookings. What could be the reason for frequent cancellations?
select  Customers.CustomerID, Customers.name,
       count(Bookings.BookingID) as total_bookings,
       sum(case when  Bookings.status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
       (sum(case when Bookings.status = 'Cancelled' then 1 else 0 end) * 100.0 / count(Bookings.BookingID)) as cancel_percentage
from Customers
join Bookings on Customers.CustomerID = Bookings.CustomerID
group by Customers.CustomerID, Customers.name
having (sum(case when Bookings.status = 'Cancelled' then 1 else 0 end) * 1.0 / count(Bookings.BookingID)) > 0.3
order by cancel_percentage desc;
--  insight:- empty table

-- 3. Determine the busiest day of the week for bookings. How can the company optimize cab availability on peak days?
select dayname(Bookings.BookingDate) as day_of_week,
       count(Bookings.BookingID) as total_bookings
from Bookings
group by dayname(Bookings.BookingDate)
order by total_bookings desc;
-- insight:- 6 rows returned



-- Driver Performance & Efficiency
-- 1. Identify drivers who have received an average rating below 3.0 in the past three months. What strategies can be implemented to improve their performance?
select FeedbackID, avg(rating) as average_rating
from Feedback
where FeedbackDate >= date_sub(curdate(), interval 3 month)
group by FeedbackID
having avg(rating) < 3.0;
-- insight:-

-- 2. Find the top 5 drivers who have completed the longest trips in terms of distance. What does this say about their working patterns?
select DriverID, max(DistanceKM) as total_distance
from TripDetails,Drivers
group by DriverID
order by total_distance desc
limit 5;
-- insight:- 4 rows returned


-- 3.Identify drivers with a high percentage of canceled trips. Could this indicate driver unreliability?
select DriverID,
       count(case when Status = 'canceled' then 1 end) as canceled_trips,
       count(*) as total_trips,
       (count(case when Status = 'canceled' then 1 end) * 100.0 / count(*)) as cancellation_rate
from Bookings,Drivers
group by DriverID
having (count(case when Status = 'canceled' then 1 end) * 100.0 / count(*)) > 30
order by cancellation_rate desc;
-- insight:- 4 rows returned

-- Revenue & Business Metrics
-- 1. Calculate the total revenue generated by completed bookings in the last 6 months. How has the revenue trend changed over time?
select date_format(BookingDate, '%Y-%m') as month,
       sum(Fare) as total_revenue
from Bookings
where status = 'completed'
  and BookingDate >= date_sub(curdate(), interval 6 month)
group by date_format(booking_date, '%Y-%m')
order by month;


-- 2. Identify the top 3 most frequently traveled routes based on PickupLocation and DropoffLocation. Should the company allocate more cabs to these routes?
select PickupLocation, DropoffLocation, count(*) as trip_count from Bookings
group by PickupLocation,DropoffLocation
order by trip_count
 desc limit 3;
 -- insight:- 3 rows returned
 
 
-- 3. Determine if higher-rated drivers tend to complete more trips and earn higher fares.Is there a direct correlation between driver ratings and earnings?
select 
    drivers.driverid,
    avg(feedback.rating) as average_rating,
    count(bookings.bookingid) as total_trips,
    sum(tripdetails.fare) as total_earnings
from drivers
join cabs on drivers.driverid = cabs.driverid
join bookings on cabs.cabid = bookings.cabid
join tripdetails on bookings.bookingid = tripdetails.bookingid
join feedback on bookings.bookingid = feedback.bookingid
where bookings.status = 'Completed'
group by drivers.driverid;
-- insight= 3 rows returned


-- Operational Efficiency & Optimization
-- 1. Analyze the average waiting time (difference between booking time and trip start time) for different pickup locations. How can this be optimized to reduce delays?
select 
    bookings.pickuplocation,
    avg(timestampdiff(minute, bookings.bookingdate, tripdetails.starttime)) as avg_waiting_time_minutes
from bookings
join tripdetails on bookings.bookingid = tripdetails.bookingid
where bookings.status = 'Completed'
group by bookings.pickuplocation;
-- insight= 3 rows returned

-- 2. Identify the most common reasons for trip cancellations from customer feedback. What actions can be taken to reduce cancellations?
select 
    feedback.comments
from bookings
join feedback on bookings.bookingid = feedback.bookingid
where bookings.status = 'Canceled';
-- insight= 0 rows returned


-- 3. Find out whether shorter trips (low-distance) contribute significantly to revenue. Should the company encourage more short-distance rides?
select 
    case 
        when tripdetails.distancekm < 10 then 'Short (<10 km)'
        when tripdetails.distancekm between 10 and 20 then 'Medium (10-20 km)'
        else 'Long (>20 km)'
    end as trip_category,
    count(*) as total_trips,
    sum(tripdetails.fare) as total_revenue,
    avg(tripdetails.fare) as avg_fare
from tripdetails
join bookings on tripdetails.bookingid = bookings.bookingid
where bookings.status = 'Completed'
group by trip_category;
-- insight= 1 row returned

-- Comparative & Predictive Analysis
-- 1. Compare the revenue generated from 'Sedan' and 'SUV' cabs. Should the company invest more in a particular vehicle type?
select 
    cabs.vehicletype,
    count(*) as total_trips,
    sum(tripdetails.fare) as total_revenue,
    avg(tripdetails.fare) as avg_revenue_per_trip
from cabs
join bookings on cabs.cabid = bookings.cabid
join tripdetails on bookings.bookingid = tripdetails.bookingid
where bookings.status = 'Completed'
group by cabs.vehicletype;
-- insight= 2 rows returned

-- 2. Predict which customers are likely to stop using the service based on their last booking date and frequency of rides. How can customer retention be improved?
select 
    customers.customerid,
    customers.name,
    max(bookings.bookingdate) as last_booking_date,
    count(bookings.bookingid) as total_rides
from customers
left join bookings on customers.customerid = bookings.customerid
group by customers.customerid, customers.name;

-- insight= 4 rows returned
-- 3. Analyze whether weekend bookings differ significantly from weekday bookings. Should the company introduce dynamic pricing based on demand?
select 
    case 
        when dayofweek(bookings.bookingdate) in (1,7) then 'Weekend'   -- 1=Sunday, 7=Saturday in MySQL
        else 'Weekday'
    end as day_type,
    count(*) as total_bookings,
    sum(tripdetails.fare) as total_revenue,
    avg(tripdetails.fare) as avg_fare
from bookings
join tripdetails on bookings.bookingid = tripdetails.bookingid
where bookings.status = 'Completed'
group by day_type;
-- insight= 2 rows returned

















