#!/bin/bash

VAGRANT_DIR=/vagrant
HOME_DIR=~/
HOME_SERVERS_DIR=~/servers
HOME_PUBLIC_HTML_DIR=~/public_html

appendToBashrc()
{
    echo ${1} >> ~/java-env
}

installPackage()
{
  local packages=$*
  echo "Installing $packages"
  sudo apt-get install -y $packages >/dev/null 2>&1
  #sudo apt-get install -y $packages
}

indent() 
{
  echo -n '    '
}

downloadWithProgress()
{
  local url=$2
  local file=$1
  echo -n "Downloading $file:"
  echo -n "    "
  wget --progress=dot $url 2>&1 | grep --line-buffered "%" | sed -u -e 's/\.//g' | awk '{printf("\b\b\b\b%4s", $2)}'
  echo -ne "\b\b\b\b"
  echo " DONE"
}

download()
{
  local url=$2
  local file=$1
  echo "Downloading $file"
  wget --progress=dot $url >/dev/null 2>&1
  #wget $3 $url
}

installMysql() 
{
  #setting non-interactive mode
  echo mysql-server mysql-server/root_password password root | sudo debconf-set-selections
  echo mysql-server mysql-server/root_password_again password root | sudo debconf-set-selections
  indent; installPackage mysql-server
  indent; indent; echo 'Creating /etc/mysql/conf.d/utf8_charset.cnf'
  sudo cp $VAGRANT_DIR/mysql/utf8_charset.cnf /etc/mysql/conf.d/utf8_charset.cnf
  indent; indent; echo 'Restarting mysql'
  #sudo service mysql restart >/dev/null 2>&1
  sudo service mysql restart
}

installPackages()
{
    echo "Installing packages"
    indent; echo 'apt-get update'
    sudo apt-get update >/dev/null 2>&1
    indent; installPackage vim
    indent; installPackage git
    indent; installPackage mc
    indent; installPackage apg
    indent; installPackage curl
    indent; installPackage wget
    installMysql
    #install zsh & oh-my-zsh
    installOhMyZsh
}

createDirs()
{
    echo 'Creating directories'
    indent; echo 'Creating vagrant dir'
    mkdir $VAGRANT_DIR
    indent; echo 'Creating bin directory'
    mkdir ~/bin
    indent; echo 'Creating public_html directory'
    mkdir $HOME_PUBLIC_HTML_DIR
    chmod o+xr $HOME_PUBLIC_HTML_DIR
    mkdir $HOME_SERVERS_DIR
    indent; echo 'Creating servers directory'
    mkdir -p ~/.m2
    
    echo 'Creating common shell config'
    echo "" > ~/java-env
}

downloadJdks()
{
  cd ~/bin
  echo "Downloading jdks"
  
  #jdk8
  jdk="jdk-8u112-linux-x64.tar.gz"
  if [ ! -e $jdk ] 
  then
    indent; echo "There is no $jdk"
    indent; indent; wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/$jdk >/dev/null 2>&1
    if [ ! -e $jdk ] 
    then
        indent; indent; echo "Failed to download $jdk"
    else
        indent; indent; echo "Download successfully $jdk"
    fi
  else
    indent; echo "$jdk is available"
  fi
  
  
  #jdk7
  jdk="jdk-7u79-linux-x64.tar.gz"
  if [ ! -e $jdk ] 
  then
    indent; echo "There is no $jdk"
    indent; indent; wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/$jdk >/dev/null 2>&1
    if [ ! -e $jdk ] 
    then
        indent; indent; echo "Failed to download $jdk"
    else
        indent; indent; echo "Download successfully $jdk"
    fi
  else
    indent; echo "$jdk is available"
  fi
}

installJdks()
{
  cd ~/bin
  echo 'Installing jdks'
  for file in `ls jdk*.tar.gz`
  do 
    indent; echo "Extracting $file"
    tar xvzf ./$file >/dev/null 2>&1
    file $file
    #tar xvzf $file
  done
  indent; echo 'Cleaning jdks'
  rm jdk*.tar.gz
  ls
}

installEnvManagers()
{
  echo 'Installing environment managers (for Java) '
  indent; echo 'Installing jenv'
  indent; indent; echo 'Clonning from github to ~/.jenv'
  git clone https://github.com/gcuisinier/jenv.git ~/.jenv >/dev/null 2>&1
  #git clone https://github.com/gcuisinier/jenv.git ~/.jenv
  indent; indent; echo "Setting environment variables"
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
  indent; indent; echo 'Make build tools jenv aware'
  message=`jenv enable-plugin ant`
  indent; indent; indent; echo $message
  message=`jenv enable-plugin maven`
  indent; indent; indent; echo $message
  message=`jenv enable-plugin gradle`
  indent; indent; indent; echo $message
  message=`jenv enable-plugin sbt`
  indent; indent; indent; echo $message
}

