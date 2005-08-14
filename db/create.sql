DROP TABLE IF EXISTS `bands`;
CREATE TABLE `bands` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `contact_email` varchar(100) NOT NULL default '',
  `bio` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;