**Table of Contents**

- [APEX Websocket Notification Bundle](#apex-websocket-notification-bundle)
  - [Demo](#demo)
  - [Changelog](#changelog)
  - [Installation and Configuration](#installation-and-configuration)
    - [Installation Node.js Server](#installation-nodejs-server)
      - [Install Node.js](#install-nodejs)
      - [Install Notification Package](#install-notification-package)
      - [Configure Notification Package](#configure-notification-package)
    - [Installation Database](#installation-database)
      - [Database ACL](#database-acl)
      - [Oracle SSL Wallet](#oracle-ssl-wallet)
      - [Compile the PL/SQL package](#compile-the-plsql-package)
    - [Installation APEX](#installation-apex)
      - [Install Plugins](#install-plugins)
  - [Usage](#usage)

  - [License](#license)


# APEX Websocket Notification Bundle

Purpose of this software bundle was to enable all APEX developers to use modern and state of the art web features like Node, Websockets and nice looking notifications in their applications.

This bundle includes all these features and simultaneously is designed to use all of them out of the box. This means:

- Ready to go Node.js websocket server especially for notifications using socket.io
- A native PL/SQL package to send all kinds of different messages/notifications using APEX_WEB_SERVICE
- APEX plugins for all kind of events that are needed by the notification system:
  - Initialize websocket connection to server
  - Send messages and notifications to users
  - Show different styled notifications on client side

Developers don´t need to be experts in Javascript or JQuery and stuff like that (But as always, it´s not a bad skill!;) ). APEX Know-How and a good knowledge of using Dynamic Actions should be enough to implement this notification bundle in your applications...


## Demo

A demo application is available under
https://apex.danielh.de/ords/f?p=WSNOTIFY

And of course you find a APEX export (demo_app.sql) of it in [../apex/](https://github.com/Dani3lSun/apex-websocket-notify-bundle/tree/master/apex) folder. To use it just import the app and then go through the installation steps below.
Under Shared Components --> Edit Application Definition --> Substitutions Strings, set "G_WS_SERVER_HOST" to the hostname or ip address and "G_WS_SERVER_PORT" to the port of your node notification server.


## Changelog

#### 1.0 - Initial Release


## Installation and Configuration

### Installation Node.js Server

#### Install Node.js

It is required to have a up and running Node.js installation on your server.
Either install it using a package manager, or download the latest version from [Nodejs homepage](https://nodejs.org)...for example:
- Ubuntu:
```
apt-get install nodejs
apt-get install npm
```

- Mac OS X (Homebrew):
```
brew install nodejs
```

- Windows:
Download and install it from [Nodejs homepage](https://nodejs.org)

npm is the package manager for Node applications. npm is used to install all required packages by the Node Websocket Notification Server...

#### Install Notification Package

- Copy the complete folder [../node/node-notify-server](https://github.com/Dani3lSun/https://github.com/Dani3lSun/apex-websocket-notify-bundle/tree/master/node/node-notify-server) to your server
- change to this directory via command line:
```
cd /path/to/node-notify-server
```
- Install all dependencies
```
npm install
```
- Start server
```
npm start
```

This should be everything to have the Notification Server up und running. To check that, you can point your web browser to http://[host-ip-of-server]:8080

There you should get a overview of all supported services by the Notification Server.

This helper pages are supported by the server:

- Overview Services: http://[host-ip-of-server]:8080
- Server Status Page: http://[host-ip-of-server]:8080/status
- Websocket Test Client: http://[host-ip-of-server]:8080/testclient

#### Configure Notification Package

You can change the default behavior of the server by editing the JSON config file [../node/node-notify-server/prefs.json](https://github.com/Dani3lSun/apex-websocket-notify-bundle/blob/master/node/node-notify-server/prefs.json)

```
{
    "server": {
        "ip": "0.0.0.0", // listener ip address 0.0.0.0 for all interfaces
        "port": "8080", // listener port
        "authUser": "", // User for HTTP basic auth, empty means no user auth (only REST-Interface)
        "authPwd": "", // Password for HTTP basic auth, empty means no user auth (only REST-Interface)
        "sslKeyPath": "", // FOR SSL: path to ssl key file (./certs/key.pem), empty means no SSL/HTTPS
        "sslCertPath": "", // FOR SSL: path to ssl certificate file (./certs/cert.pem), empty means no SSL/HTTPS
        "logging": true // logging to console on or off, for prod disable logging
    },
    "socket": {
        "private": true, // activate private websocket room/namespace of server
        "public": true // activate public websocket room/namespace of server
    }
}
```

After changing one of these settings, please restart the Node Notification Server.

SSL Support:
- For test environments you can use the script [../node/node-notify-server/certs/create_cert.sh](https://github.com/Dani3lSun/apex-websocket-notify-bundle/blob/master/node/node-notify-server/certs/create_cert.sh) to create a self signed certificate
- For production environments please get a officially signed certificate and place key.pem and cert.pem into the certs folder


### Installation Database

#### Database ACL
All notifications are sent through web service requests. Therefore a ACL is needed, so you are allowed to connect to this host. Here is a example script, configure it to reflect your environment...

```language-sql
DECLARE
  --
  l_filename    VARCHAR2(30) := 'ws-notify-host.xml';
  l_host_or_ip  VARCHAR2(50) := '<YOUR-NODE-WEBSOCKET-HOST>'
  l_port        NUMBER       := 8080;
  l_schema      VARCHAR2(20) := '<SCHEMA>';
  --
BEGIN
  --
  BEGIN
    dbms_network_acl_admin.drop_acl(acl => l_filename);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  --
  dbms_network_acl_admin.create_acl(acl         => l_filename,
                                    description => 'All requests to Node Websocket Server',
                                    principal   => l_schema,
                                    is_grant    => TRUE,
                                    privilege   => 'connect');
  --
  dbms_network_acl_admin.add_privilege(acl       => l_filename,
                                       principal => l_schema,
                                       is_grant  => TRUE,
                                       privilege => 'resolve');
  --
  dbms_network_acl_admin.assign_acl(acl        => l_filename,
                                    host       => l_host_or_ip,
                                    lower_port => l_port);
END;
/
```

#### Oracle SSL Wallet
If you configured the Node Notification Server with SSL/HTTPS support, a Oracle SSL Wallet is needed by the database to communicate with the REST-Interface for sending notifications.

To manually create a wallet, either use Oracle Wallet Manager or create the wallet with openssl utils like:
- Grab the certificate from your server [node-notify-server/certs](https://github.com/Dani3lSun/apex-websocket-notify-bundle/tree/master/node/node-notify-server/certs)
- Create the wallet on command line

```shell
openssl pkcs12 -export -in cert.pem -out ewallet.p12 -nokeys
```

- Place the wallet file on your database server
- Change the wallet path and password in the [package specification](https://github.com/Dani3lSun/apex-websocket-notify-bundle/blob/master/plsql/ws_notify_api.pks) under "Websocket REST Call defaults / security defaults"


#### Compile the PL/SQL package
Connect to your database and compile the package spec and body (ws_notify_api.pks & ws_notify_api.pkb) from [../plsql](https://github.com/Dani3lSun/apex-websocket-notify-bundle/tree/master/plsql)


### Installation APEX

#### Install Plugins






## Usage


## License
This software is under **MIT License**.

---
