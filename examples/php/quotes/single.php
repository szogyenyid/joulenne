<?php

$a = range('A', 'z');

while (true) {
    $d = '';
    foreach ($a as $letter) {
        $d .= $letter . '-';
    }
    usleep(100);
}
