<?php

$a = range('A', 'z');
$d = '';

while (true) {
    foreach ($a as $letter) {
        $d .= $letter . '-';
    }
    usleep(1_000);
}
