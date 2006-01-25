SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `upload_addrs`;
DROP TABLE IF EXISTS `tags_bands`;
DROP TABLE IF EXISTS `tags_venues`;
DROP TABLE IF EXISTS `tags_shows`;
DROP TABLE IF EXISTS `bands_shows`;
DROP TABLE IF EXISTS `bands_fans`;
DROP TABLE IF EXISTS `fans_shows`;
DROP TABLE IF EXISTS `bands`;
DROP TABLE IF EXISTS `fans`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `band_services`;
DROP TABLE IF EXISTS `shows`;
DROP TABLE IF EXISTS `venues`;
DROP TABLE IF EXISTS `comments`;
DROP TABLE IF EXISTS `photos`;

CREATE TABLE `upload_addrs` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `address` varchar(100) NOT NULL,
  `fan_id` int(10) unsigned,
  `band_id` int(10) unsigned,
  KEY `fk_cu_createdband` (`band_id`),
  CONSTRAINT `fk_cu_createdband` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  KEY `fk_cu_createdfan` (`fan_id`),
  CONSTRAINT `fk_cu_createdfan` FOREIGN KEY (`fan_id`) REFERENCES `fans` (`id`),
  PRIMARY KEY  (`id`),
  KEY name_key (address)
) ENGINE=InnoDB;

CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `short_name` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` VARCHAR(5),
  `city` varchar(100) default '',
  `state` varchar(2) default '',
  `bio` text default '',
  `salt` CHAR(40) default '',
  `official_website` varchar(100) default '',
  `salted_password` VARCHAR(40) NOT NULL default '',
  `security_token` VARCHAR(40) NOT NULL default '',
  `token_expiry` DATETIME,
  `logo` varchar(100) default '',
  `confirmed` boolean default 0,
  `confirmation_code` varchar(50) default '',
  `claimed` boolean default 1,
  `created_on` DATETIME,
  `page_views` int(10) unsigned default 0,
  PRIMARY KEY  (`id`),
  KEY name_key (name),
  KEY short_name_key (short_name)
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
  `page_views` int(10) unsigned default 0,
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
  `security_token` VARCHAR(40) NOT NULL default '',
  `token_expiry` DATETIME,
  `created_on` DATETIME,
  `page_views` int(10) unsigned default 0,
  `last_favorites_email` DATETIME,
  `default_radius` int(6) default 35,
  `wants_favorites_emails` boolean NOT NULL default 1,
  `admin` boolean NOT NULL default 0,
  PRIMARY KEY  (`id`),
  KEY name_key (name)
) ENGINE=InnoDB;

CREATE TABLE `comments` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `body` TEXT,
  `created_on` DATETIME,
  `show_id` int(10) unsigned,
  `band_id` int(10) unsigned,
  `venue_id` int(10) unsigned,
  `photo_id` int(10) unsigned,
  `created_by_fan_id` int(10) unsigned,
  `created_by_band_id` int(10) unsigned,
  KEY `fk_sc_show` (`show_id`),
  CONSTRAINT `fk_sc_show` FOREIGN KEY (`show_id`) REFERENCES `shows` (`id`),
  KEY `fk_cp_band` (`band_id`),
  CONSTRAINT `fk_cp_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  KEY `fk_cp_venue` (`venue_id`),
  CONSTRAINT `fk_cp_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`),
  KEY `fk_cp_photo` (`photo_id`),
  CONSTRAINT `fk_cp_photo` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`),
  KEY `fk_cp_createdband` (`created_by_band_id`),
  CONSTRAINT `fk_cp_createdband` FOREIGN KEY (`created_by_band_id`) REFERENCES `bands` (`id`),
  KEY `fk_cp_createdfan` (`created_by_fan_id`),
  CONSTRAINT `fk_cp_createdfan` FOREIGN KEY (`created_by_fan_id`) REFERENCES `fans` (`id`),
  PRIMARY KEY(`id`)
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

CREATE TABLE `tags_shows` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `show_id` int(10) unsigned NOT NULL,
  `tag_id` int(10) unsigned NOT NULL,
  `tag_type` int(10) unsigned NOT NULL,
  CONSTRAINT `fk_st_show` FOREIGN KEY (`show_id`) REFERENCES `shows` (`id`),
  CONSTRAINT `fk_st_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`),
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

CREATE TABLE `bands_fans` (
  `band_id` int(10) unsigned,
  `fan_id` int(10) unsigned,
  PRIMARY KEY  (`band_id`,`fan_id`),
  CONSTRAINT `FK_fave_band_id` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  CONSTRAINT `FK_fave_fan_id` FOREIGN KEY (`fan_id`) REFERENCES `fans` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `shows` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `cost` VARCHAR(50),
  `title` VARCHAR(100),
  `bands_playing_title` VARCHAR(200),
  `description` TEXT NOT NULL,
  `url` VARCHAR(100) NOT NULL,
  `date` DATETIME NOT NULL,
  `page_views` int(10) unsigned default 0,
  `venue_id` int(10) unsigned NOT NULL,
  `created_by_fan_id` int(10) unsigned,
  `created_by_band_id` int(10) unsigned,
  `created_by_system` boolean NOT NULL default 0, 
  `created_on` DATETIME,
  `last_updated` DATETIME,	
  PRIMARY KEY(`id`),
  KEY `fk_venue` (`venue_id`),
  CONSTRAINT `fk_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`),
  KEY `fk_show_createdband` (`created_by_band_id`),
  CONSTRAINT `fk_show_createdband` FOREIGN KEY (`created_by_band_id`) REFERENCES `bands` (`id`),
  KEY `fk_show_createdfan` (`created_by_fan_id`),
  CONSTRAINT `fk_show_createdfan` FOREIGN KEY (`created_by_fan_id`) REFERENCES `fans` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `fans_shows` (
  `show_id` int(10) unsigned,
  `fan_id` int(10) unsigned,
  PRIMARY KEY  (`show_id`,`fan_id`),
  CONSTRAINT `FK_attending_show_id` FOREIGN KEY (`show_id`) REFERENCES `shows` (`id`),
  CONSTRAINT `FK_attending_fan_id` FOREIGN KEY (`fan_id`) REFERENCES `fans` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `photos` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `filename` VARCHAR(100),
  `description` TEXT NOT NULL default '',
  `created_on` DATETIME NOT NULL,
  `page_views` int(10) unsigned default 0,
  `show_id` int(10) unsigned,
  `band_id` int(10) unsigned,
  `venue_id` int(10) unsigned,
  `created_by_fan_id` int(10) unsigned,
  `created_by_band_id` int(10) unsigned,
  KEY `fk_sp_show` (`show_id`),
  CONSTRAINT `fk_sp_show` FOREIGN KEY (`show_id`) REFERENCES `shows` (`id`),
  KEY `fk_sp_band` (`band_id`),
  CONSTRAINT `fk_sp_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  KEY `fk_sp_venue` (`venue_id`),
  CONSTRAINT `fk_sp_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`),
  KEY `fk_sp_createdband` (`created_by_band_id`),
  CONSTRAINT `fk_sp_createdband` FOREIGN KEY (`created_by_band_id`) REFERENCES `bands` (`id`),
  KEY `fk_sp_createdfan` (`created_by_fan_id`),
  CONSTRAINT `fk_sp_createdfan` FOREIGN KEY (`created_by_fan_id`) REFERENCES `fans` (`id`),
  PRIMARY KEY(`id`)
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