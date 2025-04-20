-- CS4400: Introduction to Database Systems: Monday, March 3, 2025
-- Flight Tracking Course Project: BASIC Autograder [v0]

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- ----------------------------------------------------------------------------------
-- [1] Implement a capability to reset the database state easily
-- ----------------------------------------------------------------------------------

drop procedure if exists magic44_reset_database_state;
delimiter //
create procedure magic44_reset_database_state ()
begin
	-- Purge and then reload all of the database rows back into the tables.
    -- Ensure that the data is deleted in reverse order with respect to the
    -- foreign key dependencies (i.e., from children up to parents).
	delete from pilot_licenses;
	delete from pilot;
	delete from flight;
	delete from route_path;
	delete from route;
	delete from leg;
	delete from passenger_vacations;
	delete from passenger;
	delete from person;
	delete from airport;
	delete from airplane;
    delete from location;
    delete from airline;

    -- Ensure that the data is inserted in order with respect to the
    -- foreign key dependencies (i.e., from parents down to children).
	insert into airline values ('Delta', 53000);
	insert into airline values ('United', 48000);
	insert into airline values ('British Airways', 24000);
	insert into airline values ('Lufthansa', 35000);
	insert into airline values ('Air_France', 29000);
	insert into airline values ('Ryanair', 10000);
	insert into airline values ('Japan Airlines', 9000);
	insert into airline values ('China Southern Airlines', 14000);
	insert into airline values ('KLM', 29000);
	insert into airline values ('Korean Air Lines', 10000);
	insert into airline values ('American', 52000);
	insert into airline values ('Spirit', 200);

	INSERT INTO location (locationID) VALUES
		('port_1'), ('port_2'), ('port_3'), ('port_10'), ('port_17'),
		('plane_1'), ('plane_5'), ('plane_8'), ('plane_13'), ('plane_20'),
		('port_12'), ('port_14'), ('port_15'), ('port_20'), ('port_4'),
		('port_16'), ('port_11'), ('port_23'), ('port_7'), ('port_6'),
		('port_13'), ('port_21'), ('port_18'), ('port_22'), ('plane_6'),
		('plane_18'), ('plane_7'), ('plane_2'), ('plane_3'), ('plane_4'),
		('port_24'), ('plane_10'), ('port_25'),('plane_26'),('plane_27'),
        ('plane_28'),('plane_29');

	INSERT INTO airplane (airlineID, tail_num, seat_capacity, speed, locationID, plane_type, maintenanced, model, neo) VALUES
		('Delta', 'n106js', 4, 800, 'plane_1', 'Airbus', NULL, NULL, FALSE),
		('Delta', 'n110jn', 5, 800, 'plane_3', 'Airbus', NULL, NULL, FALSE),
		('Delta', 'n127js', 4, 600, NULL, 'Airbus', NULL, NULL, TRUE),
		('United', 'n330ss', 4, 800, NULL, 'Airbus', NULL, NULL, FALSE),
		('United', 'n380sd', 5, 400, 'plane_5', 'Airbus', NULL, NULL, FALSE),
		('British Airways', 'n616lt', 7, 600, 'plane_6', 'Airbus', NULL, NULL, FALSE),
		('British Airways', 'n517ly', 4, 600, 'plane_7', 'Airbus', NULL, NULL, FALSE),
		('Lufthansa', 'n620la', 4, 800, 'plane_8', 'Airbus', NULL, NULL, TRUE),
		('Lufthansa', 'n401fj', 4, 300, NULL, NULL, NULL, NULL, NULL),
		('Lufthansa', 'n653fk', 6, 600, 'plane_10', 'Airbus', NULL, NULL, FALSE),
		('Air_France', 'n118fm', 4, 400, NULL, 'Boeing', FALSE, '777', NULL),
		('Air_France', 'n815pw', 3, 400, NULL, 'Airbus', NULL, NULL, FALSE),
		('Air_France', 'n816pw', 3, 400, 'plane_28', 'Airbus', NULL, NULL, FALSE),
		('KLM', 'n161fk', 4, 600, 'plane_13', 'Airbus', NULL, NULL, TRUE),
		('KLM', 'n337as', 5, 400, NULL, 'Airbus', NULL, NULL, FALSE),
		('KLM', 'n256ap', 4, 300, NULL, 'Boeing', FALSE, '737', NULL),
		('Ryanair', 'n156sq', 8, 600, NULL, 'Airbus', NULL, NULL, FALSE),
		('Ryanair', 'n451fi', 5, 600, NULL, 'Airbus', NULL, NULL, TRUE),
		('Ryanair', 'n341eb', 4, 400, 'plane_18', 'Boeing', TRUE, '737', NULL),
		('Ryanair', 'n353kz', 4, 400, NULL, 'Boeing', TRUE, '737', NULL),
		('Japan Airlines', 'n305fv', 6, 400, 'plane_20', 'Airbus', NULL, NULL, FALSE),
		('Japan Airlines', 'n443wu', 4, 800, NULL, 'Airbus', NULL, NULL, TRUE),
		('China Southern Airlines', 'n454gq', 3, 400, NULL, NULL, NULL, NULL, NULL),
		('China Southern Airlines', 'n249yk', 4, 400, NULL, 'Boeing', FALSE, '787', NULL),
		('Korean Air Lines', 'n180co', 5, 600, 'plane_4', 'Airbus', NULL, NULL, FALSE),
		('Korean Air Lines', 'n266f7', 12, 600, 'plane_26', 'Airbus', NULL, NULL, FALSE),
		('American', 'n448cs', 4, 400, NULL, 'Boeing', TRUE, '787', NULL),
		('American', 'n225sb', 8, 800, NULL, 'Airbus', NULL, NULL, FALSE),
		('American', 'n553qn', 5, 800, 'plane_2', 'Airbus', NULL, NULL, FALSE),
		('Spirit', 'n270ff', 3, 200, 'plane_27', 'Airbus', NULL, NULL, TRUE),
		('Spirit', 'n223gw', 3, 200, 'plane_29', 'Airbus', NULL, NULL, TRUE);

	INSERT INTO airport (airportID, airport_name, city, state, country, locationID) VALUES
		('ATL', 'Atlanta Hartsfield_Jackson International', 'Atlanta', 'Georgia', 'USA', 'port_1'),
		('DXB', 'Dubai International', 'Dubai', 'Al Garhoud', 'UAE', 'port_2'),
		('HND', 'Tokyo International Haneda', 'Ota City', 'Tokyo', 'JPN', 'port_3'),
		('LHR', 'London Heathrow', 'London', 'England', 'GBR', 'port_4'),
		('IST', 'Istanbul International', 'Arnavutkoy', 'Istanbul', 'TUR', NULL),
		('DFW', 'Dallas_Fort Worth International', 'Dallas', 'Texas', 'USA', 'port_6'),
		('CAN', 'Guangzhou International', 'Guangzhou', 'Guangdong', 'CHN', 'port_7'),
		('DEN', 'Denver International', 'Denver', 'Colorado', 'USA', NULL),
		('LAX', 'Los Angeles International', 'Los Angeles', 'California', 'USA', NULL),
		('ORD', 'O_Hare International', 'Chicago', 'Illinois', 'USA', 'port_10'),
		('AMS', 'Amsterdam Schipol International', 'Amsterdam', 'Haarlemmermeer', 'NLD', 'port_11'),
		('CDG', 'Paris Charles de Gaulle', 'Roissy_en_France', 'Paris', 'FRA', 'port_12'),
		('FRA', 'Frankfurt International', 'Frankfurt', 'Frankfurt_Rhine_Main', 'DEU', 'port_13'),
		('MAD', 'Madrid Adolfo Suarez_Barajas', 'Madrid', 'Barajas', 'ESP', 'port_14'),
		('BCN', 'Barcelona International', 'Barcelona', 'Catalonia', 'ESP', 'port_15'),
		('FCO', 'Rome Fiumicino', 'Fiumicino', 'Lazio', 'ITA', 'port_16'),
		('LGW', 'London Gatwick', 'London', 'England', 'GBR', 'port_17'),
		('MUC', 'Munich International', 'Munich', 'Bavaria', 'DEU', 'port_18'),
		('MDW', 'Chicago Midway International', 'Chicago', 'Illinois', 'USA', NULL),
		('IAH', 'George Bush Intercontinental', 'Houston', 'Texas', 'USA', 'port_20'),
		('HOU', 'William P_Hobby International', 'Houston', 'Texas', 'USA', 'port_21'),
		('NRT', 'Narita International', 'Narita', 'Chiba', 'JPN', 'port_22'),
		('BER', 'Berlin Brandenburg Willy Brandt International', 'Berlin', 'Schonefeld', 'DEU', 'port_23'),
		('ICN', 'Incheon International Airport', 'Seoul', 'Jung_gu', 'KOR', 'port_24'),
		('PVG', 'Shanghai Pudong International Airport', 'Shanghai', 'Pudong', 'CHN', 'port_25');

	INSERT INTO person (personID, first_name, last_name, locationID) VALUES
		('p1', 'Jeanne', 'Nelson', 'port_1'),
		('p2', 'Roxanne', 'Byrd', 'port_1'),
		('p3', 'Tanya', 'Nguyen', 'port_1'),
		('p4', 'Kendra', 'Jacobs', 'port_1'),
		('p5', 'Jeff', 'Burton', 'port_1'),
		('p6', 'Randal', 'Parks', 'port_1'),
		('p7', 'Sonya', 'Owens', 'port_2'),
		('p8', 'Bennie', 'Palmer', 'port_2'),
		('p9', 'Marlene', 'Warner', 'port_3'),
		('p10', 'Lawrence', 'Morgan', 'port_3'),
		('p11', 'Sandra', 'Cruz', 'port_3'),
		('p12', 'Dan', 'Ball', 'port_3'),
		('p13', 'Bryant', 'Figueroa', 'port_3'),
		('p14', 'Dana', 'Perry', 'port_3'),
		('p15', 'Matt', 'Hunt', 'port_10'),
		('p16', 'Edna', 'Brown', 'port_10'),
		('p17', 'Ruby', 'Burgess', 'plane_3'),
		('p18', 'Esther', 'Pittman', 'plane_10'),
		('p19', 'Doug', 'Fowler', 'port_23'),
		('p20', 'Thomas', 'Olson', 'port_4'),
		('p21', 'Mona', 'Harrison', 'plane_1'),
		('p22', 'Arlene', 'Massey', 'plane_1'),
		('p23', 'Judith', 'Patrick', 'plane_1'),
		('p24', 'Reginald', 'Rhodes', 'plane_5'),
		('p25', 'Vincent', 'Garcia', 'plane_5'),
		('p26', 'Cheryl', 'Moore', 'plane_5'),
		('p27', 'Michael', 'Rivera', 'plane_8'),
		('p28', 'Luther', 'Matthews', 'plane_8'),
		('p29', 'Moses', 'Parks', 'plane_13'),
		('p30', 'Ora', 'Steele', 'plane_13'),
		('p31', 'Antonio', 'Flores', 'plane_13'),
		('p32', 'Glenn', 'Ross', 'plane_13'),
		('p33', 'Irma', 'Thomas', 'plane_20'),
		('p34', 'Ann', 'Maldonado', 'plane_20'),
		('p35', 'Jeffrey', 'Cruz', 'port_12'),
		('p36', 'Sonya', 'Price', 'port_12'),
		('p37', 'Tracy', 'Hale', 'port_12'),
		('p38', 'Albert', 'Simmons', 'port_14'),
		('p39', 'Karen', 'Terry', 'port_15'),
		('p40', 'Glen', 'Kelley', 'port_20'),
		('p41', 'Brooke', 'Little', 'port_3'),
		('p42', 'Daryl', 'Nguyen', 'port_4'),
		('p43', 'Judy', 'Willis', 'port_14'),
		('p44', 'Marco', 'Klein', 'port_15'),
		('p45', 'Angelica', 'Hampton', 'port_16'),
		('p46', 'Janice', 'White', 'plane_10'),
		('p47', 'Charlie', 'Brown', 'port_6'),
		('p48', 'Charles', 'Schulz', 'plane_4'),
		('p49', 'Beyonce', NULL, 'port_20'),
		('p50', 'Jackie', 'Sullivan', 'plane_27'),
		('p51', 'Alayah', 'Colon', 'plane_1'),
		('p52', 'Bruce', 'Walter', 'plane_8'),
		('p53', 'Penny', 'Baldwin','plane_20'),
		('p54', 'Jaiden', 'Alvarado', 'plane_5'),
		('p55', 'Blake', 'Velazquez', 'plane_13'),
		('p56', 'Archer', 'Thomas', 'plane_28');

	INSERT INTO passenger (personID, miles, funds) VALUES
		('p21', 771, 700),
		('p22', 374, 200),
		('p23', 414, 400),
		('p24', 292, 500),
		('p25', 390, 300),
		('p26', 302, 600),
		('p27', 470, 400),
		('p28', 208, 400),
		('p29', 292, 700),
		('p30', 686, 500),
		('p31', 547, 400),
		('p32', 257, 500),
		('p33', 564, 600),
		('p34', 211, 200),
		('p35', 233, 500),
		('p36', 293, 400),
		('p37', 552, 700),
		('p38', 812, 700),
		('p39', 541, 400),
		('p40', 441, 700),
		('p41', 875, 300),
		('p42', 691, 500),
		('p43', 572, 300),
		('p44', 572, 500),
		('p45', 663, 500),
		('p46', 690, 5000),
		('p47', 230, 5000),
		('p49', 5000, 67297);

	INSERT INTO passenger_vacations (personID, airportID, sequence) VALUES
		('p21', 'AMS', 1),
		('p22', 'AMS', 1),
		('p23', 'BER', 1),
		('p24', 'MUC', 1),
		('p24', 'CDG', 2),
		('p25', 'MUC', 1),
		('p26', 'MUC', 1),
		('p27', 'BER', 1),
		('p28', 'LGW', 1),
		('p29', 'FCO', 1),
		('p29', 'LHR', 2),
		('p30', 'FCO', 1),
		('p30', 'MAD', 2),
		('p31', 'FCO', 1),
		('p32', 'FCO', 1),
		('p33', 'CAN', 1),
		('p34', 'HND', 1),
		('p35', 'LGW', 1),
		('p36', 'FCO', 1),
		('p37', 'FCO', 1),
		('p37', 'LGW', 2),
		('p37', 'CDG', 3),
		('p38', 'MUC', 1),
		('p39', 'MUC', 1),
		('p40', 'HND', 1),
		('p46', 'LGW', 1),
		('p47', 'IAH', 1),
		('p49', 'HOU', 1);

	INSERT INTO leg (legID, departure, arrival, distance) VALUES
		('leg_4', 'ATL', 'ORD', 600),
		('leg_2', 'ATL', 'AMS', 3900),
		('leg_1', 'AMS', 'BER', 400),
		('leg_31', 'ORD', 'CDG', 3700),
		('leg_14', 'CDG', 'MUC', 400),
		('leg_3', 'ATL', 'LHR', 3700),
		('leg_22', 'LHR', 'BER', 600),
		('leg_23', 'LHR', 'MUC', 500),
		('leg_29', 'MUC', 'FCO', 400),
		('leg_16', 'FCO', 'MAD', 800),
		('leg_25', 'MAD', 'CDG', 600),
		('leg_13', 'CDG', 'LHR', 200),
		('leg_24', 'MAD', 'BCN', 300),
		('leg_5', 'BCN', 'CDG', 500),
		('leg_27', 'MUC', 'BER', 300),
		('leg_8', 'BER', 'LGW', 600),
		('leg_21', 'LGW', 'BER', 600),
		('leg_9', 'BER', 'MUC', 300),
		('leg_28', 'MUC', 'CDG', 400),
		('leg_11', 'CDG', 'BCN', 500),
		('leg_6', 'BCN', 'MAD', 300),
		('leg_26', 'MAD', 'FCO', 800),
		('leg_30', 'MUC', 'FRA', 200),
		('leg_17', 'FRA', 'BER', 300),
		('leg_7', 'BER', 'CAN', 4700),
		('leg_10', 'CAN', 'HND', 1600),
		('leg_18', 'HND', 'NRT', 100),
		('leg_12', 'CDG', 'FCO', 600),
		('leg_15', 'DFW', 'IAH', 200),
		('leg_20', 'IAH', 'HOU', 100),
		('leg_19', 'HOU', 'DFW', 300),
		('leg_32', 'DFW', 'ICN', 6800),
		('leg_33', 'ICN', 'LHR', 4400),
		('leg_34', 'ICN', 'LAX', 5900),
		('leg_35', 'CDG', 'ORD', 3700),
		('leg_36', 'NRT', 'HND', 100),
		('leg_37', 'PVG', 'ICN', 500),
		('leg_38', 'LAX', 'PVG', 6500);

	INSERT INTO route (routeID) VALUES
		('americas_hub_exchange'),
		('americas_one'),
		('americas_three'),
		('americas_two'),
		('big_europe_loop'),
		('euro_north'),
		('euro_south'),
		('germany_local'),
		('pacific_rim_tour'),
		('south_euro_loop'),
		('texas_local'),
		('korea_direct');

	INSERT INTO route_path (routeID, legID, sequence) VALUES
		('americas_hub_exchange', 'leg_4', 1),
		('americas_one', 'leg_2', 1),
		('americas_one', 'leg_1', 2),
		('americas_three', 'leg_31', 1),
		('americas_three', 'leg_14', 2),
		('americas_two', 'leg_3', 1),
		('americas_two', 'leg_22', 2),
		('big_europe_loop', 'leg_23', 1),
		('big_europe_loop', 'leg_29', 2),
		('big_europe_loop', 'leg_16', 3),
		('big_europe_loop', 'leg_25', 4),
		('big_europe_loop', 'leg_13', 5),
		('euro_north', 'leg_16', 1),
		('euro_north', 'leg_24', 2),
		('euro_north', 'leg_5', 3),
		('euro_north', 'leg_14', 4),
		('euro_north', 'leg_27', 5),
		('euro_north', 'leg_8', 6),
		('euro_south', 'leg_21', 1),
		('euro_south', 'leg_9', 2),
		('euro_south', 'leg_28', 3),
		('euro_south', 'leg_11', 4),
		('euro_south', 'leg_6', 5),
		('euro_south', 'leg_26', 6),
		('germany_local', 'leg_9', 1),
		('germany_local', 'leg_30', 2),
		('germany_local', 'leg_17', 3),
		('pacific_rim_tour', 'leg_7', 1),
		('pacific_rim_tour', 'leg_10', 2),
		('pacific_rim_tour', 'leg_18', 3),
		('south_euro_loop', 'leg_16', 1),
		('south_euro_loop', 'leg_24', 2),
		('south_euro_loop', 'leg_5', 3),
		('south_euro_loop', 'leg_12', 4),
		('texas_local', 'leg_15', 1),
		('texas_local', 'leg_20', 2),
		('texas_local', 'leg_19', 3),
		('korea_direct', 'leg_32', 1);

	INSERT INTO flight (flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time, cost) VALUES
		('dl_10', 'americas_one', 'Delta', 'n106js', 1, 'in_flight', '08:00:00', 200),
		('un_38', 'americas_three', 'United', 'n380sd', 2, 'in_flight', '14:30:00', 200),
		('ba_61', 'americas_two', 'British Airways', 'n616lt', 0, 'on_ground', '09:30:00', 200),
		('lf_20', 'euro_north', 'Lufthansa', 'n620la', 3, 'in_flight', '11:00:00', 300),
		('km_16', 'euro_south', 'KLM', 'n161fk', 6, 'in_flight', '14:00:00', 400),
		('af_19', 'euro_south', 'Air_France', 'n816pw', 6, 'in_flight', '17:00:00', 450),
		('ba_51', 'big_europe_loop', 'British Airways', 'n517ly', 0, 'on_ground', '11:30:00', 100),
		('ja_35', 'pacific_rim_tour', 'Japan Airlines', 'n305fv', 1, 'in_flight', '09:30:00', 300),
		('ry_34', 'germany_local', 'Ryanair', 'n341eb', 0, 'on_ground', '15:00:00', 100),
		('aa_12', 'americas_hub_exchange', 'American', 'n553qn', 1, 'on_ground', '12:15:00', 150),
		('dl_42', 'texas_local', 'Delta', 'n110jn', 0, 'on_ground', '13:45:00', 220),
		('ke_64', 'korea_direct', 'Korean Air Lines', 'n180co', 1, 'on_ground', '16:00:00', 500),
		('lf_67', 'euro_north', 'Lufthansa', 'n653fk', 6, 'on_ground', '21:23:00', 900),
		('ke_88', 'pacific_rim_tour', 'Korean Air Lines', 'n266f7', 3, 'on_ground', '11:00:00', 450),
		('nk_98', 'texas_local', 'Spirit', 'n270ff', 1, 'on_ground', '13:13:13', 200),
		('nk_17', 'americas_two', 'spirit', 'n223gw', 0, 'on_ground', '08:30:00', 200);

	INSERT INTO pilot (personID, taxID, experience, commanding_flight) VALUES
		('p1', '330-12-6907', 31, 'dl_10'),
		('p2', '842-88-1257', 9, 'dl_10'),
		('p11', '369-22-9505', 22, 'km_16'),
		('p13', '513-40-4168', 24, 'km_16'),
		('p14', '454-71-7847', 13, 'km_16'),
		('p15', '153-47-8101', 30, 'ja_35'),
		('p16', '598-47-5172', 28, 'ja_35'),
		('p12', '680-92-5329', 24, 'ry_34'),
		('p17', '865-71-6800', 36, 'dl_42'),
		('p18', '250-86-2784', 23, 'lf_67'),
		('p19', '386-39-7881', 2, NULL),
		('p8', '701-38-2179', 12, 'ry_34'),
		('p20', '522-44-3098', 28, NULL),
		('p3', '750-24-7616', 11, 'un_38'),
		('p4', '776-21-8098', 24, 'un_38'),
		('p5', '933-93-2165', 27, 'ba_61'),
		('p6', '707-84-4555', 38, 'ba_61'),
		('p10', '769-60-1266', 15, 'lf_20'),
		('p7', '450-25-5617', 13, 'lf_20'),
		('p9', '936-44-6941', 13, 'lf_20'),
		('p48', '999-01-1369', 93, 'ke_64'),
		('p50', '937-82-7342', 40, 'nk_98'),
		('p51', '123-45-6789',12, 'dl_10'),
		('p52', '987-65-4321',78, 'lf_20'),
		('p53','333-44-5555',82, 'ja_35'),
		('p54','333-22-4444',24, 'un_38'),
		('p55','999-55-4567',23, 'km_16'),
		('p56','979-55-4567',31, 'af_19');

	INSERT INTO pilot_licenses (personID, license) VALUES
		('p1', 'Airbus'),
		('p2', 'Airbus'),
		('p2', 'Boeing'),
		('p11', 'Airbus'),
		('p11', 'Boeing'),
		('p13', 'Airbus'),
		('p14', 'Airbus'),
		('p15', 'Airbus'),
		('p15', 'Boeing'),
		('p15', 'general'),
		('p16', 'Airbus'),
		('p12', 'Boeing'),
		('p17', 'Airbus'),
		('p17', 'Boeing'),
		('p18', 'Airbus'),
		('p19', 'Airbus'),
		('p19', 'Boeing'),
		('p8', 'Boeing'),
		('p20', 'Airbus'),
		('p3', 'Airbus'),
		('p4', 'Airbus'),
		('p4', 'Boeing'),
		('p5', 'Airbus'),
		('p6', 'Airbus'),
		('p6', 'Boeing'),
		('p10', 'Airbus'),
		('p7', 'Airbus'),
		('p9', 'Airbus'),
		('p9', 'Boeing'),
		('p9', 'general'),
		('p48', 'Airbus'),
		('p50', 'Airbus'),
		('p51', 'Airbus'),
		('p52', 'Airbus'),
		('p53', 'Airbus'),
		('p54', 'Airbus'),
		('p55', 'Airbus'),
		('p56', 'Airbus');
