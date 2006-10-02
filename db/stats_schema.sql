CREATE TABLE `log_entries` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ip` varchar(16) default NULL,
  `host` varchar(100) default NULL,
  `date` datetime default NULL,
  `method` varchar(4) default NULL,
  `url` varchar(100) default NULL,
  `http_ver` varchar(16) default NULL,
  `status` varchar(4) default NULL,
  `bytes` int(10) default NULL,
  `referrer` varchar(100) default NULL,
  `browser` text,
  PRIMARY KEY  (`id`),
  KEY `url` (`url`),
  KEY `referrer` (`referrer`)
) ENGINE=MyISAM;
