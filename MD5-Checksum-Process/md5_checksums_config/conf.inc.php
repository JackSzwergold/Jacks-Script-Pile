<?php

//**************************************************************************************************/
// Enable error reporting & display errors on the screen.
error_reporting(E_ALL);
ini_set('display_errors', TRUE);

//**************************************************************************************************/
// Include the local settings.

require_once 'local.inc.php';

/**************************************************************************************************/
// Define the remaining basics.

// Define BASE_FILEPATH
$script_filename_parts = pathinfo($_SERVER['SCRIPT_FILENAME']);
define('BASE_FILEPATH', $script_filename_parts['dirname']);

// Detect if protocol is 'http' or 'https'
$URL_PROTOCOL = (array_key_exists('HTTPS', $_SERVER) && 'on' == $_SERVER['HTTPS'])
                || $_SERVER['SERVER_PORT'] == '443'
                ? 'https' : 'http';

// Detect ports used by $URL_PROTOCOL
if (('http' == $URL_PROTOCOL && '80' == $_SERVER['SERVER_PORT'])
    || ('https' == $URL_PROTOCOL && '443' == $_SERVER['SERVER_PORT']))
    $URL_PORT = '';
else
    $URL_PORT = ':' . $_SERVER['SERVER_PORT'];

$URL_HOST = $URL_PROTOCOL . '://' . $_SERVER['SERVER_NAME'] . $URL_PORT;

// Define BASE_URL
define('BASE_URL', $URL_HOST . BASE_PATH);

?>
