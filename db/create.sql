DROP TABLE IF EXISTS `bands_tags`;
DROP TABLE IF EXISTS `bands`;
DROP TABLE IF EXISTS `tags`;

CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `bio` text NOT NULL,
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