updateBashrc()
{

    #Start of template
    appendToBashrc 'export PATH="~/.jenv/bin:~/bin/apache-maven/bin:~/bin/gradle/bin:~/bin/sbt/bin:~/bin/apache-ant/bin:$PATH"'
    appendToBashrc 'eval "$(jenv init -)"'

    export PATH="~/.jenv/bin:~/bin/apache-maven/bin:~/bin/gradle/bin:~/bin/sbt/bin:~/bin/apache-ant/bin:$PATH"
    eval "$(jenv init -)"
}


installRuntimes()
{
    cd ~/bin
    echo 'Install runtimes using environment managers'
    indent; echo 'Install java'
    #for jdk in `ls ~/bin/ | grep jdk`; do jenv add ~/bin/$jdk >/dev/null 2>&1; done
    for jdk in `ls ~/bin/ | grep jdk`; do jenv add ~/bin/$jdk; done
    indent; echo 'Set jdk 1.8 globally'
    jenv global 1.8
}


installingApp()
{
  local tool_name=$1
  local file=$2
  local url=$3
  local link_src=$4
  local link_target=$5
  echo "Installing $tool_name"
  indent; download $file $url
  indent; echo -n "Extracting $file"
  if [[ "$file" =~ .*tar.gz$ || "$file" =~ .*tgz$ ]]
  then 
    echo " using tar"
    tar xvzf $file >/dev/null 2>&1
    #tar xvzf $file 
  else
    if [[ "$file" =~ .*zip$ ]]
    then
      echo " using unzip"
      unzip $file >/dev/null 2>&1
      #unzip $file 
    else
      echo
      indent; indent; echo "Can't extract $file. Unknown ext"
    fi
  fi
  indent; echo 'Cleaning'
  rm $file
  indent; echo "Creating symbolic link $link_target"
  ln -s $link_src $link_target
}

installingMvn()
{
  installingApp 'apache-maven' \
    apache-maven-3.3.9-bin.tar.gz \
    http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
    'apache-maven*' \
    apache-maven
}

installingAnt()
{
  installingApp 'apache-ant' \
    apache-ant-1.9.7-bin.tar.gz \
    http://www.eu.apache.org/dist/ant/binaries/apache-ant-1.9.7-bin.tar.gz \
    'apache-ant*' \
    apache-ant
}

installingGradle()
{
  installingApp 'gradle' \
    gradle-2.8-bin.zip \
    https://services.gradle.org/distributions/gradle-2.8-bin.zip \
    'gradle-*' \
    gradle
}

installingSbt()
{
  installingApp 'sbt' \
    sbt-0.13.9.tgz \
    https://dl.bintray.com/sbt/native-packages/sbt/0.13.9/sbt-0.13.9.tgz \
    'sbt' \
    sbt
}

installingTools() 
{
  cd ~/bin
  installingMvn
  installingAnt
  installingGradle
  installingSbt
}

installingTomcat()
{
  installingApp 'apache-tomcat' \
    apache-tomcat-8.0.28.tar.gz \
    http://ftp.piotrkosoft.net/pub/mirrors/ftp.apache.org/tomcat/tomcat-8/v8.0.39/bin/apache-tomcat-8.0.39.tar.gz \
    'apache-tomcat*' \
    apache-tomcat

  indent; echo 'Creating apache-tomcat /bin/setenv.sh'
  echo 'JAVA_HOME=`jenv javahome`' > apache-tomcat/bin/setenv.sh
  chmod +x apache-tomcat/bin/setenv.sh
  indent; echo 'Copying tomcat-users.xml to apache-tomcat/conf'
  cp $VAGRANT_DIR/tomcat/tomcat-users.xml apache-tomcat/conf
  indent; echo 'Creating /etc/init.d/tomcat script'
  sudo cp $VAGRANT_DIR/tomcat/tomcat /etc/init.d/
  sudo chmod 755 /etc/init.d/tomcat
  sudo update-rc.d tomcat defaults
  sudo update-rc.d tomcat enable
  indent; echo 'Starting tomcat'
  sudo service tomcat start
}

installingServers()
{
  cd $HOME_SERVERS_DIR
  #installingTomcat
}

