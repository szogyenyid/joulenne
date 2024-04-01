<?php

$a = range(1, 1_000_000, 2);

while (true) {
    foreach ($a as $e) {
        $d = $e;
    }
    usleep(10_000);
}
