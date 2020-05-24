<?php

/**
 * Image Asset Parser (image_asset_parser.sh) (c) by Jack Szwergold
 *
 * Image Asset Parser is licensed under a
 * Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
 *
 * You should have received a copy of the license along with this
 * work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
 * 
 *  w: http://www.preworn.com
 *  e: me@preworn.com
 * 
 * Created: 2014-08-30, js
 * Version: 2014-08-30, js: creation
 *          2014-08-30, js: development
 *
 */

//**************************************************************************************//
// Very simple proof of concept stuff for now.

if (count($argv) > 1) {

  $BASE_DIR = "/Applications/MAMP/htdocs/Image-Asset-Parser/";
  $LOG_DIR = "/Applications/MAMP/htdocs/Image-Asset-Parser/logs/";
  $php_log = $LOG_DIR . 'image_asset_php_process.log';

  if (file_exists($LOG_DIR)) {

    $filename = $argv[1];

    $output_array = array();
    $output_array[] = $filename;

    $output_array = array_filter($output_array);

    $output_final = implode("\t", $output_array);

    $php_log_data = $output_final . "\r\n";

    $handle = fopen($php_log, "a");
    fwrite($handle, $php_log_data);
    fclose($handle);

  }

}

?>