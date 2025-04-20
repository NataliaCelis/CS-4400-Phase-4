-- CS4400: Introduction to Database Systems: Monday, March 3, 2025
-- Simple Airline Management System Course Project Database (v0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;

-- Define the database structures
create table airline (
	airlineID varchar(50),
    revenue integer default null,
    primary key (airlineID)
) engine = innodb;

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

create table location (
	locationID varchar(50),
    primary key (locationID)
) engine = innodb;

INSERT INTO location (locationID) VALUES
    ('port_1'), ('port_2'), ('port_3'), ('port_10'), ('port_17'),
    ('plane_1'), ('plane_5'), ('plane_8'), ('plane_13'), ('plane_20'),
    ('port_12'), ('port_14'), ('port_15'), ('port_20'), ('port_4'),
    ('port_16'), ('port_11'), ('port_23'), ('port_7'), ('port_6'),
    ('port_13'), ('port_21'), ('port_18'), ('port_22'), ('plane_6'),
    ('plane_18'), ('plane_7'), ('plane_2'), ('plane_3'), ('plane_4'),
    ('port_24'), ('plane_10'), ('port_25'),('plane_26'),('plane_27'),
    ('plane_28'),('plane_29');

create table airplane (
	airlineID varchar(50),
    tail_num varchar(50),
    seat_capacity integer not null check (seat_capacity > 0),
    speed integer not null check (speed > 0),
    locationID varchar(50) default null,
    plane_type varchar(100) default null,
    maintenanced boolean default null,
    model varchar(50) default null,
    neo boolean default null,
    primary key (airlineID, tail_num),
    constraint fk1 foreign key (airlineID) references airline (airlineID),
    constraint fk3 foreign key (locationID) references location (locationID)
) engine = innodb;

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


create table airport (
	airportID char(3),
    airport_name varchar(200),
    city varchar(100) not null,
    state varchar(100) not null,
    country char(3) not null,
    locationID varchar(50) default null,
    primary key (airportID),
    constraint fk2 foreign key (locationID) references location (locationID)
) engine = innodb;

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

create table person (
	personID varchar(50),
    first_name varchar(100) not null,
    last_name varchar(100) default null,
    locationID varchar(50) not null,
    primary key (personID),
    constraint fk8 foreign key (locationID) references location (locationID)
) engine = innodb;

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

create table passenger (
	personID varchar(50),
    miles integer default 0,
    funds integer default 0,
    primary key (personID),
    constraint fk6 foreign key (personID) references person (personID)
) engine = innodb;

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

create table passenger_vacations (
	personID varchar(50),
    airportID char(3) not null,
    sequence integer check (sequence > 0),
    primary key (personID, sequence),
    constraint fk19 foreign key (personID) references person (personID)
		on update cascade on delete cascade,
    constraint fk20 foreign key (airportID) references airport (airportID)
) engine = innodb;

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

create table leg (
	legID varchar(50),
    departure char(3) not null,
    arrival char(3) not null,
	distance integer not null,
    primary key (legID),
    constraint fk10 foreign key (departure) references airport (airportID),
    constraint fk11 foreign key (arrival) references airport (airportID)
) engine = innodb;

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

create table route (
	routeID varchar(50),
    primary key (routeID)
) engine = innodb;

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

create table route_path (
	routeID varchar(50),
    legID varchar(50) not null,
    sequence integer check (sequence > 0),
    primary key (routeID, sequence),
    constraint fk12 foreign key (routeID) references route (routeID),
    constraint fk13 foreign key (legID) references leg (legID)
) engine = innodb;

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

create table flight (
	flightID varchar(50),
    routeID varchar(50) not null,
    support_airline varchar(50) default null,
    support_tail varchar(50) default null,
    progress integer default null,
    airplane_status varchar(100) default null,
    next_time time default null,
    cost integer default 0,
	primary key (flightID),
    constraint fk14 foreign key (routeID) references route (routeID) on update cascade,
    constraint fk15 foreign key (support_airline, support_tail) references airplane (airlineID, tail_num)
		on update cascade on delete cascade
) engine = innodb;

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


create table pilot (
	personID varchar(50),
    taxID varchar(50) not null,
    experience integer default 0,
    commanding_flight varchar(50) default null,
    primary key (personID),
    unique key (taxID),
    constraint fk4 foreign key (personID) references person (personID),
    constraint fk9 foreign key (commanding_flight) references flight (flightID)
) engine = innodb;

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

create table pilot_licenses (
	personID varchar(50),
    license varchar(100),
    primary key (personID, license),
    constraint fk5 foreign key (personID) references pilot (personID)
		on update cascade on delete cascade
) engine = innodb;

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
