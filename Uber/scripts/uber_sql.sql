CREATE DATABASE uber;
\c uber
create table uber_data (Date DATE NOT NULL, Time TIME NOT NULL, Booking_ID Varchar(50), Booking_Status Varchar(50), Customer_ID VARCHAR(50),Vehicle_Type VARCHAR (50),Pickup_Location VARCHAR(50), Drop_Location Varchar(50), Avg_VTAT NUMERIC(4,2),Avg_CTAT NUMERIC (4,2),Cancelled_Rides_by_Customer BOOLEAN,Reason_for_cancelling_by_Customer VARCHAR (100),Cancelled_Rides_by_Driver BOOLEAN,Driver_Cancellation_Reason VARCHAR(100),Incomplete_Rides BOOLEAN,Incomplete_Rides_Reason VARCHAR(100),Booking_Value smallint,Ride_Distance NUMERIC(8,2),Driver_Ratings NUMERIC(3,2),Customer_Rating NUMERIC(3,2),Payment_Method VARCHAR(30),TripID SERIAL,weekday Varchar(50),month Varchar(50),PRIMARY KEY(TripID));
\COPY uber_data From ‘C:\Users\garci\Desktop\Data analytics\Analisis\Uber\postgresql.csv’ CSV HEADER;

--Top 10 localizaciones de recogida con más viajes
SELECT
pickup_location,
drop_location,
count(TripID) as number_of_trips
FROM uber_data
GROUP BY pickup_location,drop_location
ORDER BY number_of_trips DESC
LIMIT 10;

--Top 10 usuarios con más viajes y su vehículo más usado
WITH top_users AS (
SELECT
customer_id,
count(TripID) as trips
FROM uber_data
GROUP BY customer_id
ORDER BY trips DESC
LIMIT 10
),
user_vehicle_count AS(
SELECT
u.customer_id,
d.vehicle_type,
COUNT(d.TripID) as trips,
 ROW_NUMBER() OVER (PARTITION BY u.customer_id ORDER BY COUNT(d.tripID) DESC) AS rn
FROM uber_data d
JOIN top_users u on d.customer_id = u.customer_id
GROUP BY u.customer_id, d.vehicle_type
)
SELECT
    customer_id,
    vehicle_type AS most_used_vehicle,
    trips
FROM user_vehicle_count
WHERE rn = 1
ORDER BY trips DESC;

--Día de la semana con más recaudación media
SELECT
weekday,
AVG(booking_value) as avg_earnings
FROM uber_data
GROUP BY weekday
ORDER BY avg_earnings DESC