end //
delimiter ;

-- ----------------------------------------------------------------------------------
-- [2] Create views to evaluate the queries & transactions
-- ----------------------------------------------------------------------------------
    
-- Create one view per original base table and student-created view to be used
-- to evaluate the transaction results.
create or replace view practiceQuery10 as select * from airline;
create or replace view practiceQuery11 as select * from location;
create or replace view practiceQuery12 as select * from airplane;
create or replace view practiceQuery13 as select * from airport;
create or replace view practiceQuery14 as select * from person;
create or replace view practiceQuery15 as select * from passenger;
create or replace view practiceQuery16 as select * from passenger_vacations;
create or replace view practiceQuery17 as select * from leg;
create or replace view practiceQuery18 as select * from route;
create or replace view practiceQuery19 as select * from route_path;
create or replace view practiceQuery20 as select * from flight;
create or replace view practiceQuery21 as select * from pilot;
create or replace view practiceQuery22 as select * from pilot_licenses;

create or replace view practiceQuery30 as select * from flights_in_the_air;
create or replace view practiceQuery31 as select * from flights_on_the_ground;
create or replace view practiceQuery32 as select * from people_in_the_air;
create or replace view practiceQuery33 as select * from people_on_the_ground;
create or replace view practiceQuery34 as select * from route_summary;
create or replace view practiceQuery35 as select * from alternative_airports;

-- ----------------------------------------------------------------------------------
-- [3] Prepare to capture the query results for later analysis
-- ----------------------------------------------------------------------------------

-- The magic44_data_capture table is used to store the data created by the student's queries
-- The table is populated by the magic44_evaluate_queries stored procedure
-- The data in the table is used to populate the magic44_test_results table for analysis

drop table if exists magic44_data_capture;
create table magic44_data_capture (
	stepID integer, queryID integer,
    columnDump0 varchar(1000), columnDump1 varchar(1000), columnDump2 varchar(1000), columnDump3 varchar(1000), columnDump4 varchar(1000),
    columnDump5 varchar(1000), columnDump6 varchar(1000), columnDump7 varchar(1000), columnDump8 varchar(1000), columnDump9 varchar(1000),
	columnDump10 varchar(1000), columnDump11 varchar(1000), columnDump12 varchar(1000), columnDump13 varchar(1000), columnDump14 varchar(1000)
);

-- The magic44_column_listing table is used to help prepare the insert statements for the magic44_data_capture
-- table for the student's queries which may have variable numbers of columns (the table is prepopulated)

drop table if exists magic44_column_listing;
create table magic44_column_listing (
	columnPosition integer,
    simpleColumnName varchar(50),
    nullColumnName varchar(50)
);

insert into magic44_column_listing (columnPosition, simpleColumnName) values
(0, 'columnDump0'), (1, 'columnDump1'), (2, 'columnDump2'), (3, 'columnDump3'), (4, 'columnDump4'),
(5, 'columnDump5'), (6, 'columnDump6'), (7, 'columnDump7'), (8, 'columnDump8'), (9, 'columnDump9'),
(10, 'columnDump10'), (11, 'columnDump11'), (12, 'columnDump12'), (13, 'columnDump13'), (14, 'columnDump14');

drop function if exists magic44_gen_simple_template;
delimiter //
create function magic44_gen_simple_template(numberOfColumns integer)
	returns varchar(1000) reads sql data
begin
	return (select group_concat(simpleColumnName separator ', ') from magic44_column_listing
	where columnPosition < numberOfColumns);
end //
delimiter ;

-- Create a variable to effectively act as a program counter for the testing process/steps
set @stepCounter = 0;

-- The magic44_query_capture function is used to construct the instruction
-- that can be used to execute and store the results of a query

drop function if exists magic44_query_capture;
delimiter //
create function magic44_query_capture(thisQuery integer)
	returns varchar(2000) reads sql data
begin
	set @numberOfColumns = (select count(*) from information_schema.columns
		where table_schema = @thisDatabase
        and table_name = concat('practiceQuery', thisQuery));

	set @buildQuery = 'insert into magic44_data_capture (stepID, queryID, ';
    set @buildQuery = concat(@buildQuery, magic44_gen_simple_template(@numberOfColumns));
    set @buildQuery = concat(@buildQuery, ') select ');
    set @buildQuery = concat(@buildQuery, @stepCounter, ', ');
    set @buildQuery = concat(@buildQuery, thisQuery, ', practiceQuery');
    set @buildQuery = concat(@buildQuery, thisQuery, '.* from practiceQuery');
    set @buildQuery = concat(@buildQuery, thisQuery, ';');

return @buildQuery;
end //
delimiter ;

drop function if exists magic44_query_exists;
delimiter //
create function magic44_query_exists(thisQuery integer)
	returns integer deterministic
begin
	return (select exists (select * from information_schema.views
		where table_schema = @thisDatabase
        and table_name like concat('practiceQuery', thisQuery)));
end //
delimiter ;

-- Exception checking has been implemented to prevent (as much as reasonably possible) errors
-- in the queries being evaluated from interrupting the testing process
-- The magic44_log_query_errors table captures these errors for later review

drop table if exists magic44_log_query_errors;
create table magic44_log_query_errors (
	step_id integer,
    query_id integer,
    query_text varchar(2000),
    error_code char(5),
    error_message text
);

drop procedure if exists magic44_query_check_and_run;
delimiter //
create procedure magic44_query_check_and_run(in thisQuery integer)
begin
	declare err_code char(5) default '00000';
    declare err_msg text;

	declare continue handler for SQLEXCEPTION
    begin
		get diagnostics condition 1
			err_code = RETURNED_SQLSTATE, err_msg = MESSAGE_TEXT;
	end;

    declare continue handler for SQLWARNING
    begin
		get diagnostics condition 1
			err_code = RETURNED_SQLSTATE, err_msg = MESSAGE_TEXT;
	end;

	if magic44_query_exists(thisQuery) then
		set @sql_text = magic44_query_capture(thisQuery);
		prepare statement from @sql_text;
        execute statement;
        if err_code <> '00000' then
			insert into magic44_log_query_errors values (@stepCounter, thisQuery, @sql_text, err_code, err_msg);
		end if;
        deallocate prepare statement;
	end if;
end //
delimiter ;

-- ----------------------------------------------------------------------------------
-- [4] Organize the testing results by step and query identifiers
-- ----------------------------------------------------------------------------------

drop table if exists magic44_test_case_directory;
create table if not exists magic44_test_case_directory (
	base_step_id integer,
	number_of_steps integer,
    query_label char(20),
    query_name varchar(100),
    scoring_weight integer
);

insert into magic44_test_case_directory values
(0, 1, '[V_0]', 'initial_state_check', 0),
(20, 5, '[C_1]', 'add_airplane', 4),
(40, 2, '[C_2]', 'add_airport', 4),
(60, 3, '[C_3]', 'add_person', 4),
(80, 4, '[C_4]', 'grant_or_revoke_pilot_license', 4),
(100, 4, '[C_5]', 'offer_flight', 4),
(120, 7, '[U_1]', 'flight_landing', 6),
(140, 6, '[U_2]', 'flight_takeoff', 6),
(160, 5, '[U_3]', 'passengers_board', 10),
(180, 5, '[U_4]', 'passengers_disembark', 8),
(200, 4, '[U_5]', 'assign_pilot', 6),
(220, 4, '[R_1]', 'recycle_crew', 5),
(240, 3, '[R_2]', 'retire_flight', 5),
(260, 1, '[U_6]', 'simulation_cycle', 6),
(280, 1, '[V_1]', 'flights_in_the_air', 4),
(300, 1, '[V_2]', 'flights_on_the_ground', 4),
(320, 1, '[V_3]', 'people_in_the_air', 4),
(340, 1, '[V_4]', 'people_on_the_ground', 4),
(360, 1, '[V_5]', 'route_summary', 4),
(380, 1, '[V_6]', 'alternative_airports', 4),
(400, 1, '[E_1]', 'multiple_cycles_of_actions', 4);

drop table if exists magic44_scores_guide;
create table if not exists magic44_scores_guide (
    score_tag char(1),
    score_category varchar(100),
    display_order integer
);

insert into magic44_scores_guide values
('C', 'Create Transactions', 1), ('U', 'Use Case Transactions', 2),
('R', 'Remove Transactions', 3), ('V', 'Global Views/Queries', 4),
('E', 'Event Scenarios/Sequences', 5);

-- ----------------------------------------------------------------------------------
-- [5] Test the queries & transactions and store the results
-- ----------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------
/* Check that the initial state of their database matches the required configuration.
The magic44_reset_database_state() call is deliberately missing in order to evaluate
the state of the submitted database. */
-- ----------------------------------------------------------------------------------
set @stepCounter = 0;
call magic44_query_check_and_run(10); -- airline
call magic44_query_check_and_run(11); -- location
call magic44_query_check_and_run(12); -- airplane
call magic44_query_check_and_run(13); -- airport
call magic44_query_check_and_run(14); -- person
call magic44_query_check_and_run(15); -- passenger
call magic44_query_check_and_run(16); -- passenger_vacations
call magic44_query_check_and_run(17); -- leg
call magic44_query_check_and_run(18); -- route
call magic44_query_check_and_run(19); -- route_path
call magic44_query_check_and_run(20); -- flight
call magic44_query_check_and_run(21); -- pilot
call magic44_query_check_and_run(22); -- pilot_licenses

-- ----------------------------------------------------------------------------------
/* Check the unit test cases here.  The magic44_reset_database_state() call is used
for each test to ensure that the database state is set to the initial configuration.
The @stepCounter is set to index the test appropriately, and then the test call is
performed.  Finally, calls are made to the appropriate database tables to compare the
actual state changes to the expected state changes per our answer key. */
-- ----------------------------------------------------------------------------------
-- [1] add_airplane() SUCCESS case(s)
-- Add test cases that satisfy all guard conditions and change the database state
call magic44_reset_database_state();
set @stepCounter = 20;
call add_airplane('Delta', 'n281fc', 6, 500, 'plane_41', 'Airbus', null, null, TRUE);
call magic44_query_check_and_run(12); -- airplane

-- [2] add_airport() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 40;
call add_airport('JFK', 'John F_Kennedy International', 'New York', 'New York', 'USA', 'port_33');
call magic44_query_check_and_run(13); -- airport

-- [3] add_person() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 60;
call add_person('p61', 'Sabrina', 'Duncan', 'port_1', '366-50-3732', 27, null, null);
call magic44_query_check_and_run(14); -- person
call magic44_query_check_and_run(21); -- pilot
call magic44_query_check_and_run(15); -- passenger

-- [4] grant_or_revoke_pilot_license() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 80;
call grant_or_revoke_pilot_license('p1','jets');
call magic44_query_check_and_run(22); -- pilot_licenses

-- [5] offer_flight() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 100;
call offer_flight('un_41', 'americas_three', 'United', 'n330ss', 0, '11:30:00', 400);
call magic44_query_check_and_run(20); -- flight

-- [6] flight_landing() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 120;
call flight_landing('dl_10');
call magic44_query_check_and_run(21); -- pilot
call magic44_query_check_and_run(15); -- passenger
call magic44_query_check_and_run(20); -- flight

-- [6] flight_landing() FAILURE case(s)
call magic44_reset_database_state();
set @stepCounter = @stepCounter + 1;
call flight_landing('oh_99');
call magic44_query_check_and_run(21); -- pilot
call magic44_query_check_and_run(15); -- passenger
call magic44_query_check_and_run(20); -- flight

-- [7] flight_takeoff() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 140;
call flight_takeoff('ba_61');
call magic44_query_check_and_run(20); -- flight

-- [7] flight_takeoff() FAILURE case(s)
call magic44_reset_database_state();
set @stepCounter = @stepCounter + 1;
call flight_takeoff('oh_99');
call magic44_query_check_and_run(20); -- flight

-- [8] passengers_board() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 160;
call passengers_board('dl_42');
call magic44_query_check_and_run(14); -- person

-- [8] passengers_board() FAILURE case(s)
call magic44_reset_database_state();
set @stepCounter = @stepCounter + 1;
call passengers_board('');
call magic44_query_check_and_run(14); -- person

-- [9] passengers_disembark() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 180;
call passengers_disembark('lf_67');
call magic44_query_check_and_run(14); -- person

-- [9] passengers_disembark() FAILURE case(s)
call magic44_reset_database_state();
set @stepCounter = @stepCounter + 1;
call passengers_disembark('lf_20');
call magic44_query_check_and_run(14); -- person

-- [10] assign_pilot() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 200;
call assign_pilot('ry_34', 'p19');
call magic44_query_check_and_run(14); -- person
call magic44_query_check_and_run(21); -- pilot

-- [11] recycle_crew() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 220;
call recycle_crew('ke_64');
call magic44_query_check_and_run(14); -- person
call magic44_query_check_and_run(21); -- pilot

-- [12] retire_flight() SUCCESS case(s)
call magic44_reset_database_state();
set @stepCounter = 240;
call retire_flight('ke_88');
call magic44_query_check_and_run(20); -- flight

-- [13] simulation_cycle() SUCCESS & FAILURE case(s)
call magic44_reset_database_state();
set @stepCounter = 260;
call simulation_cycle();
call magic44_query_check_and_run(12); -- airplane
call magic44_query_check_and_run(14); -- person
call magic44_query_check_and_run(21); -- pilot
call magic44_query_check_and_run(22); -- pilot_licenses
call magic44_query_check_and_run(15); -- passenger
call magic44_query_check_and_run(20); -- flight

-- [14] flights_in_the_air() INITIAL case
call magic44_reset_database_state();
set @stepCounter = 280;
call magic44_query_check_and_run(30); -- flights_in_the_air

