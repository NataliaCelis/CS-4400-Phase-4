-- CS4400: Introduction to Database Systems: Monday, March 3, 2025
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like the model and the engine.  
Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (
    in ip_airlineID varchar(50), in ip_tail_num varchar(50), in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_maintenanced boolean, in ip_model varchar(50), in ip_neo boolean
)
sp_main: begin

    -- Check that airline exists
    if (select count(*) from airline where airlineID = ip_airlineID) = 0 then 
        leave sp_main; 
    end if;

    -- Check valid plane type
    if not (ip_plane_type = 'Boeing' or ip_plane_type = 'Airbus' or ip_plane_type is null) then
        leave sp_main;
    end if;

    -- Check that (airlineID, tail_num) is unique
    if (select count(*) from airplane where airlineID = ip_airlineID and tail_num = ip_tail_num) > 0 then 
        leave sp_main; 
    end if;

    -- Ensure seat_capacity and speed > 0
    if not (ip_seat_capacity > 0 and ip_speed > 0) then
        leave sp_main;
    end if;

    -- Validate locationID is new
    if (select count(*) from location where locationID = ip_locationID) > 0 then 
        leave sp_main; 
    end if;

    -- Validate type-specific attributes
    if (ip_plane_type = 'Boeing' and (ip_maintenanced is null or ip_model is null or ip_neo is not null)) 
	or (ip_plane_type = 'Airbus' and (ip_maintenanced is not null or ip_model is not null or ip_neo is null))
	or (ip_plane_type is null and (ip_maintenanced is not null or ip_model is not null or ip_neo is not null)) then
	leave sp_main;
end if;

    -- Insert new location
    insert into location values (ip_locationID);

    -- Insert new airplane
    insert into airplane values (
        ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID,
        ip_plane_type, ip_maintenanced, ip_model, ip_neo
    );

end //
delimiter ;


-- [2] add_airport() {Andy Garcha}
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin

	-- Ensure that the airport and location values are new and unique
    -- Add airport and location into respective tables
    IF ip_airportID IN (SELECT AirportID FROM Airport) THEN LEAVE sp_main;
    ELSEIF ip_locationID IN (SELECT LocationID FROM Location) THEN LEAVE sp_main;
    END IF;
    
    INSERT into Location VALUES 
    (ip_locationID);
    
    INSERT into Airport VALUES
    (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);

end //
delimiter ;

-- [3] add_person() rachna
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------

drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
	DECLARE role_count INT; 
    
	-- Ensure that the location is valid
    IF (select count(*) from location where LocationID = ip_locationID) = 0 THEN LEAVE sp_main;
    END IF; 
    
    -- Ensure that the person ID is unique
    IF (select count(*) from person where PersonID = ip_personID) > 0 THEN LEAVE sp_main; 
    END IF; 
    
    -- Ensure required fields are not null
    IF ip_personID IS NULL OR ip_first_name IS NULL OR ip_locationID IS NULL THEN 
        LEAVE sp_main; 
    END IF;
    
	IF ip_miles < 0 OR ip_funds < 0 THEN LEAVE sp_main;
	END IF;
    
	IF EXISTS (SELECT 1 FROM pilot WHERE taxID = ip_taxID) THEN LEAVE sp_main;
	END IF;
    
    -- Ensure inputs are consistent with one role only (no partial fields)
    IF (ip_taxID IS NULL) != (ip_experience IS NULL) THEN LEAVE sp_main;
    END IF;
    IF (ip_miles IS NULL) != (ip_funds IS NULL) THEN LEAVE sp_main;
    END IF;

    -- Ensure that the person is a pilot or passenger (but not both, not neither)
    SET role_count = 0; 
    IF ip_taxID IS NOT NULL AND ip_experience IS NOT NULL THEN 
		SET role_count = role_count + 1; 
	END IF; 
    
    IF ip_miles IS NOT NULL AND ip_funds IS NOT NULL THEN 
		SET role_count = role_count + 1; 
	END IF; 
    
    IF role_count != 1 THEN LEAVE sp_main; 
    END IF;
    
    -- Add to the Person table
	INSERT INTO Person (PersonID, First_name, Last_name, LocationID)
    VALUES (ip_personID, ip_first_name, ip_last_name, ip_locationID); 
    
    -- If pilot, insert into Pilot
    IF ip_taxID IS NOT NULL AND ip_experience IS NOT NULL THEN
		INSERT INTO Pilot (PersonID, TaxID, Experience, commanding_flight) 
        VALUES (ip_personID, ip_taxID, ip_experience, NULL); 
    END IF;
    
    -- If passenger, insert into Passenger
    IF ip_miles IS NOT NULL AND ip_funds IS NOT NULL THEN 
		INSERT INTO Passenger (PersonID, Miles, Funds) 
        VALUES (ip_personID, ip_miles, ip_funds); 
    END IF;
        
end //
delimiter ;



-- [4] grant_or_revoke_pilot_license() {Andy Garcha}
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it aready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	-- Ensure that the person is a valid pilot
    -- If license exists, delete it, otherwise add the license
    IF (SELECT COUNT(*) FROM pilot WHERE personID = ip_personID) = 0 THEN
        LEAVE sp_main;
    END IF;

    -- if there is a person with that license...
    IF (SELECT COUNT(*) FROM pilot_licenses WHERE personID = ip_personID AND license = ip_license) > 0 THEN
        -- Remove the license if it exists
        DELETE FROM pilot_licenses WHERE personID = ip_personID AND license = ip_license;
    ELSE
        -- otherwise, we need to insert
        INSERT INTO pilot_licenses (personID, license) VALUES (ip_personID, ip_license);
    END IF;

end //
delimiter ;


