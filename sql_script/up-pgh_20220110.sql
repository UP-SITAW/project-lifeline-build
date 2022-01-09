-- phpMyAdmin SQL Dump
-- version 4.9.5deb2
-- https://www.phpmyadmin.net/
--
-- Host: mysql_database:3306
-- Generation Time: Jan 09, 2022 at 07:23 PM
-- Server version: 8.0.27
-- PHP Version: 7.2.34-28+ubuntu20.04.1+deb.sury.org+1

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `up-pgh`
--
CREATE DATABASE IF NOT EXISTS `up-pgh` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `up-pgh`;

DELIMITER $$
--
-- Procedures
--
CREATE PROCEDURE `sp_addMonitor` (IN `monitorname` VARCHAR(250), IN `monitordesc` VARCHAR(1000), IN `wardid` INT, IN `maxslot` INT)  BEGIN
insert into r_monitor_details VALUES(null, monitorname,maxslot, monitordesc, 0,wardid,CURRENT_TIMESTAMP);
select last_insert_id() monitorid;
END$$

CREATE PROCEDURE `sp_addnotif` (IN `patientid` INT, IN `severity` INT, IN `hcode` VARCHAR(250), IN `obsid` INT)  BEGIN
insert into t_notifications VALUES (null, patientid , severity,hcode,obsid, CURRENT_TIMESTAMP);
END$$

CREATE PROCEDURE `sp_addpatient` (IN `fname` VARCHAR(250), IN `mname` VARCHAR(250), IN `lname` VARCHAR(250), IN `birthday` VARCHAR(50), IN `gender` VARCHAR(10), IN `age` INT, IN `remarks` VARCHAR(5000), IN `address` VARCHAR(1000), IN `city` VARCHAR(100), IN `country` VARCHAR(100), IN `contact` VARCHAR(100), IN `email` VARCHAR(100), IN `sss` VARCHAR(100), IN `philhealth` VARCHAR(100), IN `hmo` VARCHAR(100), IN `ward` INT, IN `contactname` VARCHAR(100), IN `contactnumber` VARCHAR(100), IN `rel` VARCHAR(100), IN `civil` VARCHAR(100), IN `bed_no` INT, IN `covidcase` INT, IN `admissionstatus` INT, IN `classification` INT)  BEGIN
Declare patientid int;
insert into r_patient_info VALUES (null, fname, mname,lname,gender,birthday, CURRENT_TIMESTAMP,age,remarks,address,city,country,contact,email,sss,philhealth,hmo,CURRENT_TIMESTAMP,ward,contactname,contactnumber,rel,1, civil, bed_no);

select last_insert_id() into patientid;

insert into r_patient_status VALUES(null, last_insert_id(),  classification,covidcase, admissionstatus, CURRENT_TIMESTAMP );

update r_patient_info set r_patient_info.rpi_patientstatus =  last_insert_id() where r_patient_info.rpi_patientid = patientid;

select patientid patient_id ;
end$$

CREATE PROCEDURE `sp_addpatienthistory` (IN `patientid` INT, IN `respiration` DOUBLE, IN `oxygen` DOUBLE, IN `sys` INT, IN `dias` INT, IN `heartrate` INT)  BEGIN
insert into t_patient_data_history VALUES(null, patientid, respiration, oxygen, sys, dias, heartrate, CURRENT_TIMESTAMP);
select last_insert_id() data_history, "success" result ;
end$$

CREATE PROCEDURE `sp_addPatienttoMonitor` (IN `patientid` INT, IN `monitorid` INT)  begin

Declare patientslot int;

select count(tml_listid) into  patientslot from t_monitor_list where tml_patientid = patientid and tml_monitorid = monitorid;

if patientslot > 0 THEN
delete from t_monitor_list where tml_patientid = patientid and tml_monitorid = monitorid;

insert into t_monitor_list VALUES (null, patientid, monitorid,0, CURRENT_TIMESTAMP);
end if;

if patientslot <=0 then 
insert into t_monitor_list VALUES (null, patientid, monitorid,0, CURRENT_TIMESTAMP);
end if;

select "sucess" result;
END$$

CREATE PROCEDURE `sp_addpatient_observation` (IN `id` VARCHAR(250), IN `obscode` VARCHAR(250), IN `obsvalue` VARCHAR(250), IN `subject` VARCHAR(250), IN `effectivity` VARCHAR(250), IN `obsstatus` VARCHAR(250), IN `dataerror` VARCHAR(250), IN `obssystem` VARCHAR(250), IN `valuesystem` VARCHAR(250), IN `valuecode` VARCHAR(250), IN `valueunit` VARCHAR(250))  BEGIN
insert into t_patient_observation values(null,
id,obscode , obsvalue, subject, effectivity, obsstatus, dataerror, obssystem,valuesystem,valuecode,valueunit
);

select "success", last_insert_id() id;
END$$

CREATE PROCEDURE `sp_addWard` (IN `wardname` VARCHAR(250), IN `warddesc` VARCHAR(1000))  BEGIN
insert into r_ward_details VALUES (null, wardname, warddesc, 0, CURRENT_TIMESTAMP);
select last_insert_id() wardid;
end$$

