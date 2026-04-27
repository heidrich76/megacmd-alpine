#!/bin/bash
ts() { date "+[%Y-%m-%d %H:%M:%S.%3N]"; }

ts
mega-sync /test /Test
mega-sync
sleep 5
ts
mega-sync