-- [5] offer_flight() rachna
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight; #didnt insert stuff if airplane didnt exist (only one line for it and thats checking if NOT null) 
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
    DECLARE airplane_exists INT; 
    DECLARE max_progress INT; 
    
    -- Ensure that the airplane exists
    IF ip_support_tail IS NOT NULL AND ip_support_airline IS NOT NULL 
    THEN select count(*) into airplane_exists from Airplane where AirlineID = ip_support_airline and Tail_Num = ip_support_tail;
		IF airplane_exists = 0 THEN LEAVE sp_main; 
		END IF; 
    
		-- checking if airplane (if exists) is not assigned to another flight
		IF (select count(*) from flight where support_tail = ip_support_tail 
        and support_airline = ip_support_airline) > 0 THEN LEAVE sp_main; 
		END IF; 
	END IF; 
    
    -- Ensure that the route exists
    IF (select count(*) from route where routeID = ip_routeID) = 0 THEN LEAVE sp_main;
    END IF; 
    
	-- Ensure that the progress is less than the length of the route
    SELECT max(Sequence) into max_progress from Route_path where RouteID = ip_routeID;
    IF ip_progress >= max_progress THEN LEAVE sp_main; 
    END IF; 
    
    -- Create the flight with the airplane starting in on the ground & -- Insert the new flight 
    INSERT INTO flight (flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time, cost) 
	VALUES (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 'on_ground', ip_next_time, ip_cost);

--     INSERT INTO Flight (FlightID, RouteID, Cost) VALUES (ip_flightID, ip_routeID, ip_cost); 
--     -- IF ip_support_tail is not null and ip_support_airline is not null THEN 
--     -- If an airplane is assigned, add this into Supports
--     IF ip_support_tail is not null and ip_support_airline is not null THEN 
--     INSERT INTO Supports (FlightID, Tail_Num, AirlineID, Progress, Airplane_status, Next_time) 
--     
--     -- END IF;
    
end //
delimiter ;


-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

# old code, refer back
-- 	DECLARE current_progress INT;
-- 	DECLARE current_distance INT;

-- 	-- Ensure that the flight exists
--     IF ip_flightID NOT IN (SELECT flightID FROM flight) THEN LEAVE sp_main;
--     END IF;

-- -- Ensure that the flight is in the air (something is potentially wrong here)
--     IF 'on_ground' IN (SELECT airplane_status FROM flight where flightID = ip_flightID)
--     THEN LEAVE sp_main;
--     END IF;
-- 	
--     -- Increment the pilot's experience by 1
--     UPDATE pilot SET experience = experience + 1 WHERE commanding_flight = ip_flightID;
--     
--     -- Increment the frequent flyer miles of all passengers on the plane
--     SELECT progress into current_progress from flight where flightID = ip_flightID;
--     
--     #something is wrong here
-- --     SELECT distance into current_distance from leg join route_path on leg.legID = route_path.legID 
-- --     join flight on route_path.routeID = flight.routeID 
-- --     where flight.flightID = ip_flightID and flight.progress = current_progress;
--     
--     ## do the update here
--     #UPDATE passenger SET miles = miles + current_distance WHERE 
--     
--     
--     
--     
--     -- Update the status of the flight and increment the next time to 1 hour later (something is potentially wrong here)
-- 	   -- Hint: use addtime()
-- 	UPDATE flight SET airplane_status = 'on_ground' WHERE flightID = ip_flightID;
-- --     
-- --     #something is wrong with the next line help
--     UPDATE flight SET next_time = 
-- 		addtime(next_time, '1:00:00')
--         WHERE flightID = ip_flightID;

	DECLARE current_progress INT;
	DECLARE distance_of_flight INT;
    
    -- need for later
    DECLARE support_airline_l VARCHAR(50);
    DECLARE support_tail_l VARCHAR(50);
    DECLARE locationID_l VARCHAR(50);

	-- Ensure that the flight exists
    IF ip_flightID NOT IN (SELECT flightID FROM flight) THEN LEAVE sp_main;
    END IF;

-- Ensure that the flight is in the air (something is potentially wrong here)
    IF 'on_ground' IN (SELECT airplane_status FROM flight where flightID = ip_flightID)
    THEN LEAVE sp_main;
    END IF;
	
    -- Increment the pilot's experience by 1
    UPDATE pilot SET experience = experience + 1 WHERE commanding_flight = ip_flightID;
    
    -- Increment the frequent flyer miles of all passengers on the plane
    SELECT progress into current_progress from flight where flightID = ip_flightID;
    
-- code from andy's query tab that works?
-- SELECT l.distance, l.legID
-- 	FROM leg l
-- 	WHERE l.legID = (
-- 		SELECT legID
-- 		FROM route_path rp
-- 		WHERE rp.routeID = (SELECT routeID FROM flight f WHERE f.flightID = 'km_16')
-- 			AND rp.sequence = (SELECT progress FROM flight f WHERE flightID = 'km_16')
-- 	);
    
    #something is wrong here
--     SELECT distance into current_distance from leg join route_path on leg.legID = route_path.legID 
--     join flight on route_path.routeID = flight.routeID 
--     where flight.flightID = ip_flightID and flight.progress = current_progress;
	SELECT l.distance INTO distance_of_flight
	FROM leg l
	WHERE l.legID = (
		SELECT rp.legID
        FROM route_path rp
 		WHERE rp.routeID = (SELECT routeID FROM flight f WHERE f.flightID = ip_flightID)
 			AND rp.sequence = current_progress
    );
	
    
    ## do the update here
    #UPDATE passenger SET miles = miles + current_distance WHERE 
    
    SELECT f.support_airline INTO support_airline_l
    FROM flight f
    WHERE (f.flightID = ip_flightID);
    
    SELECT f.support_tail INTO support_tail_l
    FROM flight f
    WHERE (f.flightID = ip_flightID);
    
    SELECT a.locationID INTO locationID_l
    FROM airplane a
    WHERE (a.airlineID = support_airline_l) AND (a.tail_num = support_tail_l);
    
    UPDATE passenger
    SET miles = miles + distance_of_flight
    WHERE locationID_l = (SELECT p.locationID FROM person p WHERE (p.personID = passenger.personID));
    
    
    
    
    -- Update the status of the flight and increment the next time to 1 hour later (something is potentially wrong here)
	   -- Hint: use addtime()
	UPDATE flight SET airplane_status = 'on_ground' WHERE flightID = ip_flightID;
