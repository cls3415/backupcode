#!/usr/bin/env bash

# Import the helper method module.
wget -O /tmp/HDInsightUtilities-v01.sh -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/HDInsightUtilities-v01.sh && source /tmp/HDInsightUtilities-v01.sh && rm -f /tmp/HDInsightUtilities-v01.sh

# In case R is installed, exit.
if [ -e /usr/bin/R ]; then
    echo "R is already installed, exiting ..."
    exit 0
fi

# Install the latest version of R.
OS_VERSION=$(lsb_release -sr)
if [[ $OS_VERSION == 14* ]]; then
    echo "OS verion is $OS_VERSION. Using R Trusty Tahr release."
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" | tee -a /etc/apt/sources.list
else
    echo "OS verion is $OS_VERSION. Using R Precise Pangolin release."
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" | tee -a /etc/apt/sources.list
fi

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
add-apt-repository -y ppa:marutter/rdev
apt-get -y --force-yes update
apt-get -y --force-yes install r-base r-base-dev

if [ ! -e /usr/bin/R -o ! -e /usr/local/lib/R/site-library ]; then
    echo "Either /usr/bin/R or /usr/local/lib/R/site-library does not exist. Retry installing R"
    sleep 15
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
    add-apt-repository -y ppa:marutter/rdev
    apt-get -y --force-yes update
    apt-get -y --force-yes install r-base r-base-dev
fi

if [ ! -e /usr/bin/R -o ! -e /usr/local/lib/R/site-library ]; then
    echo "Either /usr/bin/R or /usr/local/lib/R/site-library does not exist after retry. Exiting..."
    exit 1
fi

# Download packages.
download_file https://hdiconfigactions.blob.core.windows.net/linuxrconfigactionv01/r-site-library.tgz /tmp/r-site-library.tgz
untar_file /tmp/r-site-library.tgz /usr/local/lib/R/site-library/

# Remove temporary files.
rm -f /tmp/r-site-library.tgz 

hadoopStreamingJar=$(find /usr/hdp/ | grep hadoop-mapreduce/hadoop-streaming-.*.jar | head -n 1)

if [ -z "$hadoopStreamingJar" ]; then
    echo "Cannot find hadoop-streaming jar file. Exiting..."
    exit 1
fi

# Add in necessary environment values.
echo "HADOOP_HOME=/usr/hdp/current/hadoop-client" | sudo tee -a /etc/environment
echo "HADOOP_CMD=/usr/bin/hadoop" | sudo tee -a /etc/environment
echo "HADOOP_STREAMING=$hadoopStreamingJar" | sudo tee -a /etc/environment
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server" | sudo tee -a /etc/environment
