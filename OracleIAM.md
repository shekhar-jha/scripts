
# Development

## Build

### Maven

This section captures snippets that can be used for maven build for various OIM specific components

#### Scheduled Task

```
<project ...>
  ...
  <build>
    ...
    <plugins>
      ...
      <plugin>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>3.1.0</version>
        <configuration>
          <descriptors>
            <descriptor>src/assembly/scriptedScheduledJob.xml</descriptor>
          </descriptors>
          <appendAssemblyId>false</appendAssemblyId>
          <archiverConfig>
            <compress>false</compress>
          </archiverConfig>
        </configuration>
        <executions>
          <execution>
            <id>make-scheduledTask</id>
            <phase>package</phase>
            <goals><goal>single</goal></goals>
          </execution>
        </executions>
      </plugin>
      ...
    </plugins>
    ...
  ...
</project
```

__Note:__

1. src/assembly/scriptedScheduledJob.xml - contains the structure of zip file to create (assembly descriptor)
   ```
   <assembly xmlns="http://maven.apache.org/ASSEMBLY/2.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/ASSEMBLY/2.0.0 http://maven.apache.org/xsd/assembly-2.0.0.xsd">
    <id>TestOIMScheduledTask</id>
    <formats><format>zip</format></formats>
    <includeBaseDirectory>false</includeBaseDirectory>
    <files>
        <file>
            <source>src/main/resources/oim-plugin/TestOIMScheduledTask-plugin.xml</source>
            <destName>plugin.xml</destName>
        </file>
        <file>
            <outputDirectory>META-INF</outputDirectory>
            <source>src/main/resources/oim-scheduledTaskDefinition/TestOIMScheduledTask-metadata.xml</source>
            <destName>TestOIMScheduledTask.xml</destName>
        </file>
    </files>
    <dependencySets>
        <dependencySet>
            <outputDirectory>lib</outputDirectory>
            <useProjectArtifact>true</useProjectArtifact>
            <excludes>
                <exclude>com.oracle.oim:oimclient</exclude>
            </excludes>
        </dependencySet>
    </dependencySets>
   </assembly>
   ```
   1. id - Identifies zip file which is added to name of zip file
   2. includeBaseDirectory - ensures that base directory under which the zip file content is layed out is not included in file.
   3. source, outputDirectory and destName - specifies what file to pick to create zip, which directory should it be copied to and what is new name of file.
   4. useProjectArtifact - ensures that generated jar file is copied to zip folder
   5. exclude - excludes any dependency not needed.
2. appendAssemblyId - does not add the name of assembly id to name of zip created
3. finalName - can be specified to generate zip file with new name
4. compress - This is required since OIM does not support compressed zip files.

# Installation

## Download Installers

```

# Ensure that cookie.txt has been created by exporting using an Addon after login to following websites
# http://www.oracle.com/technetwork/middleware/webtier/downloads/index-jsp-156711.html
# http://www.oracle.com/technetwork/middleware/id-mgmt/downloads/oid-11gr2-2104316.html
# http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html
# http://www.oracle.com/technetwork/java/javase/downloads/index.html
# http://support.oracle.com

## JDK 1.8
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.tar.gz" -O jdk-8u172-linux-x64.tar.gz

### Database Oracle 12.2.0.1
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/linux/oracle12c/122010/linuxx64_12201_database.zip" -O linuxx64_12201_database.zip

# OHS including weblogic proxy plugin & webgate
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/linux/middleware/12c/12213/fmw_12.2.1.3.0_ohs_linux64_Disk1_1of1.zip?AuthParam=1527782833_7f86917bcab8304203dd6c9c5e49ab57" -O fmw_12.2.1.3.0_ohs_linux64_Disk1_1of1.zip

# OIAM 
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_idmqs_Disk1_1of2.zip" -O fmw_12.2.1.3.0_idmqs_Disk1_1of2.zip
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_idmqs_Disk1_2of2.zip" -O fmw_12.2.1.3.0_idmqs_Disk1_2of2.zip
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_infrastructure_Disk1_1of1.zip" -O fmw_12.2.1.3.0_infrastructure_Disk1_1of1.zip
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_idm_Disk1_1of1.zip" -O fmw_12.2.1.3.0_idm_Disk1_1of1.zip

# SOA
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_soaqs_Disk1_1of2.zip" -O fmw_12.2.1.3.0_soaqs_Disk1_1of2.zip
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_soaqs_Disk1_2of2.zip" -O fmw_12.2.1.3.0_soaqs_Disk1_2of2.zip

# OUD
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_oud_Disk1_1of1.zip" -O fmw_12.2.1.3.0_oud_Disk1_1of1.zip

# OAM Webgate Patch (12.2.1.3.180414)
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27863709_122130_Linux-x86-64.zip?aru=22113013&patch_file=p27863709_122130_Linux-x86-64.zip" -O p27863709_122130_Linux-x86-64.zip

# OIAM Patch (IDM SUITE BUNDLE PATCH 12.2.1.3.180417)
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27704994_122130_Generic.zip?aru=22039066&patch_file=p27704994_122130_Generic.zip" -O p27704994_122130_Generic.zip

# WLS PATCH SET UPDATE 12.2.1.3.180417
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27342434_122130_Generic.zip?aru=21933966&patch_file=p27342434_122130_Generic.zip" -O p27342434_122130_Generic.zip

# OPatch patch of version 12.2.0.1.13 for Oracle software releases DB 12.2.0.x and DB 18.x (APR 2018) (Patch)
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p6880880_122010_Linux-x86-64.zip?aru=22116395&patch_file=p6880880_122010_Linux-x86-64.zip" -O p6880880_122010_Linux-x86-64.zip

# Oracle Database COMBO OF OJVM RU COMPONENT 12.2.0.1.180417 + DBRU 12.2.0.1.180417
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27726453_122010_Linux-x86-64.zip?aru=22117468&patch_file=p27726453_122010_Linux-x86-64.zip" -O p27726453_122010_Linux-x86-64.zip

# OHS (NATIVE) BUNDLE PATCH 12.2.1.3.171117 (Patch)
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27149535_122130_Linux-x86-64.zip?aru=21774425&patch_file=p27149535_122130_Linux-x86-64.zip" -O p27149535_122130_Linux-x86-64.zip

# SOA Bundle Patch 12.2.1.3.0(ID:180207.0210.0010) 
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27507607_122130_Generic.zip?aru=21933687&patch_file=p27507607_122130_Generic.zip" -O p27507607_122130_Generic.zip
```
