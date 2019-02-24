
CREATE TABLE `doctorsondemand`.`users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `patient` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  `string` VARCHAR(45) NOT NULL,
  `postalCode` VARCHAR(45) NOT NULL,
  `phoneNumber` VARCHAR(45) NOT NULL,
  `license` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`user_id`));

