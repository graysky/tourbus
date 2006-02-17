CREATE TABLE `band_services` (
  `id` int(11) NOT NULL auto_increment,
  `band_id` int(10) NOT NULL default '0',
  `myspace_username` varchar(100) NOT NULL default '',
  `myspace_password` varchar(40) NOT NULL default '',
  `purevolume_username` varchar(100) NOT NULL default '',
  `purevolume_password` varchar(40) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bands` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `short_name` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` varchar(5) default NULL,
  `city` varchar(100) default '',
  `state` char(2) default '',
  `bio` text,
  `salt` varchar(40) default '',
  `official_website` varchar(100) default '',
  `salted_password` varchar(40) NOT NULL default '',
  `logo` varchar(100) default '',
  `confirmed` tinyint(1) default '0',
  `confirmation_code` varchar(50) default '',
  `claimed` tinyint(1) default '1',
  `created_on` datetime default NULL,
  `page_views` int(10) default '0',
  `security_token` varchar(40) default NULL,
  `token_expiry` datetime default NULL,
  `uuid` varchar(40) default NULL,
  `last_updated` datetime default NULL,
  `num_fans` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `name_key` (`name`),
  KEY `short_name_key` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bands_fans` (
  `band_id` int(10) NOT NULL default '0',
  `fan_id` int(10) NOT NULL default '0',
  KEY `FK_fave_fan_id` (`fan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bands_shows` (
  `band_id` int(10) NOT NULL default '0',
  `show_id` int(10) NOT NULL default '0',
  `can_edit` tinyint(1) NOT NULL default '0',
  KEY `fk_bs_show` (`show_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `body` text,
  `created_on` datetime default NULL,
  `show_id` int(10) default NULL,
  `band_id` int(10) default NULL,
  `venue_id` int(10) default NULL,
  `photo_id` int(10) default NULL,
  `created_by_fan_id` int(10) default NULL,
  `created_by_band_id` int(10) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_sc_show` (`show_id`),
  KEY `fk_cp_band` (`band_id`),
  KEY `fk_cp_venue` (`venue_id`),
  KEY `fk_cp_photo` (`photo_id`),
  KEY `fk_cp_createdband` (`created_by_band_id`),
  KEY `fk_cp_createdfan` (`created_by_fan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `fans` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `real_name` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `zipcode` varchar(5) default NULL,
  `city` varchar(100) default '',
  `state` char(2) default '',
  `bio` text,
  `salt` varchar(40) default NULL,
  `website` varchar(100) default '',
  `salted_password` varchar(40) NOT NULL default '',
  `logo` varchar(100) NOT NULL default '',
  `confirmed` tinyint(1) NOT NULL default '0',
  `confirmation_code` varchar(50) default '',
  `created_on` datetime default NULL,
  `page_views` int(10) default '0',
  `last_favorites_email` datetime default NULL,
  `default_radius` int(6) default '35',
  `wants_favorites_emails` tinyint(1) NOT NULL default '1',
  `admin` tinyint(1) NOT NULL default '0',
  `security_token` varchar(40) default NULL,
  `token_expiry` datetime default NULL,
  `show_reminder_first` int(10) default '4320',
  `show_reminder_second` int(10) default '360',
  `wants_email_reminder` tinyint(1) default '1',
  `wants_mobile_reminder` tinyint(1) default '0',
  `last_show_reminder` datetime default NULL,
  `uuid` varchar(40) default NULL,
  `last_updated` datetime default NULL,
  `superuser` tinyint(1) default '0',
  `mobile_number` varchar(20) default NULL,
  `carrier_type` int(10) default '-1',
  `show_watching_reminder` int(10) default '4320',
  PRIMARY KEY  (`id`),
  KEY `name_key` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `fans_shows` (
  `show_id` int(10) NOT NULL default '0',
  `fan_id` int(10) NOT NULL default '0',
  KEY `FK_attending_fan_id` (`fan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `fans_watching_shows` (
  `show_id` int(10) NOT NULL default '0',
  `fan_id` int(10) NOT NULL default '0',
  KEY `FK_watching_fan_id` (`fan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `index_statistics` (
  `id` int(11) NOT NULL auto_increment,
  `last_indexed_on` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL auto_increment,
  `filename` varchar(100) default NULL,
  `description` text NOT NULL,
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `page_views` int(10) default '0',
  `show_id` int(10) default NULL,
  `band_id` int(10) default NULL,
  `venue_id` int(10) default NULL,
  `created_by_fan_id` int(10) default NULL,
  `created_by_band_id` int(10) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_sp_show` (`show_id`),
  KEY `fk_sp_band` (`band_id`),
  KEY `fk_sp_venue` (`venue_id`),
  KEY `fk_sp_createdband` (`created_by_band_id`),
  KEY `fk_sp_createdfan` (`created_by_fan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `sessions_session_id_index` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `shows` (
  `id` int(11) NOT NULL auto_increment,
  `cost` varchar(50) default NULL,
  `title` varchar(100) default NULL,
  `bands_playing_title` varchar(200) default NULL,
  `description` text NOT NULL,
  `url` varchar(100) NOT NULL default '',
  `date` datetime NOT NULL default '0000-00-00 00:00:00',
  `page_views` int(10) default '0',
  `venue_id` int(10) NOT NULL default '0',
  `created_by_fan_id` int(10) default NULL,
  `created_by_band_id` int(10) default NULL,
  `created_by_system` tinyint(1) NOT NULL default '0',
  `created_on` datetime default NULL,
  `last_updated` datetime default NULL,
  `num_attendees` int(11) default '0',
  `num_watchers` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_venue` (`venue_id`),
  KEY `fk_show_createdband` (`created_by_band_id`),
  KEY `fk_show_createdfan` (`created_by_fan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags_bands` (
  `id` int(11) NOT NULL auto_increment,
  `band_id` int(10) NOT NULL default '0',
  `tag_id` int(10) NOT NULL default '0',
  `tag_type` int(10) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_bt_band` (`band_id`),
  KEY `fk_bt_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags_shows` (
  `id` int(11) NOT NULL auto_increment,
  `show_id` int(10) NOT NULL default '0',
  `tag_id` int(10) NOT NULL default '0',
  `tag_type` int(10) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_st_show` (`show_id`),
  KEY `fk_st_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags_venues` (
  `id` int(11) NOT NULL auto_increment,
  `venue_id` int(10) NOT NULL default '0',
  `tag_id` int(10) NOT NULL default '0',
  `tag_type` int(10) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_vt_venue` (`venue_id`),
  KEY `fk_vt_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `upload_addrs` (
  `id` int(11) NOT NULL auto_increment,
  `address` varchar(100) NOT NULL default '',
  `fan_id` int(10) default NULL,
  `band_id` int(10) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_cu_createdband` (`band_id`),
  KEY `fk_cu_createdfan` (`fan_id`),
  KEY `name_key` (`address`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `venues` (
  `id` int(11) NOT NULL auto_increment,
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
  `latitude` varchar(30) default NULL,
  `longitude` varchar(30) default NULL,
  `page_views` int(10) default '0',
  `last_updated` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `zip_codes` (
  `zip` varchar(16) NOT NULL default '0',
  `city` varchar(30) NOT NULL default '',
  `state` varchar(30) NOT NULL default '',
  `latitude` float NOT NULL default '0',
  `longitude` float NOT NULL default '0',
  `timezone` int(2) NOT NULL default '0',
  `dst` tinyint(1) NOT NULL default '0',
  `country` char(2) NOT NULL default '',
  KEY `pc` (`country`,`zip`),
  KEY `zip` (`zip`),
  KEY `latitude` (`latitude`),
  KEY `longitude` (`longitude`),
  KEY `country` (`country`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (11)