--     

    UPDATE flight SET next_time = 
		addtime(next_time, '1:00:00')
        WHERE flightID = ip_flightID;

end //
delimiter ;

-- [7] flight_takeoff() rachna
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that Airbus and general planes have at least one pilot
assigned, while Boeing must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
	declare current_progress INT; 
    declare required_pilots INT; 
    #declare flight_time DECIMAL(10,2); 
    declare airplane_type VARCHAR(50); 
    declare airplane_speed INT; 
	declare n_next_time TIME; 
    declare leg_distance INT; 
    
    -- Ensure that the flight exists
    select next_time into n_next_time from flight where flightID = ip_flightID; 
    
    IF (select count(*) from flight where flightID = ip_flightID) = 0 THEN LEAVE sp_main; 
    END IF; 
    
    -- Ensure that the flight is on the ground
    IF (select count(*) from flight where flightID = ip_flightID and Airplane_status = 'on_ground') = 0 THEN LEAVE sp_main; 
    END IF; 

    -- Ensure that the flight has another leg to fly
    SELECT progress into current_progress from flight where flightID = ip_flightID;
    
    -- checking for another leg in the flight
    IF (select count(*) from route_path
    where routeID = (select routeID from flight where flightID = ip_flightID) 
    and sequence = current_progress + 1) = 0 THEN LEAVE sp_main;
    END IF; 
    
    -- next leg distance
    select distance into leg_distance from leg where legID = (select legID from route_path where 
    routeID = (select routeID from flight where flightID = ip_flightID) and sequence = current_progress + 1); 
    
    
    
    -- plane details
    select plane_type, speed into airplane_type, airplane_speed from airplane where tail_num = 
    (select support_tail from flight where flightID = ip_flightID); 
    -- Ensure that there are enough pilots (1 for Airbus and general, 2 for Boeing)
		-- If there are not enough, move next time to 30 minutes later
	IF airplane_type = 'Boeing' THEN set required_pilots = 2;
    END IF; 
    IF airplane_type = 'Airbus' THEN set required_pilots = 1; 
    END IF; 
    
    IF (select COUNT(*) from pilot p 
    join pilot_licenses l ON p.personID = l.personID
    where p.commanding_flight = ip_flightID 
    and l.license = airplane_type) < required_pilots 
    THEN
    -- delay flight by 30 min
    UPDATE flight set next_time = ADDTIME(n_next_time, '00:30:00') where flightID = ip_flightID;
    LEAVE sp_main;
	END IF;

    
     -- Calculate the flight time using the speed of airplane and distance of leg
     #set flight_time = distance / airplane_speed; 
     set n_next_time = ADDTIME(n_next_time, sec_to_time(leg_distance * 3600 / airplane_speed)); 

	-- Increment the progress and set the status to in flight
    -- Update the next time using the flight time
    UPDATE flight set progress = current_progress + 1, airplane_status = 'in_flight', next_time = n_next_time where flightID = ip_flightID;
    

end //
delimiter ;


-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin


DECLARE l_routeID varchar(50);		-- the route the plane is following. this should not change.
DECLARE l_progress int;				-- the progress of the flight. this also should not change. if we've just landed from the first leg in the route,
										-- the progress should still be 1.
DECLARE l_plane_locationID varchar(50);-- the current location of the airplane.
DECLARE l_cost int;					-- the cost of the flight. this also will not change.
declare l_seat_capacity int;		-- the seat capacity of the plane
DECLARE l_departure_airport CHAR(3);-- the airport we're leaving from (aka where we SHOULD be rn)
DECLARE l_arrival_airport CHAR(3);	-- the airport we're headed to
DECLARE l_tail VARCHAR(50);			-- the tail of the airplane
DECLARE l_airlineID VARCHAR(50);	-- the airline the airplane belongs to'
DECLARE l_num_eligible INT;			-- the number of eligible passengers for this flight
DECLARE l_airport_location VARCHAR(50);	-- man i hate the way locations work in this terrible system
DECLARE l_num_legs INT;				-- the number of legs

-- make sure the flight exists
IF NOT exists (select 1 from flight where flightID = ip_flightID) then leave sp_main;

-- make sure the plane is on the ground
ELSEIF (SELECT airplane_status FROM flight WHERE flightID = ip_flightID) != 'on_ground' then leave sp_main;
END IF;

-- get the vars we'll need from flight
SELECT routeID, progress, cost, support_airline, support_tail into l_routeID, l_progress, l_cost, l_airlineID, l_tail
FROM flight 
WHERE flightID = ip_flightID;

-- get the vars we'll need from airplane
SELECT locationID, seat_capacity into l_plane_locationID, l_seat_capacity
FROM airplane
WHERE airlineID = l_airlineID AND tail_num = l_tail;



-- get the vars we'll need from rp and leg
-- ok @destination is where the plane is going NEXT. let's say the plane just completed
-- its first leg, from ATL to LAX, and after this it's headed to SLC.
-- so the plane is in LAX. the flight's progress would still be 1, but
-- we need to find out where it's headed for part 2.
-- this means we need to find the arrival airport for leg 2.
SELECT l.arrival, l.departure INTO l_arrival_airport, l_departure_airport
FROM route_path rp
	JOIN leg l ON rp.legID = l.legID
