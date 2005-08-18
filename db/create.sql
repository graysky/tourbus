SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `bands_tags`;
DROP TABLE IF EXISTS `bands`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `shows`;

CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `url` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` VARCHAR(10) NOT NULL,
  `bio` text NOT NULL,
  `logo` varchar(100) NOT NULL default '',
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

CREATE TABLE `shows` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `venue` VARCHAR(100) NOT NULL,
  `venue_link` VARCHAR(100) NOT NULL,
  `cost` VARCHAR(50),
  `country` VARCHAR(45) NOT NULL,
  `state` VARCHAR(2) NOT NULL,
  `zipcode` VARCHAR(10) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `description` TEXT NOT NULL,
  `date` DATETIME NOT NULL,
  `band_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY(`id`),
  KEY `fk_band` (`band_id`),
  CONSTRAINT `fk_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`)
)
ENGINE = InnoDB;