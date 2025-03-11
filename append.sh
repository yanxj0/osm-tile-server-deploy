CURRENT_DIR=$(cd $(dirname $0); pwd)
file_dir=$(cd $(dirname $1); pwd)
file_name=$(basename $1)

chmod +x ./style/run.sh

docker run --rm \
    -v $file_dir/$file_name:/data/region.osm.pbf \
    -v $CURRENT_DIR/data/database:/data/database/ \
    -v $CURRENT_DIR/style:/data/style/ \
    --entrypoint="/data/style/run.sh" \
    overv/openstreetmap-tile-server \
    append