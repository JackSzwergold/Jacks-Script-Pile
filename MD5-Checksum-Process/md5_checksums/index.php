<?php

/**
 * MD5 Checksum Index Controller (index.php) (c) by Jack Szwergold
 *
 * MD5 Checksum Index Controller is licensed under a
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

//**************************************************************************************//
// Require the basic configuration settings & functions.
require_once '../md5_checksums_config/conf.inc.php';
require_once 'common/functions.inc.php';
require_once 'classes/frontendDisplay.class.php';

//**************************************************************************************//
// Init the "frontendDisplay()" class.

$frontendDisplayClass = new frontendDisplay(FALSE);
$frontendDisplayClass->initContent();


?>