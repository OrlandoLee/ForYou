#!/bin/bash
mysql -u zongsheng  --default_character_set utf8 foryou  < drop.sql
mysql -u zongsheng  --default_character_set utf8 foryou < create.sql
mysql -u zongsheng  --default_character_set utf8 foryou < load.sql
