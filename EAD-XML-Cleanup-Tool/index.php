<?

/**
 * EAD XML Cleanup Class (EADXMLCleanup.class.php)
 *
 * Programming: Jack Szwergold
 *
 * Created: 2014-10-01 js
 * Version: 2014-10-01, js: creation
 *          2014-10-01, js: development & cleanup
 *          2014-10-02, js: factoring into a class
 *          2014-10-03, js: development & tweaking
 *          2014-10-04, js: core set; set the headers & structure
 *          2014-10-09, js: more development; looping through a list of item
 *          2014-10-16, js: more development & refinements
 *
 */

//**************************************************************************************//
// Require the basic configuration settings & functions.

require_once 'classes/EADXMLCleanup.class.php';

//**************************************************************************************//
// Init the "EADXMLCleanup()" class.

$EADXMLCleanup = new EADXMLCleanup(FALSE);

//**************************************************************************************//
// Set the array of items to parse.

$xml_files = array();
$xml_files[] = 'MOE_001.xml';
$xml_files[] = 'LARRY_002.xml';
$xml_files[] = 'CURLY_003.xml';

//**************************************************************************************//
// Set the array of items to parse.

foreach ($xml_files as $xml_file) {

  // Get the path info for the file.
  $pathinfo = pathinfo($xml_file);
  
  // Set the source & destination filenames.
  $source_file = $pathinfo['filename'] . '.' . $pathinfo['extension'];
  $destination_file = $pathinfo['filename'] . '.' . $pathinfo['extension'];

  // Set the source & destination paths.
  $source_path = '/Users/jack/Desktop/ead_xml_source/';
  $destination_path = '/Users/jack/Desktop/ead_xml_destination/';

  // Process the files.
  $EADXMLCleanup->initFiles($source_path . $source_file, $destination_path . $destination_file, FALSE, TRUE);
  $EADXMLCleanup->displayXML(FALSE);
  $EADXMLCleanup->formatDOMDocument(TRUE);
  $EADXMLCleanup->formatStripNewlines(TRUE);
  $EADXMLCleanup->initCleanup();

} // foreach

?>