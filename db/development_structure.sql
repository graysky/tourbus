CREATE TABLE `band_services` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `band_id` int(10) unsigned NOT NULL default '0',
  `myspace_username` varchar(100) NOT NULL default '',
  `myspace_password` varchar(40) NOT NULL default '',
  `purevolume_username` varchar(100) NOT NULL default '',
  `purevolume_password` varchar(40) NOT NULL default '',
  PRIMARY KEY  (`id`),
  CONSTRAINT `FK_bs_band_id` FOREIGN KEY (`id`) REFERENCES `bands` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `band_id` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` varchar(5) default NULL,
  `city` varchar(100) default '',
  `state` char(2) default '',
  `bio` text NOT NULL,
  `salt` varchar(40) NOT NULL default '',
  `official_website` varchar(100) default '',
  `salted_password` varchar(40) NOT NULL default '',
  `logo` varchar(100) NOT NULL default '',
  `confirmed` tinyint(1) NOT NULL default '0',
  `confirmation_code` varchar(50) default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bands_shows` (
  `band_id` int(10) unsigned NOT NULL default '0',
  `show_id` int(10) unsigned NOT NULL default '0',
  `can_edit` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`band_id`,`show_id`),
  KEY `fk_bs_show` (`show_id`),
  CONSTRAINT `fk_bs_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  CONSTRAINT `fk_bs_show` FOREIGN KEY (`show_id`) REFERENCES `shows` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `shows` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cost` varchar(50) default NULL,
  `description` text NOT NULL,
  `url` varchar(100) NOT NULL default '',
  `date` datetime default NULL,
  `venue_id` int(10) unsigned NOT NULL default '0',
  `tour_id` int(10) unsigned default NULL,
  `title` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`,`title`),
  KEY `fk_venue` (`venue_id`),
  KEY `fk_tpir` (`tour_id`),
  CONSTRAINT `fk_tour` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`id`),
  CONSTRAINT `fk_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags_bands` (
  `band_id` int(10) unsigned NOT NULL default '0',
  `tag_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`band_id`,`tag_id`),
  KEY `fk_bt_tag` (`tag_id`),
  CONSTRAINT `fk_bt_band` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`),
  CONSTRAINT `fk_bt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tours` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `band_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`),
  KEY `FK_tours_band_id` (`band_id`),
  CONSTRAINT `FK_tours_band_id` FOREIGN KEY (`band_id`) REFERENCES `bands` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `venues` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `url` varchar(100) NOT NULL default '',
  `address` varchar(255) NOT NULL default '',
  `city` varchar(100) NOT NULL default '',
  `state` char(2) NOT NULL default '',
  `zipcode` varchar(10) NOT NULL default '',
  `country` varchar(45) NOT NULL default '',
  `phone_number` varchar(15) NOT NULL default '',
  `description` text NOT NULL,
  `contact_email` varchar(100) NOT NULL default '',
  `latitude` varchar(30) NOT NULL default '',
  `longitude` varchar(30) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `zip_codes` (
  `zip` varchar(16) NOT NULL default '0',
  `city` varchar(30) NOT NULL default '',
  `state` varchar(30) NOT NULL default '',
  `latitude` decimal(10,6) NOT NULL default '0.000000',
  `longitude` decimal(10,6) NOT NULL default '0.000000',
  `timezone` tinyint(2) NOT NULL default '0',
  `dst` tinyint(1) NOT NULL default '0',
  `country` char(2) NOT NULL default '',
  PRIMARY KEY  (`country`,`zip`),
  KEY `pc` (`country`,`zip`),
  KEY `zip` (`zip`),
  KEY `latitude` (`latitude`),
  KEY `longitude` (`longitude`),
  KEY `country` (`country`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

