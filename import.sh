CURRENT_DIR=$(cd $(dirname $0); pwd)
file_dir=$(cd $(dirname $1); pwd)
file_name=$(basename $1)

sed -i 's/\r$//' $CURRENT_DIR/style/run.sh
chmod +x $CURRENT_DIR/style/run.sh

docker run --rm \
    --security-opt seccomp=unconfined \
    -v $file_dir/$file_name:/data/region.osm.pbf \
    -v $CURRENT_DIR/data/database:/data/database/ \
    -v $CURRENT_DIR/data/tiles:/data/tiles/ \
    -v $CURRENT_DIR/external_data:/external_data/ \
    -v $CURRENT_DIR/data/style:/data/style/ \
    -v $CURRENT_DIR/style/run.sh:/run.sh \
    --shm-size="192m" \
    overv/openstreetmap-tile-server:latest \
    import
