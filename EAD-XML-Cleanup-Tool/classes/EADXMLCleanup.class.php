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
// Here is where the magic begins!

class EADXMLCleanup {

  private $DEBUG_MODE = FALSE;

  private $domdocument_formatting = FALSE;
  private $strip_newlines = FALSE;

  //**************************************************************************************//
  // Constructor.

  public function __construct($DEBUG_MODE = NULL) {

    // Added to increase memory limit for this specific script & spare the rest of the server.
    ini_set('memory_limit', '512M');

  } // __construct


  //**************************************************************************************//
  // Set the displayXML setting.

  function displayXML($display_xml = FALSE) {
  
    $this->display_xml = $display_xml;

  } // displayXML


  //**************************************************************************************//
  // Set the DOMDocument formatting setting.

  function formatDOMDocument($domdocument_formatting = FALSE) {
  
    $this->domdocument_formatting = $domdocument_formatting;

  } // formatDOMDocument


  //**************************************************************************************//
  // Set the strip newlines setting.

  function formatStripNewlines($strip_newlines = FALSE) {
  
    $this->strip_newlines = $strip_newlines;

  } // formatStripNewlines


  //**************************************************************************************//
  // Init the files.

  function initFiles($file_in = null, $file_out = null) {

    // Set the input file.
    if ($file_in) {
      $this->file_in = $file_in;
    }

    // Set the output file.
    if ($file_out) {
      $this->file_out = $file_out;
    }

  } // initFiles


  //**************************************************************************************//
  // Init the cleanup process.

  function initCleanup() {

    // Check if we have input & output files to work with.
    if (!$this->file_in) {
      return;
    }

    // Check if the input file actually exists.
    if (!file_exists($this->file_in)) {
      return;
    }

    // Load the file.
    $xml_resource = simplexml_load_file($this->file_in);

    // Check if the XML resource is valid.
    if (!$xml_resource) {
      return;
    }

    // Adjust the 'eadheader' attributes.
    $xml_resource = $this->adjustEADHeaderAttributes($xml_resource);

    // Adjust the 'unitdate' attributes.
    $xml_resource = $this->adjustUnitdateAttributes($xml_resource);

    // Adjust the DAO href title.
    $xml_resource = $this->adjustDAOhrefTitle($xml_resource);

    // Adjust the DAO href title.
    $xml_resource = $this->adjustC0Tags($xml_resource);

    // Adjust 'physdesc' tags.
    $xml_resource = $this->adjustPhysDescTags($xml_resource);

    // Render the XML to a variable.
    if ($this->domdocument_formatting) {
      $dom = new DOMDocument;
      $dom->preserveWhiteSpace = false;
      $dom->loadXML($xml_resource->asXML());
      if ($this->strip_newlines) {
        $xpath = new DOMXPath($dom);
        foreach ($xpath->query('//text()') as $domText) {
          $domText->data = preg_replace('/\s\s+/', ' ', $domText->nodeValue);
        }
      }
      $dom->formatOutput = true;
      $ret = $dom->saveXML();
    }
    else {
      $ret = $xml_resource->asXML();
    }

    // Output the adjusted XML to the screen.
    if ($this->display_xml) {
      echo '<pre>';
      echo htmlentities($ret);
      echo '</pre>';
    }
    else {
      echo "Processed: " . $this->file_in . '<br />';
    }

    // Save the XML to a file.
    if ($this->file_out) {
      if ($this->domdocument_formatting) {
        $dom->save($this->file_out);
      }
      else {
        $xml_resource->formatOutput = true;
        $xml_resource->asXml($this->file_out);
      }
    }
    
    unset($dom);
    unset($xml_resource);

  } // initContent


  //**************************************************************************************//
  // Adjust 'physdesc' tags.

  function adjustPhysDescTags($xml_resource) {

    $result = $xml_resource->xpath('//did/physdesc[@label="Volume:"]');

    foreach ($result as $key => $value) {
      $physdesc_volume = trim((string) $value);
      $value[0][0] = null;
      $value->addChild("extent", $physdesc_volume)->addAttribute('altrender', 'materialtype spaceoccupied');
    }

    return $xml_resource;

  } // adjustPhysDescTags


  //**************************************************************************************//
  // Adjust the DAO href title.