CREATE PROCEDURE `sp_add_patient_config` (IN `patientid` INT, IN `rpc_ecg_st_msec` DOUBLE, IN `rpc_heartrate_upper_bpm` DOUBLE, IN `rpc_heartrate_lower_bpm` DOUBLE, IN `rpc_pulserate_upper_bpm` DOUBLE, IN `rpc_pulserate_lower_bpm` DOUBLE, IN `rpc_oxygen_upper_saturation` DOUBLE, IN `rpc_oxygen_lower_saturation` DOUBLE, IN `rpc_respiratory_upper_rpm` DOUBLE, IN `rpc_respiratory_lower_rpm` DOUBLE, IN `rpc_bp_systolic_upper` DOUBLE, IN `rpc_bp_systolic_lower` DOUBLE, IN `rpc_bp_diastolic_upper` DOUBLE, IN `rpc_bp_diastolic_lower` DOUBLE, IN `rpc_bp_time_frame` DOUBLE, IN `rpc_temperature_upper` DOUBLE, IN `rpc_temperature_lower` DOUBLE)  begin 
insert into r_patient_config VALUES(null, patientid, rpc_ecg_st_msec, rpc_heartrate_upper_bpm, rpc_heartrate_lower_bpm, rpc_pulserate_upper_bpm, rpc_pulserate_lower_bpm, rpc_oxygen_upper_saturation, rpc_oxygen_lower_saturation, rpc_respiratory_upper_rpm, rpc_respiratory_lower_rpm, rpc_bp_systolic_upper, rpc_bp_systolic_lower, rpc_bp_diastolic_upper, rpc_bp_diastolic_lower, rpc_bp_time_frame, rpc_temperature_upper, rpc_temperature_lower, CURRENT_TIMESTAMP);
select last_insert_id() configid;
END$$

CREATE PROCEDURE `sp_checkpassword` (IN `userpass` VARCHAR(250))  BEGIN
declare checkpassword int;
select count(rsc_configid) into  checkpassword from r_system_config where rsc_hashedvalue= md5(userpass) and rsc_name="systempass";
if  checkpassword >0 then 
select "granted" as  access;
end if;
if checkpassword  =0 then 
select "fail"  as access;
end if;
END$$

CREATE PROCEDURE `sp_createstatuscode` (IN `name` VARCHAR(50), IN `descr` VARCHAR(150), IN `category` VARCHAR(100))  BEGIN
insert into r_patient_status() values(null,name, descr, category,1);
select last_insert_id() statusid;
END$$

CREATE PROCEDURE `sp_deleteMonitor` (IN `monitorid` INT)  begin
 update r_monitor_details set rmd_isRemoved =1 where rmd_monitorid = monitorid;
 update t_monitor_list set tml_isRemoved = 1 where tml_monitorid = monitorid;
select "deleted" result;
end$$

CREATE PROCEDURE `sp_deletepatient` (IN `patientid` INT)  BEGIN
update r_patient_info set rpi_patientstatus = NULL  where r_patient_info.rpi_patientid = patientid;
select "deleted" deletepatient_report;
end$$

CREATE PROCEDURE `sp_deletestatuscode` (IN `codeid` INT)  BEGIN
update r_patient_status set rps_isActive =0 where rps_id = codeid;
select 'deleted' result;
END$$

CREATE PROCEDURE `sp_filterstatuscode` (IN `category` VARCHAR(100))  BEGIN
select rps_id, rps_name, rps_desc, rps_category from r_patient_status_type where rps_category like concat('%',category,'%') and rps_isActive =1 ;
END$$

CREATE PROCEDURE `sp_getBPValue` (IN `requestid` INT)  BEGIN
select rob_bp, rob_status, rob_created from r_ondemand_bp where rob_requestid = requestid;
END$$

CREATE PROCEDURE `sp_getECGObs` ()  BEGIN
select * from t_patient_ecg inner join (select max(tpe_ecgkey) as ecgkey , tpe_subject as subject from t_patient_ecg GROUP by subject) jt on jt.ecgkey = tpe_ecgkey;
END$$

CREATE PROCEDURE `sp_getMonitorList` ()  BEGIN
select rmd_monitorid id, rmd_monitorname description , rmd_monitorname as name, concat('[',(select GROUP_CONCAT(tml_patientid) from t_monitor_list where tml_monitorid = rmd_monitorid and tml_isRemoved = 0),']') as patientIds, rmd_maxslot patientSlot from r_monitor_details where rmd_isRemoved != 1;
end$$

CREATE PROCEDURE `sp_getmonitorpatientlist` (IN `monitorname` VARCHAR(250))  begin
    select rmd_monitorid id, rmd_monitorname description , rmd_monitorname as name, concat('[',(select GROUP_CONCAT(tml_patientid)
        from t_monitor_list
        where tml_monitorid = rmd_monitorid and tml_isRemoved = 0),']') as patientIds, rmd_maxslot patientSlot
    from r_monitor_details
    where rmd_isRemoved != 1 and rmd_monitorname = monitorname;
END$$

