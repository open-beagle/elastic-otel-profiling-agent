# elastic/otel-profiling-agent

## build

```bash
# build image amd64
docker build \
  -t registry.cn-qingdao.aliyuncs.com/wod/elastic-otel-profiling-agent:build \
  --build-arg arch=amd64 \
  -f .beagle/build.Dockerfile \
  .

docker run -it --rm \
  -v $PWD/:/go/src/github.com/elastic/otel-profiling-agent \
  registry.cn-qingdao.aliyuncs.com/wod/elastic-otel-profiling-agent:build \
  make
```

## git

<https://github.com/elastic/otel-profiling-agent>

```bash
git remote add upstream git@github.com:elastic/otel-profiling-agent.git

git fetch upstream

git merge upstream/main
```

## cache

```bash
# 构建缓存-->推送缓存至服务器
docker run --rm \
  -e PLUGIN_REBUILD=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="elastic-otel-profiling-agent" \
  -e PLUGIN_MOUNT="./.git" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0

# 读取缓存-->将缓存从服务器拉取到本地
docker run --rm \
  -e PLUGIN_RESTORE=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="elastic-otel-profiling-agent" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0
```
