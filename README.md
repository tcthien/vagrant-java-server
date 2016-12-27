Creates server development environment for java developer

## Prerequisite
* Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](https://www.vagrantup.com/downloads.html)
* Navigate to project you would like to work
```
    cd ~/myWorkingProject
    vagrant init tcthien/java-dev-server
    vagrant up
```

## Environment for Java Developer
* Download JDK directly
```
    #java8
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz

    #java7
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz
```

* mysql (starts on boot)
  * all character sets set to ```utf8``` 
  * server 
    * management (```Usage: /etc/init.d/mysql start|stop|restart|reload|force-reload|status```)
      * ```sudo service mysql stop```
      * ```sudo service mysql start```
      * ```sudo service mysql restart```
      * ```sudo service mysql reload```
      * ```sudo service mysql status```
  * client 
    * ```mysql -u root -proot```
* nginx (starts on boot)
  * serves content from ```/home/vagrant/public_html``` 
    * [http://localhost:8080](http://localhost:8080)
    * [https://localhost:4443](https://localhost:4443)
    * [http://192.168.100.100](http://192.168.100.100)
    * [https://192.168.100.100](https://192.168.100.100)
  * management (```Usage: nginx {start|stop|restart|reload|force-reload|status|configtest|rotate|upgrade}```)
    * ```sudo service nginx stop```
    * ```sudo service nginx start```
    * ```sudo service nginx reload```
    * ```sudo service nginx restart```
    * ```sudo service nginx status```
* tomcat 8 (starts on boot) 
  * http://192.168.100.100:8080 (root content)
  * http://192.168.100.100/manager (manager - configuration in nginx)
  * http://192.168.100.100:8080/manager
  * management (```Run as /etc/init.d/tomcat <start|stop|restart>```)
    * ```sudo service tomcat stop```
    * ```sudo service tomcat start```
    * ```sudo service tomcat restart```
* git
* svn
* mc
* vim
* java tools
  * mvn
  * ant
  * gradle
* environment managers
  * [jenv](https://github.com/gcuisinier/jenv.git)
  * [rbenv](https://github.com/sstephenson/rbenv.git)
  * [nodenv](https://github.com/OiNutter/nodenv.git)
  * [pyenv](https://github.com/yyuu/pyenv.git)
* port forwarding 
  * http ```8080 (host) -> 80 (guest)```
  * https ```4443 (host) -> 443 (guest)```
* enabled private network interface (guest -> ```192.168.100.100```)
* current host directory mounted in guest at ```/vagrant```

## connecting to mysql server
```
vagrant@vagrant-ubuntu-vivid-64:~$ mysql -u root -proot
```
## how to use jenv

### Configure which jvm to use

*globally*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv global 1.8
```
*locally* (means which jvm to use in the current directory)
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv local 1.7
```
*shell instance* (which jvm to use in the current shell instance)
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv shell 1.7
```

*precedence*

1. shell
2. local
3. global

### Configure jvm options

*globally*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv global-options "-Xmx512m"
```
*locally*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv local-options "-Xmx512m"
```
*shell instance*
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv shell-options "-Xmx512m"
```

*precedence*

same as for 'Configure which jvm to use'

### Configure gc logging in shell scope

To set gc logging on do
```
vagrant@vagrant-ubuntu-vivid-64:~$ gc_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -XX:+PrintGCDetails -Xloggc:gc.log
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```

To unset do
```
vagrant@vagrant-ubuntu-vivid-64:~$ gc_unset
```

### Configure debug options

To set debug options on do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jdebug_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```
To unset do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jdebug_unset
```

### Configure jrebel

To use jrebel (```jrebel.jar``` must be placed in ```/home/vagrant/bin/jrebel/```) during starting applications do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jrebel_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -javaagent:/home/vagrant/bin/jrebel/jrebel.jar -noverify
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```

### Configure jprofiler

To profile application with jprofiler (jprofiler ```agent.jar``` must to be placed in ```/home/vagrant/bin/jprofiler/bin/```) do
```
vagrant@vagrant-ubuntu-vivid-64:~$ jprofiler_set
```
and
```
vagrant@vagrant-ubuntu-vivid-64:~$ jenv info java
```
will output
```
Jenv will exec : /home/vagrant/.jenv/versions/1.8/bin/java -javaagent:/home/vagrant/bin/jprofiler/bin/agent.jar
Exported variables :
  JAVA_HOME=/home/vagrant/.jenv/versions/1.8
```

### Resources
For more information please visit [jenv](https://github.com/gcuisinier/jenv)
