### 部署流程

```bash
#镜像
docker pull overv/openstreetmap-tile-server
#arm
docker pull savardfs/openstreetmap-tile-server-arm


# 导入 linux执行import.sh
.\import.cmd .\pbf\china.osm.pbf local

# 在导入的过程中，将style的内容拷贝到/data/style 下

# 运行 
docker-compose up -d

```

### 部署记录
- import导入   
  修改了import.cmd里面的style卷映射(单引号改成双引号);entrypoint入口修改(/data/style/run.sh不存在);
```cmd
 .\import.cmd .\pbf\china-latest.osm.pbf local
```

- external_data的导入   
  在前面的run.sh脚本有这些数据导入,由于style的内容是脚本从镜像里拷出来的，所以不支持本地zip数据导入，需要做以下修改
  - 将get-external-data.py覆盖到data/style/scripts下的同名文件
  - 将external-data.yml覆盖到data/style目录下的同名文件(注意file://后面部分相对路径)
  **注**：由于import导入时错误,不想重新删除在跑,直接在运行的容器里面执行了external-data.yml相关的命令，以及在这之后的命令


### entrypoint指定文件是可行的
由于在windows进行了sh文件的修改，换行符导致linux执行出现no such file ,通过如下命令解决：
```bash
sed -i 's/\r$//' ./style/run.sh
```
**注**修改了sh文件就需要执行上面语句修正


### linux下出现的问题
> 可能是因为使用的服务器docker版本的原因导致出现各种问题，通过增加security-opt配置得以解决
- linux import 

```bash
chmod +x import.sh
.\import.sh .\pbf\china.osm.pbf local
```

> 错误：  ../src/node_platform.cc:61:std::unique_ptr<long unsigned int> node::WorkerThreadsTaskRunner::DelayedTaskScheduler::Start(): Assertion `(0) == (uv_thread_create(t.get(), start_thread, this))' failed.

修复：
```sh
# 增加配置 --security-opt seccomp=unconfined
 docker run --security-opt seccomp=unconfined 。。。
```

- linux run 
> 错误 postgresql: unrecognized service  同上配置security-opt

```yml
version: '3'

services:
  map:
    image: overv/openstreetmap-tile-server
    security_opt:
      - seccomp=unconfined  # 关闭 seccomp 保护
    volumes:
      - ./data/database:/data/database/
      - ./data/tiles:/data/tiles/
      - ./data/style:/data/style/
      - ./external_data:/external_data
      - ./style/run.sh:/run.sh
    ports:
      # 若8080已被使用，请修改为其它端口
      - "8090:80"
      - "8432:5432"
    environment:
      - ALLOW_CORS=enabled
      # 瓦片服务使用的线程数默认为4，可根据实际情况增减
      #- THREADS=24
      # 瓦片服务默认使用 800M RAM cache，可根据实际情况增减
      #- OSM2PGSQL_EXTRA_ARGS="-C 4096"
      #- UPDATES=enable
    command: "run"
    
    # 如果日志中记录到 "ERROR: could not resize shared memory segment / No space left on device"
    # 意味着默认的64MB共享内存太少了，需要增加shm-size的值
    shm_size: "128M"
```

- linux tile 404
> 问题：/var/cache/renderd/tiles/default: Permission denied

```sh
# 在容器内部执行(使用外部run.sh运行的已支持)
chown renderer: /data/tiles/
```
- linux arm html打开错误
> /var/www/html/index.html 引用了在线leaflet地址
```yml
# 在docker-compose.yml添加映射
 - ./html:/var/www/html/
```
- linux arm 注记乱码
```yml
# 在docker-compose.yml添加映射
- ./fonts/unifont-Medium.ttf:/usr/share/fonts/unifont-Medium.ttf  # arm镜像字体缺失
- ./fonts/NotoSansCJK-Regular.ttc:/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc
```

### pbf文件处理
[工具](https://github.com/osmcode/osmium-tool)
[pbf下载](https://download.geofabrik.de/index.html)

已编译：osmium.7z  (配置环境变量)

- **分割**
```cmd
# 提取china ,-p geojson , -o outputfile
osmium extract -p china.geojson -o china.osm.pbf asia-latest.osm.pbf
```
- **合并**
```cmd
# 合并 
osmium merge china-latest.osm.pbf taiwan-latest.osm.pbf -o china.osm.pbf
```

### external_data下载
[simplified-water-polygons-split-3857.zip](https://osmdata.openstreetmap.de/download/simplified-water-polygons-split-3857.zip)   
[water-polygons-split-3857.zip](https://osmdata.openstreetmap.de/download/water-polygons-split-3857.zip)   
[antarctica-icesheet-polygons-3857.zip](https://osmdata.openstreetmap.de/download/antarctica-icesheet-polygons-3857.zip)    
[antarctica-icesheet-outlines-3857.zip](https://osmdata.openstreetmap.de/download/antarctica-icesheet-outlines-3857.zip)   
[ne_110m_admin_0_boundary_lines_land.zip](https://naturalearth.s3.amazonaws.com/110m_cultural/ne_110m_admin_0_boundary_lines_land.zip)   

