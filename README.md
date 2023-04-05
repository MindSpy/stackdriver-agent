# stackdriver-agent
Google Cloud Monitoring agent docker image for managed VMs. You may want to spin up the slackdrive service in the container if you are not able to deploy the agent on OS level.

Based on https://github.com/wikiwi/stackdriver-agent.

## Running the container

Set params in ```.env```:
```
image_name=stackdriver-agent
image_ver=6.3.1
registry_repository=mindspy
gapp_cred=<path/to/credentials.json>
```

Start:
```docker compose up -d```


## Building the image
Set params ```env.hcl```:
```
registry_repository="mindspy"
image_name="stackdriver-agent"
image_ver="6.3.1"
```
and build
```
docker buildx bake -f docker-bake.hcl -f env.hcl --load
```

Which can be done with ```./bake.sh --targets=agent```.
