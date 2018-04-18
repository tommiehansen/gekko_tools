<?php

	/*
		this file needs cleaning and classes
	*/

	# GET FILTER
	function _G($var){
		$val = false;
		if( isset($_GET[$var]) ) { $val = $_GET[$var]; }
		$val = htmlspecialchars($val);
		$val = strip_tags($val); // remove tags

		return $val;
	}

	# POST filter
	function _P($var){
		$val = false;
		if( isset($_POST[$var]) ) { $val = $_POST[$var]; }
		#$val = htmlspecialchars($val);
		$val = strip_tags($val); // remove tags

		return $val;
	}

	# FILTER DATA, remove all tags
	function filterData($str){
		$str = preg_replace("/<([a-z][a-z0-9]*)[^>]*?(\/?)>/i",'<$1$2>', $str);
		return $str;
	}

	# prp: <pre> + print_r
	function prp($str, $color = ''){ echo '<pre style="color: '. $color .'">'; print_r($str); echo '</pre>'; }
	function prph($str){
		echo '<pre>=======================================</pre>';
		echo '<pre>'; print_r($str); echo '</pre>';
		echo '<pre>=======================================</pre>';
	}


	# get all files in a dir
	function listFiles( $dir ){
        $files = @array_diff(scandir($dir), array('.', '..', '.gitignore'));
	    if( !$files ) $files = 'Error: No files reside within the directory ' . $dir;
		return $files;
	}


	# contains
	# sample: if( contains('something', $source) ){ /* string 'something' existed in $source */ }
	function contains($needle, $haystack) {
		return strpos($haystack, $needle) !== false;
	}


	# rtrim + ltrim
	function rmspace($str){
		$data = rtrim(ltrim($str, ' '), ' ');
		$data = str_replace("&nbsp;", '', $data);
		return $data;
	}

	function numfix($str){
		$data = str_replace(',','.',$str);
		$data = htmlentities($data);
		$data = rmspace($data);
		return $data;
	}


	# date diff
	function date_between($a, $b){
		$a = new DateTime($a);
		$b = new DateTime($b);
		return $b->diff($a);
	}

	# T-date split e.g. 2017-24-12T16:00:00.000Z > 2017-24-12 16:00:00
	function tdate($str){
		$arr = explode('T', $str);
		$date = $arr[0];
		$time = explode('.', $arr[1])[0];

		return $date .' ' .$time;
	}

	# convert ms to days, hours etc
	function secondsToHuman($str){
	    $a = new \DateTime('@0');
	    $b = new \DateTime("@$str");

		$diff = $a->diff($b);
		if( $diff->days > 0 ){
			return $diff->format('%ad, %hh');
		}
		else {
			return $diff->format('%hh');
		}
	}


	# curl get
	function curl_get($url)
	{

		defined(SERVER_TIMEOUT) ? $timeout = SERVER_TIMEOUT : $timeout = 600;

		$curl = curl_init($url);
		curl_setopt($curl, CURLOPT_ENCODING, 0);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4 );
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, 0);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 120);
		curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);

		$result = curl_exec($curl);
		$status = curl_getinfo($curl, CURLINFO_HTTP_CODE);

		if ( $status != 200 ) {
			die("Error: call to URL $url failed with status $status, response $result, curl_error " . curl_error($curl) . ", curl_errno " . curl_errno($curl));
		}

		curl_close($curl);

		return $result;

	}


	# measure time (simple)
	function timer_start(){ $a =  microtime(true); return $a; }
	function timer_end($start){
		$end = microtime(true);
		$diff = ($end-$start); // secondsls
		$diff = round($diff*100)/100;

		// conver to minutes
		if( $diff > 65 ) { $diff = round(($diff/60)*10)/10 . 'min'; }
		else { $diff = $diff . 's'; } // or just use seconds
		return $diff;
	}



	# output table from query; requires PDO::FETCHASSOC from query result
	function sqlTable($res, $class = 'tbl', $echo = true, $id = false ){
		$html = '';
		$head = $res[0];
		if($id) $id = " id='$id'";
		$html .= "<table class='$class'$id><thead><tr>";
		foreach($head as $k=>$v){
		    $html .= "<th>$k</th>";
		}
		$html .= "</tr></thead><tbody>";

		foreach( $res as $key => $val ){
		    $html .= "<tr>";
		    foreach($head as $i=>$h){
		        $html .= "<td>" . $val[$i] . "</td>";
		    }
		    $html .= "</tr>";
		}

		$html .= "</tbody></table>";

		if($echo) { echo $html; }
		else { return $html; }

	}


	# flatten arrays
	function array_flatten( $a, $key=NULL)
	{
		$r = array();
		if(is_array($a))foreach($a as $k=>$v)$r=array_merge($r,array_flatten($v,$k));
		else $r[$key]=$a;
		return $r;
	}


	/*-----------------------------------------------------

		SIMPLIFIED CURL GET CACHE FUNC

	    example
	    curl_cache('http://google.com', 'cache/mycachefile.php', '1 hour');

	-----------------------------------------------------*/

	function curl_cache($src, $file, $time){

	    $exists = file_exists($file);
	    $time = "+" . $time;

		$isExternal = false;
		if (strpos($src, 'http') !== false) { $isExternal = true; }

	    // file does not exist or is over x time
	    if( !$exists || ( $exists && time() > strtotime("$time", filemtime($file))) ) {

			if( $isExternal ){

				defined(SERVER_TIMEOUT) ? $timeout = SERVER_TIMEOUT : $timeout = 600;

		        $curl = curl_init($src);
				curl_setopt($curl, CURLOPT_ENCODING, 1);
				curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4 );
				curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, 0);
				curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 120);
				curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);
				curl_setopt($curl, CURLOPT_HTTPHEADER, array('Accept-Encoding: gzip,deflate')); // important -- reduce doc by 90%

				$data = curl_exec($curl);
				$status = curl_getinfo($curl, CURLINFO_HTTP_CODE);

				if( $status === 200 ){
					file_put_contents( $file, gzencode($data) );
				}

				curl_close($curl);

			} // $isExternal

			// not external, is a string of some sort -- so just put it in a file
			else {
				file_put_contents( $file, gzencode($src) );
			}

	    }

	    // file exists, just get it
	    else {
	        $data = gzdecode( file_get_contents($file) );
	    }

		// return
		return $data;

	} // curl_cache()




	/*-----------------------------------------------------

		CURL POST

		uri
		object with vars {}

	-----------------------------------------------------*/

	function curl_post($url, $vars)
	{
		defined(SERVER_TIMEOUT) ? $timeout = SERVER_TIMEOUT : $timeout = 600;

		$curl = curl_init($url);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($curl, CURLOPT_FOLLOWLOCATION, TRUE);
		curl_setopt($curl, CURLOPT_HTTPHEADER, array("Content-type: application/json",'Accept-Encoding: gzip,deflate'));
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, 0);
		curl_setopt($curl, CURLOPT_POSTFIELDS, $vars);
		curl_setopt($curl, CURLOPT_POST, true);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 120);
		curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);

		$data = curl_exec($curl);
		$status = curl_getinfo($curl, CURLINFO_HTTP_CODE);

		$arr['data'] = $data;
		$arr['status'] = $status;
		$arr = (object) $arr;

		curl_close($curl);

		return $arr;

	}

	// used to posting to 'self'
	function curl_post2($url, $vars)
	{
		defined(SERVER_TIMEOUT) ? $timeout = SERVER_TIMEOUT : $timeout = 600;

		$curl = curl_init($url);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, 0);
		curl_setopt($curl, CURLOPT_POST, true);
		curl_setopt($curl, CURLOPT_POSTFIELDS, $vars);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 120);
		curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);
		$data = curl_exec($curl);

		curl_close($curl);

		return $data;

	}

	function curl_post_cache( $url, $vars, $file, $cacheTime )
	{
		$exists = file_exists($file);
	    $time = "+" . $cacheTime;

		// file does not exist or is over x time
	    if( !$exists || ( $exists && time() > strtotime("$time", filemtime($file))) )
		{
			$data = curl_post($url, $vars);

			# only cache file if everything was ok
			if( $data->status === 200 ){
				file_put_contents( $file, gzencode(json_encode($data)) );
			}
		}

		// file exists, just get it
	    else {
	        $data = json_decode(gzdecode(file_get_contents($file)));
	    }

		$data->data = json_decode($data->data);

		return $data;

	}


?>