CREATE PROCEDURE `sp_getNotifications` ()  BEGIN
select tn_patientid,tpo_code, tn_severity,r_severity.rs_level, r_severity.rs_description tn_code, tn_dateadded from t_notifications inner join r_severity on r_severity.rs_id = tn_severity inner join t_patient_observation on t_patient_observation.tpo_obsid = tn_obsid where TIMESTAMPDIFF(SECOND, tn_dateadded, now()) < 10 ;
END$$

CREATE PROCEDURE `sp_getondemandbp` ()  BEGIN
SELECT * FROM `r_ondemand_bp` WHERE rob_created >= NOW() - INTERVAL 30 second or rob_status = 0 and  rob_created >= NOW() - INTERVAL 2 minute;
END$$

CREATE PROCEDURE `sp_getPatientDetails` (IN `patientid` INT)  BEGIN
select  rpi_patientid, rpi_patientfname, rpi_patientmname, rpi_patientlname, rpi_gender,  (select rps_name from r_patient_status_type where rps_id = (select rps_class from r_patient_status where rps_pid=rpi_patientid)) classification,
(select rps_name from r_patient_status_type where rps_id = (select rps_case from r_patient_status where rps_pid=rpi_patientid)) 'Covid Case',
(select rps_name from r_patient_status_type where rps_id = (select rps_admission from r_patient_status where rps_pid=rpi_patientid)) 'Admission Status',
rpi_dateregistered, rpi_age, rpi_remarks, rpi_address, rpi_city, rpi_country, rpi_contact, rpi_email_add, rpi_sss_gsis_number, rpi_philhealth_number, rpi_hmo, rpi_date_admitted, rpi_ward_id, rpi_contact_name, rpi_contact_number, rpi_contact_relationship, rpi_patientstatus, DATE_FORMAT(str_to_date(rpi_birthday, '%m/%d/%Y' ), "%Y-%m-%d") rpi_birthday from r_patient_info where r_patient_info.rpi_patientid = patientid;
END$$

CREATE PROCEDURE `sp_getpatientlist` ()  BEGIN
select rpi_patientid,rpi_patientfname, rpi_patientmname, rpi_patientlname, rpi_gender, rpi_birthday, rpi_dateregistered, 
rpi_age,
(select rps_name from r_patient_status_type where rps_id = (select rps_class from r_patient_status where rps_pid=rpi_patientid)) classification,
(select rps_name from r_patient_status_type where rps_id = (select rps_case from r_patient_status where rps_pid=rpi_patientid)) 'Covid Case',
(select rps_name from r_patient_status_type where rps_id = (select rps_admission from r_patient_status where rps_pid=rpi_patientid)) 'Admission Status',
rpi_remarks, rpi_address, rpi_city, rpi_country,rpi_contact, rpi_email_add, rpi_sss_gsis_number, rpi_philhealth_number, rpi_hmo, rpi_date_admitted, "stable" rpi_patient_status, rpi_civilstatus, rpi_bednumber  from r_patient_info ;
end$$

CREATE PROCEDURE `sp_getPatientObservationRange` (IN `obscode` VARCHAR(50), IN `spec_date` VARCHAR(50), IN `patientid` VARCHAR(250), IN `utc_offset` VARCHAR(10))  BEGIN
select avg(tpo_value) avg_value, tpo_obsid, date_format( DATE_ADD(tpo_effectivity, INTERVAL utc_offset MINUTE), '%H' ) hour_clustered from t_patient_observation where date_format( DATE_ADD(tpo_effectivity, INTERVAL utc_offset MINUTE), '%Y-%m-%d' ) = date_format( spec_date, '%Y-%m-%d' ) and tpo_subject = patientid and tpo_code = obscode group by hour_clustered ;
end$$

CREATE PROCEDURE `sp_getPatientObservations` ()  BEGIN
select `tpo_effectivity`, tpo_subject, tpo_obsid, tpo_id, tpo_code, tpo_value, tpo_status, tpo_dataerror, tpo_system, tpo_valuesystem, tpo_valuecode, tpo_unit from t_patient_observation t inner join (select max(tpo_effectivity) as max_effectivity, tpo_code as code, tpo_subject as subject from t_patient_observation group by `tpo_code`, `tpo_subject`)g on g.max_effectivity = t.tpo_effectivity and g.subject = t.tpo_subject and g.code = t.tpo_code;
end$$

CREATE PROCEDURE `sp_getpatienttimeframe` (IN `patientid` INT)  BEGIN
select rpc_time_frame from r_patient_config where rpc_patientid = patientid order by rpc_configid desc limit 1;
end$$

CREATE PROCEDURE `sp_getpatient_config` (IN `patientid` INT)  BEGIN
select * from r_patient_config where rpc_patientid = patientid order by rpc_configid desc limit 1;
END$$

CREATE PROCEDURE `sp_getstatuscode` ()  BEGIN
select * from r_patient_status_type;
END$$

CREATE PROCEDURE `sp_getstatustype` ()  BEGIN
select * from r_patient_status_type;
END$$

