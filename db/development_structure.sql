CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `url` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` varchar(10) NOT NULL default '',
  `bio` text NOT NULL,
  `logo` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bands_tags` (
  `band_id` int(10) unsigned NOT NULL default '0',
  `tag_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`band_id`,`tag_id`),
  KEY `fk_bt_tag` (`tag_id`),
  CONSTRAINT `fk_bt_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  CONSTRAINT `fk_bt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `shows` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `venue` varchar(100) NOT NULL default '',
  `venue_link` varchar(100) NOT NULL default '',
  `cost` varchar(50) default NULL,
  `country` varchar(45) NOT NULL default '',
  `state` char(2) NOT NULL default '',
  `zipcode` varchar(10) NOT NULL default '',
  `address` varchar(255) NOT NULL default '',
  `city` varchar(100) NOT NULL default '',
  `description` text NOT NULL,
  `date` datetime NOT NULL default '0000-00-00 00:00:00',
  `band_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_band` (`band_id`),
  CONSTRAINT `fk_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

