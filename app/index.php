<?php

// Переменная, возвращающая IP адрес хоста
$internal_ip = $_SERVER['SERVER_ADDR'];

echo "<h1>This is Kubernetes cluster test application.</h1><br>";
echo "It shows internal IP address of currently working pod.<br>";
echo "Current pod`s IP: $internal_ip";

?>
