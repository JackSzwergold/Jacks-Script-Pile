<?php

/**
 * MD5 Checksum Frontend Display Class (frontendDisplay.class.php) (c) by Jack Szwergold
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
 *          2013-08-06, js: development
 *          2013-08-07, js: development
 *          2013-08-08, js: development
 *          2013-08-09, js: development
 *          2013-08-13, js: development
 *          2013-08-14, js: refining reporting
 *          2013-08-15, js: adding date & time of checks
 *          2013-08-16, js: small refinements
 *          2013-08-23, js: fixed an issue with filenames being used as keys causing non-reporting in some cases
 *
 */

//**************************************************************************************//
// Class based version of the system.

class frontendDisplay {

  private $DEBUG_MODE = FALSE;

  private $db_conn = null;

  private $content_type = 'text/plain';
  private $charset = 'utf-8';

  private $directory_limit = null;
  private $directory_path_limit = null;
  private $file_limit = null;

  private $directory_include = array();
  private $directory_exclude = array();

  private $header_shown = FALSE;
  private $time_start = FALSE;
  private $time_end = FALSE;

  private $mode = '';

  public function __construct($DEBUG_MODE = NULL) {

    // Added to increase memory limit for this specific script & spare the rest of the server.
    ini_set('memory_limit', '512M');

    $this->mode = 'one_thing';
    // $this->mode = 'another_thing';

  } // __construct


  //**************************************************************************************//
  // Init the content.
  function initContent() {

    $ret = '';

    switch ($this->mode) {
      case 'one_thing':
        $this->directory_include = array();
        $this->directory_exclude = array('Moe', 'Larry', 'Curly');
        break;
      case 'another_thing':
        $this->directory_include = array('Moe', 'Larry', 'Curly');
        $this->directory_exclude = array();
        break;
      default:
        break;
    }

    $this->time_start = microtime(true);

    $directory_names = $this->fetchParentDirectories();

    if (!empty($directory_names)) {
      $processed_names = $this->processParentDirectories($directory_names);
      $this->time_end = microtime(true);
      $time_diff = (($this->time_end - $this->time_start) / 60);
      echo "\n";
      echo "Script Time: " . round($time_diff, 2);
    }
    else {
      echo "No directories found.";
    }

  } // initContent


  //**************************************************************************************//
  // Simplify the path info.
  function simplifyPathInfo($value) {

    $directory_array = array();

    $directory_array['/here/is/a/long/path/'] = 'Here-Is-A-Nicer-Name-For-It';

    $ret = '';

    if (array_key_exists($value, $directory_array)) {
      $ret = $directory_array[$value];
    }
    else {
      $ret = $value;
    }

    return $ret;

  } // simplifyPathInfo


  //**************************************************************************************//
  // Fetch the parent directory names.
  private function fetchParentDirectories() {
    global $DB_CONFIG;

    $where_array = array();
    if (!empty($this->directory_include)) {
      $where_array[] = sprintf("directory_name IN ('%s')", implode("','", $this->directory_include));
    }
    if (!empty($this->directory_exclude)) {
      $where_array[] = sprintf("directory_name NOT IN ('%s')", implode("','", $this->directory_exclude));
    }
    $where_condition = sprintf(' WHERE %s', implode(' AND ', $where_array));

    $limit = !empty($this->directory_limit) ? sprintf(' LIMIT %d', $this->directory_limit) : null;

    $query = 'SELECT DISTINCT'
           . ' directory_name'
           . ' FROM'
           . ' checksum_data'
           . $where_condition
           . ' ORDER BY'
           . ' directory_name'
           . $limit
           ;

    $db_conn_api = INIT_DB($DB_CONFIG);
    list($results, $found_rows) = FETCH_DB($db_conn_api, $query);

    return ($found_rows > 0) ? $results : FALSE;

  } // fetchParentDirectories


  //**************************************************************************************//
  // Fetch the directory paths.
  private function fetchDirectoryPaths($directory_name = null) {
    global $DB_CONFIG;

    $where_array = array();
    if (!empty($directory_name)) {
      $where_array[] = sprintf("directory_name = '%s'", $directory_name);
    }
    $where_condition = sprintf(' WHERE %s', implode(' AND ', $where_array));

    $limit = !empty($this->directory_path_limit) ? sprintf(' LIMIT %d', $this->directory_path_limit) : null;

    $query = 'SELECT DISTINCT'
           . ' directory_path'
           . ' FROM'
           . ' checksum_data'
           . $where_condition
           . ' ORDER BY'
           . ' directory_path'
           . $limit
           ;

    $db_conn_api = INIT_DB($DB_CONFIG);
    list($results, $found_rows) = FETCH_DB($db_conn_api, $query);

    return ($found_rows > 0) ? $results : FALSE;

  } // fetchDirectoryPaths