WHERE rp.routeID = l_routeID AND rp.sequence = l_progress + 1; -- i hate this plus 1 i know why it's here i just hate it

-- get what we need from airport
SELECT a.locationID into l_airport_location
FROM airport a
WHERE l_departure_airport = a.airportID;

-- check on the leg numbers
SELECT MAX(sequence) INTO l_num_legs
FROM route_path
WHERE routeID = l_routeID;

-- too many legs....
IF l_progress >= l_num_legs THEN leave sp_main;
END IF;

-- get the number of passengers who want to board this flight
SELECT COUNT(*) into l_num_eligible
FROM passenger p
	JOIN person pe ON p.personID = pe.personID
    JOIN (
		SELECT pv.personID, min(pv.sequence) as min_sequence 
        FROM passenger_vacations pv
        GROUP BY pv.personID
	) as pv2 on p.personID = pv2.personID
    JOIN passenger_vacations pv3 ON p.personID = pv3.personID AND pv3.sequence = pv2.min_sequence
WHERE pe.locationID = l_airport_location
    AND pe.locationID NOT LIKE 'plane_%'
    AND pv3.airportID = l_arrival_airport
    AND p.funds >= l_cost;

-- if there's not enough seats, leave
IF l_num_eligible > l_seat_capacity then leave sp_main;
END IF;

-- update the person's location
UPDATE person pe
	JOIN passenger p ON p.personID = pe.personID
    JOIN (
		SELECT pv.personID, min(pv.sequence) as min_sequence 
        FROM passenger_vacations pv
        GROUP BY pv.personID
	) as pv2 on p.personID = pv2.personID
    JOIN passenger_vacations pv3 ON p.personID = pv3.personID AND pv3.sequence = pv2.min_sequence
SET pe.locationID = l_plane_locationID,
	p.funds = p.funds - l_cost
WHERE pe.locationID = l_airport_location
    AND pe.locationID NOT LIKE 'plane_%'
    AND pv3.airportID = l_arrival_airport
    AND p.funds >= l_cost;
    


--     declare current_leg int;
--     declare num_legs int;
--     declare current_status varchar(100);
--     declare routeID varchar(50);
--     declare departing_airport char(3);
--     declare arriving_airport char(3);
--     declare current_port varchar(50);
--     declare plane_location varchar(50);
--     declare seat_capacity int;
--     declare num_boarding int;

--    -- if the flight doesn't exist then leave
--     if (select count(*) from flight where flightID = ip_flightID) = 0 then
--         leave sp_main;
--     end if;


-- 	-- get the flight's progress, the status, and the id of the route for later
--     select progress, airplane_status, routeID into current_leg, current_status, routeID
--     from flight where flightID = ip_flightID;

--     -- if our flight isn't on the ground then leave
--     if current_status != 'on_ground' then
--         leave sp_main;
--     end if;

-- 	-- get the number of legs connected to the route
--     select count(*) into num_legs from route_path where routeID = routeID;

