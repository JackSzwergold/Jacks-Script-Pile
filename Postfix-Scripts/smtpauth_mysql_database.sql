-- $Id: smtpauth_mysql_database.sql 1119 2005-02-28 09:03:09Z patrick $
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
-- Table structure for table `users`
--

CREATE TABLE users (
  id int(11) unsigned NOT NULL auto_increment,
  username varchar(255) NOT NULL default '0',
  userrealm varchar(255) NOT NULL default 'example.com',
  userpassword varchar(255) NOT NULL default '1stP@ss',
  auth tinyint(1) default '1',
  PRIMARY KEY  (id),
  UNIQUE KEY id (id)
) TYPE=MyISAM COMMENT='SMTP AUTH relay users';

--
-- Dumping data for table `users`
--


INSERT INTO users VALUES (1,'test','mail.example.com','testpass',1);

