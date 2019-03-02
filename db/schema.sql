-- use this if you don't have the db created yet
-- CREATE DATABASE `dod` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

-- use these if tables already exist
-- DROP TABLE `dod`.`AUDIT_LOG`;
-- DROP TABLE `dod`.`SESSIONS`;
-- DROP TABLE `dod`.`USERS`;

CREATE TABLE `AUDIT_LOG` (
  `AUDIT_LOG_ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `USER_ID` int(10) unsigned NOT NULL,
  `TIMESTAMP` datetime NOT NULL,
  `ACTION` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`AUDIT_LOG_ID`),
  UNIQUE KEY `AUDIT_LOG_ID_UNIQUE` (`AUDIT_LOG_ID`),
  KEY `user_fk_idx` (`USER_ID`),
  CONSTRAINT `user_fk` FOREIGN KEY (`USER_ID`) REFERENCES `USERS` (`USER_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `SESSIONS` (
  `SESSION_ID` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `USER_ID` int(10) unsigned NOT NULL,
  `EXP_DT` datetime NOT NULL,
  PRIMARY KEY (`SESSION_ID`),
  KEY `users_fk` (`USER_ID`),
  CONSTRAINT `users_fk` FOREIGN KEY (`USER_ID`) REFERENCES `USERS` (`USER_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `USERS` (
  `USER_ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CREATED_DT` datetime NOT NULL,
  `ROLE` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'patient',
  `PASSW` text COLLATE utf8_unicode_ci NOT NULL,
  `NAME` text COLLATE utf8_unicode_ci NOT NULL,
  `EMAIL` text COLLATE utf8_unicode_ci NOT NULL,
  `ADDR` text COLLATE utf8_unicode_ci NOT NULL,
  `CITY` text COLLATE utf8_unicode_ci NOT NULL,
  `STATE` text COLLATE utf8_unicode_ci NOT NULL,
  `POSTAL_CODE` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `PHONE` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `LICENSES` text COLLATE utf8_unicode_ci,
  `active` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`USER_ID`),
  UNIQUE KEY `USER_ID_UNIQUE` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


/*
 * Load sample data
 */
INSERT INTO `dod`.`USERS` (`USER_ID`,`CREATED_DT`,`ROLE`,`PASSW`,`NAME`,`EMAIL`,`ADDR`,`CITY`,`STATE`,`POSTAL_CODE`,`PHONE`,`LICENSES`)
VALUES (1, '2019-01-01 01:01:00', 'patient', '$2a$04$U5xNWAAZ08.KOodlcYUPIucpXVVWNQCqOJMDoZD6SGaon4ZKKIkRy', 'test', 'test@test.com', '1 main st', 'city', 'state', '00000', '123-123-1234', NULL);