-- 	-- if our "leg number" is too high then leave (when could this happen? it's not an input)
--     if current_leg >= num_legs then
--         leave sp_main;
--     end if;

--     -- get the departure and arrival airport (come back to this, may not work?)
--     select l.departure, l.arrival into departing_airport, arriving_airport
--     from route_path rp join leg l on rp.legID = l.legID
--     where rp.routeID = routeID and rp.sequence = current_leg + 1;

-- 	-- grab the locationID of the airport where we're leaving from
--     -- so that we can find all the people at that location
--     -- (i think we could just pull the flight's location ID but that's ok)
--     select locationID into current_port from airport where airportID = departing_airport;

--     -- grab the location and the seat capacity of the airplane
--     select locationID, seat_capacity into plane_location, seat_capacity
--     from airplane a 
--     join flight f on a.airlineID = f.support_airline and a.tail_num = f.support_tail
--     where f.flightID = ip_flightID;

--     select count(*) into num_boarding
--     from person p
--     join passenger pa on p.personID = pa.personID
--     join passenger_vacations pv on pa.personID = pv.personID
--     where p.locationID = current_port
--       and pv.sequence = 1
--       and pv.airportID = arriving_airport
--       and pa.funds >= (select cost from flight where flightID = ip_flightID);

--     if num_boarding <= seat_capacity then
--         update person p
--         join passenger pa on p.personID = pa.personID
--         join passenger_vacations pv on pa.personID = pv.personID
--         set p.locationID = plane_location,
--             pa.funds = pa.funds - (select cost from flight where flightID = ip_flightID)
--         where p.locationID = current_port
--           and pv.sequence = 1
--           and pv.airportID = arriving_airport
--           and pa.funds >= (select cost from flight where flightID = ip_flightID);
--     end if;

#### SAMI CODE
	-- Variable declaration
 --    DECLARE current_status VARCHAR(100);
 --    DECLARE current_leg INT;
 --    DECLARE num_legs INT;
 --    DECLARE route_ID VARCHAR(50);
	-- DECLARE departing_airport char(3);
 --    DECLARE arriving_airport char(3);
 --    DECLARE flight_cost INT;
 --    DECLARE capacity INT;
 --    DECLARE num_boarding INT;
 --    declare current_port varchar(50);
 --    DECLARE plane_location VARCHAR(50);
    

	-- -- Ensure the flight exists
 --    IF ip_flightID NOT IN (SELECT flightID FROM flight) THEN LEAVE sp_main;
 --    END IF;
    
 --    -- Ensure that the flight is on the ground
 --    SELECT airplane_status INTO current_status FROM flight WHERE flightID = ip_flightID;
 --    IF current_status != 'on_ground' THEN
 --        LEAVE sp_main;
 --    END IF;

 --    -- Ensure that the flight has further legs to be flown
 --    SELECT progress INTO current_leg FROM flight WHERE flightID = ip_flightID;
 --    SELECT count(*) INTO num_legs FROM route_path WHERE routeID = route_ID;

 --    IF current_leg >= num_legs THEN LEAVE sp_main;
 --    END IF;
    
 --    -- Determine the number of passengers attempting to board the flight
 --    -- Use the following to check:
	-- 	-- The airport the airplane is currently located at
    
 --    select leg.departure, leg.arrival into departing_airport, arriving_airport 
 --    from route_path join leg on route_path.legID = leg.legID 
 --    where route_path.routeID = route_ID and route_path.sequence = current_leg + 1;
    
 --    select locationID into current_port from airport where airportID = departing_airport;
    
 --    select locationID into plane_location
	-- from airplane a join flight f on a.airlineID = f.support_airline and a.tail_num = f.support_tail
	-- where f.flightID = ip_flightID;

	
 --        -- The passengers are located at that airport - check if passengers are located at departing airport
 --        -- The passenger's immediate next destination matches that of the flight - check if next destination is arriving airport
 --        -- The passenger has enough funds to afford the flight
	-- SELECT cost INTO flight_cost FROM flight where flightID = ip_flightID;
        
	-- SELECT count(*) INTO num_boarding FROM person join passenger on person.personID = passenger.personID
 --    join passenger_vacations on passenger_vacations.personID = passenger.personID
 --    where person.locationID = current_port
 --    AND passenger_vacations.airportID = arriving_airport
 --    AND passenger.funds >= flight_cost;

	-- -- Check if there enough seats for all the passengers
 --    SELECT seat_capacity INTO capacity from flight JOIN airplane ON flight.support_tail = airplane.tail_num where flightID = ip_flightID;
    
	-- 	-- If not, do not board any passengers
	-- IF capacity < num_boarding THEN LEAVE sp_main;
 --    END IF;
	
 --        -- If there are, board them and deduct their funds
	-- IF num_boarding <= seat_capacity THEN
	-- 	UPDATE person 
	-- 	JOIN passenger ON person.personID = passenger.personID
 --        JOIN passenger_vacations on passenger_vacations.personID = passenger.personID
 --        SET person.locationID = plane_location,
	-- 		passenger.funds = passenger.funds - flight_cost
	-- 	WHERE person.locationID = current_port
 --        AND passenger_vacations.airportID = arriving_airport
 --        AND passenger.funds >= flight_cost; 
	-- END IF;
            


	-- Ensure the flight exists
    -- Ensure that the flight is on the ground
    -- Ensure that the flight has further legs to be flown
    
    -- Determine the number of passengers attempting to board the flight
    -- Use the following to check:
		-- The airport the airplane is currently located at
        -- The passengers are located at that airport
        -- The passenger's immediate next destination matches that of the flight
        -- The passenger has enough funds to afford the flight
        
	-- Check if there enough seats for all the passengers
		-- If not, do not add board any passengers
        -- If there are, board them and deduct their funds

end //
delimiter ;


-- [9] passengers_disembark() {natalia}
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
	declare routeID, legID varchar(50);
    declare airportID char(3);
    declare prog int;
    declare loc, airplaneLoc varchar(50);

	-- Ensure the flight exists
	-- Ensure that the flight is in the air
    if not exists (
        select 1 from flight 
        where flightID = ip_flightID and airplane_status = 'on_ground'
    ) then 
        leave sp_main;
    end if;

    -- Determine the list of passengers who are disembarking
	-- Use the following to check:
	-- Passengers must be on the plane supporting the flight
	-- Passenger has reached their immediate next destionation air
    set prog = (select f.progress from flight f where f.flightID = ip_flightID);
    set routeID = (select f.routeID from flight f where f.flightID = ip_flightID);
    set legID = (select rp.legID from route_path rp where rp.routeID = routeID and rp.sequence = prog);
    set airportID = (select l.arrival from leg l where l.legID = legID);
    set loc = (select a.locationID from airport a where a.airportID = airportID);
    set airplaneLoc = (
        select ap.locationID 
        from airplane ap 
        join flight f on ap.airlineID = f.support_airline and ap.tail_num = f.support_tail
        where f.flightID = ip_flightID
    );
    -- Move the appropriate passengers to the airport
	-- Update the vacation plans of the passengers
    update person 
    join (
        select pv.personID
        from passenger_vacations pv
        join person p on pv.personID = p.personID
        where pv.airportID = airportID and pv.sequence = 1 and p.locationID = airplaneLoc
    ) as eligible on person.personID = eligible.personID
    set person.locationID = loc;

    -- Update the vacation plans of the passengers
    update person 
    join (
        select pv.personID
        from passenger_vacations pv
        join person p on pv.personID = p.personID
        where pv.airportID = airportID and pv.sequence = 1 and p.locationID = airplaneLoc
    ) as eligible on person.personID = eligible.personID
    set person.locationID = loc;

end //
delimiter ;


-- [10] assign_pilot() {natalia}
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

    declare planeLoc, pilotLoc, supportTail, supportAir, routeID, currLegID, planeNum varchar(50) default null;
    declare planeType varchar(100) default null;
    declare airportID char(3) default null;
    declare currLegNum, numLeg integer default 0;
    declare currStat varchar(100) default null;

    -- Ensure the flight exists
    if (select count(*) from flight f where f.flightID = ip_flightID) < 1 then leave sp_main; end if;
    -- Ensure that the flight is on the ground
    if currStat = 'in_flight' then leave sp_main; end if;
    
    -- Make sure that personID exists
    if (select count(*) from person p where p.personID = ip_personID) < 1 then leave sp_main; end if;
    
    -- Get flight information
	-- x = locationname, locatedat
	-- get current flight id's aiport location id 
	set supportTail = (select f.support_tail from flight f where f.flightID = ip_flightID);
    set supportAir = (select f.support_airline from flight f where f.flightID = ip_flightID);
    set planeType = (select a.plane_type from airplane a where a.airlineID = supportAir and a.tail_num = supportTail);
    set routeID = (select f.routeID from flight f where f.flightID = ip_flightID);
    set currStat = (select f.airplane_status from flight f where f.flightID = ip_flightID);
    
    -- Ensure that the pilot has the appropriate license
    if (select count(*) from pilot_licenses pl where pl.personID = ip_personID and pl.license = planeType) < 1 then leave sp_main; end if;
    
    -- Get leg information
    set currLegNum = (select f.progress from flight f where f.flightID = ip_flightID);
    set numLeg = (select count(*) from route_path rp where rp.routeID = routeID);
    
    -- Ensure that the flight has further legs to be flown
    if (currLegNum = numLeg) then leave sp_main; end if;
    
    -- Find which airport the plane is at
    if (currLegNum = 0) then
        set currLegID = (select rp.legID from route_path rp where rp.routeID = routeID and rp.sequence = currLegNum + 1);
        set airportID = (select l.departure from leg l where l.legID = currLegID);
    else 
        set currLegID = (select rp.legID from route_path rp where rp.routeID = routeID and rp.sequence = currLegNum);
        set airportID = (select l.arrival from leg l where l.legID = currLegID);
    end if;
    
    -- Get current flight's airport location
    set planeLoc = (select a.locationID from airport a where a.airportID = airportID);
    
    -- Get pilot's current location
	-- check person's location and ensure same as pilot location
	-- pilots locations are ports not the plane
    set pilotLoc = (select p.locationID from person p where p.personID = ip_personID);
    set planeNum = (select a.locationID from airplane a where a.airlineID = supportAir and a.tail_num = supportTail);
    
    -- Ensure the pilot is located at the airport of the plane that is supporting the flight
    if (planeLoc != pilotLoc) then leave sp_main; end if;
    
    -- Ensure that the pilot exists and is not already assigned
    if (select commanding_flight from pilot p where p.personID = ip_personID) is not null 
    then leave sp_main; 
    end if;
    
    -- Assign the pilot to the flight and update their location to be on the plane
    update pilot p set p.commanding_flight = ip_flightID where p.personID = ip_personID;
    update person p set p.locationID = planeNum where p.personID = ip_personID;

end //
delimiter ;



-- [11] recycle_crew() {natalia}
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

	declare numLeg, currLeg, numPassengers integer default 0;
	declare currStat varchar(100) default null;
	declare supportAir, supportTail, planeNum, routeID, currLegID, portID varchar(50) default null;
	declare airportID char(3) default null;

    -- flight exists
	if (select count(*) from flight f where f.flightID = ip_flightID) < 1 
    then leave sp_main; 
    end if;
    
    -- Ensure that the flight is on the ground
    -- Ensure that the flight does not have any more legs
    set currLeg = (select f.progress from flight f where f.flightID = ip_flightID);
    set numLeg = (select count(*) from route_path rp where rp.routeID = (select f.routeID from flight f where f.flightID = ip_flightID));
    set currStat = (select f.airplane_status from flight f where f.flightID = ip_flightID);
    set supportTail = (select f.support_tail from flight f where f.flightID = ip_flightID);
    set supportAir = (select f.support_airline from flight f where f.flightID = ip_flightID);
    
    -- flight hasnt ended
    if (currLeg != numLeg) 
    then leave sp_main; 
    end if;
    
    -- cant let crew go
    if currStat = 'in_flight' 
    then leave sp_main; 
    end if;
    
    set planeNum = (select a.locationID from airplane a where a.airlineID = supportAir and a.tail_num = supportTail);
    set numPassengers = (select count(*) from person p where p.locationID = planeNum and p.personID in (select personID from passenger));
     
    -- Ensure that the flight is empty of passengers
    if numPassengers > 0 
    then leave sp_main; 
    end if;
            
	-- Update assignments of all pilots
    -- Move all pilots to the airport the plane of the flight is located at
	set routeID = (select f.routeID from flight f where f.flightID = ip_flightID);
	set currLegID = (select rp.legID from route_path rp where rp.routeID = routeID and rp.sequence = currLeg);
	set airportID = (select l.arrival from leg l where l.legID = currLegID);
    set portID = (select a.locationID from airport a where a.airportID = airportID);
	
    update person p set p.locationID = portID 
    where p.personID in (select pi.personID from pilot pi where pi.commanding_flight = ip_flightID);
            
    update pilot p set p.commanding_flight = null 
    where p.commanding_flight = ip_flightID;
end //
delimiter ;


-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin

	DECLARE current_progress INT;
    DECLARE current_location VARCHAR(50);

	-- Ensure that the flight is on the ground
    IF 'in_flight' IN (select airplane_status from flight where flightID = ip_flightID) THEN LEAVE sp_main;
    END IF;
    
    -- Ensure that the flight does not have any more legs
    SELECT progress INTO current_progress FROM flight WHERE flightID = ip_flightID;

    IF current_progress
		!= (SELECT COUNT(*) FROM route_path WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)) 
        THEN LEAVE sp_main;
	END IF;
    
    -- Ensure that there are no more people on the plane supporting the flight
    
      # pilots
    IF ip_flightID in (select flightID from pilot join flight on pilot.commanding_flight = flight.flightID) THEN LEAVE sp_main;
    END IF;
    
      # passengers (something is not working here) - maybe try declaring a variable
    select locationID INTO current_location from flight join airplane on flight.support_tail = airplane.tail_num WHERE flight.flightID = ip_flightID; 
    IF current_location IN
    (select locationID from passenger join person on passenger.personID = person.personID) THEN LEAVE sp_main;
    END IF;

    -- Remove the flight from the system
    DELETE FROM flight WHERE flightID = ip_flightID;

