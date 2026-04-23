#!/bin/bash
mega-sync /test /Test
for i in {1..30}; do date "+[%Y-%m-%d %H:%M:%S]"; sleep 0.1; mega-sync; done