  function adjustC0Tags($xml_resource) {

    $xpath_array = array();
    for ($i = 1; $i <= 9; $i++) {
      $xpath_array[] = "self::c" . str_pad($i, 2, 0, STR_PAD_LEFT);
    }

    $result = $xml_resource->xpath("//*[" . implode(" or ", $xpath_array) . "]");

    foreach ($result as $key => $value) {
      if (isset($value->did) && !empty($value->did)) {

        // Remove newlines from 'unittitle' values.
        $href_title = '';
        if (isset($value->did->unittitle) && !empty($value->did->unittitle)) {
          $href_title = trim(preg_replace('/\s\s+/', ' ', $value->did->unittitle));
          $value->did->unittitle = $href_title;
        }

        // Remove 'unitdate' if empty.
        $unitdate = trim($value->did->unitdate);
        if (empty($unitdate)) {
          unset($value->did->unitdate);
        }

        // Remove 'container' elements of 'box' or 'folder' is empty.
        $container_type_array = array('box', 'folder');
        if (isset($value->did->container)) {
          $index_counter = 0;
          $container_count = count($value->did->container);
          for ($i = 0; $i < $container_count; $i++) {
            if (in_array($value->did->container[$index_counter]['type'], $container_type_array)) {
              $trimmed_value = trim($value->did->container[$index_counter]);
              if (empty($trimmed_value)) {
                unset($value->did->container[$index_counter]);
              }
              $index_counter--;
            }
            $index_counter++;
          }
        }

      }
    }

    return $xml_resource;

  } // adjustC0Tags


  //**************************************************************************************//
  // Adjust the DAO href title.

  function adjustDAOhrefTitle($xml_resource) {

    $result = $xml_resource->xpath('//did');

    if (!empty($result)) {
      foreach ($result as $key => $value) {
        if (isset($value->dao)) {
          $href_title = '';
          if (isset($value->unittitle) && !empty($value->unittitle)) {
            $href_title = trim(preg_replace('/\s\s+/', ' ', $value->unittitle));
          }
          $value->dao->addAttribute("title", $href_title);
        }
      }
    }

    return $xml_resource;

  } // adjustDAOhrefTitle


  //**************************************************************************************//
  // Adjust the 'eadheader' attributes.

  function adjustEADHeaderAttributes($xml_resource) {

    // Set the EAD element.
    $ead = '<?xml version="1.0" encoding="utf-8" standalone="no"?>';
    $ead .= '<!DOCTYPE ead SYSTEM "ead.dtd">';
    // $ead .= '<!DOCTYPE ead PUBLIC "-//Society of American Archivists//DTD ead.dtd (Encoded Archival Description (EAD) Version 1.0)//EN" "ead.dtd">';
    $ead .= '<ead xmlns="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"'
          . ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
          . ' xsi:schemaLocation="urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd" />'
          ;

    $ead_final = new SimpleXMLElement($ead);

    // Set the EAD header element.
    $eadheader = '<eadheader countryencoding="iso3166-1" dateencoding="iso8601"'
               . ' findaidstatus="complete" langencoding="iso639-2b" repositoryencoding="iso15511" />'
               ;

    $eadheader_final = new SimpleXMLElement($eadheader);

    // Get the source header values and insert them into the new header.
    foreach ($xml_resource->eadheader->xpath('.')[0] as $eadheader_key => $eadheader_value) {
      $this->simplexml_append_nodes($eadheader_final, $eadheader_value);
    }

    // Append the new header into the EAD.
    $this->simplexml_append_nodes($ead_final, $eadheader_final);

    // Append the core ARCHDESC into the EAD.
    $this->simplexml_append_nodes($ead_final, $xml_resource->archdesc);

    // Return the final EAD.
    return $ead_final;

  } // adjustEADHeaderAttributes


  //**************************************************************************************//
  // Ideas for merging.

  // SOURCE: http://stackoverflow.com/a/4778964/117259
  function simplexml_append_nodes(SimpleXMLElement $to, SimpleXMLElement $from) {
    $toDom = dom_import_simplexml($to);
    $fromDom = dom_import_simplexml($from);
    $toDom->appendChild($toDom->ownerDocument->importNode($fromDom, true));
  } // simplexml_append_nodes


  //**************************************************************************************//
  // Adjust the 'unitdate' attributes.

  function adjustUnitdateAttributes($xml_resource) {

    $result = $xml_resource->xpath('//unitdate');

    if (!empty($result)) {
      foreach ($result as $key => $value) {
        $value->addAttribute("type", "inclusive");
      }
    }

    return $xml_resource;

  } // adjustUnitdateAttributes


} // EADXMLCleanup

?>