end //
delimiter ;

-- [13] simulation_cycle() {natalia}
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

    -- Declare variables
    declare flightID_select varchar(50) default null;
    declare selected_progress int default 0;
    declare max_progress int default 0;
    declare status varchar(100) default null;
    declare route_id varchar(50) default null;

    -- Select the next flight to process
    select f.flightID, f.airplane_status, f.progress, f.routeID
    into flightID_select, status, selected_progress, route_id
    from flight f
    where f.airplane_status in ('in_flight', 'on_ground')
    order by f.next_time,
             case f.airplane_status
                 when 'in_flight' then 0
                 when 'on_ground' then 1
                 else 2
             end,
             f.flightID
    limit 1;

    -- If no flight found, exit
    if flightID_select is null then
        leave sp_main;
    end if;

    -- Get max sequence for that route
    select max(sequence) into max_progress
    from route_path
    where routeID = route_id;

    -- If flight is in the air
    if status = 'in_flight' then
        call flight_landing(flightID_select);
        call passengers_disembark(flightID_select);

        -- Check progress again after landing
        select progress into selected_progress
        from flight
        where flightID = flightID_select;

        if selected_progress >= max_progress then
            call recycle_crew(flightID_select);
            call retire_flight(flightID_select);
        end if;

    -- Else if on ground
    else
        if selected_progress >= max_progress then
            call passengers_disembark(flightID_select);
            call recycle_crew(flightID_select);
            call retire_flight(flightID_select);
        else
            call passengers_board(flightID_select);
            call flight_takeoff(flightID_select);
        end if;
    end if;