installNodeJsYeoman()
{
    cd ~/bin
    nodejs="node-v7.3.0-linux-x64.tar.gz"
    nodejsdir="node-v7.3.0-linux-x64"
    #download nodejs
    if [ ! -e $nodejs ] 
        then
            indent; echo "There is no $nodejs"
            indent; indent; download "$nodejs" "https://nodejs.org/dist/v7.3.0/$nodejs"
        else
            indent; echo "$nodejs is available"
    fi
    #install nodejs
    indent; echo "Extracting $file"
    tar xvzf $nodejs >/dev/null 2>&1
    indent; echo 'Cleaning $nodejs'
    rm $nodejs
    
    appendToBashrc 'export PATH="~/bin/node-v7.3.0-linux-x64/lib/node_modules/:~/bin/node-v7.3.0-linux-x64/bin/:$PATH"'
    export PATH="~/bin/node-v7.3.0-linux-x64/lib/node_modules/:~/bin/node-v7.3.0-linux-x64/bin/:$PATH"
    indent; echo $PATH
    
    #install yeoman
    indent; echo 'Installing yeoman'
    npm install -g yo
}

installCommonShellScript()
{
    mkdir ~/scripts
    cd ~/scripts
    git clone https://github.com/tcthien/common-shell-scripts >/dev/null 2>&1
    appendToBashrc 'export PATH="~/scripts/common-shell-scripts/:$PATH"'
    sudo chmod +x ~/scripts/common-shell-scripts/common
    appendToBashrc 'source ~/scripts/common-shell-scripts/common'
}

installDocker()
{
    #install docker
    mkdir ~/tmp
    mkdir ~/tmp/tts-configcenter
    curl -L https://get.docker.com/ > ~/tmp/tts-configcenter/installDocker.sh
    sudo sh ~/tmp/tts-configcenter/installDocker.sh
    #install docker compose
    sudo chmod 777 /usr/local/bin
    sudo curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

installCassandra()
{
    # Update chmod in /bin/
    sudo chmod 777 ~/bin/
    echo "Installing Cassandra"
    cd /vagrant
    local cassandra="apache-cassandra-3.9-bin.tar.gz"
    local cassandraFolder="apache-cassandra-3.9"
    # Check & install cassandra ---------------------------------------------------------
    if [ ! -e $cassandra ] 
    then
        indent; echo "Prepare to download $cassandra"
        download $cassandra http://supergsego.com/apache/cassandra/3.9/$cassandra
        file $cassandra
    else
        indent; echo "Nothing new to download"
    fi
    # Copy cassandra to ~/bin
    cp -v $cassandra ~/bin/
    # Extract & add cassandra to PATH
    cd ~/bin/
    indent; echo "Extracting ~/bin/$cassandra"
    tar xvzf ./$cassandra >/dev/null 2>&1
    rm -rf $cassandra
    sudo chmod 777 ~/bin/$cassandraFolder
        
        # Add Cassandra home to bashrc ------------------------------------------------------
    appendToBashrc ''
    appendToBashrc '#Add Cassandra Home'
    appendToBashrc 'export CASSANDRA_HOME=~/bin/apache-cassandra-3.9/'
    appendToBashrc 'export PATH="${CASSANDRA_HOME}/bin/:$PATH"'
}

installOhMyZsh()
{
    echo "Installing zsh & OhMyZsh"
    indent; installPackage zsh
    indent; sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
}

updateConfiguration()
{
    #Update mysql config
    yes | sudo cp -v ~/scripts/common-shell-scripts/app-conf/my.cnf /etc/mysql/
    #Update mysql config
    yes | cp -v ~/scripts/common-shell-scripts/app-conf/cassandra.yaml ~/bin/apache-cassandra-3.9/conf
    #Update maven setting
    yes | cp -v ~/scripts/common-shell-scripts/app-conf/settings.xml ~/.m2
}

run() {
    createDirs
    
    #Install some common package & oh-my-zsh
    installPackages
    
    #Include vagrant-java-server env variable to shell bash
    echo '. ~/java-env' >> ~/.bashrc
    echo '. ~/java-env' >> ~/.zshrc
    
    downloadJdks
    installJdks
    installingTools
    installEnvManagers
    updateBashrc
    installRuntimes
    installingServers

    #install nodejs, yeoman
    installNodeJsYeoman

    #install common-shell-script
    installCommonShellScript
    
    #install docker
    installDocker
    
    #install cassandra
    installCassandra
    
    
    
    #Update configuration
    updateConfiguration
}


if [ ! -f "/var/vagrant_provision" ]; then
  sudo touch /var/vagrant_provision
  run
else
  echo "Nothing to do"
fi
