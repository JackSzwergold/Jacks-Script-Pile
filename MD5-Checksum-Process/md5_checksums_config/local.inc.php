<?php 

/**************************************************************************************************/
// Define the BASE_PATH URL fragent

define('BASE_PATH', '/');

/**************************************************************************************************/
// Define the database connection variables.

$DB_CONFIG = array();
$DB_CONFIG['db_host'] = 'localhost';
$DB_CONFIG['db_username'] = 'root';
$DB_CONFIG['db_passwd'] = 'root';
$DB_CONFIG['db_dbname'] = 'md5_checksums';
$DB_CONFIG['db_port'] = '3306';
$DB_CONFIG['db_socket'] = null;

/**************************************************************************************************/
// Set the DB connection character set.

$DB_CHARSET = 'latin1';
// $DB_CHARSET = 'utf8';

?>