-- [15] flights_on_the_ground() INITIAL case
call magic44_reset_database_state();
set @stepCounter = 300;
call magic44_query_check_and_run(31); -- flights_on_the_ground

-- [16] people_in_the_air() INITIAL case
call magic44_reset_database_state();
set @stepCounter = 320;
call magic44_query_check_and_run(32); -- people_in_the_air

-- [17] people_on_the_ground() INITIAL case
call magic44_reset_database_state();
set @stepCounter = 340;
call magic44_query_check_and_run(33); -- people_on_the_ground

-- [18] route_summary() INITIAL case
call magic44_reset_database_state();
set @stepCounter = 360;
call magic44_query_check_and_run(34); -- route_summary

-- [19] alternative_airports() INITIAL case
call magic44_reset_database_state();
set @stepCounter = 380;
call magic44_query_check_and_run(35); -- alternative_airports

-- [20] event sequence #1 [multiple_cycles_of_actions]
call magic44_reset_database_state();
set @stepCounter = 400;
call passengers_board('dl_42');
call flight_takeoff('dl_42');
call magic44_query_check_and_run(14); -- person
call magic44_query_check_and_run(21); -- pilot
call magic44_query_check_and_run(15); -- passenger
call magic44_query_check_and_run(20); -- flight

-- for consistency with the initial database state after testing
call magic44_reset_database_state();

-- ----------------------------------------------------------------------------------
-- [6] Collect and analyze the testing results for the student's submission
-- ----------------------------------------------------------------------------------

-- These tables are used to store the answers and test results.  The answers are generated by executing
-- the test script against our reference solution.  The test results are collected by running the test
-- script against your submission in order to compare the results.

-- The results from magic44_data_capture are transferred into the magic44_test_results table
drop table if exists magic44_test_results;
create table magic44_test_results (
	step_id integer not null,
    query_id integer,
	row_hash varchar(2000) not null
);

insert into magic44_test_results
select stepID, queryID, concat_ws('#', ifnull(columndump0, ''), ifnull(columndump1, ''), ifnull(columndump2, ''), ifnull(columndump3, ''),
ifnull(columndump4, ''), ifnull(columndump5, ''), ifnull(columndump6, ''), ifnull(columndump7, ''), ifnull(columndump8, ''), ifnull(columndump9, ''),
ifnull(columndump10, ''), ifnull(columndump11, ''), ifnull(columndump12, ''), ifnull(columndump13, ''), ifnull(columndump14, ''))
from magic44_data_capture;

-- the answers generated from the reference solution are loaded below
drop table if exists magic44_expected_results;
create table magic44_expected_results (
	step_id integer not null,
    query_id integer,
	row_hash varchar(2000) not null,
    index (step_id),
    index (query_id)
);

