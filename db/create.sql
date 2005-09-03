SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `bands_tags`;
DROP TABLE IF EXISTS `bands`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `band_services`;
DROP TABLE IF EXISTS `shows`;
DROP TABLE IF EXISTS `venues`;
DROP TABLE IF EXISTS `zip_codes`;

CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `band_id` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` VARCHAR(10) NOT NULL,
  `bio` text NOT NULL,
  `salt` CHAR(40) NOT NULL,
  `salted_password` VARCHAR(40) NOT NULL,
  `logo` varchar(100) NOT NULL default '',
  `confirmed` boolean NOT NULL default 0,
  `confirmation_code` varchar(50) default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB;

CREATE TABLE `tags` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB;

CREATE TABLE `bands_tags` (
  `band_id` int(10) unsigned NOT NULL,
  `tag_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`band_id`,`tag_id`),
  CONSTRAINT `fk_bt_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  CONSTRAINT `fk_bt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `band_services` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `band_id` int(10) unsigned NOT NULL default '0',
  `myspace_username` varchar(100) NOT NULL default '',
  `myspace_salt` varchar(40) NOT NULL default '',
  `purevolume_username` varchar(100) NOT NULL default '',
  `purevolume_password` varchar(40) NOT NULL default '',
  PRIMARY KEY  (`id`),
  CONSTRAINT `FK_band_id` FOREIGN KEY (`id`) REFERENCES `bands` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `shows` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `cost` VARCHAR(50),
  `description` TEXT NOT NULL,
  `url` VARCHAR(100) NOT NULL,
  `date` DATETIME NOT NULL,
  `band_id` int(10) unsigned NOT NULL,
  `venue_id` int(10) unsigned NOT NULL,
  PRIMARY KEY(`id`),
  KEY `fk_band` (`band_id`),
  CONSTRAINT `fk_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  KEY `fk_venue` (`venue_id`),
  CONSTRAINT `fk_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `venues` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `url` VARCHAR(100) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `state` VARCHAR(2) NOT NULL,
  `zipcode` VARCHAR(10) NOT NULL,
  `country` VARCHAR(45) NOT NULL,
  `phone_number` VARCHAR(15) NOT NULL,
  `description` TEXT NOT NULL,
  `contact_email` varchar(100) NOT NULL,
  `latitude` VARCHAR(30) NOT NULL,
  `longitude` VARCHAR(30) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE `zip_codes` (
  zip varchar(16) NOT NULL default '0',
  city varchar(30) NOT NULL default '',
  state varchar(30) NOT NULL default '',
  latitude decimal(10,6) NOT NULL default '0.000000',
  longitude decimal(10,6) NOT NULL default '0.000000',
  timezone tinyint(2) NOT NULL default '0',
  dst tinyint(1) NOT NULL default '0',
  country char(2) NOT NULL default '',
  PRIMARY KEY  (country,zip),
  KEY pc (country,zip),
  KEY zip (zip),
  KEY latitude (latitude),
  KEY longitude (longitude),
  KEY country (country)
) TYPE=MyISAM;
INSERT INTO zip_codes VALUES ('02140','Cambridge','MA','42.393327','-71.128370',-5,1,'us');
INSERT INTO zip_codes VALUES ('01721','Ashland','MA','42.257956','-71.458860',-5,1,'us');
