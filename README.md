# stackdriver-agent
Google Cloud Monitoring agent docker image for managed VMs. You may want to spin up the slackdrive service in the container if you are not able to deploy the agent on OS level.


Set params:
```
uid=
gid=
user=

image_name=stackdriver-agent
image_ver=6.3.1

registry_repository=

tmp_dir=
gapp_cred=
```

Build:
```docker compose build```

Start:
```docker compose up -d```
