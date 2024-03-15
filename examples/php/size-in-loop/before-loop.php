<?php

$a = range(1, 1_000_000, 2);

while (true) {
    $c = count($a);
    for ($i=0; $i<$c; $i++) {
        $d = $i;
    }
    usleep(10_000);
}