end //
delimiter ;


-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. 
We need to display what airports these flights are departing from, what airports 
they are arriving at, the number of flights that are flying between the 
departure and arrival airport, the list of those flights (ordered by their 
flight IDs), the earliest and latest arrival times for the destinations and the 
list of planes (by their respective flight IDs) flying these flights. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
SELECT 
	l.departure as departing_from,
    l.arrival as arriving_at,
    COUNT(f.flightID) as num_flights,
    GROUP_CONCAT(f.flightID order by f.flightID separator ',') as flight_list,
    MIN(f.next_time) as earliest_arrival,
    MAX(f.next_time) as latest_arrival,
    GROUP_CONCAT(
		(SELECT a.locationID from airplane a WHERE a.airlineID = f.support_airline AND  a.tail_num = f.support_tail)
		order by f.flightID separator ','
	) as airplane_list
FROM flight f
	JOIN route_path rp on f.routeID = rp.routeID AND f.progress = rp.sequence
    JOIN leg l on l.legID = rp.legID
WHERE 
	f.progress is not null AND f.airplane_status = 'in_flight'
GROUP BY
	l.departure, l.arrival;
    
-- # andy's version:
-- create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
-- 	flight_list, earliest_arrival, latest_arrival, airplane_list) as
-- SELECT
-- 	l.departure as departing_from,
--     l.arrival as arriving_at,
--     COUNT(*) AS num_flights,
--     GROUP_CONCAT(f.flightID ORDER BY f.flightID SEPARATOR ', ') as flight_list,
--     MIN(f.next_time) AS earliest_arrival, 
--     MAX(f.next_time) AS latest_arrival,
--     GROUP_CONCAT(f.support_tail ORDER BY f.flightID SEPARATOR ', ') AS airplane_list
-- FROM flight f
-- 	JOIN route_path rp ON rp.routeID = f.routeID AND rp.sequence = f.progress
--     JOIN leg l ON l.legID = rp.legID
-- WHERE f.airplane_status LIKE 'in_flight'
-- GROUP BY l.departure, l.arrival;
--     
-- [15] flights_on_the_ground() {natalia}
-- ------------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are 
located. We need to display what airports these flights are departing from, how 
many flights are departing from each airport, the list of flights departing from 
each airport (ordered by their flight IDs), the earliest and latest arrival time 
amongst all of these flights at each airport, and the list of planes (by their 
respective flight IDs) that are departing from each airport.*/
-- ------------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
	with tempFlight as (
    select fl.flightID, fl.routeID, fl.progress, fl.airplane_status, fl.next_time, rp.legID, rp.sequence, a.locationID, l.departure, l.arrival
    from flight fl
    join airplane a on fl.support_airline = a.airlineID and fl.support_tail = a.tail_num
    join route_path rp on fl.routeID = rp.routeID
    join leg l on rp.legID = l.legID
    where fl.airplane_status = 'on_ground'
)
select departing_from,
    count(*) as num_flights,
    group_concat(flightID order by flightID) as flight_list,
    min(next_time) as earliest_arrival,
    max(next_time) as latest_arrival,
    group_concat(locationID order by flightID) as airplane_list
from (select departure as departing_from, flightID, routeID, progress, airplane_status, next_time, legID, sequence, locationID, departure, arrival
    from tempFlight
    where progress = 0 and sequence = 1 union all
    select arrival as departing_from, flightID, routeID, progress, airplane_status, next_time, legID, sequence, locationID, departure, arrival from tempFlight where progress = sequence) as groupedFlights group by departing_from;
    
