[pbf下载](https://download.geofabrik.de/index.html)


# 提取china ,-p geojson , -o outputfile
osmium extract -p china.geojson -o china.osm.pbf asia-latest.osm.pbf


# 合并 
osmium merge china-latest.osm.pbf taiwan-latest.osm.pbf -o china.osm.pbf