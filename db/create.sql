SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `tags_bands`;
DROP TABLE IF EXISTS `tags_venues`;
DROP TABLE IF EXISTS `bands_shows`;
DROP TABLE IF EXISTS `bands`;
DROP TABLE IF EXISTS `fans`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `tours`;
DROP TABLE IF EXISTS `band_services`;
DROP TABLE IF EXISTS `shows`;
DROP TABLE IF EXISTS `venues`;
DROP TABLE IF EXISTS `zip_codes`;

CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `band_id` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` VARCHAR(5),
  `city` varchar(100) default '',
  `state` varchar(2) default '',
  `bio` text NOT NULL,
  `salt` CHAR(40) NOT NULL,
  `official_website` varchar(100) default '',
  `salted_password` VARCHAR(40) NOT NULL,
  `logo` varchar(100) NOT NULL default '',
  `confirmed` boolean NOT NULL default 0,
  `confirmation_code` varchar(50) default '',
  PRIMARY KEY  (`id`),
  KEY name_key (name),
  KEY band_id_key (band_id)
) ENGINE=InnoDB;

CREATE TABLE `venues` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `url` VARCHAR(100) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `state` VARCHAR(2) NOT NULL,
  `zipcode` VARCHAR(10) NOT NULL,
  `country` VARCHAR(45) NOT NULL,
  `phone_number` VARCHAR(15) NOT NULL,
  `description` TEXT NOT NULL,
  `contact_email` varchar(100) NOT NULL,
  `latitude` VARCHAR(30),
  `longitude` VARCHAR(30),
  PRIMARY KEY(`id`)
) ENGINE=InnoDB;

CREATE TABLE `fans` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `real_name` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` VARCHAR(5),
  `city` varchar(100) default '',
  `state` varchar(2) default '',
  `bio` text,
  `salt` CHAR(40),
  `website` varchar(100) default '',
  `salted_password` VARCHAR(40) NOT NULL,
  `logo` varchar(100) NOT NULL default '',
  `confirmed` boolean NOT NULL default 0,
  `confirmation_code` varchar(50) default '',
  `created_on` DATETIME,
  PRIMARY KEY  (`id`),
  KEY name_key (name)
) ENGINE=InnoDB;

CREATE TABLE `tags` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB;

CREATE TABLE `tags_bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `band_id` int(10) unsigned NOT NULL,
  `tag_id` int(10) unsigned NOT NULL,
  `tag_type` int(10) unsigned NOT NULL,
  CONSTRAINT `fk_bt_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  CONSTRAINT `fk_bt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`),
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB;

CREATE TABLE `tags_venues` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `venue_id` int(10) unsigned NOT NULL,
  `tag_id` int(10) unsigned NOT NULL,
  `tag_type` int(10) unsigned NOT NULL,
  CONSTRAINT `fk_vt_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`),
  CONSTRAINT `fk_vt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`),
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB;

CREATE TABLE `bands_shows` (
  `band_id` int(10) unsigned NOT NULL,
  `show_id` int(10) unsigned NOT NULL,
  `can_edit` boolean NOT NULL default 0,
  PRIMARY KEY  (`band_id`,`show_id`),
  CONSTRAINT `fk_bs_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  CONSTRAINT `fk_bs_show` FOREIGN KEY (`show_id`) REFERENCES `shows` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `band_services` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `band_id` int(10) unsigned NOT NULL default '0',
  `myspace_username` varchar(100) NOT NULL default '',
  `myspace_password` varchar(40) NOT NULL default '',
  `purevolume_username` varchar(100) NOT NULL default '',
  `purevolume_password` varchar(40) NOT NULL default '',
  PRIMARY KEY  (`id`),
  CONSTRAINT `FK_bs_band_id` FOREIGN KEY (`id`) REFERENCES `bands` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `tours` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `band_id` INTEGER UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY(`id`),
  KEY `FK_tours_band_id` (`band_id`),
  CONSTRAINT `FK_tours_band_id` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `shows` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `cost` VARCHAR(50),
  `title` VARCHAR(100),
  `description` TEXT NOT NULL,
  `url` VARCHAR(100) NOT NULL,
  `date` DATETIME NOT NULL,
  `venue_id` int(10) unsigned NOT NULL,
  PRIMARY KEY(`id`),
  KEY `fk_venue` (`venue_id`),
  CONSTRAINT `fk_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`)
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