CREATE PROCEDURE `sp_getWards` ()  BEGIN
select *,rmd_monitorid, rmd_monitorname, rmd_monitordesc, concat(rpi_patientfname,' ',rpi_patientmname,' ',rpi_patientlname) rpi_patientfullname  from r_monitor_details inner join t_monitor_list on t_monitor_list.tml_monitorid = rmd_monitorid inner join r_patient_info on r_patient_info.rpi_patientid = t_monitor_list.tml_patientid where t_monitor_list.tml_listid in (select max(t_monitor_list.tml_listid) from t_monitor_list GROUP by t_monitor_list.tml_patientid);
end$$

CREATE PROCEDURE `sp_get_patient_config` (IN `patientid` INT)  BEGIN
select * from r_patient_config where rpc_patientid = patientid order by rpc_configid desc limit 1;
end$$

CREATE PROCEDURE `sp_insertECG` (IN `id` INT, IN `ecg_status` VARCHAR(250), IN `ecg_system` VARCHAR(250), IN `subject` VARCHAR(250), IN `effectivity` DATETIME, IN `originvalue` VARCHAR(250), IN `period` INT, IN `factor` DOUBLE, IN `dimension` INT, IN `ecg_data` VARCHAR(20000))  BEGIN
insert into t_patient_ecg values (null, id, ecg_status,ecg_system, subject, effectivity, originvalue, period, factor, dimension, ecg_data);
END$$

CREATE PROCEDURE `sp_postBP` (IN `requestid` INT, IN `bpvalue` DOUBLE)  BEGIN
update r_ondemand_bp set rob_status = 1, rob_bp = bpvalue where rob_requestid = requestid;
END$$

CREATE PROCEDURE `sp_removepatientMonitor` (IN `patientid` INT, IN `monitorid` INT)  BEGIN
update t_monitor_list set tml_isRemoved = 1 where tml_monitorid = monitorid and t_monitor_list.tml_patientid = patientid;
select "removed" result;
end$$

CREATE PROCEDURE `sp_RemoveWard` (IN `wardid` INT)  BEGIN
update r_ward_details set rwd_isRemoved = 1 where rwd_wardid = wardid;
select "removed" result;
end$$

CREATE PROCEDURE `sp_requestbp` (IN `patientid` INT)  BEGIN
insert into r_ondemand_bp VALUES(null, patientid, 0, 0, CURRENT_TIMESTAMP);
select last_insert_id() "requestid";
END$$

CREATE PROCEDURE `sp_UpdateMonitor` (IN `monitorid` INT, IN `monitorname` VARCHAR(250), IN `monitordesc` VARCHAR(1000), IN `wardid` INT, IN `maxslot` INT)  BEGIN
update r_monitor_details set rmd_monitorname = monitorname, rmd_maxslot = maxslot, rmd_monitordesc = monitordesc, rmd_wardid = wardid where rmd_monitorid = monitorid
;
select "updated" result;
end$$

CREATE PROCEDURE `sp_updatepatientinfo` (IN `fname` VARCHAR(250), IN `mname` VARCHAR(250), IN `lname` VARCHAR(250), IN `birthday` VARCHAR(50), IN `gender` VARCHAR(10), IN `age` INT, IN `remarks` VARCHAR(5000), IN `address` VARCHAR(1000), IN `city` VARCHAR(100), IN `country` VARCHAR(100), IN `contact` VARCHAR(100), IN `email` VARCHAR(100), IN `sss` VARCHAR(100), IN `philhealth` VARCHAR(100), IN `hmo` VARCHAR(100), IN `ward` INT, IN `contactname` VARCHAR(100), IN `contactnumber` VARCHAR(100), IN `rel` VARCHAR(100), IN `patientid` INT, IN `civil` VARCHAR(100), IN `bedno` INT, IN `classification` INT, IN `covidcase` INT, IN `admissionstatus` INT, IN `admissiondate` VARCHAR(250))  BEGIN update r_patient_status set rps_class = classification, rps_case = covidcase, rps_admission = admissionstatus where rps_pid = patientid; update r_patient_info set rpi_patientfname = fname, rpi_patientmname= mname, rpi_patientlname=lname, rpi_gender = gender, rpi_birthday = birthday, rpi_dateregistered = CURRENT_TIMESTAMP,rpi_age=age, rpi_remarks = remarks,rpi_address=address, rpi_city = city, rpi_country = country, rpi_contact = contact, rpi_email_add = email, rpi_sss_gsis_number= sss, rpi_philhealth_number = philhealth , rpi_hmo = hmo, rpi_date_admitted = admissiondate, rpi_ward_id = ward, rpi_contact_name = contactname, rpi_contact_number = contactnumber, rpi_contact_relationship = rel, rpi_civilstatus = civil, rpi_bednumber = bedno where rpi_patientid = patientid;
select "updated successfully" result;
end$$

CREATE PROCEDURE `sp_updateWard` (IN `wardid` INT, IN `wardname` VARCHAR(250), IN `warddesc` VARCHAR(1000))  BEGIN
update r_ward_details set rwd_wardname = wardname, rwd_warddesc =  warddesc where rwd_wardid = wardid;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `r_monitor_details`
--