insert into magic44_expected_results values
(0, 10, 'air_france#29000#############'),
(0, 10, 'american#52000#############'),
(0, 10, 'britishairways#24000#############'),
(0, 10, 'chinasouthernairlines#14000#############'),
(0, 10, 'delta#53000#############'),
(0, 10, 'japanairlines#9000#############'),
(0, 10, 'klm#29000#############'),
(0, 10, 'koreanairlines#10000#############'),
(0, 10, 'lufthansa#35000#############'),
(0, 10, 'ryanair#10000#############'),
(0, 10, 'spirit#200#############'),
(0, 10, 'united#48000#############'),
(0, 11, 'plane_1##############'),
(0, 11, 'plane_10##############'),
(0, 11, 'plane_13##############'),
(0, 11, 'plane_18##############'),
(0, 11, 'plane_2##############'),
(0, 11, 'plane_20##############'),
(0, 11, 'plane_26##############'),
(0, 11, 'plane_27##############'),
(0, 11, 'plane_28##############'),
(0, 11, 'plane_29##############'),
(0, 11, 'plane_3##############'),
(0, 11, 'plane_4##############'),
(0, 11, 'plane_5##############'),
(0, 11, 'plane_6##############'),
(0, 11, 'plane_7##############'),
(0, 11, 'plane_8##############'),
(0, 11, 'port_1##############'),
(0, 11, 'port_10##############'),
(0, 11, 'port_11##############'),
(0, 11, 'port_12##############'),
(0, 11, 'port_13##############'),
(0, 11, 'port_14##############'),
(0, 11, 'port_15##############'),
(0, 11, 'port_16##############'),
(0, 11, 'port_17##############'),
(0, 11, 'port_18##############'),
(0, 11, 'port_2##############'),
(0, 11, 'port_20##############'),
(0, 11, 'port_21##############'),
(0, 11, 'port_22##############'),
(0, 11, 'port_23##############'),
(0, 11, 'port_24##############'),
(0, 11, 'port_25##############'),
(0, 11, 'port_3##############'),
(0, 11, 'port_4##############'),
(0, 11, 'port_6##############'),
(0, 11, 'port_7##############'),
(0, 12, 'air_france#n118fm#4#400##boeing#0#777#######'),
(0, 12, 'air_france#n815pw#3#400##airbus###0######'),
(0, 12, 'air_france#n816pw#3#400#plane_28#airbus###0######'),
(0, 12, 'american#n225sb#8#800##airbus###0######'),
(0, 12, 'american#n448cs#4#400##boeing#1#787#######'),
(0, 12, 'american#n553qn#5#800#plane_2#airbus###0######'),
(0, 12, 'britishairways#n517ly#4#600#plane_7#airbus###0######'),
(0, 12, 'britishairways#n616lt#7#600#plane_6#airbus###0######'),
(0, 12, 'chinasouthernairlines#n249yk#4#400##boeing#0#787#######'),
(0, 12, 'chinasouthernairlines#n454gq#3#400###########'),
(0, 12, 'delta#n106js#4#800#plane_1#airbus###0######'),
(0, 12, 'delta#n110jn#5#800#plane_3#airbus###0######'),
(0, 12, 'delta#n127js#4#600##airbus###1######'),
(0, 12, 'japanairlines#n305fv#6#400#plane_20#airbus###0######'),
(0, 12, 'japanairlines#n443wu#4#800##airbus###1######'),
(0, 12, 'klm#n161fk#4#600#plane_13#airbus###1######'),
(0, 12, 'klm#n256ap#4#300##boeing#0#737#######'),
(0, 12, 'klm#n337as#5#400##airbus###0######'),
(0, 12, 'koreanairlines#n180co#5#600#plane_4#airbus###0######'),
(0, 12, 'koreanairlines#n266f7#12#600#plane_26#airbus###0######'),
(0, 12, 'lufthansa#n401fj#4#300###########'),
(0, 12, 'lufthansa#n620la#4#800#plane_8#airbus###1######'),
(0, 12, 'lufthansa#n653fk#6#600#plane_10#airbus###0######'),
(0, 12, 'ryanair#n156sq#8#600##airbus###0######'),
(0, 12, 'ryanair#n341eb#4#400#plane_18#boeing#1#737#######'),
(0, 12, 'ryanair#n353kz#4#400##boeing#1#737#######'),
(0, 12, 'ryanair#n451fi#5#600##airbus###1######'),
(0, 12, 'spirit#n223gw#3#200#plane_29#airbus###1######'),
(0, 12, 'spirit#n270ff#3#200#plane_27#airbus###1######'),
(0, 12, 'united#n330ss#4#800##airbus###0######'),
(0, 12, 'united#n380sd#5#400#plane_5#airbus###0######'),
(0, 13, 'ams#amsterdamschipolinternational#amsterdam#haarlemmermeer#nld#port_11#########'),
(0, 13, 'atl#atlantahartsfield_jacksoninternational#atlanta#georgia#usa#port_1#########'),
(0, 13, 'bcn#barcelonainternational#barcelona#catalonia#esp#port_15#########'),
(0, 13, 'ber#berlinbrandenburgwillybrandtinternational#berlin#schonefeld#deu#port_23#########'),
(0, 13, 'can#guangzhouinternational#guangzhou#guangdong#chn#port_7#########'),
(0, 13, 'cdg#parischarlesdegaulle#roissy_en_france#paris#fra#port_12#########'),
(0, 13, 'den#denverinternational#denver#colorado#usa##########'),
(0, 13, 'dfw#dallas_fortworthinternational#dallas#texas#usa#port_6#########'),
(0, 13, 'dxb#dubaiinternational#dubai#algarhoud#uae#port_2#########'),
(0, 13, 'fco#romefiumicino#fiumicino#lazio#ita#port_16#########'),
(0, 13, 'fra#frankfurtinternational#frankfurt#frankfurt_rhine_main#deu#port_13#########'),
(0, 13, 'hnd#tokyointernationalhaneda#otacity#tokyo#jpn#port_3#########'),
(0, 13, 'hou#williamp_hobbyinternational#houston#texas#usa#port_21#########'),
(0, 13, 'iah#georgebushintercontinental#houston#texas#usa#port_20#########'),
(0, 13, 'icn#incheoninternationalairport#seoul#jung_gu#kor#port_24#########'),
(0, 13, 'ist#istanbulinternational#arnavutkoy#istanbul#tur##########'),
(0, 13, 'lax#losangelesinternational#losangeles#california#usa##########'),
(0, 13, 'lgw#londongatwick#london#england#gbr#port_17#########'),
(0, 13, 'lhr#londonheathrow#london#england#gbr#port_4#########'),
(0, 13, 'mad#madridadolfosuarez_barajas#madrid#barajas#esp#port_14#########'),
(0, 13, 'mdw#chicagomidwayinternational#chicago#illinois#usa##########'),
(0, 13, 'muc#munichinternational#munich#bavaria#deu#port_18#########'),
(0, 13, 'nrt#naritainternational#narita#chiba#jpn#port_22#########'),
(0, 13, 'ord#o_hareinternational#chicago#illinois#usa#port_10#########'),
(0, 13, 'pvg#shanghaipudonginternationalairport#shanghai#pudong#chn#port_25#########'),
(0, 14, 'p1#jeanne#nelson#port_1###########'),
(0, 14, 'p10#lawrence#morgan#port_3###########'),
(0, 14, 'p11#sandra#cruz#port_3###########'),
(0, 14, 'p12#dan#ball#port_3###########'),
(0, 14, 'p13#bryant#figueroa#port_3###########'),
(0, 14, 'p14#dana#perry#port_3###########'),
(0, 14, 'p15#matt#hunt#port_10###########'),
(0, 14, 'p16#edna#brown#port_10###########'),
(0, 14, 'p17#ruby#burgess#plane_3###########'),
(0, 14, 'p18#esther#pittman#plane_10###########'),
(0, 14, 'p19#doug#fowler#port_23###########'),
(0, 14, 'p2#roxanne#byrd#port_1###########'),
(0, 14, 'p20#thomas#olson#port_4###########'),
(0, 14, 'p21#mona#harrison#plane_1###########'),
(0, 14, 'p22#arlene#massey#plane_1###########'),
(0, 14, 'p23#judith#patrick#plane_1###########'),
(0, 14, 'p24#reginald#rhodes#plane_5###########'),
(0, 14, 'p25#vincent#garcia#plane_5###########'),
(0, 14, 'p26#cheryl#moore#plane_5###########'),
(0, 14, 'p27#michael#rivera#plane_8###########'),
(0, 14, 'p28#luther#matthews#plane_8###########'),
(0, 14, 'p29#moses#parks#plane_13###########'),
(0, 14, 'p3#tanya#nguyen#port_1###########'),
(0, 14, 'p30#ora#steele#plane_13###########'),
(0, 14, 'p31#antonio#flores#plane_13###########'),
(0, 14, 'p32#glenn#ross#plane_13###########'),
(0, 14, 'p33#irma#thomas#plane_20###########'),
(0, 14, 'p34#ann#maldonado#plane_20###########'),
(0, 14, 'p35#jeffrey#cruz#port_12###########'),
(0, 14, 'p36#sonya#price#port_12###########'),
(0, 14, 'p37#tracy#hale#port_12###########'),
(0, 14, 'p38#albert#simmons#port_14###########'),
(0, 14, 'p39#karen#terry#port_15###########'),
(0, 14, 'p4#kendra#jacobs#port_1###########'),
(0, 14, 'p40#glen#kelley#port_20###########'),
(0, 14, 'p41#brooke#little#port_3###########'),
(0, 14, 'p42#daryl#nguyen#port_4###########'),
(0, 14, 'p43#judy#willis#port_14###########'),
(0, 14, 'p44#marco#klein#port_15###########'),
(0, 14, 'p45#angelica#hampton#port_16###########'),
(0, 14, 'p46#janice#white#plane_10###########'),
(0, 14, 'p47#charlie#brown#port_6###########'),
(0, 14, 'p48#charles#schulz#plane_4###########'),
(0, 14, 'p49#beyonce##port_20###########'),
(0, 14, 'p5#jeff#burton#port_1###########'),
(0, 14, 'p50#jackie#sullivan#plane_27###########'),
(0, 14, 'p51#alayah#colon#plane_1###########'),
(0, 14, 'p52#bruce#walter#plane_8###########'),
(0, 14, 'p53#penny#baldwin#plane_20###########'),
(0, 14, 'p54#jaiden#alvarado#plane_5###########'),
(0, 14, 'p55#blake#velazquez#plane_13###########'),
(0, 14, 'p56#archer#thomas#plane_28###########'),
(0, 14, 'p6#randal#parks#port_1###########'),
(0, 14, 'p7#sonya#owens#port_2###########'),
(0, 14, 'p8#bennie#palmer#port_2###########'),
(0, 14, 'p9#marlene#warner#port_3###########'),
(0, 15, 'p21#771#700############'),
(0, 15, 'p22#374#200############'),
(0, 15, 'p23#414#400############'),
(0, 15, 'p24#292#500############'),
(0, 15, 'p25#390#300############'),
(0, 15, 'p26#302#600############'),
(0, 15, 'p27#470#400############'),
(0, 15, 'p28#208#400############'),
(0, 15, 'p29#292#700############'),
(0, 15, 'p30#686#500############'),
(0, 15, 'p31#547#400############'),
(0, 15, 'p32#257#500############'),
(0, 15, 'p33#564#600############'),
(0, 15, 'p34#211#200############'),
(0, 15, 'p35#233#500############'),
(0, 15, 'p36#293#400############'),
(0, 15, 'p37#552#700############'),
(0, 15, 'p38#812#700############'),
(0, 15, 'p39#541#400############'),
(0, 15, 'p40#441#700############'),
(0, 15, 'p41#875#300############'),
(0, 15, 'p42#691#500############'),
(0, 15, 'p43#572#300############'),
(0, 15, 'p44#572#500############'),
(0, 15, 'p45#663#500############'),
(0, 15, 'p46#690#5000############'),
(0, 15, 'p47#230#5000############'),
(0, 15, 'p49#5000#67297############'),
(0, 16, 'p21#ams#1############'),
(0, 16, 'p22#ams#1############'),
(0, 16, 'p23#ber#1############'),
(0, 16, 'p27#ber#1############'),
(0, 16, 'p33#can#1############'),
(0, 16, 'p24#cdg#2############'),
(0, 16, 'p37#cdg#3############'),
(0, 16, 'p29#fco#1############'),
(0, 16, 'p30#fco#1############'),
(0, 16, 'p31#fco#1############'),
(0, 16, 'p32#fco#1############'),
(0, 16, 'p36#fco#1############'),
(0, 16, 'p37#fco#1############'),
(0, 16, 'p34#hnd#1############'),
(0, 16, 'p40#hnd#1############'),
(0, 16, 'p49#hou#1############'),
(0, 16, 'p47#iah#1############'),
(0, 16, 'p28#lgw#1############'),
(0, 16, 'p35#lgw#1############'),
(0, 16, 'p37#lgw#2############'),
(0, 16, 'p46#lgw#1############'),
(0, 16, 'p29#lhr#2############'),
(0, 16, 'p30#mad#2############'),
(0, 16, 'p24#muc#1############'),
(0, 16, 'p25#muc#1############'),
(0, 16, 'p26#muc#1############'),
(0, 16, 'p38#muc#1############'),
(0, 16, 'p39#muc#1############'),
(0, 17, 'leg_1#ams#ber#400###########'),
(0, 17, 'leg_10#can#hnd#1600###########'),
(0, 17, 'leg_11#cdg#bcn#500###########'),
(0, 17, 'leg_12#cdg#fco#600###########'),
(0, 17, 'leg_13#cdg#lhr#200###########'),
(0, 17, 'leg_14#cdg#muc#400###########'),
(0, 17, 'leg_15#dfw#iah#200###########'),
(0, 17, 'leg_16#fco#mad#800###########'),
(0, 17, 'leg_17#fra#ber#300###########'),
(0, 17, 'leg_18#hnd#nrt#100###########'),
(0, 17, 'leg_19#hou#dfw#300###########'),
(0, 17, 'leg_2#atl#ams#3900###########'),
(0, 17, 'leg_20#iah#hou#100###########'),
(0, 17, 'leg_21#lgw#ber#600###########'),
(0, 17, 'leg_22#lhr#ber#600###########'),
(0, 17, 'leg_23#lhr#muc#500###########'),
(0, 17, 'leg_24#mad#bcn#300###########'),
(0, 17, 'leg_25#mad#cdg#600###########'),
(0, 17, 'leg_26#mad#fco#800###########'),
(0, 17, 'leg_27#muc#ber#300###########'),
(0, 17, 'leg_28#muc#cdg#400###########'),
(0, 17, 'leg_29#muc#fco#400###########'),
(0, 17, 'leg_3#atl#lhr#3700###########'),
(0, 17, 'leg_30#muc#fra#200###########'),
(0, 17, 'leg_31#ord#cdg#3700###########'),
(0, 17, 'leg_32#dfw#icn#6800###########'),
(0, 17, 'leg_33#icn#lhr#4400###########'),
(0, 17, 'leg_34#icn#lax#5900###########'),
(0, 17, 'leg_35#cdg#ord#3700###########'),
(0, 17, 'leg_36#nrt#hnd#100###########'),
(0, 17, 'leg_37#pvg#icn#500###########'),
(0, 17, 'leg_38#lax#pvg#6500###########'),
(0, 17, 'leg_4#atl#ord#600###########'),
(0, 17, 'leg_5#bcn#cdg#500###########'),
(0, 17, 'leg_6#bcn#mad#300###########'),
(0, 17, 'leg_7#ber#can#4700###########'),
(0, 17, 'leg_8#ber#lgw#600###########'),
(0, 17, 'leg_9#ber#muc#300###########'),
(0, 18, 'americas_hub_exchange##############'),
(0, 18, 'americas_one##############'),
(0, 18, 'americas_three##############'),
(0, 18, 'americas_two##############'),
(0, 18, 'big_europe_loop##############'),
(0, 18, 'euro_north##############'),
(0, 18, 'euro_south##############'),
(0, 18, 'germany_local##############'),
(0, 18, 'korea_direct##############'),
(0, 18, 'pacific_rim_tour##############'),
(0, 18, 'south_euro_loop##############'),
(0, 18, 'texas_local##############'),
(0, 19, 'americas_one#leg_1#2############'),
(0, 19, 'pacific_rim_tour#leg_10#2############'),
(0, 19, 'euro_south#leg_11#4############'),
(0, 19, 'south_euro_loop#leg_12#4############'),
(0, 19, 'big_europe_loop#leg_13#5############'),
(0, 19, 'americas_three#leg_14#2############'),
(0, 19, 'euro_north#leg_14#4############'),
(0, 19, 'texas_local#leg_15#1############'),
(0, 19, 'big_europe_loop#leg_16#3############'),
(0, 19, 'euro_north#leg_16#1############'),
(0, 19, 'south_euro_loop#leg_16#1############'),
(0, 19, 'germany_local#leg_17#3############'),
(0, 19, 'pacific_rim_tour#leg_18#3############'),
(0, 19, 'texas_local#leg_19#3############'),
(0, 19, 'americas_one#leg_2#1############'),
(0, 19, 'texas_local#leg_20#2############'),
(0, 19, 'euro_south#leg_21#1############'),
(0, 19, 'americas_two#leg_22#2############'),
(0, 19, 'big_europe_loop#leg_23#1############'),
(0, 19, 'euro_north#leg_24#2############'),
(0, 19, 'south_euro_loop#leg_24#2############'),
(0, 19, 'big_europe_loop#leg_25#4############'),
(0, 19, 'euro_south#leg_26#6############'),
(0, 19, 'euro_north#leg_27#5############'),
(0, 19, 'euro_south#leg_28#3############'),
(0, 19, 'big_europe_loop#leg_29#2############'),
(0, 19, 'americas_two#leg_3#1############'),
(0, 19, 'germany_local#leg_30#2############'),
(0, 19, 'americas_three#leg_31#1############'),
(0, 19, 'korea_direct#leg_32#1############'),
(0, 19, 'americas_hub_exchange#leg_4#1############'),
(0, 19, 'euro_north#leg_5#3############'),
(0, 19, 'south_euro_loop#leg_5#3############'),
(0, 19, 'euro_south#leg_6#5############'),
(0, 19, 'pacific_rim_tour#leg_7#1############'),
(0, 19, 'euro_north#leg_8#6############'),
(0, 19, 'euro_south#leg_9#2############'),
(0, 19, 'germany_local#leg_9#1############'),
(0, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(0, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(0, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(0, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(0, 20, 'dl_10#americas_one#delta#n106js#1#in_flight#08:00:00#200#######'),
(0, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(0, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(0, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(0, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(0, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(0, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(0, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(0, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(0, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(0, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(0, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(0, 21, 'p1#330-12-6907#31#dl_10###########'),
(0, 21, 'p10#769-60-1266#15#lf_20###########'),
(0, 21, 'p11#369-22-9505#22#km_16###########'),
(0, 21, 'p12#680-92-5329#24#ry_34###########'),
(0, 21, 'p13#513-40-4168#24#km_16###########'),
(0, 21, 'p14#454-71-7847#13#km_16###########'),
(0, 21, 'p15#153-47-8101#30#ja_35###########'),
(0, 21, 'p16#598-47-5172#28#ja_35###########'),
(0, 21, 'p17#865-71-6800#36#dl_42###########'),
(0, 21, 'p18#250-86-2784#23#lf_67###########'),
(0, 21, 'p19#386-39-7881#2############'),
(0, 21, 'p2#842-88-1257#9#dl_10###########'),
(0, 21, 'p20#522-44-3098#28############'),
(0, 21, 'p3#750-24-7616#11#un_38###########'),
(0, 21, 'p4#776-21-8098#24#un_38###########'),
(0, 21, 'p48#999-01-1369#93#ke_64###########'),
(0, 21, 'p5#933-93-2165#27#ba_61###########'),
(0, 21, 'p50#937-82-7342#40#nk_98###########'),
(0, 21, 'p51#123-45-6789#12#dl_10###########'),
(0, 21, 'p52#987-65-4321#78#lf_20###########'),
(0, 21, 'p53#333-44-5555#82#ja_35###########'),
(0, 21, 'p54#333-22-4444#24#un_38###########'),
(0, 21, 'p55#999-55-4567#23#km_16###########'),
(0, 21, 'p56#979-55-4567#31#af_19###########'),
(0, 21, 'p6#707-84-4555#38#ba_61###########'),
(0, 21, 'p7#450-25-5617#13#lf_20###########'),
(0, 21, 'p8#701-38-2179#12#ry_34###########'),
(0, 21, 'p9#936-44-6941#13#lf_20###########'),
(0, 22, 'p1#airbus#############'),
(0, 22, 'p10#airbus#############'),
(0, 22, 'p11#airbus#############'),
(0, 22, 'p11#boeing#############'),
(0, 22, 'p12#boeing#############'),
(0, 22, 'p13#airbus#############'),
(0, 22, 'p14#airbus#############'),
(0, 22, 'p15#airbus#############'),
(0, 22, 'p15#boeing#############'),
(0, 22, 'p15#general#############'),
(0, 22, 'p16#airbus#############'),
(0, 22, 'p17#airbus#############'),
(0, 22, 'p17#boeing#############'),
(0, 22, 'p18#airbus#############'),
(0, 22, 'p19#airbus#############'),
(0, 22, 'p19#boeing#############'),
(0, 22, 'p2#airbus#############'),
(0, 22, 'p2#boeing#############'),
(0, 22, 'p20#airbus#############'),
(0, 22, 'p3#airbus#############'),
(0, 22, 'p4#airbus#############'),
(0, 22, 'p4#boeing#############'),
(0, 22, 'p48#airbus#############'),
(0, 22, 'p5#airbus#############'),
(0, 22, 'p50#airbus#############'),
(0, 22, 'p51#airbus#############'),
(0, 22, 'p52#airbus#############'),
(0, 22, 'p53#airbus#############'),
(0, 22, 'p54#airbus#############'),
(0, 22, 'p55#airbus#############'),
(0, 22, 'p56#airbus#############'),
(0, 22, 'p6#airbus#############'),
(0, 22, 'p6#boeing#############'),
(0, 22, 'p7#airbus#############'),
(0, 22, 'p8#boeing#############'),
(0, 22, 'p9#airbus#############'),
(0, 22, 'p9#boeing#############'),
(0, 22, 'p9#general#############'),
(20, 12, 'air_france#n118fm#4#400##boeing#0#777#######'),
(20, 12, 'air_france#n815pw#3#400##airbus###0######'),
(20, 12, 'air_france#n816pw#3#400#plane_28#airbus###0######'),
(20, 12, 'american#n225sb#8#800##airbus###0######'),
(20, 12, 'american#n448cs#4#400##boeing#1#787#######'),
(20, 12, 'american#n553qn#5#800#plane_2#airbus###0######'),
(20, 12, 'britishairways#n517ly#4#600#plane_7#airbus###0######'),
(20, 12, 'britishairways#n616lt#7#600#plane_6#airbus###0######'),
(20, 12, 'chinasouthernairlines#n249yk#4#400##boeing#0#787#######'),
(20, 12, 'chinasouthernairlines#n454gq#3#400###########'),
(20, 12, 'delta#n106js#4#800#plane_1#airbus###0######'),
(20, 12, 'delta#n110jn#5#800#plane_3#airbus###0######'),
(20, 12, 'delta#n127js#4#600##airbus###1######'),
(20, 12, 'delta#n281fc#6#500#plane_41#airbus###1######'),
(20, 12, 'japanairlines#n305fv#6#400#plane_20#airbus###0######'),
(20, 12, 'japanairlines#n443wu#4#800##airbus###1######'),
(20, 12, 'klm#n161fk#4#600#plane_13#airbus###1######'),
(20, 12, 'klm#n256ap#4#300##boeing#0#737#######'),
(20, 12, 'klm#n337as#5#400##airbus###0######'),
(20, 12, 'koreanairlines#n180co#5#600#plane_4#airbus###0######'),
(20, 12, 'koreanairlines#n266f7#12#600#plane_26#airbus###0######'),
(20, 12, 'lufthansa#n401fj#4#300###########'),
(20, 12, 'lufthansa#n620la#4#800#plane_8#airbus###1######'),
(20, 12, 'lufthansa#n653fk#6#600#plane_10#airbus###0######'),
(20, 12, 'ryanair#n156sq#8#600##airbus###0######'),
(20, 12, 'ryanair#n341eb#4#400#plane_18#boeing#1#737#######'),
(20, 12, 'ryanair#n353kz#4#400##boeing#1#737#######'),
(20, 12, 'ryanair#n451fi#5#600##airbus###1######'),
(20, 12, 'spirit#n223gw#3#200#plane_29#airbus###1######'),
(20, 12, 'spirit#n270ff#3#200#plane_27#airbus###1######'),
(20, 12, 'united#n330ss#4#800##airbus###0######'),
(20, 12, 'united#n380sd#5#400#plane_5#airbus###0######'),
(40, 13, 'ams#amsterdamschipolinternational#amsterdam#haarlemmermeer#nld#port_11#########'),
(40, 13, 'atl#atlantahartsfield_jacksoninternational#atlanta#georgia#usa#port_1#########'),
(40, 13, 'bcn#barcelonainternational#barcelona#catalonia#esp#port_15#########'),
(40, 13, 'ber#berlinbrandenburgwillybrandtinternational#berlin#schonefeld#deu#port_23#########'),
(40, 13, 'can#guangzhouinternational#guangzhou#guangdong#chn#port_7#########'),
(40, 13, 'cdg#parischarlesdegaulle#roissy_en_france#paris#fra#port_12#########'),
(40, 13, 'den#denverinternational#denver#colorado#usa##########'),
(40, 13, 'dfw#dallas_fortworthinternational#dallas#texas#usa#port_6#########'),
(40, 13, 'dxb#dubaiinternational#dubai#algarhoud#uae#port_2#########'),
(40, 13, 'fco#romefiumicino#fiumicino#lazio#ita#port_16#########'),
(40, 13, 'fra#frankfurtinternational#frankfurt#frankfurt_rhine_main#deu#port_13#########'),
(40, 13, 'hnd#tokyointernationalhaneda#otacity#tokyo#jpn#port_3#########'),
(40, 13, 'hou#williamp_hobbyinternational#houston#texas#usa#port_21#########'),
(40, 13, 'iah#georgebushintercontinental#houston#texas#usa#port_20#########'),
(40, 13, 'icn#incheoninternationalairport#seoul#jung_gu#kor#port_24#########'),
(40, 13, 'ist#istanbulinternational#arnavutkoy#istanbul#tur##########'),
(40, 13, 'jfk#johnf_kennedyinternational#newyork#newyork#usa#port_33#########'),
(40, 13, 'lax#losangelesinternational#losangeles#california#usa##########'),
(40, 13, 'lgw#londongatwick#london#england#gbr#port_17#########'),
(40, 13, 'lhr#londonheathrow#london#england#gbr#port_4#########'),
(40, 13, 'mad#madridadolfosuarez_barajas#madrid#barajas#esp#port_14#########'),
(40, 13, 'mdw#chicagomidwayinternational#chicago#illinois#usa##########'),
(40, 13, 'muc#munichinternational#munich#bavaria#deu#port_18#########'),
(40, 13, 'nrt#naritainternational#narita#chiba#jpn#port_22#########'),
(40, 13, 'ord#o_hareinternational#chicago#illinois#usa#port_10#########'),
(40, 13, 'pvg#shanghaipudonginternationalairport#shanghai#pudong#chn#port_25#########'),
(60, 14, 'p1#jeanne#nelson#port_1###########'),
(60, 14, 'p10#lawrence#morgan#port_3###########'),
(60, 14, 'p11#sandra#cruz#port_3###########'),
(60, 14, 'p12#dan#ball#port_3###########'),
(60, 14, 'p13#bryant#figueroa#port_3###########'),
(60, 14, 'p14#dana#perry#port_3###########'),
(60, 14, 'p15#matt#hunt#port_10###########'),
(60, 14, 'p16#edna#brown#port_10###########'),
(60, 14, 'p17#ruby#burgess#plane_3###########'),
(60, 14, 'p18#esther#pittman#plane_10###########'),
(60, 14, 'p19#doug#fowler#port_23###########'),
(60, 14, 'p2#roxanne#byrd#port_1###########'),
(60, 14, 'p20#thomas#olson#port_4###########'),
(60, 14, 'p21#mona#harrison#plane_1###########'),
(60, 14, 'p22#arlene#massey#plane_1###########'),
(60, 14, 'p23#judith#patrick#plane_1###########'),
(60, 14, 'p24#reginald#rhodes#plane_5###########'),
(60, 14, 'p25#vincent#garcia#plane_5###########'),
(60, 14, 'p26#cheryl#moore#plane_5###########'),
(60, 14, 'p27#michael#rivera#plane_8###########'),
(60, 14, 'p28#luther#matthews#plane_8###########'),
(60, 14, 'p29#moses#parks#plane_13###########'),
(60, 14, 'p3#tanya#nguyen#port_1###########'),
(60, 14, 'p30#ora#steele#plane_13###########'),
(60, 14, 'p31#antonio#flores#plane_13###########'),
(60, 14, 'p32#glenn#ross#plane_13###########'),
(60, 14, 'p33#irma#thomas#plane_20###########'),
(60, 14, 'p34#ann#maldonado#plane_20###########'),
(60, 14, 'p35#jeffrey#cruz#port_12###########'),
(60, 14, 'p36#sonya#price#port_12###########'),
(60, 14, 'p37#tracy#hale#port_12###########'),
(60, 14, 'p38#albert#simmons#port_14###########'),
(60, 14, 'p39#karen#terry#port_15###########'),
(60, 14, 'p4#kendra#jacobs#port_1###########'),
(60, 14, 'p40#glen#kelley#port_20###########'),
(60, 14, 'p41#brooke#little#port_3###########'),
(60, 14, 'p42#daryl#nguyen#port_4###########'),
(60, 14, 'p43#judy#willis#port_14###########'),
(60, 14, 'p44#marco#klein#port_15###########'),
(60, 14, 'p45#angelica#hampton#port_16###########'),
(60, 14, 'p46#janice#white#plane_10###########'),
(60, 14, 'p47#charlie#brown#port_6###########'),
(60, 14, 'p48#charles#schulz#plane_4###########'),
(60, 14, 'p49#beyonce##port_20###########'),
(60, 14, 'p5#jeff#burton#port_1###########'),
(60, 14, 'p50#jackie#sullivan#plane_27###########'),
(60, 14, 'p51#alayah#colon#plane_1###########'),
(60, 14, 'p52#bruce#walter#plane_8###########'),
(60, 14, 'p53#penny#baldwin#plane_20###########'),
(60, 14, 'p54#jaiden#alvarado#plane_5###########'),
(60, 14, 'p55#blake#velazquez#plane_13###########'),
(60, 14, 'p56#archer#thomas#plane_28###########'),
(60, 14, 'p6#randal#parks#port_1###########'),
(60, 14, 'p61#sabrina#duncan#port_1###########'),
(60, 14, 'p7#sonya#owens#port_2###########'),
(60, 14, 'p8#bennie#palmer#port_2###########'),
(60, 14, 'p9#marlene#warner#port_3###########'),
(60, 21, 'p1#330-12-6907#31#dl_10###########'),
(60, 21, 'p10#769-60-1266#15#lf_20###########'),
(60, 21, 'p11#369-22-9505#22#km_16###########'),
(60, 21, 'p12#680-92-5329#24#ry_34###########'),
(60, 21, 'p13#513-40-4168#24#km_16###########'),
(60, 21, 'p14#454-71-7847#13#km_16###########'),
(60, 21, 'p15#153-47-8101#30#ja_35###########'),
(60, 21, 'p16#598-47-5172#28#ja_35###########'),
(60, 21, 'p17#865-71-6800#36#dl_42###########'),
(60, 21, 'p18#250-86-2784#23#lf_67###########'),
(60, 21, 'p19#386-39-7881#2############'),
(60, 21, 'p2#842-88-1257#9#dl_10###########'),
(60, 21, 'p20#522-44-3098#28############'),
(60, 21, 'p3#750-24-7616#11#un_38###########'),
(60, 21, 'p4#776-21-8098#24#un_38###########'),
(60, 21, 'p48#999-01-1369#93#ke_64###########'),
(60, 21, 'p5#933-93-2165#27#ba_61###########'),
(60, 21, 'p50#937-82-7342#40#nk_98###########'),
(60, 21, 'p51#123-45-6789#12#dl_10###########'),
(60, 21, 'p52#987-65-4321#78#lf_20###########'),
(60, 21, 'p53#333-44-5555#82#ja_35###########'),
(60, 21, 'p54#333-22-4444#24#un_38###########'),
(60, 21, 'p55#999-55-4567#23#km_16###########'),
(60, 21, 'p56#979-55-4567#31#af_19###########'),
(60, 21, 'p6#707-84-4555#38#ba_61###########'),
(60, 21, 'p61#366-50-3732#27############'),
(60, 21, 'p7#450-25-5617#13#lf_20###########'),
(60, 21, 'p8#701-38-2179#12#ry_34###########'),
(60, 21, 'p9#936-44-6941#13#lf_20###########'),
(60, 15, 'p21#771#700############'),
(60, 15, 'p22#374#200############'),
(60, 15, 'p23#414#400############'),
(60, 15, 'p24#292#500############'),
(60, 15, 'p25#390#300############'),
(60, 15, 'p26#302#600############'),
(60, 15, 'p27#470#400############'),
(60, 15, 'p28#208#400############'),
(60, 15, 'p29#292#700############'),
(60, 15, 'p30#686#500############'),
(60, 15, 'p31#547#400############'),
(60, 15, 'p32#257#500############'),
(60, 15, 'p33#564#600############'),
(60, 15, 'p34#211#200############'),
(60, 15, 'p35#233#500############'),
(60, 15, 'p36#293#400############'),
(60, 15, 'p37#552#700############'),
(60, 15, 'p38#812#700############'),
(60, 15, 'p39#541#400############'),
(60, 15, 'p40#441#700############'),
(60, 15, 'p41#875#300############'),
(60, 15, 'p42#691#500############'),
(60, 15, 'p43#572#300############'),
(60, 15, 'p44#572#500############'),
(60, 15, 'p45#663#500############'),
(60, 15, 'p46#690#5000############'),
(60, 15, 'p47#230#5000############'),
(60, 15, 'p49#5000#67297############'),
(80, 22, 'p1#airbus#############'),
(80, 22, 'p1#jets#############'),
(80, 22, 'p10#airbus#############'),
(80, 22, 'p11#airbus#############'),
(80, 22, 'p11#boeing#############'),
(80, 22, 'p12#boeing#############'),
(80, 22, 'p13#airbus#############'),
(80, 22, 'p14#airbus#############'),
(80, 22, 'p15#airbus#############'),
(80, 22, 'p15#boeing#############'),
(80, 22, 'p15#general#############'),
(80, 22, 'p16#airbus#############'),
(80, 22, 'p17#airbus#############'),
(80, 22, 'p17#boeing#############'),
(80, 22, 'p18#airbus#############'),
(80, 22, 'p19#airbus#############'),
(80, 22, 'p19#boeing#############'),
(80, 22, 'p2#airbus#############'),
(80, 22, 'p2#boeing#############'),
(80, 22, 'p20#airbus#############'),
(80, 22, 'p3#airbus#############'),
(80, 22, 'p4#airbus#############'),
(80, 22, 'p4#boeing#############'),
(80, 22, 'p48#airbus#############'),
(80, 22, 'p5#airbus#############'),
(80, 22, 'p50#airbus#############'),
(80, 22, 'p51#airbus#############'),
(80, 22, 'p52#airbus#############'),
(80, 22, 'p53#airbus#############'),
(80, 22, 'p54#airbus#############'),
(80, 22, 'p55#airbus#############'),
(80, 22, 'p56#airbus#############'),
(80, 22, 'p6#airbus#############'),
(80, 22, 'p6#boeing#############'),
(80, 22, 'p7#airbus#############'),
(80, 22, 'p8#boeing#############'),
(80, 22, 'p9#airbus#############'),
(80, 22, 'p9#boeing#############'),
(80, 22, 'p9#general#############'),
(100, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(100, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(100, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(100, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(100, 20, 'dl_10#americas_one#delta#n106js#1#in_flight#08:00:00#200#######'),
(100, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(100, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(100, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(100, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(100, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(100, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(100, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(100, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(100, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(100, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(100, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(100, 20, 'un_41#americas_three#united#n330ss#0#on_ground#11:30:00#400#######'),
(120, 21, 'p1#330-12-6907#32#dl_10###########'),
(120, 21, 'p10#769-60-1266#15#lf_20###########'),
(120, 21, 'p11#369-22-9505#22#km_16###########'),
(120, 21, 'p12#680-92-5329#24#ry_34###########'),
(120, 21, 'p13#513-40-4168#24#km_16###########'),
(120, 21, 'p14#454-71-7847#13#km_16###########'),
(120, 21, 'p15#153-47-8101#30#ja_35###########'),
(120, 21, 'p16#598-47-5172#28#ja_35###########'),
(120, 21, 'p17#865-71-6800#36#dl_42###########'),
(120, 21, 'p18#250-86-2784#23#lf_67###########'),
(120, 21, 'p19#386-39-7881#2############'),
(120, 21, 'p2#842-88-1257#10#dl_10###########'),
(120, 21, 'p20#522-44-3098#28############'),
(120, 21, 'p3#750-24-7616#11#un_38###########'),
(120, 21, 'p4#776-21-8098#24#un_38###########'),
(120, 21, 'p48#999-01-1369#93#ke_64###########'),
(120, 21, 'p5#933-93-2165#27#ba_61###########'),
(120, 21, 'p50#937-82-7342#40#nk_98###########'),
(120, 21, 'p51#123-45-6789#13#dl_10###########'),
(120, 21, 'p52#987-65-4321#78#lf_20###########'),
(120, 21, 'p53#333-44-5555#82#ja_35###########'),
(120, 21, 'p54#333-22-4444#24#un_38###########'),
(120, 21, 'p55#999-55-4567#23#km_16###########'),
(120, 21, 'p56#979-55-4567#31#af_19###########'),
(120, 21, 'p6#707-84-4555#38#ba_61###########'),
(120, 21, 'p7#450-25-5617#13#lf_20###########'),
(120, 21, 'p8#701-38-2179#12#ry_34###########'),
(120, 21, 'p9#936-44-6941#13#lf_20###########'),
(120, 15, 'p21#4671#700############'),
(120, 15, 'p22#4274#200############'),
(120, 15, 'p23#4314#400############'),
(120, 15, 'p24#292#500############'),
(120, 15, 'p25#390#300############'),
(120, 15, 'p26#302#600############'),
(120, 15, 'p27#470#400############'),
(120, 15, 'p28#208#400############'),
(120, 15, 'p29#292#700############'),
(120, 15, 'p30#686#500############'),
(120, 15, 'p31#547#400############'),
(120, 15, 'p32#257#500############'),
(120, 15, 'p33#564#600############'),
(120, 15, 'p34#211#200############'),
(120, 15, 'p35#233#500############'),
(120, 15, 'p36#293#400############'),
(120, 15, 'p37#552#700############'),
(120, 15, 'p38#812#700############'),
(120, 15, 'p39#541#400############'),
(120, 15, 'p40#441#700############'),
(120, 15, 'p41#875#300############'),
(120, 15, 'p42#691#500############'),
(120, 15, 'p43#572#300############'),
(120, 15, 'p44#572#500############'),
(120, 15, 'p45#663#500############'),
(120, 15, 'p46#690#5000############'),
(120, 15, 'p47#230#5000############'),
(120, 15, 'p49#5000#67297############'),
(120, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(120, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(120, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(120, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(120, 20, 'dl_10#americas_one#delta#n106js#1#on_ground#09:00:00#200#######'),
(120, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(120, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(120, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(120, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(120, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(120, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(120, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(120, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(120, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(120, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(120, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(121, 21, 'p1#330-12-6907#31#dl_10###########'),
(121, 21, 'p10#769-60-1266#15#lf_20###########'),
(121, 21, 'p11#369-22-9505#22#km_16###########'),
(121, 21, 'p12#680-92-5329#24#ry_34###########'),
(121, 21, 'p13#513-40-4168#24#km_16###########'),
(121, 21, 'p14#454-71-7847#13#km_16###########'),
(121, 21, 'p15#153-47-8101#30#ja_35###########'),
(121, 21, 'p16#598-47-5172#28#ja_35###########'),
(121, 21, 'p17#865-71-6800#36#dl_42###########'),
(121, 21, 'p18#250-86-2784#23#lf_67###########'),
(121, 21, 'p19#386-39-7881#2############'),
(121, 21, 'p2#842-88-1257#9#dl_10###########'),
(121, 21, 'p20#522-44-3098#28############'),
(121, 21, 'p3#750-24-7616#11#un_38###########'),
(121, 21, 'p4#776-21-8098#24#un_38###########'),
(121, 21, 'p48#999-01-1369#93#ke_64###########'),
(121, 21, 'p5#933-93-2165#27#ba_61###########'),
(121, 21, 'p50#937-82-7342#40#nk_98###########'),
(121, 21, 'p51#123-45-6789#12#dl_10###########'),
(121, 21, 'p52#987-65-4321#78#lf_20###########'),
(121, 21, 'p53#333-44-5555#82#ja_35###########'),
(121, 21, 'p54#333-22-4444#24#un_38###########'),
(121, 21, 'p55#999-55-4567#23#km_16###########'),
(121, 21, 'p56#979-55-4567#31#af_19###########'),
(121, 21, 'p6#707-84-4555#38#ba_61###########'),
(121, 21, 'p7#450-25-5617#13#lf_20###########'),
(121, 21, 'p8#701-38-2179#12#ry_34###########'),
(121, 21, 'p9#936-44-6941#13#lf_20###########'),
(121, 15, 'p21#771#700############'),
(121, 15, 'p22#374#200############'),
(121, 15, 'p23#414#400############'),
(121, 15, 'p24#292#500############'),
(121, 15, 'p25#390#300############'),
(121, 15, 'p26#302#600############'),
(121, 15, 'p27#470#400############'),
(121, 15, 'p28#208#400############'),
(121, 15, 'p29#292#700############'),
(121, 15, 'p30#686#500############'),
(121, 15, 'p31#547#400############'),
(121, 15, 'p32#257#500############'),
(121, 15, 'p33#564#600############'),
(121, 15, 'p34#211#200############'),
(121, 15, 'p35#233#500############'),
(121, 15, 'p36#293#400############'),
(121, 15, 'p37#552#700############'),
(121, 15, 'p38#812#700############'),
(121, 15, 'p39#541#400############'),
(121, 15, 'p40#441#700############'),
(121, 15, 'p41#875#300############'),
(121, 15, 'p42#691#500############'),
(121, 15, 'p43#572#300############'),
(121, 15, 'p44#572#500############'),
(121, 15, 'p45#663#500############'),
(121, 15, 'p46#690#5000############'),
(121, 15, 'p47#230#5000############'),
(121, 15, 'p49#5000#67297############'),
(121, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(121, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(121, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(121, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(121, 20, 'dl_10#americas_one#delta#n106js#1#in_flight#08:00:00#200#######'),
(121, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(121, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(121, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(121, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(121, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(121, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(121, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(121, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(121, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(121, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(121, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(140, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(140, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(140, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(140, 20, 'ba_61#americas_two#britishairways#n616lt#1#in_flight#15:40:00#200#######'),
(140, 20, 'dl_10#americas_one#delta#n106js#1#in_flight#08:00:00#200#######'),
(140, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(140, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(140, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(140, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(140, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(140, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(140, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(140, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(140, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(140, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(140, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(141, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(141, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(141, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(141, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(141, 20, 'dl_10#americas_one#delta#n106js#1#in_flight#08:00:00#200#######'),
(141, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(141, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(141, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(141, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(141, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(141, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(141, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(141, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(141, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(141, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(141, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(160, 14, 'p1#jeanne#nelson#port_1###########'),
(160, 14, 'p10#lawrence#morgan#port_3###########'),
(160, 14, 'p11#sandra#cruz#port_3###########'),
(160, 14, 'p12#dan#ball#port_3###########'),
(160, 14, 'p13#bryant#figueroa#port_3###########'),
(160, 14, 'p14#dana#perry#port_3###########'),
(160, 14, 'p15#matt#hunt#port_10###########'),
(160, 14, 'p16#edna#brown#port_10###########'),
(160, 14, 'p17#ruby#burgess#plane_3###########'),
(160, 14, 'p18#esther#pittman#plane_10###########'),
(160, 14, 'p19#doug#fowler#port_23###########'),
(160, 14, 'p2#roxanne#byrd#port_1###########'),
(160, 14, 'p20#thomas#olson#port_4###########'),
(160, 14, 'p21#mona#harrison#plane_1###########'),
(160, 14, 'p22#arlene#massey#plane_1###########'),
(160, 14, 'p23#judith#patrick#plane_1###########'),
(160, 14, 'p24#reginald#rhodes#plane_5###########'),
(160, 14, 'p25#vincent#garcia#plane_5###########'),
(160, 14, 'p26#cheryl#moore#plane_5###########'),
(160, 14, 'p27#michael#rivera#plane_8###########'),
(160, 14, 'p28#luther#matthews#plane_8###########'),
(160, 14, 'p29#moses#parks#plane_13###########'),
(160, 14, 'p3#tanya#nguyen#port_1###########'),
(160, 14, 'p30#ora#steele#plane_13###########'),
(160, 14, 'p31#antonio#flores#plane_13###########'),
(160, 14, 'p32#glenn#ross#plane_13###########'),
(160, 14, 'p33#irma#thomas#plane_20###########'),
(160, 14, 'p34#ann#maldonado#plane_20###########'),
(160, 14, 'p35#jeffrey#cruz#port_12###########'),
(160, 14, 'p36#sonya#price#port_12###########'),
(160, 14, 'p37#tracy#hale#port_12###########'),
(160, 14, 'p38#albert#simmons#port_14###########'),
(160, 14, 'p39#karen#terry#port_15###########'),
(160, 14, 'p4#kendra#jacobs#port_1###########'),
(160, 14, 'p40#glen#kelley#port_20###########'),
(160, 14, 'p41#brooke#little#port_3###########'),
(160, 14, 'p42#daryl#nguyen#port_4###########'),
(160, 14, 'p43#judy#willis#port_14###########'),
(160, 14, 'p44#marco#klein#port_15###########'),
(160, 14, 'p45#angelica#hampton#port_16###########'),
(160, 14, 'p46#janice#white#plane_10###########'),
(160, 14, 'p47#charlie#brown#plane_3###########'),
(160, 14, 'p48#charles#schulz#plane_4###########'),
(160, 14, 'p49#beyonce##port_20###########'),
(160, 14, 'p5#jeff#burton#port_1###########'),
(160, 14, 'p50#jackie#sullivan#plane_27###########'),
(160, 14, 'p51#alayah#colon#plane_1###########'),
(160, 14, 'p52#bruce#walter#plane_8###########'),
(160, 14, 'p53#penny#baldwin#plane_20###########'),
(160, 14, 'p54#jaiden#alvarado#plane_5###########'),
(160, 14, 'p55#blake#velazquez#plane_13###########'),
(160, 14, 'p56#archer#thomas#plane_28###########'),
(160, 14, 'p6#randal#parks#port_1###########'),
(160, 14, 'p7#sonya#owens#port_2###########'),
(160, 14, 'p8#bennie#palmer#port_2###########'),
(160, 14, 'p9#marlene#warner#port_3###########'),
(161, 14, 'p1#jeanne#nelson#port_1###########'),
(161, 14, 'p10#lawrence#morgan#port_3###########'),
(161, 14, 'p11#sandra#cruz#port_3###########'),
(161, 14, 'p12#dan#ball#port_3###########'),
(161, 14, 'p13#bryant#figueroa#port_3###########'),
(161, 14, 'p14#dana#perry#port_3###########'),
(161, 14, 'p15#matt#hunt#port_10###########'),
(161, 14, 'p16#edna#brown#port_10###########'),
(161, 14, 'p17#ruby#burgess#plane_3###########'),
(161, 14, 'p18#esther#pittman#plane_10###########'),
(161, 14, 'p19#doug#fowler#port_23###########'),
(161, 14, 'p2#roxanne#byrd#port_1###########'),
(161, 14, 'p20#thomas#olson#port_4###########'),
(161, 14, 'p21#mona#harrison#plane_1###########'),
(161, 14, 'p22#arlene#massey#plane_1###########'),
(161, 14, 'p23#judith#patrick#plane_1###########'),
(161, 14, 'p24#reginald#rhodes#plane_5###########'),
(161, 14, 'p25#vincent#garcia#plane_5###########'),
(161, 14, 'p26#cheryl#moore#plane_5###########'),
(161, 14, 'p27#michael#rivera#plane_8###########'),
(161, 14, 'p28#luther#matthews#plane_8###########'),
(161, 14, 'p29#moses#parks#plane_13###########'),
(161, 14, 'p3#tanya#nguyen#port_1###########'),
(161, 14, 'p30#ora#steele#plane_13###########'),
(161, 14, 'p31#antonio#flores#plane_13###########'),
(161, 14, 'p32#glenn#ross#plane_13###########'),
(161, 14, 'p33#irma#thomas#plane_20###########'),
(161, 14, 'p34#ann#maldonado#plane_20###########'),
(161, 14, 'p35#jeffrey#cruz#port_12###########'),
(161, 14, 'p36#sonya#price#port_12###########'),
(161, 14, 'p37#tracy#hale#port_12###########'),
(161, 14, 'p38#albert#simmons#port_14###########'),
(161, 14, 'p39#karen#terry#port_15###########'),
(161, 14, 'p4#kendra#jacobs#port_1###########'),
(161, 14, 'p40#glen#kelley#port_20###########'),
(161, 14, 'p41#brooke#little#port_3###########'),
(161, 14, 'p42#daryl#nguyen#port_4###########'),
(161, 14, 'p43#judy#willis#port_14###########'),
(161, 14, 'p44#marco#klein#port_15###########'),
(161, 14, 'p45#angelica#hampton#port_16###########'),
(161, 14, 'p46#janice#white#plane_10###########'),
(161, 14, 'p47#charlie#brown#port_6###########'),
(161, 14, 'p48#charles#schulz#plane_4###########'),
(161, 14, 'p49#beyonce##port_20###########'),
(161, 14, 'p5#jeff#burton#port_1###########'),
(161, 14, 'p50#jackie#sullivan#plane_27###########'),
(161, 14, 'p51#alayah#colon#plane_1###########'),
(161, 14, 'p52#bruce#walter#plane_8###########'),
(161, 14, 'p53#penny#baldwin#plane_20###########'),
(161, 14, 'p54#jaiden#alvarado#plane_5###########'),
(161, 14, 'p55#blake#velazquez#plane_13###########'),
(161, 14, 'p56#archer#thomas#plane_28###########'),
(161, 14, 'p6#randal#parks#port_1###########'),
(161, 14, 'p7#sonya#owens#port_2###########'),
(161, 14, 'p8#bennie#palmer#port_2###########'),
(161, 14, 'p9#marlene#warner#port_3###########'),
(180, 14, 'p1#jeanne#nelson#port_1###########'),
(180, 14, 'p10#lawrence#morgan#port_3###########'),
(180, 14, 'p11#sandra#cruz#port_3###########'),
(180, 14, 'p12#dan#ball#port_3###########'),
(180, 14, 'p13#bryant#figueroa#port_3###########'),
(180, 14, 'p14#dana#perry#port_3###########'),
(180, 14, 'p15#matt#hunt#port_10###########'),
(180, 14, 'p16#edna#brown#port_10###########'),
(180, 14, 'p17#ruby#burgess#plane_3###########'),
(180, 14, 'p18#esther#pittman#plane_10###########'),
(180, 14, 'p19#doug#fowler#port_23###########'),
(180, 14, 'p2#roxanne#byrd#port_1###########'),
(180, 14, 'p20#thomas#olson#port_4###########'),
(180, 14, 'p21#mona#harrison#plane_1###########'),
(180, 14, 'p22#arlene#massey#plane_1###########'),
(180, 14, 'p23#judith#patrick#plane_1###########'),
(180, 14, 'p24#reginald#rhodes#plane_5###########'),
(180, 14, 'p25#vincent#garcia#plane_5###########'),
(180, 14, 'p26#cheryl#moore#plane_5###########'),
(180, 14, 'p27#michael#rivera#plane_8###########'),
(180, 14, 'p28#luther#matthews#plane_8###########'),
(180, 14, 'p29#moses#parks#plane_13###########'),
(180, 14, 'p3#tanya#nguyen#port_1###########'),
(180, 14, 'p30#ora#steele#plane_13###########'),
(180, 14, 'p31#antonio#flores#plane_13###########'),
(180, 14, 'p32#glenn#ross#plane_13###########'),
(180, 14, 'p33#irma#thomas#plane_20###########'),
(180, 14, 'p34#ann#maldonado#plane_20###########'),
(180, 14, 'p35#jeffrey#cruz#port_12###########'),
(180, 14, 'p36#sonya#price#port_12###########'),
(180, 14, 'p37#tracy#hale#port_12###########'),
(180, 14, 'p38#albert#simmons#port_14###########'),
(180, 14, 'p39#karen#terry#port_15###########'),
(180, 14, 'p4#kendra#jacobs#port_1###########'),
(180, 14, 'p40#glen#kelley#port_20###########'),
(180, 14, 'p41#brooke#little#port_3###########'),
(180, 14, 'p42#daryl#nguyen#port_4###########'),
(180, 14, 'p43#judy#willis#port_14###########'),
(180, 14, 'p44#marco#klein#port_15###########'),
(180, 14, 'p45#angelica#hampton#port_16###########'),
(180, 14, 'p46#janice#white#port_17###########'),
(180, 14, 'p47#charlie#brown#port_6###########'),
(180, 14, 'p48#charles#schulz#plane_4###########'),
(180, 14, 'p49#beyonce##port_20###########'),
(180, 14, 'p5#jeff#burton#port_1###########'),
(180, 14, 'p50#jackie#sullivan#plane_27###########'),
(180, 14, 'p51#alayah#colon#plane_1###########'),
(180, 14, 'p52#bruce#walter#plane_8###########'),
(180, 14, 'p53#penny#baldwin#plane_20###########'),
(180, 14, 'p54#jaiden#alvarado#plane_5###########'),
(180, 14, 'p55#blake#velazquez#plane_13###########'),
(180, 14, 'p56#archer#thomas#plane_28###########'),
(180, 14, 'p6#randal#parks#port_1###########'),
(180, 14, 'p7#sonya#owens#port_2###########'),
(180, 14, 'p8#bennie#palmer#port_2###########'),
(180, 14, 'p9#marlene#warner#port_3###########'),
(181, 14, 'p1#jeanne#nelson#port_1###########'),
(181, 14, 'p10#lawrence#morgan#port_3###########'),
(181, 14, 'p11#sandra#cruz#port_3###########'),
(181, 14, 'p12#dan#ball#port_3###########'),
(181, 14, 'p13#bryant#figueroa#port_3###########'),
(181, 14, 'p14#dana#perry#port_3###########'),
(181, 14, 'p15#matt#hunt#port_10###########'),
(181, 14, 'p16#edna#brown#port_10###########'),
(181, 14, 'p17#ruby#burgess#plane_3###########'),
(181, 14, 'p18#esther#pittman#plane_10###########'),
(181, 14, 'p19#doug#fowler#port_23###########'),
(181, 14, 'p2#roxanne#byrd#port_1###########'),
(181, 14, 'p20#thomas#olson#port_4###########'),
(181, 14, 'p21#mona#harrison#plane_1###########'),
(181, 14, 'p22#arlene#massey#plane_1###########'),
(181, 14, 'p23#judith#patrick#plane_1###########'),
(181, 14, 'p24#reginald#rhodes#plane_5###########'),
(181, 14, 'p25#vincent#garcia#plane_5###########'),
(181, 14, 'p26#cheryl#moore#plane_5###########'),
(181, 14, 'p27#michael#rivera#plane_8###########'),
(181, 14, 'p28#luther#matthews#plane_8###########'),
(181, 14, 'p29#moses#parks#plane_13###########'),
(181, 14, 'p3#tanya#nguyen#port_1###########'),
(181, 14, 'p30#ora#steele#plane_13###########'),
(181, 14, 'p31#antonio#flores#plane_13###########'),
(181, 14, 'p32#glenn#ross#plane_13###########'),
(181, 14, 'p33#irma#thomas#plane_20###########'),
(181, 14, 'p34#ann#maldonado#plane_20###########'),
(181, 14, 'p35#jeffrey#cruz#port_12###########'),
(181, 14, 'p36#sonya#price#port_12###########'),
(181, 14, 'p37#tracy#hale#port_12###########'),
(181, 14, 'p38#albert#simmons#port_14###########'),
(181, 14, 'p39#karen#terry#port_15###########'),
(181, 14, 'p4#kendra#jacobs#port_1###########'),
(181, 14, 'p40#glen#kelley#port_20###########'),
(181, 14, 'p41#brooke#little#port_3###########'),
(181, 14, 'p42#daryl#nguyen#port_4###########'),
(181, 14, 'p43#judy#willis#port_14###########'),
(181, 14, 'p44#marco#klein#port_15###########'),
(181, 14, 'p45#angelica#hampton#port_16###########'),
(181, 14, 'p46#janice#white#plane_10###########'),
(181, 14, 'p47#charlie#brown#port_6###########'),
(181, 14, 'p48#charles#schulz#plane_4###########'),
(181, 14, 'p49#beyonce##port_20###########'),
(181, 14, 'p5#jeff#burton#port_1###########'),
(181, 14, 'p50#jackie#sullivan#plane_27###########'),
(181, 14, 'p51#alayah#colon#plane_1###########'),
(181, 14, 'p52#bruce#walter#plane_8###########'),
(181, 14, 'p53#penny#baldwin#plane_20###########'),
(181, 14, 'p54#jaiden#alvarado#plane_5###########'),
(181, 14, 'p55#blake#velazquez#plane_13###########'),
(181, 14, 'p56#archer#thomas#plane_28###########'),
(181, 14, 'p6#randal#parks#port_1###########'),
(181, 14, 'p7#sonya#owens#port_2###########'),
(181, 14, 'p8#bennie#palmer#port_2###########'),
(181, 14, 'p9#marlene#warner#port_3###########'),
(200, 14, 'p1#jeanne#nelson#port_1###########'),
(200, 14, 'p10#lawrence#morgan#port_3###########'),
(200, 14, 'p11#sandra#cruz#port_3###########'),
(200, 14, 'p12#dan#ball#port_3###########'),
(200, 14, 'p13#bryant#figueroa#port_3###########'),
(200, 14, 'p14#dana#perry#port_3###########'),
(200, 14, 'p15#matt#hunt#port_10###########'),
(200, 14, 'p16#edna#brown#port_10###########'),
(200, 14, 'p17#ruby#burgess#plane_3###########'),
(200, 14, 'p18#esther#pittman#plane_10###########'),
(200, 14, 'p19#doug#fowler#plane_18###########'),
(200, 14, 'p2#roxanne#byrd#port_1###########'),
(200, 14, 'p20#thomas#olson#port_4###########'),
(200, 14, 'p21#mona#harrison#plane_1###########'),
(200, 14, 'p22#arlene#massey#plane_1###########'),
(200, 14, 'p23#judith#patrick#plane_1###########'),
(200, 14, 'p24#reginald#rhodes#plane_5###########'),
(200, 14, 'p25#vincent#garcia#plane_5###########'),
(200, 14, 'p26#cheryl#moore#plane_5###########'),
(200, 14, 'p27#michael#rivera#plane_8###########'),
(200, 14, 'p28#luther#matthews#plane_8###########'),
(200, 14, 'p29#moses#parks#plane_13###########'),
(200, 14, 'p3#tanya#nguyen#port_1###########'),
(200, 14, 'p30#ora#steele#plane_13###########'),
(200, 14, 'p31#antonio#flores#plane_13###########'),
(200, 14, 'p32#glenn#ross#plane_13###########'),
(200, 14, 'p33#irma#thomas#plane_20###########'),
(200, 14, 'p34#ann#maldonado#plane_20###########'),
(200, 14, 'p35#jeffrey#cruz#port_12###########'),
(200, 14, 'p36#sonya#price#port_12###########'),
(200, 14, 'p37#tracy#hale#port_12###########'),
(200, 14, 'p38#albert#simmons#port_14###########'),
(200, 14, 'p39#karen#terry#port_15###########'),
(200, 14, 'p4#kendra#jacobs#port_1###########'),
(200, 14, 'p40#glen#kelley#port_20###########'),
(200, 14, 'p41#brooke#little#port_3###########'),
(200, 14, 'p42#daryl#nguyen#port_4###########'),
(200, 14, 'p43#judy#willis#port_14###########'),
(200, 14, 'p44#marco#klein#port_15###########'),
(200, 14, 'p45#angelica#hampton#port_16###########'),
(200, 14, 'p46#janice#white#plane_10###########'),
(200, 14, 'p47#charlie#brown#port_6###########'),
(200, 14, 'p48#charles#schulz#plane_4###########'),
(200, 14, 'p49#beyonce##port_20###########'),
(200, 14, 'p5#jeff#burton#port_1###########'),
(200, 14, 'p50#jackie#sullivan#plane_27###########'),
(200, 14, 'p51#alayah#colon#plane_1###########'),
(200, 14, 'p52#bruce#walter#plane_8###########'),
(200, 14, 'p53#penny#baldwin#plane_20###########'),
(200, 14, 'p54#jaiden#alvarado#plane_5###########'),
(200, 14, 'p55#blake#velazquez#plane_13###########'),
(200, 14, 'p56#archer#thomas#plane_28###########'),
(200, 14, 'p6#randal#parks#port_1###########'),
(200, 14, 'p7#sonya#owens#port_2###########'),
(200, 14, 'p8#bennie#palmer#port_2###########'),
(200, 14, 'p9#marlene#warner#port_3###########'),
(200, 21, 'p1#330-12-6907#31#dl_10###########'),
(200, 21, 'p10#769-60-1266#15#lf_20###########'),
(200, 21, 'p11#369-22-9505#22#km_16###########'),
(200, 21, 'p12#680-92-5329#24#ry_34###########'),
(200, 21, 'p13#513-40-4168#24#km_16###########'),
(200, 21, 'p14#454-71-7847#13#km_16###########'),
(200, 21, 'p15#153-47-8101#30#ja_35###########'),
(200, 21, 'p16#598-47-5172#28#ja_35###########'),
(200, 21, 'p17#865-71-6800#36#dl_42###########'),
(200, 21, 'p18#250-86-2784#23#lf_67###########'),
(200, 21, 'p19#386-39-7881#2#ry_34###########'),
(200, 21, 'p2#842-88-1257#9#dl_10###########'),
(200, 21, 'p20#522-44-3098#28############'),
(200, 21, 'p3#750-24-7616#11#un_38###########'),
(200, 21, 'p4#776-21-8098#24#un_38###########'),
(200, 21, 'p48#999-01-1369#93#ke_64###########'),
(200, 21, 'p5#933-93-2165#27#ba_61###########'),
(200, 21, 'p50#937-82-7342#40#nk_98###########'),
(200, 21, 'p51#123-45-6789#12#dl_10###########'),
(200, 21, 'p52#987-65-4321#78#lf_20###########'),
(200, 21, 'p53#333-44-5555#82#ja_35###########'),
(200, 21, 'p54#333-22-4444#24#un_38###########'),
(200, 21, 'p55#999-55-4567#23#km_16###########'),
(200, 21, 'p56#979-55-4567#31#af_19###########'),
(200, 21, 'p6#707-84-4555#38#ba_61###########'),
(200, 21, 'p7#450-25-5617#13#lf_20###########'),
(200, 21, 'p8#701-38-2179#12#ry_34###########'),
(200, 21, 'p9#936-44-6941#13#lf_20###########'),
(220, 14, 'p1#jeanne#nelson#port_1###########'),
(220, 14, 'p10#lawrence#morgan#port_3###########'),
(220, 14, 'p11#sandra#cruz#port_3###########'),
(220, 14, 'p12#dan#ball#port_3###########'),
(220, 14, 'p13#bryant#figueroa#port_3###########'),
(220, 14, 'p14#dana#perry#port_3###########'),
(220, 14, 'p15#matt#hunt#port_10###########'),
(220, 14, 'p16#edna#brown#port_10###########'),
(220, 14, 'p17#ruby#burgess#plane_3###########'),
(220, 14, 'p18#esther#pittman#plane_10###########'),
(220, 14, 'p19#doug#fowler#port_23###########'),
(220, 14, 'p2#roxanne#byrd#port_1###########'),
(220, 14, 'p20#thomas#olson#port_4###########'),
(220, 14, 'p21#mona#harrison#plane_1###########'),
(220, 14, 'p22#arlene#massey#plane_1###########'),
(220, 14, 'p23#judith#patrick#plane_1###########'),
(220, 14, 'p24#reginald#rhodes#plane_5###########'),
(220, 14, 'p25#vincent#garcia#plane_5###########'),
(220, 14, 'p26#cheryl#moore#plane_5###########'),
(220, 14, 'p27#michael#rivera#plane_8###########'),
(220, 14, 'p28#luther#matthews#plane_8###########'),
(220, 14, 'p29#moses#parks#plane_13###########'),
(220, 14, 'p3#tanya#nguyen#port_1###########'),
(220, 14, 'p30#ora#steele#plane_13###########'),
(220, 14, 'p31#antonio#flores#plane_13###########'),
(220, 14, 'p32#glenn#ross#plane_13###########'),
(220, 14, 'p33#irma#thomas#plane_20###########'),
(220, 14, 'p34#ann#maldonado#plane_20###########'),
(220, 14, 'p35#jeffrey#cruz#port_12###########'),
(220, 14, 'p36#sonya#price#port_12###########'),
(220, 14, 'p37#tracy#hale#port_12###########'),
(220, 14, 'p38#albert#simmons#port_14###########'),
(220, 14, 'p39#karen#terry#port_15###########'),
(220, 14, 'p4#kendra#jacobs#port_1###########'),
(220, 14, 'p40#glen#kelley#port_20###########'),
(220, 14, 'p41#brooke#little#port_3###########'),
(220, 14, 'p42#daryl#nguyen#port_4###########'),
(220, 14, 'p43#judy#willis#port_14###########'),
(220, 14, 'p44#marco#klein#port_15###########'),
(220, 14, 'p45#angelica#hampton#port_16###########'),
(220, 14, 'p46#janice#white#plane_10###########'),
(220, 14, 'p47#charlie#brown#port_6###########'),
(220, 14, 'p48#charles#schulz#port_24###########'),
(220, 14, 'p49#beyonce##port_20###########'),
(220, 14, 'p5#jeff#burton#port_1###########'),
(220, 14, 'p50#jackie#sullivan#plane_27###########'),
(220, 14, 'p51#alayah#colon#plane_1###########'),
(220, 14, 'p52#bruce#walter#plane_8###########'),
(220, 14, 'p53#penny#baldwin#plane_20###########'),
(220, 14, 'p54#jaiden#alvarado#plane_5###########'),
(220, 14, 'p55#blake#velazquez#plane_13###########'),
(220, 14, 'p56#archer#thomas#plane_28###########'),
(220, 14, 'p6#randal#parks#port_1###########'),
(220, 14, 'p7#sonya#owens#port_2###########'),
(220, 14, 'p8#bennie#palmer#port_2###########'),
(220, 14, 'p9#marlene#warner#port_3###########'),
(220, 21, 'p1#330-12-6907#31#dl_10###########'),
(220, 21, 'p10#769-60-1266#15#lf_20###########'),
(220, 21, 'p11#369-22-9505#22#km_16###########'),
(220, 21, 'p12#680-92-5329#24#ry_34###########'),
(220, 21, 'p13#513-40-4168#24#km_16###########'),
(220, 21, 'p14#454-71-7847#13#km_16###########'),
(220, 21, 'p15#153-47-8101#30#ja_35###########'),
(220, 21, 'p16#598-47-5172#28#ja_35###########'),
(220, 21, 'p17#865-71-6800#36#dl_42###########'),
(220, 21, 'p18#250-86-2784#23#lf_67###########'),
(220, 21, 'p19#386-39-7881#2############'),
(220, 21, 'p2#842-88-1257#9#dl_10###########'),
(220, 21, 'p20#522-44-3098#28############'),
(220, 21, 'p3#750-24-7616#11#un_38###########'),
(220, 21, 'p4#776-21-8098#24#un_38###########'),
(220, 21, 'p48#999-01-1369#93############'),
(220, 21, 'p5#933-93-2165#27#ba_61###########'),
(220, 21, 'p50#937-82-7342#40#nk_98###########'),
(220, 21, 'p51#123-45-6789#12#dl_10###########'),
(220, 21, 'p52#987-65-4321#78#lf_20###########'),
(220, 21, 'p53#333-44-5555#82#ja_35###########'),
(220, 21, 'p54#333-22-4444#24#un_38###########'),
(220, 21, 'p55#999-55-4567#23#km_16###########'),
(220, 21, 'p56#979-55-4567#31#af_19###########'),
(220, 21, 'p6#707-84-4555#38#ba_61###########'),
(220, 21, 'p7#450-25-5617#13#lf_20###########'),
(220, 21, 'p8#701-38-2179#12#ry_34###########'),
(220, 21, 'p9#936-44-6941#13#lf_20###########'),
(240, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(240, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(240, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(240, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(240, 20, 'dl_10#americas_one#delta#n106js#1#in_flight#08:00:00#200#######'),
(240, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(240, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(240, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(240, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(240, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(240, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(240, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(240, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(240, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(240, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(260, 12, 'air_france#n118fm#4#400##boeing#0#777#######'),
(260, 12, 'air_france#n815pw#3#400##airbus###0######'),
(260, 12, 'air_france#n816pw#3#400#plane_28#airbus###0######'),
(260, 12, 'american#n225sb#8#800##airbus###0######'),
(260, 12, 'american#n448cs#4#400##boeing#1#787#######'),
(260, 12, 'american#n553qn#5#800#plane_2#airbus###0######'),
(260, 12, 'britishairways#n517ly#4#600#plane_7#airbus###0######'),
(260, 12, 'britishairways#n616lt#7#600#plane_6#airbus###0######'),
(260, 12, 'chinasouthernairlines#n249yk#4#400##boeing#0#787#######'),
(260, 12, 'chinasouthernairlines#n454gq#3#400###########'),
(260, 12, 'delta#n106js#4#800#plane_1#airbus###0######'),
(260, 12, 'delta#n110jn#5#800#plane_3#airbus###0######'),
(260, 12, 'delta#n127js#4#600##airbus###1######'),
(260, 12, 'japanairlines#n305fv#6#400#plane_20#airbus###0######'),
(260, 12, 'japanairlines#n443wu#4#800##airbus###1######'),
(260, 12, 'klm#n161fk#4#600#plane_13#airbus###1######'),
(260, 12, 'klm#n256ap#4#300##boeing#0#737#######'),
(260, 12, 'klm#n337as#5#400##airbus###0######'),
(260, 12, 'koreanairlines#n180co#5#600#plane_4#airbus###0######'),
(260, 12, 'koreanairlines#n266f7#12#600#plane_26#airbus###0######'),
(260, 12, 'lufthansa#n401fj#4#300###########'),
(260, 12, 'lufthansa#n620la#4#800#plane_8#airbus###1######'),
(260, 12, 'lufthansa#n653fk#6#600#plane_10#airbus###0######'),
(260, 12, 'ryanair#n156sq#8#600##airbus###0######'),
(260, 12, 'ryanair#n341eb#4#400#plane_18#boeing#1#737#######'),
(260, 12, 'ryanair#n353kz#4#400##boeing#1#737#######'),
(260, 12, 'ryanair#n451fi#5#600##airbus###1######'),
(260, 12, 'spirit#n223gw#3#200#plane_29#airbus###1######'),
(260, 12, 'spirit#n270ff#3#200#plane_27#airbus###1######'),
(260, 12, 'united#n330ss#4#800##airbus###0######'),
(260, 12, 'united#n380sd#5#400#plane_5#airbus###0######'),
(260, 14, 'p1#jeanne#nelson#port_1###########'),
(260, 14, 'p10#lawrence#morgan#port_3###########'),
(260, 14, 'p11#sandra#cruz#port_3###########'),
(260, 14, 'p12#dan#ball#port_3###########'),
(260, 14, 'p13#bryant#figueroa#port_3###########'),
(260, 14, 'p14#dana#perry#port_3###########'),
(260, 14, 'p15#matt#hunt#port_10###########'),
(260, 14, 'p16#edna#brown#port_10###########'),
(260, 14, 'p17#ruby#burgess#plane_3###########'),
(260, 14, 'p18#esther#pittman#plane_10###########'),
(260, 14, 'p19#doug#fowler#port_23###########'),
(260, 14, 'p2#roxanne#byrd#port_1###########'),
(260, 14, 'p20#thomas#olson#port_4###########'),
(260, 14, 'p21#mona#harrison#port_11###########'),
(260, 14, 'p22#arlene#massey#port_11###########'),
(260, 14, 'p23#judith#patrick#plane_1###########'),
(260, 14, 'p24#reginald#rhodes#plane_5###########'),
(260, 14, 'p25#vincent#garcia#plane_5###########'),
(260, 14, 'p26#cheryl#moore#plane_5###########'),
(260, 14, 'p27#michael#rivera#plane_8###########'),
(260, 14, 'p28#luther#matthews#plane_8###########'),
(260, 14, 'p29#moses#parks#plane_13###########'),
(260, 14, 'p3#tanya#nguyen#port_1###########'),
(260, 14, 'p30#ora#steele#plane_13###########'),
(260, 14, 'p31#antonio#flores#plane_13###########'),
(260, 14, 'p32#glenn#ross#plane_13###########'),
(260, 14, 'p33#irma#thomas#plane_20###########'),
(260, 14, 'p34#ann#maldonado#plane_20###########'),
(260, 14, 'p35#jeffrey#cruz#port_12###########'),
(260, 14, 'p36#sonya#price#port_12###########'),
(260, 14, 'p37#tracy#hale#port_12###########'),
(260, 14, 'p38#albert#simmons#port_14###########'),
(260, 14, 'p39#karen#terry#port_15###########'),
(260, 14, 'p4#kendra#jacobs#port_1###########'),
(260, 14, 'p40#glen#kelley#port_20###########'),
(260, 14, 'p41#brooke#little#port_3###########'),
(260, 14, 'p42#daryl#nguyen#port_4###########'),
(260, 14, 'p43#judy#willis#port_14###########'),
(260, 14, 'p44#marco#klein#port_15###########'),
(260, 14, 'p45#angelica#hampton#port_16###########'),
(260, 14, 'p46#janice#white#plane_10###########'),
(260, 14, 'p47#charlie#brown#port_6###########'),
(260, 14, 'p48#charles#schulz#plane_4###########'),
(260, 14, 'p49#beyonce##port_20###########'),
(260, 14, 'p5#jeff#burton#port_1###########'),
(260, 14, 'p50#jackie#sullivan#plane_27###########'),
(260, 14, 'p51#alayah#colon#plane_1###########'),
(260, 14, 'p52#bruce#walter#plane_8###########'),
(260, 14, 'p53#penny#baldwin#plane_20###########'),
(260, 14, 'p54#jaiden#alvarado#plane_5###########'),
(260, 14, 'p55#blake#velazquez#plane_13###########'),
(260, 14, 'p56#archer#thomas#plane_28###########'),
(260, 14, 'p6#randal#parks#port_1###########'),
(260, 14, 'p7#sonya#owens#port_2###########'),
(260, 14, 'p8#bennie#palmer#port_2###########'),
(260, 14, 'p9#marlene#warner#port_3###########'),
(260, 21, 'p1#330-12-6907#32#dl_10###########'),
(260, 21, 'p10#769-60-1266#15#lf_20###########'),
(260, 21, 'p11#369-22-9505#22#km_16###########'),
(260, 21, 'p12#680-92-5329#24#ry_34###########'),
(260, 21, 'p13#513-40-4168#24#km_16###########'),
(260, 21, 'p14#454-71-7847#13#km_16###########'),
(260, 21, 'p15#153-47-8101#30#ja_35###########'),
(260, 21, 'p16#598-47-5172#28#ja_35###########'),
(260, 21, 'p17#865-71-6800#36#dl_42###########'),
(260, 21, 'p18#250-86-2784#23#lf_67###########'),
(260, 21, 'p19#386-39-7881#2############'),
(260, 21, 'p2#842-88-1257#10#dl_10###########'),
(260, 21, 'p20#522-44-3098#28############'),
(260, 21, 'p3#750-24-7616#11#un_38###########'),
(260, 21, 'p4#776-21-8098#24#un_38###########'),
(260, 21, 'p48#999-01-1369#93#ke_64###########'),
(260, 21, 'p5#933-93-2165#27#ba_61###########'),
(260, 21, 'p50#937-82-7342#40#nk_98###########'),
(260, 21, 'p51#123-45-6789#13#dl_10###########'),
(260, 21, 'p52#987-65-4321#78#lf_20###########'),
(260, 21, 'p53#333-44-5555#82#ja_35###########'),
(260, 21, 'p54#333-22-4444#24#un_38###########'),
(260, 21, 'p55#999-55-4567#23#km_16###########'),
(260, 21, 'p56#979-55-4567#31#af_19###########'),
(260, 21, 'p6#707-84-4555#38#ba_61###########'),
(260, 21, 'p7#450-25-5617#13#lf_20###########'),
(260, 21, 'p8#701-38-2179#12#ry_34###########'),
(260, 21, 'p9#936-44-6941#13#lf_20###########'),
(260, 22, 'p1#airbus#############'),
(260, 22, 'p10#airbus#############'),
(260, 22, 'p11#airbus#############'),
(260, 22, 'p11#boeing#############'),
(260, 22, 'p12#boeing#############'),
(260, 22, 'p13#airbus#############'),
(260, 22, 'p14#airbus#############'),
(260, 22, 'p15#airbus#############'),
(260, 22, 'p15#boeing#############'),
(260, 22, 'p15#general#############'),
(260, 22, 'p16#airbus#############'),
(260, 22, 'p17#airbus#############'),
(260, 22, 'p17#boeing#############'),
(260, 22, 'p18#airbus#############'),
(260, 22, 'p19#airbus#############'),
(260, 22, 'p19#boeing#############'),
(260, 22, 'p2#airbus#############'),
(260, 22, 'p2#boeing#############'),
(260, 22, 'p20#airbus#############'),
(260, 22, 'p3#airbus#############'),
(260, 22, 'p4#airbus#############'),
(260, 22, 'p4#boeing#############'),
(260, 22, 'p48#airbus#############'),
(260, 22, 'p5#airbus#############'),
(260, 22, 'p50#airbus#############'),
(260, 22, 'p51#airbus#############'),
(260, 22, 'p52#airbus#############'),
(260, 22, 'p53#airbus#############'),
(260, 22, 'p54#airbus#############'),
(260, 22, 'p55#airbus#############'),
(260, 22, 'p56#airbus#############'),
(260, 22, 'p6#airbus#############'),
(260, 22, 'p6#boeing#############'),
(260, 22, 'p7#airbus#############'),
(260, 22, 'p8#boeing#############'),
(260, 22, 'p9#airbus#############'),
(260, 22, 'p9#boeing#############'),
(260, 22, 'p9#general#############'),
(260, 15, 'p21#4671#700############'),
(260, 15, 'p22#4274#200############'),
(260, 15, 'p23#4314#400############'),
(260, 15, 'p24#292#500############'),
(260, 15, 'p25#390#300############'),
(260, 15, 'p26#302#600############'),
(260, 15, 'p27#470#400############'),
(260, 15, 'p28#208#400############'),
(260, 15, 'p29#292#700############'),
(260, 15, 'p30#686#500############'),
(260, 15, 'p31#547#400############'),
(260, 15, 'p32#257#500############'),
(260, 15, 'p33#564#600############'),
(260, 15, 'p34#211#200############'),
(260, 15, 'p35#233#500############'),
(260, 15, 'p36#293#400############'),
(260, 15, 'p37#552#700############'),
(260, 15, 'p38#812#700############'),
(260, 15, 'p39#541#400############'),
(260, 15, 'p40#441#700############'),
(260, 15, 'p41#875#300############'),
(260, 15, 'p42#691#500############'),
(260, 15, 'p43#572#300############'),
(260, 15, 'p44#572#500############'),
(260, 15, 'p45#663#500############'),
(260, 15, 'p46#690#5000############'),
(260, 15, 'p47#230#5000############'),
(260, 15, 'p49#5000#67297############'),
(260, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(260, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(260, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(260, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(260, 20, 'dl_10#americas_one#delta#n106js#1#on_ground#09:00:00#200#######'),
(260, 20, 'dl_42#texas_local#delta#n110jn#0#on_ground#13:45:00#220#######'),
(260, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(260, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(260, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(260, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(260, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(260, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(260, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(260, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(260, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(260, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######'),
(280, 30, 'atl#ams#1#dl_10#08:00:00#08:00:00#plane_1########'),
(280, 30, 'bcn#cdg#1#lf_20#11:00:00#11:00:00#plane_8########'),
(280, 30, 'ber#can#1#ja_35#09:30:00#09:30:00#plane_20########'),
(280, 30, 'cdg#muc#1#un_38#14:30:00#14:30:00#plane_5########'),
(280, 30, 'mad#fco#2#af_19,km_16#14:00:00#17:00:00#plane_28,plane_13########'),
(300, 31, 'iah#1#nk_98#13:13:13#13:13:13#plane_27#########'),
(300, 31, 'icn#1#ke_64#16:00:00#16:00:00#plane_4#########'),
(300, 31, 'lgw#1#lf_67#21:23:00#21:23:00#plane_10#########'),
(300, 31, 'nrt#1#ke_88#11:00:00#11:00:00#plane_26#########'),
(300, 31, 'ord#1#aa_12#12:15:00#12:15:00#plane_2#########'),
(300, 31, 'atl#2#ba_61,nk_17#08:30:00#09:30:00#plane_6,plane_29#########'),
(300, 31, 'ber#1#ry_34#15:00:00#15:00:00#plane_18#########'),
(300, 31, 'dfw#1#dl_42#13:45:00#13:45:00#plane_3#########'),
(300, 31, 'lhr#1#ba_51#11:30:00#11:30:00#plane_7#########'),
(320, 32, 'atl#ams#1#plane_1#dl_10#08:00:00#08:00:00#1#3#4#p21,p22,p23,p51####'),
(320, 32, 'bcn#cdg#1#plane_8#lf_20#11:00:00#11:00:00#1#2#3#p27,p28,p52####'),
(320, 32, 'ber#can#1#plane_20#ja_35#09:30:00#09:30:00#1#2#3#p33,p34,p53####'),
(320, 32, 'cdg#muc#1#plane_5#un_38#14:30:00#14:30:00#1#3#4#p24,p25,p26,p54####'),
(320, 32, 'mad#fco#2#plane_13,plane_28#af_19,km_16#14:00:00#17:00:00#2#4#6#p29,p30,p31,p32,p55,p56####'),
(340, 33, 'atl#port_1#atlantahartsfield_jacksoninternational#atlanta#georgia#usa#6#0#6#p1,p2,p3,p4,p5,p6#####'),
(340, 33, 'bcn#port_15#barcelonainternational#barcelona#catalonia#esp#0#2#2#p39,p44#####'),
(340, 33, 'ber#port_23#berlinbrandenburgwillybrandtinternational#berlin#schonefeld#deu#1#0#1#p19#####'),
(340, 33, 'cdg#port_12#parischarlesdegaulle#roissy_en_france#paris#fra#0#3#3#p35,p36,p37#####'),
(340, 33, 'dfw#port_6#dallas_fortworthinternational#dallas#texas#usa#0#1#1#p47#####'),
(340, 33, 'dxb#port_2#dubaiinternational#dubai#algarhoud#uae#2#0#2#p7,p8#####'),
(340, 33, 'fco#port_16#romefiumicino#fiumicino#lazio#ita#0#1#1#p45#####'),
(340, 33, 'hnd#port_3#tokyointernationalhaneda#otacity#tokyo#jpn#6#1#7#p10,p11,p12,p13,p14,p41,p9#####'),
(340, 33, 'iah#port_20#georgebushintercontinental#houston#texas#usa#0#2#2#p40,p49#####'),
(340, 33, 'lhr#port_4#londonheathrow#london#england#gbr#1#1#2#p20,p42#####'),
(340, 33, 'mad#port_14#madridadolfosuarez_barajas#madrid#barajas#esp#0#2#2#p38,p43#####'),
(340, 33, 'ord#port_10#o_hareinternational#chicago#illinois#usa#2#0#2#p15,p16#####'),
(360, 34, 'americas_hub_exchange#1#leg_4#600#1#aa_12#atl->ord########'),
(360, 34, 'americas_one#2#leg_2,leg_1#4300#1#dl_10#atl->ams,ams->ber########'),
(360, 34, 'americas_three#2#leg_31,leg_14#4100#1#un_38#ord->cdg,cdg->muc########'),
(360, 34, 'americas_two#2#leg_3,leg_22#4300#2#ba_61,nk_17#atl->lhr,lhr->ber########'),
(360, 34, 'big_europe_loop#5#leg_23,leg_29,leg_16,leg_25,leg_13#2500#1#ba_51#lhr->muc,muc->fco,fco->mad,mad->cdg,cdg->lhr########'),
(360, 34, 'euro_north#6#leg_16,leg_24,leg_5,leg_14,leg_27,leg_8#2900#2#lf_20,lf_67#fco->mad,mad->bcn,bcn->cdg,cdg->muc,muc->ber,ber->lgw########'),
(360, 34, 'euro_south#6#leg_21,leg_9,leg_28,leg_11,leg_6,leg_26#2900#2#af_19,km_16#lgw->ber,ber->muc,muc->cdg,cdg->bcn,bcn->mad,mad->fco########'),
(360, 34, 'germany_local#3#leg_9,leg_30,leg_17#800#1#ry_34#ber->muc,muc->fra,fra->ber########'),
(360, 34, 'korea_direct#1#leg_32#6800#1#ke_64#dfw->icn########'),
(360, 34, 'pacific_rim_tour#3#leg_7,leg_10,leg_18#6400#2#ja_35,ke_88#ber->can,can->hnd,hnd->nrt########'),
(360, 34, 'south_euro_loop#4#leg_16,leg_24,leg_5,leg_12#2200#0##fco->mad,mad->bcn,bcn->cdg,cdg->fco########'),
(360, 34, 'texas_local#3#leg_15,leg_20,leg_19#600#2#dl_42,nk_98#dfw->iah,iah->hou,hou->dfw########'),
(380, 35, 'chicago#illinois#usa#2#mdw,ord#chicagomidwayinternational,o_hareinternational#########'),
(380, 35, 'houston#texas#usa#2#hou,iah#williamp_hobbyinternational,georgebushintercontinental#########'),
(380, 35, 'london#england#gbr#2#lgw,lhr#londongatwick,londonheathrow#########'),
(400, 14, 'p1#jeanne#nelson#port_1###########'),
(400, 14, 'p10#lawrence#morgan#port_3###########'),
(400, 14, 'p11#sandra#cruz#port_3###########'),
(400, 14, 'p12#dan#ball#port_3###########'),
(400, 14, 'p13#bryant#figueroa#port_3###########'),
(400, 14, 'p14#dana#perry#port_3###########'),
(400, 14, 'p15#matt#hunt#port_10###########'),
(400, 14, 'p16#edna#brown#port_10###########'),
(400, 14, 'p17#ruby#burgess#plane_3###########'),
(400, 14, 'p18#esther#pittman#plane_10###########'),
(400, 14, 'p19#doug#fowler#port_23###########'),
(400, 14, 'p2#roxanne#byrd#port_1###########'),
(400, 14, 'p20#thomas#olson#port_4###########'),
(400, 14, 'p21#mona#harrison#plane_1###########'),
(400, 14, 'p22#arlene#massey#plane_1###########'),
(400, 14, 'p23#judith#patrick#plane_1###########'),
(400, 14, 'p24#reginald#rhodes#plane_5###########'),
(400, 14, 'p25#vincent#garcia#plane_5###########'),
(400, 14, 'p26#cheryl#moore#plane_5###########'),
(400, 14, 'p27#michael#rivera#plane_8###########'),
(400, 14, 'p28#luther#matthews#plane_8###########'),
(400, 14, 'p29#moses#parks#plane_13###########'),
(400, 14, 'p3#tanya#nguyen#port_1###########'),
(400, 14, 'p30#ora#steele#plane_13###########'),
(400, 14, 'p31#antonio#flores#plane_13###########'),
(400, 14, 'p32#glenn#ross#plane_13###########'),
(400, 14, 'p33#irma#thomas#plane_20###########'),
(400, 14, 'p34#ann#maldonado#plane_20###########'),
(400, 14, 'p35#jeffrey#cruz#port_12###########'),
(400, 14, 'p36#sonya#price#port_12###########'),
(400, 14, 'p37#tracy#hale#port_12###########'),
(400, 14, 'p38#albert#simmons#port_14###########'),
(400, 14, 'p39#karen#terry#port_15###########'),
(400, 14, 'p4#kendra#jacobs#port_1###########'),
(400, 14, 'p40#glen#kelley#port_20###########'),
(400, 14, 'p41#brooke#little#port_3###########'),
(400, 14, 'p42#daryl#nguyen#port_4###########'),
(400, 14, 'p43#judy#willis#port_14###########'),
(400, 14, 'p44#marco#klein#port_15###########'),
(400, 14, 'p45#angelica#hampton#port_16###########'),
(400, 14, 'p46#janice#white#plane_10###########'),
(400, 14, 'p47#charlie#brown#plane_3###########'),
(400, 14, 'p48#charles#schulz#plane_4###########'),
(400, 14, 'p49#beyonce##port_20###########'),
(400, 14, 'p5#jeff#burton#port_1###########'),
(400, 14, 'p50#jackie#sullivan#plane_27###########'),
(400, 14, 'p51#alayah#colon#plane_1###########'),
(400, 14, 'p52#bruce#walter#plane_8###########'),
(400, 14, 'p53#penny#baldwin#plane_20###########'),
(400, 14, 'p54#jaiden#alvarado#plane_5###########'),
(400, 14, 'p55#blake#velazquez#plane_13###########'),
(400, 14, 'p56#archer#thomas#plane_28###########'),
(400, 14, 'p6#randal#parks#port_1###########'),
(400, 14, 'p7#sonya#owens#port_2###########'),
(400, 14, 'p8#bennie#palmer#port_2###########'),
(400, 14, 'p9#marlene#warner#port_3###########'),
(400, 21, 'p1#330-12-6907#31#dl_10###########'),
(400, 21, 'p10#769-60-1266#15#lf_20###########'),
(400, 21, 'p11#369-22-9505#22#km_16###########'),
(400, 21, 'p12#680-92-5329#24#ry_34###########'),
(400, 21, 'p13#513-40-4168#24#km_16###########'),
(400, 21, 'p14#454-71-7847#13#km_16###########'),
(400, 21, 'p15#153-47-8101#30#ja_35###########'),
(400, 21, 'p16#598-47-5172#28#ja_35###########'),
(400, 21, 'p17#865-71-6800#36#dl_42###########'),
(400, 21, 'p18#250-86-2784#23#lf_67###########'),
(400, 21, 'p19#386-39-7881#2############'),
(400, 21, 'p2#842-88-1257#9#dl_10###########'),
(400, 21, 'p20#522-44-3098#28############'),
(400, 21, 'p3#750-24-7616#11#un_38###########'),
(400, 21, 'p4#776-21-8098#24#un_38###########'),
(400, 21, 'p48#999-01-1369#93#ke_64###########'),
(400, 21, 'p5#933-93-2165#27#ba_61###########'),
(400, 21, 'p50#937-82-7342#40#nk_98###########'),
(400, 21, 'p51#123-45-6789#12#dl_10###########'),
(400, 21, 'p52#987-65-4321#78#lf_20###########'),
(400, 21, 'p53#333-44-5555#82#ja_35###########'),
(400, 21, 'p54#333-22-4444#24#un_38###########'),
(400, 21, 'p55#999-55-4567#23#km_16###########'),
(400, 21, 'p56#979-55-4567#31#af_19###########'),
(400, 21, 'p6#707-84-4555#38#ba_61###########'),
(400, 21, 'p7#450-25-5617#13#lf_20###########'),
(400, 21, 'p8#701-38-2179#12#ry_34###########'),
(400, 21, 'p9#936-44-6941#13#lf_20###########'),
(400, 15, 'p21#771#700############'),
(400, 15, 'p22#374#200############'),
(400, 15, 'p23#414#400############'),
(400, 15, 'p24#292#500############'),
(400, 15, 'p25#390#300############'),
(400, 15, 'p26#302#600############'),
(400, 15, 'p27#470#400############'),
(400, 15, 'p28#208#400############'),
(400, 15, 'p29#292#700############'),
(400, 15, 'p30#686#500############'),
(400, 15, 'p31#547#400############'),
(400, 15, 'p32#257#500############'),
(400, 15, 'p33#564#600############'),
(400, 15, 'p34#211#200############'),
(400, 15, 'p35#233#500############'),
(400, 15, 'p36#293#400############'),
(400, 15, 'p37#552#700############'),
(400, 15, 'p38#812#700############'),
(400, 15, 'p39#541#400############'),
(400, 15, 'p40#441#700############'),
(400, 15, 'p41#875#300############'),
(400, 15, 'p42#691#500############'),
(400, 15, 'p43#572#300############'),
(400, 15, 'p44#572#500############'),
(400, 15, 'p45#663#500############'),
(400, 15, 'p46#690#5000############'),
(400, 15, 'p47#230#4780############'),
(400, 15, 'p49#5000#67297############'),
(400, 20, 'aa_12#americas_hub_exchange#american#n553qn#1#on_ground#12:15:00#150#######'),
(400, 20, 'af_19#euro_south#air_france#n816pw#6#in_flight#17:00:00#450#######'),
(400, 20, 'ba_51#big_europe_loop#britishairways#n517ly#0#on_ground#11:30:00#100#######'),
(400, 20, 'ba_61#americas_two#britishairways#n616lt#0#on_ground#09:30:00#200#######'),
(400, 20, 'dl_10#americas_one#delta#n106js#1#in_flight#08:00:00#200#######'),
(400, 20, 'dl_42#texas_local#delta#n110jn#1#in_flight#14:00:00#220#######'),
(400, 20, 'ja_35#pacific_rim_tour#japanairlines#n305fv#1#in_flight#09:30:00#300#######'),
(400, 20, 'ke_64#korea_direct#koreanairlines#n180co#1#on_ground#16:00:00#500#######'),
(400, 20, 'ke_88#pacific_rim_tour#koreanairlines#n266f7#3#on_ground#11:00:00#450#######'),
(400, 20, 'km_16#euro_south#klm#n161fk#6#in_flight#14:00:00#400#######'),
(400, 20, 'lf_20#euro_north#lufthansa#n620la#3#in_flight#11:00:00#300#######'),
(400, 20, 'lf_67#euro_north#lufthansa#n653fk#6#on_ground#21:23:00#900#######'),
(400, 20, 'nk_17#americas_two#spirit#n223gw#0#on_ground#08:30:00#200#######'),
(400, 20, 'nk_98#texas_local#spirit#n270ff#1#on_ground#13:13:13#200#######'),
(400, 20, 'ry_34#germany_local#ryanair#n341eb#0#on_ground#15:00:00#100#######'),
(400, 20, 'un_38#americas_three#united#n380sd#2#in_flight#14:30:00#200#######');

create or replace view magic44_test_case_frequencies as
select test_case_category, count(distinct step_id) as num_test_cases
from (select step_id, query_id, row_hash, 20 * truncate(step_id / 20, 0) as test_case_category
from magic44_expected_results where step_id < 600) as combine_tests
group by test_case_category
union
select test_case_category, count(distinct step_id) as num_test_cases
from (select step_id, query_id, row_hash, 50 * truncate(step_id / 50, 0) as test_case_category
from magic44_expected_results where step_id >= 600) as combine_tests
group by test_case_category;

-- ----------------------------------------------------------------------------------
-- [7] Compare & evaluate the testing results
-- ----------------------------------------------------------------------------------

-- Delete the unneeded rows from the answers table to simplify later analysis
-- delete from magic44_expected_results where not magic44_query_exists(query_id);

-- Modify the row hash results for the results table to eliminate spaces and convert all characters to lowercase
update magic44_test_results set row_hash = lower(replace(row_hash, ' ', ''));

-- The magic44_count_differences view displays the differences between the number of rows contained in the answers
-- and the test results.  The value null in the answer_total and result_total columns represents zero (0) rows for
-- that query result.

drop view if exists magic44_count_answers;
create view magic44_count_answers as
select step_id, query_id, count(*) as answer_total
from magic44_expected_results group by step_id, query_id;

drop view if exists magic44_count_test_results;
create view magic44_count_test_results as
select step_id, query_id, count(*) as result_total
from magic44_test_results group by step_id, query_id;

drop view if exists magic44_count_differences;
create view magic44_count_differences as
select magic44_count_answers.query_id, magic44_count_answers.step_id, answer_total, result_total
from magic44_count_answers left outer join magic44_count_test_results
	on magic44_count_answers.step_id = magic44_count_test_results.step_id
	and magic44_count_answers.query_id = magic44_count_test_results.query_id
where answer_total <> result_total or result_total is null
union
select magic44_count_test_results.query_id, magic44_count_test_results.step_id, answer_total, result_total
from magic44_count_test_results left outer join magic44_count_answers
	on magic44_count_test_results.step_id = magic44_count_answers.step_id
	and magic44_count_test_results.query_id = magic44_count_answers.query_id
where result_total <> answer_total or answer_total is null
order by query_id, step_id;

-- The magic44_content_differences view displays the differences between the answers and test results
-- in terms of the row attributes and values.  the error_category column contains missing for rows that
-- are not included in the test results but should be, while extra represents the rows that should not
-- be included in the test results.  the row_hash column contains the values of the row in a single
-- string with the attribute values separated by a selected delimiter (i.e., the pound sign/#).

drop view if exists magic44_content_differences;
create view magic44_content_differences as
select query_id, step_id, 'missing' as category, row_hash
from magic44_expected_results where row(step_id, query_id, row_hash) not in
	(select step_id, query_id, row_hash from magic44_test_results)
union
select query_id, step_id, 'extra' as category, row_hash
from magic44_test_results where row(step_id, query_id, row_hash) not in
	(select step_id, query_id, row_hash from magic44_expected_results)
order by query_id, step_id, row_hash;

drop view if exists magic44_result_set_size_errors;
create view magic44_result_set_size_errors as
select step_id, query_id, 'result_set_size' as err_category from magic44_count_differences
group by step_id, query_id;

drop view if exists magic44_attribute_value_errors;
create view magic44_attribute_value_errors as
select step_id, query_id, 'attribute_values' as err_category from magic44_content_differences
where row(step_id, query_id) not in (select step_id, query_id from magic44_count_differences)
group by step_id, query_id;

drop view if exists magic44_errors_assembled;
create view magic44_errors_assembled as
select * from magic44_result_set_size_errors
union
select * from magic44_attribute_value_errors;

drop table if exists magic44_row_count_errors;
create table magic44_row_count_errors
select * from magic44_count_differences
order by query_id, step_id;

drop table if exists magic44_column_errors;
create table magic44_column_errors
select * from magic44_content_differences
order by query_id, step_id, row_hash;

drop view if exists magic44_fast_expected_results;
create view magic44_fast_expected_results as
select step_id, query_id, query_label, query_name
from magic44_expected_results, magic44_test_case_directory
where base_step_id <= step_id and step_id <= (base_step_id + number_of_steps - 1)
group by step_id, query_id, query_label, query_name;

drop view if exists magic44_fast_row_based_errors;
create view magic44_fast_row_based_errors as
select step_id, query_id, query_label, query_name
from magic44_row_count_errors, magic44_test_case_directory
where base_step_id <= step_id and step_id <= (base_step_id + number_of_steps - 1)
group by step_id, query_id, query_label, query_name;

drop view if exists magic44_fast_column_based_errors;
create view magic44_fast_column_based_errors as
select step_id, query_id, query_label, query_name
from magic44_column_errors, magic44_test_case_directory
where base_step_id <= step_id and step_id <= (base_step_id + number_of_steps - 1)
group by step_id, query_id, query_label, query_name;

drop view if exists magic44_fast_total_test_cases;
create view magic44_fast_total_test_cases as
select query_label, query_name, count(*) as total_cases
from magic44_fast_expected_results group by query_label, query_name;

drop view if exists magic44_fast_correct_test_cases;
create view magic44_fast_correct_test_cases as
select query_label, query_name, count(*) as correct_cases
from magic44_fast_expected_results where row(step_id, query_id) not in
(select step_id, query_id from magic44_fast_row_based_errors
union select step_id, query_id from magic44_fast_column_based_errors)
group by query_label, query_name;

drop table if exists magic44_autograding_low_level;
create table magic44_autograding_low_level
select magic44_fast_total_test_cases.*, ifnull(correct_cases, 0) as passed_cases
from magic44_fast_total_test_cases left outer join magic44_fast_correct_test_cases
on magic44_fast_total_test_cases.query_label = magic44_fast_correct_test_cases.query_label
and magic44_fast_total_test_cases.query_name = magic44_fast_correct_test_cases.query_name;

drop table if exists magic44_autograding_score_summary;
create table magic44_autograding_score_summary
select query_label, query_name,
	round(scoring_weight * passed_cases / total_cases, 2) as final_score, scoring_weight
from magic44_autograding_low_level natural join magic44_test_case_directory
where passed_cases < total_cases
union
select null, 'REMAINING CORRECT CASES', sum(round(scoring_weight * passed_cases / total_cases, 2)), null
from magic44_autograding_low_level natural join magic44_test_case_directory
where passed_cases = total_cases
union
select null, 'TOTAL SCORE', sum(round(scoring_weight * passed_cases / total_cases, 2)), null
from magic44_autograding_low_level natural join magic44_test_case_directory;

drop table if exists magic44_autograding_high_level;
create table magic44_autograding_high_level
select score_tag, score_category, sum(total_cases) as total_possible,
	sum(passed_cases) as total_passed
from magic44_scores_guide natural join
(select *, mid(query_label, 2, 1) as score_tag from magic44_autograding_low_level) as temp
group by score_tag, score_category; -- order by display_order;

-- Evaluate potential query errors against the original state and the modified state
drop view if exists magic44_result_errs_original;
create view magic44_result_errs_original as
select distinct 'row_count_errors_initial_state' as title, query_id
from magic44_row_count_errors where step_id = 0;

drop view if exists magic44_result_errs_modified;
create view magic44_result_errs_modified as
select distinct 'row_count_errors_test_cases' as title, query_id
from magic44_row_count_errors
where query_id not in (select query_id from magic44_result_errs_original)
union
select * from magic44_result_errs_original;

drop view if exists magic44_attribute_errs_original;
create view magic44_attribute_errs_original as
select distinct 'column_errors_initial_state' as title, query_id
from magic44_column_errors where step_id = 0
and query_id not in (select query_id from magic44_result_errs_modified)
union
select * from magic44_result_errs_modified;

drop view if exists magic44_attribute_errs_modified;
create view magic44_attribute_errs_modified as
select distinct 'column_errors_test_cases' as title, query_id
from magic44_column_errors
where query_id not in (select query_id from magic44_attribute_errs_original)
union
select * from magic44_attribute_errs_original;

drop view if exists magic44_correct_remainders;
create view magic44_correct_remainders as
select distinct 'fully_correct' as title, query_id
from magic44_test_results
where query_id not in (select query_id from magic44_attribute_errs_modified)
union
select * from magic44_attribute_errs_modified;

drop view if exists magic44_grading_rollups;
create view magic44_grading_rollups as
select title, count(*) as number_affected, group_concat(query_id order by query_id asc) as queries_affected
from magic44_correct_remainders
group by title;

drop table if exists magic44_autograding_directory;
create table magic44_autograding_directory (query_status_category varchar(1000));
insert into magic44_autograding_directory values ('fully_correct'),
('column_errors_initial_state'), ('row_count_errors_initial_state'),
('column_errors_test_cases'), ('row_count_errors_test_cases');

drop table if exists magic44_autograding_query_level;
create table magic44_autograding_query_level
select query_status_category, number_affected, queries_affected
from magic44_autograding_directory left outer join magic44_grading_rollups
on query_status_category = title;

-- ----------------------------------------------------------------------------------
-- Validate/verify that the test case results are correct
-- The test case results are compared to the initial database state contents
-- ----------------------------------------------------------------------------------

drop procedure if exists magic44_check_test_case;
delimiter //
create procedure magic44_check_test_case(in ip_test_case_number integer)
begin
	select * from (select query_id, 'added' as category, row_hash
	from magic44_test_results where step_id = ip_test_case_number and row(query_id, row_hash) not in
		(select query_id, row_hash from magic44_expected_results where step_id = 0)
	union
	select temp.query_id, 'removed' as category, temp.row_hash
	from (select query_id, row_hash from magic44_expected_results where step_id = 0) as temp
	where row(temp.query_id, temp.row_hash) not in
		(select query_id, row_hash from magic44_test_results where step_id = ip_test_case_number)
	and temp.query_id in
		(select query_id from magic44_test_results where step_id = ip_test_case_number)) as unified
	order by query_id, row_hash;
end //
delimiter ;

-- ----------------------------------------------------------------------------------
-- [8] Generate views to help interpret the test results more easily
-- ----------------------------------------------------------------------------------
drop table if exists magic44_table_name_lookup;
create table magic44_table_name_lookup (
	query_id integer,
	table_or_view_name varchar(2000),
    primary key (query_id)
);

insert into magic44_table_name_lookup values
(10, 'airline'), (11, 'location'), (12, 'airplane'), (13, 'airport'), (14, 'person'),
(15, 'passenger'), (16, 'passenger_vacations'), (17, 'leg'), (18, 'route'), (19, 'route_path'),
(20, 'flight'), (21, 'pilot'), (22, 'pilot_licenses'), (30, 'flights_in_the_air'),
(31, 'flights_on_the_ground'), (32, 'people_in_the_air'), (33, 'people_on_the_ground'),
(34, 'route_summary'), (35, 'alternative_airports');

create or replace view magic44_column_errors_traceable as
select query_label as test_category, query_name as test_name, step_id as test_step_counter,
	table_or_view_name, category as error_category, row_hash
from (magic44_column_errors join magic44_test_case_directory
on (step_id between base_step_id and base_step_id + number_of_steps - 1))
natural join magic44_table_name_lookup
order by test_category, test_step_counter, row_hash;

-- ----------------------------------------------------------------------------------
-- [9] Remove unneeded tables, views, stored procedures and functions
-- ----------------------------------------------------------------------------------
-- Keep only those structures needed to provide student feedback
drop table if exists magic44_autograding_directory;

drop view if exists magic44_grading_rollups;
drop view if exists magic44_correct_remainders;
drop view if exists magic44_attribute_errs_modified;
drop view if exists magic44_attribute_errs_original;
drop view if exists magic44_result_errs_modified;
drop view if exists magic44_result_errs_original;
drop view if exists magic44_errors_assembled;
drop view if exists magic44_attribute_value_errors;
drop view if exists magic44_result_set_size_errors;
drop view if exists magic44_content_differences;
drop view if exists magic44_count_differences;
drop view if exists magic44_count_test_results;
drop view if exists magic44_count_answers;

drop procedure if exists magic44_query_check_and_run;

drop function if exists magic44_query_exists;
drop function if exists magic44_query_capture;
drop function if exists magic44_gen_simple_template;

drop table if exists magic44_column_listing;

-- The magic44_reset_database_state() and magic44_check_test_case procedures can be
-- dropped if desired, but they might be helpful for troubleshooting
-- drop procedure if exists magic44_reset_database_state;
-- drop procedure if exists magic44_check_test_case;

drop view if exists practiceQuery10;
drop view if exists practiceQuery11;
drop view if exists practiceQuery12;
drop view if exists practiceQuery13;
drop view if exists practiceQuery14;
drop view if exists practiceQuery15;
drop view if exists practiceQuery16;
drop view if exists practiceQuery17;
drop view if exists practiceQuery18;
drop view if exists practiceQuery19;
drop view if exists practiceQuery20;
drop view if exists practiceQuery21;
drop view if exists practiceQuery22;

drop view if exists practiceQuery30;
drop view if exists practiceQuery31;
drop view if exists practiceQuery32;
drop view if exists practiceQuery33;
drop view if exists practiceQuery34;
drop view if exists practiceQuery35;

drop view if exists magic44_fast_correct_test_cases;
drop view if exists magic44_fast_total_test_cases;
drop view if exists magic44_fast_column_based_errors;
drop view if exists magic44_fast_row_based_errors;
drop view if exists magic44_fast_expected_results;

drop table if exists magic44_scores_guide;
