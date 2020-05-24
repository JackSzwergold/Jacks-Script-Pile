<?php

/**
 * MD5 Checksum Functions (functions.inc.php) (c) by Jack Szwergold
 *
 * MD5 Checksum Frontend Display Class is licensed under a
 * Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
 *
 * You should have received a copy of the license along with this
 * work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
 *
 * w: http://www.preworn.com
 * e: me@preworn.com
 *
 * Created: 2013-08-05 js
 * Version: 2013-08-05, js: creation
 *          2013-08-05, js: development & cleanup
 *
 */

// Init the DB.
function INIT_DB ($DB_CONFIG, $DB_CHARSET = null) {

  // return mysqli_connect($this->db_host, $this->db_username, $this->db_passwd, $this->db_dbname, $this->db_port, $this->db_socket);
  $mysqli = new mysqli($DB_CONFIG['db_host'], $DB_CONFIG['db_username'], $DB_CONFIG['db_passwd'], $DB_CONFIG['db_dbname'], $DB_CONFIG['db_port'], $DB_CONFIG['db_socket']);
  if (!empty($DB_CHARSET)) {
    $mysqli->set_charset($DB_CHARSET);
  }
  if (mysqli_connect_error()) {
  // if ($mysqli->connect_error) {
    die();
  }
  return $mysqli;

} // INIT_DB

// Fetch the DB query & found rows.
function FETCH_DB ($db_conn, $query = null) {

  $raw_result = mysqli_query($db_conn, $query);
  $results = array();
  while ($raw_result_row = mysqli_fetch_assoc($raw_result)) {
    $results[] = $raw_result_row;
  }

  $found_result = mysqli_query($db_conn, 'SELECT FOUND_ROWS()');
  while ($found_result_row = mysqli_fetch_row($found_result)) {
    $found_rows = $found_result_row[0];
  }

  return array($results, $found_rows);

} // fetchDB

# SOURCE: http://stackoverflow.com/questions/6837148/change-foreign-characters-to-normal-equivalent
function unaccent($string) {
  if (strpos($string = htmlentities($string, ENT_QUOTES, 'UTF-8'), '&') !== false) {
    $string = html_entity_decode(preg_replace('~&([a-z]{1,2})(?:acute|cedil|circ|grave|lig|orn|ring|slash|tilde|uml);~i', '$1', $string), ENT_QUOTES, 'UTF-8');
  }
  return $string;
}

?>