CREATE TABLE `r_monitor_details` (
  `rmd_monitorid` int NOT NULL,
  `rmd_monitorname` varchar(250) NOT NULL,
  `rmd_maxslot` int NOT NULL,
  `rmd_monitordesc` varchar(1000) DEFAULT NULL,
  `rmd_isRemoved` int DEFAULT NULL,
  `rmd_wardid` int NOT NULL,
  `rmd_dateadded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `r_observation_type`
--

CREATE TABLE `r_observation_type` (
  `rot_typeid` int NOT NULL,
  `rot_typename` varchar(250) NOT NULL,
  `rot_description` varchar(5000) DEFAULT NULL,
  `rot_codenumber` varchar(50) NOT NULL,
  `rot_codevalue` varchar(20) NOT NULL,
  `rot_valuesystem` varchar(250) DEFAULT NULL,
  `rot_codesystem` varchar(250) DEFAULT NULL,
  `rot_dateadded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `r_observation_type`
--

INSERT INTO `r_observation_type` (`rot_typeid`, `rot_typename`, `rot_description`, `rot_codenumber`, `rot_codevalue`, `rot_valuesystem`, `rot_codesystem`, `rot_dateadded`) VALUES
(1, 'SPO2', 'This observation contains the patient\'s SPO2 reading measured using a pulse oximeter on the finger', '59407-7', '%', 'unitsofmeasure.org', 'loinc.org', '2020-04-08 01:35:25'),
(2, 'Respiration Rate', 'This observation contains the patient\'s respiration rate measured using ecg impedance', '76270-8', '{Breaths}/min', 'unitsofmeasure.org', 'loinc.org', '2020-04-08 01:35:25'),
(3, 'Temperature', 'This observation contains the patient\'s body temperature', '8310-5', '/min', 'unitsofmeasure.org', 'loinc.org', '2020-04-08 01:35:25'),
(4, 'Heart Rate', 'This observation contains the patient\'s heart rate measured using a pulse oximeter', '73799-9', '/min', 'unitsofmeasure.org', 'loinc.org', '2020-04-08 01:35:25'),
(5, 'Systolic Pressure', 'This component contains the patient\'s systolic pressure non-invasively measured using oscillometry', '8480-6', 'mm[Hg]', 'unitsofmeasure.org', 'loinc.org', '2020-04-11 16:29:30'),
(6, 'Diastolic Pressure', 'This component contains the patient\'s diastolic pressure non-invasively measured using oscillometry', '8462-4', 'mm[Hg]', 'unitsofmeasure.org', 'loinc.org', '2020-04-11 16:29:30'),
(7, '', 'This component contains the method by which the BP was measured. The type of the value is a CodeableConcept', '', '8357-6', 'unitsofmeasure.org', 'loinc.org', '2020-04-11 16:29:30');

-- --------------------------------------------------------

--
-- Table structure for table `r_ondemand_bp`
--

CREATE TABLE `r_ondemand_bp` (
  `rob_requestid` int NOT NULL,
  `rob_patientid` int NOT NULL,
  `rob_status` int NOT NULL,
  `rob_bp` double NOT NULL,
  `rob_created` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `r_patient_config`
--

CREATE TABLE `r_patient_config` (
  `rpc_configid` int NOT NULL,
  `rpc_patientid` int NOT NULL,
  `rpc_ecg_st_msec` double DEFAULT NULL,
  `rpc_heartrate_upper_bpm` double DEFAULT NULL,
  `rpc_heartrate_lower_bpm` double DEFAULT NULL,
  `rpc_pulserate_upper_bpm` double DEFAULT NULL,
  `rpc_pulserate_lower_bpm` double DEFAULT NULL,
  `rpc_oxygen_upper_saturation` double DEFAULT NULL,
  `rpc_oxygen_lower_saturation` double DEFAULT NULL,
  `rpc_respiratory_upper_rpm` double DEFAULT NULL,
  `rpc_respiratory_lower_rpm` double DEFAULT NULL,
  `rpc_bp_systolic_upper` double DEFAULT NULL,
  `rpc_bp_systolic_lower` double DEFAULT NULL,
  `rpc_bp_diastolic_upper` double DEFAULT NULL,
  `rpc_bp_diastolic_lower` double DEFAULT NULL,
  `rpc_time_frame` int DEFAULT NULL,
  `rpc_temperature_upper` double NOT NULL,
  `rpc_temperature_lower` double DEFAULT NULL,
  `rpc_dateadded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `r_patient_info`
--

CREATE TABLE `r_patient_info` (
  `rpi_patientid` int NOT NULL,
  `rpi_patientfname` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'N/A',
  `rpi_patientmname` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'N/A',
  `rpi_patientlname` varchar(250) NOT NULL,
  `rpi_gender` varchar(50) NOT NULL DEFAULT 'unknown',
  `rpi_birthday` varchar(50) DEFAULT NULL,
  `rpi_dateregistered` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `rpi_age` int NOT NULL,
  `rpi_remarks` varchar(5000) NOT NULL,
  `rpi_address` varchar(1000) NOT NULL,
  `rpi_city` varchar(100) NOT NULL,
  `rpi_country` varchar(100) NOT NULL,
  `rpi_contact` varchar(100) NOT NULL,
  `rpi_email_add` varchar(100) NOT NULL,
  `rpi_sss_gsis_number` varchar(100) NOT NULL,
  `rpi_philhealth_number` varchar(100) NOT NULL,
  `rpi_hmo` varchar(100) NOT NULL,
  `rpi_date_admitted` varchar(100) NOT NULL,
  `rpi_ward_id` int NOT NULL,
  `rpi_contact_name` varchar(100) NOT NULL,
  `rpi_contact_number` varchar(100) NOT NULL,
  `rpi_contact_relationship` varchar(100) NOT NULL,
  `rpi_patientstatus` int DEFAULT NULL,
  `rpi_civilstatus` varchar(100) NOT NULL,
  `rpi_bednumber` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `r_patient_status`
--

CREATE TABLE `r_patient_status` (
  `rps_id` int NOT NULL,
  `rps_pid` int NOT NULL,
  `rps_class` int NOT NULL DEFAULT '20',
  `rps_case` int NOT NULL DEFAULT '15',
  `rps_admission` int NOT NULL DEFAULT '1',
  `rps_dateadded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `r_patient_status_type`
--

CREATE TABLE `r_patient_status_type` (
  `rps_id` int NOT NULL,
  `rps_name` varchar(50) NOT NULL,
  `rps_desc` varchar(150) DEFAULT NULL,
  `rps_category` varchar(100) NOT NULL,
  `rps_isActive` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `r_patient_status_type`
--

INSERT INTO `r_patient_status_type` (`rps_id`, `rps_name`, `rps_desc`, `rps_category`, `rps_isActive`) VALUES
(1, 'Active', 'Active', 'Admission Status', 1),
(11, 'Recovered', 'Recovered', 'Admission Status', 1),
(12, 'Transferred', 'Transferred', 'Admission Status', 1),
(13, 'Discharged', 'Discharged', 'Admission Status', 1),
(14, 'Expired', 'Expired', 'Admission Status', 1),
(15, 'Asymptomatic', 'Asymptomatic', 'Covid Case', 1),
(16, 'Mild', 'Mild', 'Covid Case', 1),
(17, 'Moderate', 'Moderate', 'Covid Case', 1),
(18, 'Severe', 'Severe', 'Covid Case', 1),
(19, 'Critical', 'Critical', 'Covid Case', 1),
(20, 'Stable or No Co-morbid', 'Stable or No Co-morbid', 'Classification', 0),
(21, 'Stable or Unstable Co-morbid', 'Stable or Unstable Co-morbid', 'Classification', 0),
(22, 'CAP-HR, Sepsis or Shock', 'CAP-HR, Sepsis or Shock', 'Classification', 0),
(23, 'ARDS', 'ARDS', 'Classification', 0),
(24, 'Confirmed', NULL, 'Classification', 1),
(26, 'Probable', NULL, 'Classification', 1),
(27, 'Suspect', NULL, 'Classification', 1);

-- --------------------------------------------------------

--
-- Table structure for table `r_rxbox_session`
--

CREATE TABLE `r_rxbox_session` (
  `ip` varchar(25) NOT NULL,
  `patient_id` int NOT NULL,
  `login_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_report` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `r_severity`
--

CREATE TABLE `r_severity` (
  `rs_id` int NOT NULL,
  `rs_level` varchar(250) NOT NULL,
  `rs_score` int NOT NULL,
  `rs_description` varchar(1500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `r_system_config`
--

CREATE TABLE `r_system_config` (
  `rsc_configid` int NOT NULL,
  `rsc_name` varchar(250) NOT NULL,
  `rsc_value` varchar(250) NOT NULL,
  `rsc_hashedvalue` varbinary(250) NOT NULL,
  `rsc_dateadded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `r_system_config`
--

INSERT INTO `r_system_config` (`rsc_configid`, `rsc_name`, `rsc_value`, `rsc_hashedvalue`, `rsc_dateadded`) VALUES
(1, 'systempass', 'saltvalue', 0x6564326138393235633631623937633830653966373866316666303632356163, '2020-10-23 09:50:52');

-- --------------------------------------------------------

--
-- Table structure for table `r_ward_details`
--

CREATE TABLE `r_ward_details` (
  `rwd_wardid` int NOT NULL,
  `rwd_wardname` varchar(250) NOT NULL,
  `rwd_warddesc` varchar(250) NOT NULL,
  `rwd_isRemoved` int NOT NULL DEFAULT '0',
  `rwd_dateadded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_monitor_list`
--

CREATE TABLE `t_monitor_list` (
  `tml_listid` int NOT NULL,
  `tml_patientid` int NOT NULL,
  `tml_monitorid` int DEFAULT NULL,
  `tml_isRemoved` int DEFAULT NULL,
  `tml_dateadded` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_notifications`
--

CREATE TABLE `t_notifications` (
  `tn_notifid` int NOT NULL,
  `tn_patientid` int NOT NULL,
  `tn_severity` int NOT NULL,
  `tn_code` varchar(250) NOT NULL,
  `tn_obsid` int NOT NULL,
  `tn_dateadded` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_patient_data_history`
--

CREATE TABLE `t_patient_data_history` (
  `tpdh_historyid` int NOT NULL,
  `tpdh_patientid` int NOT NULL,
  `tpdh_respiration_rate` double NOT NULL,
  `tpdh_oxygen_level` double NOT NULL,
  `tpdh_bprate_sys` int NOT NULL,
  `tpdh_bprate_dias` int NOT NULL,
  `tpdh_heart_rate` int NOT NULL,
  `tpdh_dt_registered` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_patient_ecg`
--

CREATE TABLE `t_patient_ecg` (
  `tpe_ecgkey` int NOT NULL,
  `tpe_id` int NOT NULL,
  `tpe_status` varchar(250) DEFAULT 'final',
  `tpe_valuesystem` varchar(250) NOT NULL,
  `tpe_subject` varchar(250) NOT NULL,
  `tpe_effectivity` datetime NOT NULL,
  `tpe_originvalue` int NOT NULL,
  `tpe_period` int NOT NULL,
  `tpe_factor` double NOT NULL,
  `tpe_dimension` int NOT NULL,
  `tpe_data` varchar(20000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `t_patient_observation`
--

CREATE TABLE `t_patient_observation` (
  `tpo_obsid` int NOT NULL,
  `tpo_id` varchar(1000) NOT NULL,
  `tpo_code` varchar(50) NOT NULL,
  `tpo_value` varchar(250) NOT NULL,
  `tpo_subject` varchar(250) NOT NULL,
  `tpo_effectivity` datetime NOT NULL,
  `tpo_status` varchar(250) NOT NULL,
  `tpo_dataerror` varchar(250) DEFAULT NULL,
  `tpo_system` varchar(500) DEFAULT NULL,
  `tpo_valuesystem` varchar(250) NOT NULL,
  `tpo_valuecode` varchar(50) NOT NULL,
  `tpo_unit` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `r_monitor_details`
--
ALTER TABLE `r_monitor_details`
  ADD PRIMARY KEY (`rmd_monitorid`),
  ADD UNIQUE KEY `rmd_monitorname` (`rmd_monitorname`),
  ADD KEY `rmd_wardid_fk` (`rmd_wardid`);

--
-- Indexes for table `r_observation_type`
--
ALTER TABLE `r_observation_type`
  ADD PRIMARY KEY (`rot_typeid`),
  ADD UNIQUE KEY `rot_codenumber` (`rot_codenumber`);

--
-- Indexes for table `r_ondemand_bp`
--
ALTER TABLE `r_ondemand_bp`
  ADD PRIMARY KEY (`rob_requestid`),
  ADD KEY `rob_patientid_fk` (`rob_patientid`);

--
-- Indexes for table `r_patient_config`
--
ALTER TABLE `r_patient_config`
  ADD PRIMARY KEY (`rpc_configid`),
  ADD KEY `rpc_patientid` (`rpc_patientid`);

--
-- Indexes for table `r_patient_info`
--
ALTER TABLE `r_patient_info`
  ADD PRIMARY KEY (`rpi_patientid`),
  ADD KEY `rpi_patientstatus_fk` (`rpi_patientstatus`);

--
-- Indexes for table `r_patient_status`
--
ALTER TABLE `r_patient_status`
  ADD PRIMARY KEY (`rps_id`),
  ADD KEY `rps_pid` (`rps_pid`),
  ADD KEY `rps_class` (`rps_class`),
  ADD KEY `rps_case` (`rps_case`),
  ADD KEY `rps_admission_fk` (`rps_admission`);

--
-- Indexes for table `r_patient_status_type`
--
ALTER TABLE `r_patient_status_type`
  ADD PRIMARY KEY (`rps_id`);

--
-- Indexes for table `r_severity`
--
ALTER TABLE `r_severity`
  ADD PRIMARY KEY (`rs_id`);

--
-- Indexes for table `r_system_config`
--
ALTER TABLE `r_system_config`
  ADD PRIMARY KEY (`rsc_configid`);

--
-- Indexes for table `r_ward_details`
--
ALTER TABLE `r_ward_details`
  ADD PRIMARY KEY (`rwd_wardid`);

--
-- Indexes for table `t_monitor_list`
--
ALTER TABLE `t_monitor_list`
  ADD PRIMARY KEY (`tml_listid`),
  ADD KEY `tml_patientid_fk` (`tml_patientid`),
  ADD KEY `tml_monitorid` (`tml_monitorid`);

--
-- Indexes for table `t_notifications`
--
ALTER TABLE `t_notifications`
  ADD PRIMARY KEY (`tn_notifid`),
  ADD KEY `tn_patientid` (`tn_patientid`),
  ADD KEY `tn_severity` (`tn_severity`),
  ADD KEY `tn_obsid` (`tn_obsid`);

--
-- Indexes for table `t_patient_data_history`
--
ALTER TABLE `t_patient_data_history`
  ADD PRIMARY KEY (`tpdh_historyid`),
  ADD KEY `tpdh_patientid` (`tpdh_patientid`);

--
-- Indexes for table `t_patient_ecg`
--
ALTER TABLE `t_patient_ecg`
  ADD PRIMARY KEY (`tpe_ecgkey`),
  ADD KEY `tpe_subject` (`tpe_subject`);

--
-- Indexes for table `t_patient_observation`
--
ALTER TABLE `t_patient_observation`
  ADD PRIMARY KEY (`tpo_obsid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `r_monitor_details`
--
ALTER TABLE `r_monitor_details`
  MODIFY `rmd_monitorid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_observation_type`
--
ALTER TABLE `r_observation_type`
  MODIFY `rot_typeid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_ondemand_bp`
--
ALTER TABLE `r_ondemand_bp`
  MODIFY `rob_requestid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_patient_config`
--
ALTER TABLE `r_patient_config`
  MODIFY `rpc_configid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_patient_info`
--
ALTER TABLE `r_patient_info`
  MODIFY `rpi_patientid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_patient_status`
--
ALTER TABLE `r_patient_status`
  MODIFY `rps_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_patient_status_type`
--
ALTER TABLE `r_patient_status_type`
  MODIFY `rps_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_severity`
--
ALTER TABLE `r_severity`
  MODIFY `rs_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_system_config`
--
ALTER TABLE `r_system_config`
  MODIFY `rsc_configid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `r_ward_details`
--
ALTER TABLE `r_ward_details`
  MODIFY `rwd_wardid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `t_monitor_list`
--
ALTER TABLE `t_monitor_list`
  MODIFY `tml_listid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `t_notifications`
--
ALTER TABLE `t_notifications`
  MODIFY `tn_notifid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `t_patient_data_history`
--
ALTER TABLE `t_patient_data_history`
  MODIFY `tpdh_historyid` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `t_patient_ecg`
--
ALTER TABLE `t_patient_ecg`
  MODIFY `tpe_ecgkey` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `t_patient_observation`
--
ALTER TABLE `t_patient_observation`
  MODIFY `tpo_obsid` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `r_monitor_details`
--
ALTER TABLE `r_monitor_details`
  ADD CONSTRAINT `rmd_wardid_fk` FOREIGN KEY (`rmd_wardid`) REFERENCES `r_ward_details` (`rwd_wardid`);

--
-- Constraints for table `r_ondemand_bp`
--
ALTER TABLE `r_ondemand_bp`
  ADD CONSTRAINT `rob_patientid_fk` FOREIGN KEY (`rob_patientid`) REFERENCES `r_patient_info` (`rpi_patientid`) ON DELETE CASCADE;

--
-- Constraints for table `r_patient_config`
--
ALTER TABLE `r_patient_config`
  ADD CONSTRAINT `r_patient_config_ibfk_1` FOREIGN KEY (`rpc_patientid`) REFERENCES `r_patient_info` (`rpi_patientid`) ON DELETE CASCADE;

--
-- Constraints for table `r_patient_info`
--
ALTER TABLE `r_patient_info`
  ADD CONSTRAINT `rpi_patientstatus_fk` FOREIGN KEY (`rpi_patientstatus`) REFERENCES `r_patient_status_type` (`rps_id`) ON DELETE CASCADE;

--
-- Constraints for table `r_patient_status`
--
ALTER TABLE `r_patient_status`
  ADD CONSTRAINT `r_patient_status_ibfk_1` FOREIGN KEY (`rps_pid`) REFERENCES `r_patient_info` (`rpi_patientid`) ON DELETE CASCADE,
  ADD CONSTRAINT `r_patient_status_ibfk_2` FOREIGN KEY (`rps_class`) REFERENCES `r_patient_status_type` (`rps_id`),
  ADD CONSTRAINT `r_patient_status_ibfk_3` FOREIGN KEY (`rps_case`) REFERENCES `r_patient_status_type` (`rps_id`),
  ADD CONSTRAINT `r_patient_status_ibfk_4` FOREIGN KEY (`rps_case`) REFERENCES `r_patient_status_type` (`rps_id`),
  ADD CONSTRAINT `rps_admission_fk` FOREIGN KEY (`rps_admission`) REFERENCES `r_patient_status_type` (`rps_id`);

--
-- Constraints for table `t_monitor_list`
--
ALTER TABLE `t_monitor_list`
  ADD CONSTRAINT `tml_monitorid` FOREIGN KEY (`tml_monitorid`) REFERENCES `r_monitor_details` (`rmd_monitorid`),
  ADD CONSTRAINT `tml_patientid_fk` FOREIGN KEY (`tml_patientid`) REFERENCES `r_patient_info` (`rpi_patientid`) ON DELETE CASCADE;

--
-- Constraints for table `t_notifications`
--
ALTER TABLE `t_notifications`
  ADD CONSTRAINT `t_notifications_ibfk_1` FOREIGN KEY (`tn_patientid`) REFERENCES `r_patient_info` (`rpi_patientid`),
  ADD CONSTRAINT `t_notifications_ibfk_2` FOREIGN KEY (`tn_severity`) REFERENCES `r_severity` (`rs_id`),
  ADD CONSTRAINT `t_notifications_ibfk_3` FOREIGN KEY (`tn_obsid`) REFERENCES `t_patient_observation` (`tpo_obsid`);

--
-- Constraints for table `t_patient_data_history`
--
ALTER TABLE `t_patient_data_history`
  ADD CONSTRAINT `t_patient_data_history_ibfk_1` FOREIGN KEY (`tpdh_patientid`) REFERENCES `r_patient_info` (`rpi_patientid`);
SET FOREIGN_KEY_CHECKS=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
