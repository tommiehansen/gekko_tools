<!doctype html>
<html>
<head>
	<title># TEST</title>
	<style>
	html {font-size: 62.5%; }
	body{padding:2% 0;font-family:monospace,mono-space;font-size:1.5rem;color:deeppink;text-align:center;overlow-x:hidden}*,:after,:before{box-sizing:border-box}body,html{height:100%}
	body { background-image: linear-gradient(to top,#060311,#140b3c); background-attachment: fixed; }
	h1{color:#ff1493;font-weight:400;font-size:1.2rem;margin:20px 0 30px}
	pre,textarea{display:block;text-align:left;border:1px dashed #ff0;color:#ff0;padding:20px;vertical-align:top;transition:all .5s ease;cursor:default;min-width:30%;max-width:100%;position:relative;border-radius:2px;line-height:1.4}
	pre { margin-bottom: 20px; }
	pre:after,textarea:after{content:'$';line-height:1;position:absolute;left:20px;top:-7px;background:#140b3c;padding:0 5px}
	pre b,textarea b{font-size:40px;font-weight:400}
	
	body,html { height: 100%; margin: 0; }
	body { margin-bottom: 200px; }
	h1,h2 { color: deeppink; font-weight: normal; }
	h1 { font-size: 1.8rem; }
	section { max-width: 600px; position: relative; margin:0 auto; }
	
	/* pre stuff */
	pre { margin-bottom: 30px; }
	pre:nth-child(2n+1){ border-color: deeppink; color: deeppink; }
	pre:nth-child(3n+1){ border-color: cyan; color: cyan; }
	pre:focus,pre:hover{color:#fff;border-color:lime; }
	</style>
</head>
<body>
<section>
<h1>some test</h1>

<?php

	// JS-date > readable date
	function timeToDate( $str, $format = 'Y-m-d' ) {
		return date($format, $str);
	}
	
	/*
		min/max date range for a pair
		-
		get min/max date range and convert to readable date
		requires db-handle and table name
		-
		return array with date_min/date_max
	*/
	function minMax( $db, $table )
	{
		$sql = "
			SELECT
				strftime('%Y-%m-%d %H:%M', datetime(MIN(start), 'unixepoch')) as date_min,
				strftime('%Y-%m-%d %H:%M', datetime(MAX(start), 'unixepoch')) as date_max
			FROM `$table`
		";
		$q = $db->query($sql);
		$q = $q->fetchAll()[0]; // always just one
		return $q;
	}
	

	/*
		CRITICAL CHECKS
	*/

	// check if user config exists
	if( !file_exists('system/user.config.php') ) die('<b>ERROR</b> Could not find user.config.php, make sure you have createad it.');
	
	require_once 'system/functions.php';
	require_once 'system/user.config.php';
	
	// check if the path is correct
	if( !file_exists($gekko_path . 'README.md') ) die('<b>ERROR</b> The path to your Gekko install is wrong or not working.');
	
	
	
	
	/*
		SETUP PATHS
	*/
	
	$gp = $gekko_path;
	$paths = [
		'gekko' => $gp,
		'history' => $gp . 'history/',
	];
	
	$paths = json_decode(json_encode($paths));
	#prp($paths);
	
	
	
	
	/*
		GET ALL HISTORY FILES
	*/
	
	$files = listFiles( $paths->history );
	
	// ..then remove any not ending with '.db'
	foreach($files as $key => $value)
	{
		$cur = end(explode('.', $files[$key]));	// explode + get last	
		if( $cur !== 'db' ) unset($files[$key]);
	}
	
	$files = array_values($files); // re-index
	echo 'history files';
	prp($files);
	
	
	
	
	
	/*
		TRY SQLite STUFF
	*/
	
	// init $db, TEMP: use first db
	$first = $paths->history . $files[0];
	$db = new PDO('sqlite:' . $first) or die('<b>ERROR</b> Could not connect to database.');
	$db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
	
	$sql = "
		SELECT name
		FROM main.sqlite_master
		WHERE type = 'table'
	";
	
	$tables = $db->query($sql);
	$tables = $tables->fetchAll();
	
	
	// filter out tables not containg candles_
	foreach( $tables as $key => $val )
	{
		$cur = $tables[$key];
		$name = $val['name'];		
		if( !contains('candles_', $name) || contains('sqlite', $name) ) unset($tables[$key]);
	}
	
	echo 'tables';
	prp($tables);
	
	
	// get min/max
	echo 'min/max';
	$stuff = minMax($db, $tables[0]['name']);
	prp($stuff);
	
	$db = null;
?>

</section>
</body>
</html>