### 部署流程

```bash
#镜像
docker pull overv/openstreetmap-tile-server
#arm
docker pull savardfs/openstreetmap-tile-server-arm


# 导入 linux执行import.sh
.\import.cmd .\pbf\china.osm.pbf local

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


### linux import 

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

