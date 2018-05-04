# ActiveEON Proactive Server

Docker image with trial version of ActiveEon Proactive Server v8.0.0

---
### Prerequisites
This project is dependent on the following librariess and programs.

	- ActiveEON Proactive Server:
		- docker
		- make
	- Tests:
		- curl

---
### License
My code (Dockerfile, Makefile, src, tests) is licensed under [MIT license](./LICENSE).

Docker is licensed under various licenses as stated [here](https://www.docker.com/components-licenses).

Ubuntu [License](https://www.ubuntu.com/licensing)

Proactive Server license needs to be obtained from ActiveEon.
This code is using Proactive Server 8.0.0 Enterprise Trial Edition. All rights reserved. Copyright (C) 1997-2018 INRIA/University of Nice-Sophia Antipolis/ActiveEon

---
### Dockerfile
Docker image uses Ubuntu 16.04 Xenial minimal server as base.
OpenSDK 8 Java is installed on top of it.
ActiveEon Proactive Server 8.0.0 Enterprise Trial Edition is downloaded from secured AWS S3 bucket and installed to `/opt/activeeon_proactive_server/` directory. 
AWS S3 bucket is IP restricted. [Contact us](mailto:engineering@noledgetech.com) with your IP and we'll open it for you (you can get your IP from various lovcations, e.g. [http://ip-api.com](http://ip-api.com/line/?fields=query)
Installation contains **empty** server configuration (`./config`) and  workflows (`./data/defaultuser`) directories, which are mounted as volumes at runtime, hence all config and workflows are saved to persistent storage. These 2 directores are part of this repository, however `config` is the default one, while `defaultuser` contains 2 demo projects.

##### TODO - check if any other directories needs to be persisted and update code accordingly

---
### Makefile
Even though `make` is an ancient technology, it is very handy to simplify/automate a lot of work. the following targetts have been created to ease your life:

#### `make help`
Shows all available targets

#### `make build`
Builds container image with the following default name and tag:
```bash
DOCKER_NAME=activeeon_proactive_server
DOCKER_VER=0.0.1
```
`DOCKER_NAME` represents (surprise, surprise) docker name.
`DOCKER_VER` is current version of docker image. Useful for deployment control and rollbacks.
If you have `.env` file present in current directory and it contains the above mentioned variables, they are automatically overwritten with `.env` values.


#### `make start`
- starts `activeeon_proactive_server`:`0.0.1` container
- maps port `8080` to host network
- attaches `config` volume
- attaches `defaultuser` volume
- starts ActiveEON Proactive Server inside container
Please allow couple seconds for server to get ready.
You can check logs with `make logs` command
##### TODO - update entrypoint script to wait for server to start up for certain amount of time and `exit 1` if it's not started 

#### `make logs`
Show and follows infinitely container logs
You need to Ctrl-C (Windows and Linux) or Cmd+C (MacOS) to stop this command

#### `make test`
Run tests. Currently testing only the following endpoints:
- `scheduling-api`: http://localhost:8080/scheduling-api
- `studio`: http://localhost:8080/studio
- `catalog`: http://localhost:8080/catalog
- `rm`: http://localhost:8080/rm
- `automation-dashboard`: http://localhost:8080/automation-dashboard
- `rest`: http://localhost:8080/rest
- `scheduler`: http://localhost:8080/scheduler
The follwing tests are disabled due to the fact that below mentioned endpoints are not active at start time or are active periodically
- `connector-iaas`: http://localhost:8080/connector-iaas
- `proactive-cloud-watch`: http://localhost:8080/proactive-cloud-watch
- `job-planner`: http://localhost:8080/job-planner
- `cloud-automation-service`: http://localhost:8080/cloud-automation-service
- `notification-service"`: http://localhost:8080/notification-service"
##### TODO - investigate when these endpoints are active and update tests accordingly

#### `make stop`
Stops running `activeeon_proactive_server`:`0.0.1` container.
If it stops fine it removes it from docker so it does not conflict with next run.
Any nonpersistent changes are lost at this time.

#### `make deploy`
Tags container with `activeeon_proactive_server`:`0.0.1` and deploys image to container registry
`Makefile` contains the following hardcoded settings, which need to be adjusted with your environment settings:
```bash
DCR_HOST=localhost
DCR_PORT=5000
```

#### `make bash`
Logins/ssh to running `activeeon_proactive_server`:`0.0.1` container with root account in case any internal toubleshooting is needed.
It should not be used after deployment to live environment. Only for development assistance.

---
### Security
This repository contains all default security credentials, databases, keystores and connections.
For real life deployments you need to convert them into variables using whatever security means you want and make sure they are sufficiently secured. We recommend to use Vault by HashiCorp, but it's only our personal preference. It will require you to write custom scripts to retrieve secrets from Vault and put them in configuration before starting server.
We also recommend to separate any databases used by this server and secure them according to your security policy.
For external communication it is advised to encryt all traffic using HTTPS.
You can configure LDAP/Active Directory authentication/authorisation.
For support please contact us at security@noledgetech.com