set cur_dir=%~dp0
docker run --rm -v %cur_dir:0,-1%:/openstreetmap alpine tar cvf /openstreetmap/docker-compose.yaml /openstreetmap/data