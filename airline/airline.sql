-- Ensure no auto value on zero and transaction start
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- Create `admin` table
CREATE TABLE IF NOT EXISTS `admin` (
  `Admin_ID` varchar(20) NOT NULL,
  `Name` varchar(20) DEFAULT NULL,
  `Pswd` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`Admin_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default admin
INSERT INTO `admin` (`Admin_ID`, `Name`, `Pswd`) VALUES ('1', 'admin', 'admin');

-- Create `planes` table
CREATE TABLE IF NOT EXISTS `planes` (
  `Plane_Name` varchar(20) NOT NULL,
  `Class` varchar(10) DEFAULT NULL,
  `Seats` int(11) DEFAULT NULL,
  PRIMARY KEY (`Plane_Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data into `planes`
INSERT INTO `planes` (`Plane_Name`, `Class`, `Seats`) VALUES
('AirIndia', 'Business', 30),
('emirates', 'General', 10),
('indigo', 'Business', 3),
('Kingfisher', 'Business', 20),
('SpiceJet', 'Business', 5);

-- Create `aircraft` table (without inserting values)
CREATE TABLE IF NOT EXISTS `aircraft` (
  `Flight_ID` varchar(20) NOT NULL,
  `Dep_Time` datetime NOT NULL,
  `Arr_Time` datetime DEFAULT NULL,
  `Plane_Name` varchar(20) DEFAULT NULL,
  `Src` varchar(20) DEFAULT NULL,
  `Dstn` varchar(20) DEFAULT NULL,
  `Fare` decimal(10,2) DEFAULT NULL,
  `Dep_Date` date DEFAULT NULL,
  `Flight_Status` varchar(20) DEFAULT 'Scheduled',
  PRIMARY KEY (`Flight_ID`, `Dep_Time`),
  KEY `Plane_Name` (`Plane_Name`),
  CONSTRAINT `fk_aircraft_planes` FOREIGN KEY (`Plane_Name`) REFERENCES `planes` (`Plane_Name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create `users` table
CREATE TABLE IF NOT EXISTS `users` (
  `User_ID` int(11) NOT NULL AUTO_INCREMENT,
  `User_Name` varchar(20) NOT NULL,
  `Pswd` varchar(20) DEFAULT NULL,
  `Email` varchar(20) DEFAULT NULL,
  `Phone` varchar(13) DEFAULT NULL,
  `Age` int(11) DEFAULT NULL,
  PRIMARY KEY (`User_ID`),
  UNIQUE KEY `User_Name` (`User_Name`),
  UNIQUE KEY `Phone` (`Phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
ALTER TABLE users ADD Gender VARCHAR(10);



-- Create `bookings` table
CREATE TABLE IF NOT EXISTS `bookings` (
  `Booking_ID` int(11) NOT NULL AUTO_INCREMENT,
  `User_ID` int(11) NOT NULL,
  `Flight_ID` varchar(20) NOT NULL,
  `Dep_Time` datetime NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Phone` varchar(20) NOT NULL,
  `Age` int(11) NOT NULL,
  `Gender` enum('Male','Female','Other') NOT NULL,
  PRIMARY KEY (`Booking_ID`),
  KEY `User_ID` (`User_ID`),
  KEY `Flight_ID` (`Flight_ID`, `Dep_Time`),
  CONSTRAINT `fk_bookings_users` FOREIGN KEY (`User_ID`) REFERENCES `users` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_bookings_aircraft` FOREIGN KEY (`Flight_ID`, `Dep_Time`) REFERENCES `aircraft` (`Flight_ID`, `Dep_Time`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- Create `passenger` table
CREATE TABLE IF NOT EXISTS `passenger` (
  `P_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) DEFAULT NULL,
  `Age` int(11) DEFAULT NULL,
  `Flight_ID` varchar(20) NOT NULL,
  `Dep_Time` datetime NOT NULL,
  `User_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`P_ID`),
  KEY `Flight_ID` (`Flight_ID`, `Dep_Time`),
  KEY `User_ID` (`User_ID`),
  CONSTRAINT `fk_passenger_aircraft` FOREIGN KEY (`Flight_ID`, `Dep_Time`) REFERENCES `aircraft` (`Flight_ID`, `Dep_Time`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_passenger_users` FOREIGN KEY (`User_ID`) REFERENCES `users` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Trigger to update `aircraft` table Flight_Status after insert in `passenger`
DELIMITER //

CREATE TRIGGER `passenger_insert_trigger` AFTER INSERT ON `passenger`
FOR EACH ROW
BEGIN
    UPDATE `aircraft` SET `Flight_Status` = 'Booked' WHERE `Flight_ID` = NEW.`Flight_ID` AND `Dep_Time` = NEW.`Dep_Time`;
END;

//

-- Trigger to update `aircraft` table Flight_Status after update in `passenger`
CREATE TRIGGER `passenger_update_trigger` AFTER UPDATE ON `passenger`
FOR EACH ROW
BEGIN
    UPDATE `aircraft` SET `Flight_Status` = 'Booked' WHERE `Flight_ID` = NEW.`Flight_ID` AND `Dep_Time` = NEW.`Dep_Time`;
END;

//

-- Trigger to update `aircraft` table Flight_Status after delete in `passenger`
CREATE TRIGGER `passenger_delete_trigger` AFTER DELETE ON `passenger`
FOR EACH ROW
BEGIN
    UPDATE `aircraft` SET `Flight_Status` = 'Scheduled' WHERE `Flight_ID` = OLD.`Flight_ID` AND `Dep_Time` = OLD.`Dep_Time`;
END;

//

DELIMITER ;



-- Insert sample data into `aircraft`
INSERT INTO `aircraft` (`Flight_ID`, `Dep_Time`, `Arr_Time`, `Plane_Name`, `Src`, `Dstn`, `Fare`, `Dep_Date`, `Flight_Status`) VALUES
-- Week 1 (July 8 - July 14, 2024)
('FL001', '2024-07-08 08:00:00', '2024-07-08 10:00:00', 'AirIndia', 'Bangalore', 'Mumbai', 3000, '2024-07-08', 'Scheduled'),
('FL002', '2024-07-08 11:00:00', '2024-07-08 13:30:00', 'emirates', 'Mumbai', 'Delhi', 3500, '2024-07-08', 'Scheduled'),
('FL003', '2024-07-08 14:00:00', '2024-07-08 16:00:00', 'indigo', 'Delhi', 'Chennai', 2500, '2024-07-08', 'Scheduled'),
('FL004', '2024-07-08 17:00:00', '2024-07-08 19:30:00', 'Kingfisher', 'Chennai', 'Bangalore', 2000, '2024-07-08', 'Scheduled'),
('FL005', '2024-07-09 08:00:00', '2024-07-09 10:00:00', 'AirIndia', 'Mumbai', 'Delhi', 4000, '2024-07-09', 'Scheduled'),
('FL006', '2024-07-09 11:00:00', '2024-07-09 13:30:00', 'emirates', 'Delhi', 'Bangalore', 3200, '2024-07-09', 'Scheduled'),
('FL007', '2024-07-09 14:00:00', '2024-07-09 16:00:00', 'indigo', 'Bangalore', 'Chennai', 2200, '2024-07-09', 'Scheduled'),
('FL008', '2024-07-09 17:00:00', '2024-07-09 19:30:00', 'Kingfisher', 'Chennai', 'Mumbai', 2800, '2024-07-09', 'Scheduled'),
('FL009', '2024-07-10 08:00:00', '2024-07-10 10:00:00', 'AirIndia', 'Delhi', 'Chennai', 4500, '2024-07-10', 'Scheduled'),
('FL010', '2024-07-10 11:00:00', '2024-07-10 13:30:00', 'emirates', 'Chennai', 'Mumbai', 2700, '2024-07-10', 'Scheduled'),
('FL011', '2024-07-10 14:00:00', '2024-07-10 16:00:00', 'indigo', 'Mumbai', 'Bangalore', 2500, '2024-07-10', 'Scheduled'),
('FL012', '2024-07-10 17:00:00', '2024-07-10 19:30:00', 'Kingfisher', 'Bangalore', 'Delhi', 3000, '2024-07-10', 'Scheduled'),
('FL013', '2024-07-11 08:00:00', '2024-07-11 10:00:00', 'AirIndia', 'Chennai', 'Bangalore', 2000, '2024-07-11', 'Scheduled'),
('FL014', '2024-07-11 11:00:00', '2024-07-11 13:30:00', 'emirates', 'Bangalore', 'Delhi', 3200, '2024-07-11', 'Scheduled'),
('FL015', '2024-07-11 14:00:00', '2024-07-11 16:00:00', 'indigo', 'Delhi', 'Mumbai', 4000, '2024-07-11', 'Scheduled'),
('FL016', '2024-07-11 17:00:00', '2024-07-11 19:30:00', 'Kingfisher', 'Mumbai', 'Chennai', 2700, '2024-07-11', 'Scheduled'),
('FL017', '2024-07-12 08:00:00', '2024-07-12 10:00:00', 'AirIndia', 'Bangalore', 'Mumbai', 3000, '2024-07-12', 'Scheduled'),
('FL018', '2024-07-12 11:00:00', '2024-07-12 13:30:00', 'emirates', 'Mumbai', 'Delhi', 3500, '2024-07-12', 'Scheduled'),
('FL019', '2024-07-12 14:00:00', '2024-07-12 16:00:00', 'indigo', 'Delhi', 'Chennai', 2500, '2024-07-12', 'Scheduled'),
('FL020', '2024-07-12 17:00:00', '2024-07-12 19:30:00', 'Kingfisher', 'Chennai', 'Bangalore', 2000, '2024-07-12', 'Scheduled'),
('FL021', '2024-07-13 08:00:00', '2024-07-13 10:00:00', 'AirIndia', 'Mumbai', 'Delhi', 4000, '2024-07-13', 'Scheduled'),
('FL022', '2024-07-13 11:00:00', '2024-07-13 13:30:00', 'emirates', 'Delhi', 'Bangalore', 3200, '2024-07-13', 'Scheduled'),
('FL023', '2024-07-13 14:00:00', '2024-07-13 16:00:00', 'indigo', 'Bangalore', 'Chennai', 2200, '2024-07-13', 'Scheduled'),
('FL024', '2024-07-13 17:00:00', '2024-07-13 19:30:00', 'Kingfisher', 'Chennai', 'Mumbai', 2800, '2024-07-13', 'Scheduled'),
('FL025', '2024-07-14 08:00:00', '2024-07-14 10:00:00', 'AirIndia', 'Delhi', 'Chennai', 4500, '2024-07-14', 'Scheduled'),
('FL026', '2024-07-14 11:00:00', '2024-07-14 13:30:00', 'emirates', 'Chennai', 'Mumbai', 2700, '2024-07-14', 'Scheduled'),
('FL027', '2024-07-14 14:00:00', '2024-07-14 16:00:00', 'indigo', 'Mumbai', 'Bangalore', 2500, '2024-07-14', 'Scheduled'),
('FL028', '2024-07-14 17:00:00', '2024-07-14 19:30:00', 'Kingfisher', 'Bangalore', 'Delhi', 3000, '2024-07-14', 'Scheduled'),

-- Week 2 (July 15 - July 21, 2024)
('FL029', '2024-07-15 08:00:00', '2024-07-15 10:00:00', 'AirIndia', 'Chennai', 'Bangalore', 2000, '2024-07-15', 'Scheduled'),
('FL030', '2024-07-15 11:00:00', '2024-07-15 13:30:00', 'emirates', 'Bangalore', 'Delhi', 3200, '2024-07-15', 'Scheduled'),
('FL031', '2024-07-15 14:00:00', '2024-07-15 16:00:00', 'indigo', 'Delhi', 'Mumbai', 4000, '2024-07-15', 'Scheduled'),
('FL032', '2024-07-15 17:00:00', '2024-07-15 19:30:00', 'Kingfisher', 'Mumbai', 'Chennai', 2700, '2024-07-15', 'Scheduled'),
('FL033', '2024-07-16 08:00:00', '2024-07-16 10:00:00', 'AirIndia', 'Bangalore', 'Mumbai', 3000, '2024-07-16', 'Scheduled'),
('FL034', '2024-07-16 11:00:00', '2024-07-16 13:30:00', 'emirates', 'Mumbai', 'Delhi', 3500, '2024-07-16', 'Scheduled'),
('FL035', '2024-07-16 14:00:00', '2024-07-16 16:00:00', 'indigo', 'Delhi', 'Chennai', 2500, '2024-07-16', 'Scheduled'),
('FL036', '2024-07-16 17:00:00', '2024-07-16 19:30:00', 'Kingfisher', 'Chennai', 'Bangalore', 2000, '2024-07-16', 'Scheduled'),
('FL037', '2024-07-17 08:00:00', '2024-07-17 10:00:00', 'AirIndia', 'Mumbai', 'Delhi', 4000, '2024-07-17', 'Scheduled'),
('FL038', '2024-07-17 11:00:00', '2024-07-17 13:30:00', 'emirates', 'Delhi', 'Bangalore', 3200, '2024-07-17', 'Scheduled'),
('FL039', '2024-07-17 14:00:00', '2024-07-17 16:00:00', 'indigo', 'Bangalore', 'Chennai', 2200, '2024-07-17', 'Scheduled'),
('FL040', '2024-07-17 17:00:00', '2024-07-17 19:30:00', 'Kingfisher', 'Chennai', 'Mumbai', 2800, '2024-07-17', 'Scheduled'),
('FL041', '2024-07-18 08:00:00', '2024-07-18 10:00:00', 'AirIndia', 'Delhi', 'Chennai', 4500, '2024-07-18', 'Scheduled'),
('FL042', '2024-07-18 11:00:00', '2024-07-18 13:30:00', 'emirates', 'Chennai', 'Mumbai', 2700, '2024-07-18', 'Scheduled'),
('FL043', '2024-07-18 14:00:00', '2024-07-18 16:00:00', 'indigo', 'Mumbai', 'Bangalore', 2500, '2024-07-18', 'Scheduled'),
('FL044', '2024-07-18 17:00:00', '2024-07-18 19:30:00', 'Kingfisher', 'Bangalore', 'Delhi', 3000, '2024-07-18', 'Scheduled'),
('FL045', '2024-07-19 08:00:00', '2024-07-19 10:00:00', 'AirIndia', 'Chennai', 'Bangalore', 2000, '2024-07-19', 'Scheduled'),
('FL046', '2024-07-19 11:00:00', '2024-07-19 13:30:00', 'emirates', 'Bangalore', 'Delhi', 3200, '2024-07-19', 'Scheduled'),
('FL047', '2024-07-19 14:00:00', '2024-07-19 16:00:00', 'indigo', 'Delhi', 'Mumbai', 4000, '2024-07-19', 'Scheduled'),
('FL048', '2024-07-19 17:00:00', '2024-07-19 19:30:00', 'Kingfisher', 'Mumbai', 'Chennai', 2700, '2024-07-19', 'Scheduled'),
('FL049', '2024-07-20 08:00:00', '2024-07-20 10:00:00', 'AirIndia', 'Bangalore', 'Mumbai', 3000, '2024-07-20', 'Scheduled'),
('FL050', '2024-07-20 11:00:00', '2024-07-20 13:30:00', 'emirates', 'Mumbai', 'Delhi', 3500, '2024-07-20', 'Scheduled'),
('FL051', '2024-07-20 14:00:00', '2024-07-20 16:00:00', 'indigo', 'Delhi', 'Chennai', 2500, '2024-07-20', 'Scheduled'),
('FL052', '2024-07-20 17:00:00', '2024-07-20 19:30:00', 'Kingfisher', 'Chennai', 'Bangalore', 2000, '2024-07-20', 'Scheduled'),
('FL053', '2024-07-21 08:00:00', '2024-07-21 10:00:00', 'AirIndia', 'Mumbai', 'Delhi', 4000, '2024-07-21', 'Scheduled'),
('FL054', '2024-07-21 11:00:00', '2024-07-21 13:30:00', 'emirates', 'Delhi', 'Bangalore', 3200, '2024-07-21', 'Scheduled'),
('FL055', '2024-07-21 14:00:00', '2024-07-21 16:00:00', 'indigo', 'Bangalore', 'Chennai', 2200, '2024-07-21', 'Scheduled'),
('FL056', '2024-07-21 17:00:00', '2024-07-21 19:30:00', 'Kingfisher', 'Chennai', 'Mumbai', 2800, '2024-07-21', 'Scheduled'),

-- Week 3 (July 22 - July 28, 2024)
('FL057', '2024-07-22 08:00:00', '2024-07-22 10:00:00', 'AirIndia', 'Delhi', 'Chennai', 4500, '2024-07-22', 'Scheduled'),
('FL058', '2024-07-22 11:00:00', '2024-07-22 13:30:00', 'emirates', 'Chennai', 'Mumbai', 2700, '2024-07-22', 'Scheduled'),
('FL059', '2024-07-22 14:00:00', '2024-07-22 16:00:00', 'indigo', 'Mumbai', 'Bangalore', 2500, '2024-07-22', 'Scheduled'),
('FL060', '2024-07-22 17:00:00', '2024-07-22 19:30:00', 'Kingfisher', 'Bangalore', 'Delhi', 3000, '2024-07-22', 'Scheduled'),
('FL061', '2024-07-23 08:00:00', '2024-07-23 10:00:00', 'AirIndia', 'Chennai', 'Bangalore', 2000, '2024-07-23', 'Scheduled'),
('FL062', '2024-07-23 11:00:00', '2024-07-23 13:30:00', 'emirates', 'Bangalore', 'Delhi', 3200, '2024-07-23', 'Scheduled'),
('FL063', '2024-07-23 14:00:00', '2024-07-23 16:00:00', 'indigo', 'Delhi', 'Mumbai', 4000, '2024-07-23', 'Scheduled'),
('FL064', '2024-07-23 17:00:00', '2024-07-23 19:30:00', 'Kingfisher', 'Mumbai', 'Chennai', 2700, '2024-07-23', 'Scheduled'),
('FL065', '2024-07-24 08:00:00', '2024-07-24 10:00:00', 'AirIndia', 'Bangalore', 'Mumbai', 3000, '2024-07-24', 'Scheduled'),
('FL066', '2024-07-24 11:00:00', '2024-07-24 13:30:00', 'emirates', 'Mumbai', 'Delhi', 3500, '2024-07-24', 'Scheduled'),
('FL067', '2024-07-24 14:00:00', '2024-07-24 16:00:00', 'indigo', 'Delhi', 'Chennai', 2500, '2024-07-24', 'Scheduled'),
('FL068', '2024-07-24 17:00:00', '2024-07-24 19:30:00', 'Kingfisher', 'Chennai', 'Bangalore', 2000, '2024-07-24', 'Scheduled'),
('FL069', '2024-07-25 08:00:00', '2024-07-25 10:00:00', 'AirIndia', 'Mumbai', 'Delhi', 4000, '2024-07-25', 'Scheduled'),
('FL070', '2024-07-25 11:00:00', '2024-07-25 13:30:00', 'emirates', 'Delhi', 'Bangalore', 3200, '2024-07-25', 'Scheduled'),
('FL071', '2024-07-25 14:00:00', '2024-07-25 16:00:00', 'indigo', 'Bangalore', 'Chennai', 2200, '2024-07-25', 'Scheduled'),
('FL072', '2024-07-25 17:00:00', '2024-07-25 19:30:00', 'Kingfisher', 'Chennai', 'Mumbai', 2800, '2024-07-25', 'Scheduled'),
('FL073', '2024-07-26 08:00:00', '2024-07-26 10:00:00', 'AirIndia', 'Delhi', 'Chennai', 4500, '2024-07-26', 'Scheduled'),
('FL074', '2024-07-26 11:00:00', '2024-07-26 13:30:00', 'emirates', 'Chennai', 'Mumbai', 2700, '2024-07-26', 'Scheduled'),
('FL075', '2024-07-26 14:00:00', '2024-07-26 16:00:00', 'indigo', 'Mumbai', 'Bangalore', 2500, '2024-07-26', 'Scheduled'),
('FL076', '2024-07-26 17:00:00', '2024-07-26 19:30:00', 'Kingfisher', 'Bangalore', 'Delhi', 3000, '2024-07-26', 'Scheduled'),
('FL077', '2024-07-27 08:00:00', '2024-07-27 10:00:00', 'AirIndia', 'Chennai', 'Bangalore', 2000, '2024-07-27', 'Scheduled'),
('FL078', '2024-07-27 11:00:00', '2024-07-27 13:30:00', 'emirates', 'Bangalore', 'Delhi', 3200, '2024-07-27', 'Scheduled'),
('FL079', '2024-07-27 14:00:00', '2024-07-27 16:00:00', 'indigo', 'Delhi', 'Mumbai', 4000, '2024-07-27', 'Scheduled'),
('FL080', '2024-07-27 17:00:00', '2024-07-27 19:30:00', 'Kingfisher', 'Mumbai', 'Chennai', 2700, '2024-07-27', 'Scheduled'),
('FL081', '2024-07-28 08:00:00', '2024-07-28 10:00:00', 'AirIndia', 'Bangalore', 'Mumbai', 3000, '2024-07-28', 'Scheduled'),
('FL082', '2024-07-28 11:00:00', '2024-07-28 13:30:00', 'emirates', 'Mumbai', 'Delhi', 3500, '2024-07-28', 'Scheduled'),
('FL083', '2024-07-28 14:00:00', '2024-07-28 16:00:00', 'indigo', 'Delhi', 'Chennai', 2500, '2024-07-28', 'Scheduled'),
('FL084', '2024-07-28 17:00:00', '2024-07-28 19:30:00', 'Kingfisher', 'Chennai', 'Bangalore', 2000, '2024-07-28', 'Scheduled'),

-- Week 4 (July 29 - August 4, 2024)
('FL085', '2024-07-29 08:00:00', '2024-07-29 10:00:00', 'AirIndia', 'Delhi', 'Chennai', 4500, '2024-07-29', 'Scheduled'),
('FL086', '2024-07-29 11:00:00', '2024-07-29 13:30:00', 'emirates', 'Chennai', 'Mumbai', 2700, '2024-07-29', 'Scheduled'),
('FL087', '2024-07-29 14:00:00', '2024-07-29 16:00:00', 'indigo', 'Mumbai', 'Bangalore', 2500, '2024-07-29', 'Scheduled'),
('FL088', '2024-07-29 17:00:00', '2024-07-29 19:30:00', 'Kingfisher', 'Bangalore', 'Delhi', 3000, '2024-07-29', 'Scheduled'),
('FL089', '2024-07-30 08:00:00', '2024-07-30 10:00:00', 'AirIndia', 'Chennai', 'Bangalore', 2000, '2024-07-30', 'Scheduled'),
('FL090', '2024-07-30 11:00:00', '2024-07-30 13:30:00', 'emirates', 'Bangalore', 'Delhi', 3200, '2024-07-30', 'Scheduled'),
('FL091', '2024-07-30 14:00:00', '2024-07-30 16:00:00', 'indigo', 'Delhi', 'Mumbai', 4000, '2024-07-30', 'Scheduled'),
('FL092', '2024-07-30 17:00:00', '2024-07-30 19:30:00', 'Kingfisher', 'Mumbai', 'Chennai', 2700, '2024-07-30', 'Scheduled'),
('FL093', '2024-07-31 08:00:00', '2024-07-31 10:00:00', 'AirIndia', 'Bangalore', 'Mumbai', 3000, '2024-07-31', 'Scheduled'),
('FL094', '2024-07-31 11:00:00', '2024-07-31 13:30:00', 'emirates', 'Mumbai', 'Delhi', 3500, '2024-07-31', 'Scheduled'),
('FL095', '2024-07-31 14:00:00', '2024-07-31 16:00:00', 'indigo', 'Delhi', 'Chennai', 2500, '2024-07-31', 'Scheduled'),
('FL096', '2024-07-31 17:00:00', '2024-07-31 19:30:00', 'Kingfisher', 'Chennai', 'Bangalore', 2000, '2024-07-31', 'Scheduled'),
('FL097', '2024-08-01 08:00:00', '2024-08-01 10:00:00', 'AirIndia', 'Mumbai', 'Delhi', 4000, '2024-08-01', 'Scheduled'),
('FL098', '2024-08-01 11:00:00', '2024-08-01 13:30:00', 'emirates', 'Delhi', 'Bangalore', 3200, '2024-08-01', 'Scheduled'),
('FL099', '2024-08-01 14:00:00', '2024-08-01 16:00:00', 'indigo', 'Bangalore', 'Chennai', 2200, '2024-08-01', 'Scheduled'),
('FL100', '2024-08-01 17:00:00', '2024-08-01 19:30:00', 'Kingfisher', 'Chennai', 'Mumbai', 2800, '2024-08-01', 'Scheduled'),
('FL101', '2024-08-02 08:00:00', '2024-08-02 10:00:00', 'AirIndia', 'Delhi', 'Chennai', 4500, '2024-08-02', 'Scheduled'),
('FL102', '2024-08-02 11:00:00', '2024-08-02 13:30:00', 'emirates', 'Chennai', 'Mumbai', 2700, '2024-08-02', 'Scheduled');

COMMIT;

--Explanation:
--Triggers Overview:

--Insert Trigger (passenger_insert_trigger): Fires after an insert operation on the passenger table. It updates the corresponding row in the aircraft table, setting Flight_Status to 'Booked'.

--Update Trigger (passenger_update_trigger): Fires after an update operation on the passenger table. It updates the corresponding row in the aircraft table, setting Flight_Status to 'Booked'.

--Delete Trigger (passenger_delete_trigger): Fires after a delete operation on the passenger table. It updates the corresponding row in the aircraft table, setting Flight_Status back to 'Scheduled'.

--Execution:

--The DELIMITER command is used to change the delimiter from ; to // for creating triggers, as triggers contain multiple statements.
--After defining triggers, DELIMITER ; resets the delimiter back to ;.
--These triggers will silently update the Flight_Status in the aircraft table whenever a passenger booking is inserted, updated, or deleted, reflecting the current booking status of flights without generating any output or logging. Adjustments can be made based on specific requirements or additional functionality needed in your application.