  //**************************************************************************************//
  // Fetch MD5 checksums.
  private function fetchMD5Checksums($directory_name = null, $directory_path = null) {
    global $DB_CONFIG;

    $where_array = array();
    if (!empty($directory_name)) {
      $where_array[] = sprintf("directory_name = '%s'", $directory_name);
    }
    if (!empty($directory_path)) {
      $where_array[] = sprintf("directory_path = '%s'", $directory_path);
    }
    $where_condition = sprintf(' WHERE %s', implode(' AND ', $where_array));

    $limit = !empty($this->file_limit) ? sprintf(' LIMIT %d', $this->file_limit) : null;

    $query = 'SELECT'
           . ' check_date,'
           . ' check_time,'
           . ' md5_value,'
           . ' file_name'
           . ' FROM'
           . ' checksum_data'
           . $where_condition
           . ' ORDER BY'
           . ' directory_name,'
           . ' directory_path,'
           . ' file_name'
           . $limit
           ;

    $db_conn_api = INIT_DB($DB_CONFIG);
    list($results, $found_rows) = FETCH_DB($db_conn_api, $query);

    return ($found_rows > 0) ? $results : FALSE;

  } // fetchMD5Checksums


  //**************************************************************************************//
  // Process the directory names.
  private function processParentDirectories($raw_items ='') {

    if ($this->header_shown === FALSE) {
      // header('Content-Type: text/plain; charset=utf-8');
      header('Content-Type: text/plain;');
      $this->header_shown = TRUE;
    }

    foreach ($raw_items as $raw_items_key => $raw_items_value) {

      $item_counter = 0;

      $parent_items = array();

      $paths = $this->fetchDirectoryPaths($raw_items_value['directory_name']);

      foreach($paths as $paths_key => $paths_value) {

        // Split the pathname.
        list($root_path, $sub_path) = $this->splitPathname($raw_items_value['directory_name'], $paths_value['directory_path']);

        // Fetch the MD5 checksums.
        $results_value = $this->fetchMD5Checksums($raw_items_value['directory_name'], $paths_value['directory_path']);
        $parent_items[$root_path][$sub_path] = $results_value;

      } // paths_value

      if (FALSE) {
        print_r($parent_items);
      }

      $item_file_array = array();
      foreach ($parent_items as $parent_key => $parent_value) {
        foreach ($parent_value as $child_key => $child_value) {
          foreach ($child_value as $directory_key => $directory_value) {

            // Get the sinmple path info for the path being used.
            $simple_path = $this->simplifyPathInfo($parent_key);

            if (FALSE) {
              print_r($directory_value);
            }

            // Set the file data blob.
            $file_data_blob = array();
            $file_data_blob['md5_value'] = $directory_value['md5_value'];
            $file_data_blob['check_date'] = $directory_value['check_date'];
            $file_data_blob['check_time'] = $directory_value['check_time'];

            // Set the file array data.
            $file_name = !empty($directory_value['file_name']) ? $directory_value['file_name'] : null;
            $item_file_array[$child_key.$file_name][$file_name][$child_key][$simple_path] = $file_data_blob;

          } // directory_value
        } // child_value
      } // parent_value



      // Now process the file array.
      foreach ($item_file_array as $real_item_file_array) {
        foreach ($real_item_file_array as $item_file_key => $item_file_value) {

          $data_counter = 0;
          $md5_data_full = array();
          foreach ($item_file_value as $file_data_key => $file_data_value) {
            $key_array =  array();
            foreach ($file_data_value as $data_key => $data_value) {
              $key_array[] = $data_key;
              $key_array[] = 'Check Date';
              $key_array[] = 'Check Time';
              $md5_data_full[$data_key] = $data_value;
            }
          }

          // Simple data integrity check via array unique.
          $md5_data_check = array_map(function ($value) { return $value['md5_value']; }, $md5_data_full);
          $unique_array = array_unique($md5_data_check);

          $final_header_array = $final_key_array = array();
          if ($item_counter == 0) {
            $final_header_array[] = $raw_items_value['directory_name'];
            $final_key_array[] = "Filename";
            $final_key_array[] = "Path";
            $final_key_array[] = "Status";
            $final_key_array[] = implode("\t", $key_array);
            echo implode("\t", $final_header_array);
            echo "\n";
            echo implode("\t", $final_key_array);
            echo "\n";
          }

          $final_data_array = array();
          if ($data_counter == 0) {
            $final_data_array[] = $item_file_key;
            $final_data_array[] = $file_data_key;
          }
          $data_counter++;

          $final_data_array[] = (count($unique_array) > 1) ? 'MISMATCH' : 'OK';
          foreach ($md5_data_full as $md5_data_full_key => $md5_data_full_value) {
            $final_data_array[] = implode("\t", $md5_data_full_value);
          }
          echo implode("\t", $final_data_array);
          echo "\n";

          $item_counter++;
        }
      }

      echo "\n";

    }

  } // processParentDirectories


  //**************************************************************************************//
  // Split the pathname.
  private function splitPathname($directory_name, $directory_path) {
    return preg_split(sprintf('/%s/', $directory_name), $directory_path, 2);
  } // splitPathname


} // frontendDisplay

?>