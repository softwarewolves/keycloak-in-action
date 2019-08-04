This repo offers a very thin layer over a vanilla Keycloak Docker image to demonstrate interacting with a brokered identity provider.

# Prerequisites

* Unix or Unix-like shell to execute commands. The shell should make the usual Unix utilities available. The following are used in this project:
  * `make`
  * `git`
  * `sed`
  * `pwd`
* `docker` installed and running
* `npm` installed

# Usage

```
git clone git@github.com:softwarewolves/keycloak-in-action.git
cd keycloak-in-action
make run
```

The last command brings up both a Keycloak docker container and an Angular development server. This takes a long time as a new Docker image is built each time - this can be avoided on subsequent runs by removing the build dependency of the `run` make target. Unfortunately, the first time `make run` is executed, this inevitably takes a long time as the Docker image needs to be downloaded and all the Angular application's dependencies installed.

The shell in which `make run` executes remains attached to both the Keycloak and the Angular dev server's stdout and stdin, so you see them starting up and throwing exceptions if something goes wrong. The servers can be stopped by sending an interrupt signal (Ctrl + C in the shell).

When the Keycloak server has started up, its UI is available at `https://localhost:8443`. You can log into the management console with `admin:admin` if you click through the warning about an invalid certificate - in this demo configuration, each Keycloak container generates a new key pair and a self-signed certificate.

The Angular app is based on a sample application in IdentityModel's (oidc-client-js library)[https://github.com/IdentityModel/oidc-client-js]. When it has started up, it is available at `http://localhost:4200`. This client has been registered in Keycloak with the identifier `spa`. The Angular client starts an OIDC authorization code flow with the running Keycloak instance as the authorization server when the `login` button is pressed. This will fail, unless you previously accepted the invalid Keycloak certificate, see above, as the authorization request cannot be sent.

Keycloak has been configured to act as a broker for an Identity Provider. For this to work, the following environment variables need to be set in a .env file in the root directory of the project:
* `USER_INFO_URL`
* `CLIENT_ID`
* `CLIENT_SECRET`
* `TOKEN_URL`
* `JWKS_URL`
* `ISSUER`
* `AUTHORIZATION_URL`

The `Makefile` expands these variables into `realm.json` to produce `realm.js.o`. The latter file is mounted into the Docker container and imported as a realm configuration. A Keycloak realm manages a set of applications and users. A user belongs to and logs into a realm. Realms are isolated from one another and can only manage and authenticate the users that they control via an application registered in the realm. A realm can also delegate user authentication to an identity provider.

# Further disclaimers

Vanilla Keycloak comes with a single realm, Master. This is dedicated to users with administrative privileges. So an additional realm for end-users has been created which is imported by the command line executed by the `run` make target. In a production scenario, a realm would obviously be stored persistently in a database.

The Dockerfile does not really do anything currently - it merely specifies the version of a Keycloak Docker base image. This could have been done on the command line as well. Consider it a placeholder for further layers.
