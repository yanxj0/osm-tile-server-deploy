@echo off

set file_name=%~nx1
set file_dir=%~dp1
set cur_dir=%~dp0

docker run --rm -v "%file_dir%%file_name%:/data/region.osm.pbf" -v "%cur_dir%data\database\:/data/database/" -v "%cur_dir%data\tiles:/data/tiles/" -v '%cur_dir%style:/data/style/' -v "%cur_dir%external_data:/external_data/" --entrypoint="/data/style/run.sh" overv/openstreetmap-tile-server import