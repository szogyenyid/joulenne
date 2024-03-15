<?php

$a = range(1, 1_000_000, 2);

while (true) {
    for ($i=0; $i<count($a); $i++) {
        $d = $i;
    }
    usleep(10_000);
}
