Creates server development environment for java developer

## Prerequisite
* Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](https://www.vagrantup.com/downloads.html)
* Navigate to project you would like to work
```
    cd ~/yourWorkingProject
    vagrant init tcthien/java-dev-server
    vagrant up
```

## Using this vagrant effectively
* Mapping your source folder & maven repository folder from host to guest 
```
    cd ~/yourWorkingProject
    vim Vagrantfile
    # Copy following to your vagrant file --------------------------------
    # 
    Vagrant.configure("2") do |config|
      config.vm.box = "tcthien/java-dev-server"

      config.vm.synced_folder "C:/Users/admin/.m2/repository", "/share/mavenRepo"
      config.vm.synced_folder "", "/share/source"
      
      # MySQL Port
      config.vm.network "forwarded_port", guest: 3306, host: 3306
      # Cassandra Port
      config.vm.network "forwarded_port", guest: 9042, host: 9042
      config.vm.network "forwarded_port", guest: 7000, host: 7000
      config.vm.network "forwarded_port", guest: 7001, host: 7001
      config.vm.network "forwarded_port", guest: 9160, host: 9160
      
      config.vm.provider "virtualbox" do |vb|
         vb.memory = "4096"
         vb.name = "codelab-server"
      end
    end
    # End file -----------------------------------------------------------
    
```
* Create ```settings.xml``` in ```~/.m2``` and update your maven repository points to ```/share/mavenRepo```
* Access to your source file in
```
    cd /share/source
```

## Environment for Java Developer
* Download JDK directly
```
    #java8
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz

    #java7
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz
```

* Cassandra 3.9
  * Cassandra located under ~/bin/
  * Execute following to start Cassandra server ````    cassandra -f ````
  * Create user
```
cqlsh localhost -u cassandra -p cassandra
create user root with password 'root' superuser;

CREATE KEYSPACE keyspaceName WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3};
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
  * Enable remote access on root:
```
sudo vi /etc/mysql/my.cnf

#comment out line: bind-address = 127.0.0.1 as following:
#bind-address = 127.0.0.1

sudo service mysql restart

mysql –u root -p
GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
```
* git
* svn
* mc
* vim
* nodejs
  * npm
  * yo
* java tools
  * mvn
  * ant
  * gradle
* environment managers
  * [jenv](https://github.com/gcuisinier/jenv.git)
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
Thanks a lot [ssledz](https://github.com/ssledz/vagrant-boxes/tree/master/java-dev-environment) for valuable initial version
For more information please visit [jenv](https://github.com/gcuisinier/jenv)
