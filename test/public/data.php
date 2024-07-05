<?php
$dir = '/var/www/data';

if ( $_SERVER['REQUEST_METHOD'] === 'POST' ) {
	$timestamp = date('Y-m-d_H-i-s');
	$newFile = $dir . '/file_' . $timestamp . '.txt';
	file_put_contents($newFile, "This file was created at $timestamp");
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Create Timestamped File</title>
</head>
<body>
<form method="post">
	<button type="submit">Create New File</button>
</form>

<h2>Existing Files:</h2>
<ul>
	<?php
	$files = glob($dir . '/*.txt');
	foreach ( $files as $file ) {
		echo '<li>' . basename($file) . '</li>';
	}
	?>
</ul>
</body>
</html>
