-- MySQL dump 8.23
--
-- Host: localhost    Database: mail
---------------------------------------------------------
-- Server version	3.23.58

--
-- Current Database: mail
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ mail;

USE mail;

--
-- Table structure for table `virtual_aliases`
--

CREATE TABLE virtual_aliases (
  Id int(10) unsigned NOT NULL auto_increment,
  alias varchar(255) default NULL,
  virtual_user_email text,
  PRIMARY KEY  (Id),
  FULLTEXT KEY aliases (alias,virtual_user_email)
) TYPE=MyISAM COMMENT='Postfix virtual recipient aliases';

--
-- Dumping data for table `virtual_aliases`
--


INSERT INTO virtual_aliases VALUES (1,'postmaster@example.com','bamm.bamm@example.com');
INSERT INTO virtual_aliases VALUES (2,'abuse@example.com','bamm.bamm@example.com');

--
-- Table structure for table `virtual_mailbox_domains`
--

CREATE TABLE virtual_mailbox_domains (
  Id int(10) unsigned NOT NULL auto_increment,
  domain varchar(255) default NULL,
  PRIMARY KEY  (Id),
  FULLTEXT KEY domains (domain)
) TYPE=MyISAM COMMENT='Postfix virtual domains';

--
-- Dumping data for table `virtual_mailbox_domains`
--


INSERT INTO virtual_mailbox_domains VALUES (1,'example.com');

--
-- Table structure for table `virtual_users`
--

CREATE TABLE virtual_users (
  id int(11) unsigned NOT NULL auto_increment,
  username varchar(255) NOT NULL default '0',
  userrealm varchar(255) NOT NULL default 'state-of-mind.de',
  userpassword varchar(255) NOT NULL default 'AendrM1ch!',
  auth tinyint(1) default '1',
  active tinyint(1) default '1',
  email varchar(255) NOT NULL default '',
  virtual_uid smallint(5) default '1000',
  virtual_gid smallint(5) default '1000',
  virtual_mailbox varchar(255) default NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY id (id),
  FULLTEXT KEY recipient (email)
) TYPE=MyISAM COMMENT='SMTP AUTH and virtual mailbox users';

--
-- Dumping data for table `virtual_users`
--


INSERT INTO virtual_users VALUES (1,'bamm.bamm','mail.example.com','1stP@ss',1,1,'bamm.bamm@example.com',1001,1001,'example.com/bamm.bamm/');

