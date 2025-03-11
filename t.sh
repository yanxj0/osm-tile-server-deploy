CURRENT_DIR=$(cd $(dirname $0); pwd)
file_dir=$(cd $(dirname $1); pwd)
file_name=$(basename $1)
echo $file_name

if [ "$2" == "local" ]; then
    volume_ext_data="-v $CURRENT_DIR/external-data.yml:/data/style/external-data.yml"
fi

docker run --rm \
    -v $file_dir/$file_name:/data/region.osm.pbf \
    -v $CURRENT_DIR/data/database:/data/database/ \
    -v $CURRENT_DIR/data/tiles:/data/tiles/ \
    -v $CURRENT_DIR/external_data:/external_data/ \
    $volume_ext_data \
    overv/openstreetmap-tile-server \
    import