-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. We 
need to display what airports these people are departing from, what airports 
they are arriving at, the list of planes (by the location id) flying these 
people, the list of flights these people are on (by flight ID), the earliest 
and latest arrival times of these people, the number of these people that are 
pilots, the number of these people that are passengers, the total number of 
people on the airplane, and the list of these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view route_summ  as
select route_path.routeID as route,
count( distinct legID) as num_legs, 
GROUP_CONCAT( distinct  route_path.legID order by sequence) as leg_sequence, 
round(sum(distance)/greatest(1,count(distinct flightID))) as route_length,
count(Distinct flightID)as num_flights, group_concat(distinct flight.flightID) as flight_list, 
group_concat(distinct concat( leg.departure, '->', leg.arrival) order by sequence) as 'airport_sequence'
from route_path natural join leg left outer join flight on flight.routeID = route_path.routeID group by route_path.routeID;


create or replace view table1 as
select  count(*) as num_airplanes, group_concat(distinct locationID) as 'airplane_list', flightID, 
min(next_time) as 'earliest_arrival', max(next_time) as 'latest_arrival'  from airplane join flight 
on airlineID = support_airline and support_tail = tail_num where tail_num in (select support_tail 
from flight where airplane_status like '%in_flight') group by flightID;

create or replace view people as
SELECT

  p.personid,
  p.locationID,
  pi.personid AS pilot_personid,
  pa.personid AS passenger_personid
FROM person p
LEFT JOIN pilot as pi ON p.personid = pi.personID
LEFT JOIN passenger as pa ON p.personid = pa.personID;

create or replace view view2 as
select * from flight, airplane where support_tail = tail_num;

create or replace view view3 as
select people.locationID, flightID as fID, sum(case when pilot_personid is not null then 1 else 0 end) as num_pilots, 
sum(case when passenger_personid is not null then 1 else 0 end) as num_passengers, count(distinct personID) as joint_pilots_passengers , 
group_concat(personID) as person_list from people join view2 where people.locationID = view2.locationID and tail_num in (select support_tail 
from flight where airplane_status like '%in_flight') group by people.locationID, flightID;

create or replace view view4 as
select departure, arrival,num_airplanes, airplane_list, earliest_arrival,latest_arrival from table1, leg, flight, route_path, route_summ
where flight.flightID = table1.flightID 
and route_path.routeID = flight.routeID 
and route_summ.route = flight.routeID 
and leg.legID = route_path.legID 
and route_path.sequence = flight.progress;
				

create or replace view people_in_the_air AS
SELECT 
    v4.departure AS departing_from,
    v4.arrival AS arriving_at,
    COUNT(DISTINCT v4.airplane_list) AS num_airplanes,
    GROUP_CONCAT(DISTINCT v4.airplane_list ORDER BY v4.airplane_list SEPARATOR ',') AS airplane_list, 
    GROUP_CONCAT(DISTINCT v3.fID ORDER BY v3.fID SEPARATOR ',') AS flight_list,
    MIN(v4.earliest_arrival) AS earliest_arrival, MAX(v4.latest_arrival) AS latest_arrival,
    SUM(v3.num_pilots) AS num_pilots, SUM(v3.num_passengers) AS num_passengers, SUM(v3.joint_pilots_passengers) AS joint_pilots_passengers,
    GROUP_CONCAT(DISTINCT v3.person_list ORDER BY v3.person_list SEPARATOR ',') AS person_list
from view4 v4
join view3 v3 ON v3.locationID = v4.airplane_list 
GROUP BY v4.departure, v4.arrival;


-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground and in an 
airport are located. We need to display what airports these people are departing 
from by airport id, location id, and airport name, the city and state of these 
airports, the number of these people that are pilots, the number of these people 
that are passengers, the total number people at the airport, and the list of 
these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
SELECT 
    a.airportID AS departing_from,
    a.locationID AS airport,
    a.airport_name,
    a.city,
    a.state,
    a.country,
    SUM(CASE WHEN pi.personID IS NOT NULL THEN 1 ELSE 0 END) AS num_pilots,
    SUM(CASE WHEN pa.personID IS NOT NULL THEN 1 ELSE 0 END) AS num_passengers,
    COUNT(p.personID) AS joint_pilots_passengers,
    GROUP_CONCAT(p.personID ORDER BY p.personID SEPARATOR ',') AS person_list

FROM person p

JOIN airport a 
    ON p.locationID = a.locationID -- person is physically located at the airport

LEFT JOIN pilot pi 
    ON p.personID = pi.personID

LEFT JOIN passenger pa 
    ON p.personID = pa.personID

GROUP BY 
    a.airportID, a.locationID, a.airport_name, a.city, a.state, a.country

ORDER BY 
    a.airportID;

-- [18] route_summary() {natalia}
-- -----------------------------------------------------------------------------
/* This view will give a summary of every route. This will include the routeID, 
the number of legs per route, the legs of the route in sequence, the total 
distance of the route, the number of flights on this route, the flightIDs of 
those flights by flight ID, and the sequence of airports visited by the route. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
	select route_path.routeID as route,
	count(distinct legID) as num_legs, 
	GROUP_CONCAT(distinct route_path.legID order by sequence) as leg_sequence, 
	round(sum(distance)/greatest(1,count(distinct flightID))) as route_length,
	count(distinct flight.flightID) as num_flights,
    group_concat(distinct flight.flightID) as flight_list, 
	group_concat(distinct concat(leg.departure, '->', leg.arrival) order by sequence) as 'airport_sequence'
	from route_path natural join leg left outer join flight on flight.routeID = route_path.routeID group by route_path.routeID;

-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. It should 
specify the city, state, the number of airports shared, and the lists of the 
airport codes and airport names that are shared both by airport ID. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
SELECT
    city,
    state,
    country,
    COUNT(*) AS num_airports,
    GROUP_CONCAT(airportID ORDER BY airportID) AS airport_code_list,
    GROUP_CONCAT(airport_name ORDER BY airportID) AS airport_name_list
FROM
    airport
GROUP BY
    city, state, country
HAVING
    num_airports > 1
ORDER BY
    city, 
    airport_code_list;
