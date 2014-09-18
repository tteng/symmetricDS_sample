h1. 使用symmetricDS进行数据库同步

* *symmetricDS简介*

> symmetricDS 可以几乎同步所有已知数据库与文件，"官网":http://www.symmetricds.org/ 与 "快速上手":http://www.symmetricds.org/doc/3.6/quick-start/html-single/quick-start.html 本篇基于 v3.6.7, 另外"官方文档":http://www.symmetricds.org/docs/overview

* *配置*
 
p.  1, 将文件下载解压到本地目录 ~/Workspace/dbs

<pre>
  <code class="shell">

    tteng@u14:~/Workspace/dbs$ ls symmetric-3.6.7/ -alh
    total 200K
    drwxrwxrwx 14 tteng tteng 4.0K  9月  2 15:53 .
    drwxrwxr-x  4 tteng tteng 4.0K  9月 16 17:08 ..
    drwxrwxrwx  2 tteng tteng 4.0K  9月  2 15:53 bin
    -rw-r--r--  1 tteng tteng 100K  9月  2 15:46 change-log-3.0.txt
    drwxrwxrwx  2 tteng tteng 4.0K  9月  2 15:53 conf
    -rw-r--r--  1 tteng tteng  35K  9月  2 15:47 COPYING
    -rw-r--r--  1 tteng tteng  724  9月  2 15:47 CREDITS
    drwxr-xr-x  4 tteng tteng 4.0K  9月  2 15:46 databases
    drwxr-xr-x  4 tteng tteng 4.0K  9月  2 15:46 doc
    drwxr-xr-x  2 tteng tteng 4.0K  9月  2 15:46 engines
    drwxr-xr-x  2 tteng tteng 4.0K  9月  2 15:46 lib
    drwxr-xr-x  2 tteng tteng 4.0K  9月  2 15:46 logs
    -rw-r--r--  1 tteng tteng 3.2K  9月  2 15:47 NOTICE
    drwxr-xr-x  2 tteng tteng 4.0K  9月  2 15:46 patches
    drwxr-xr-x  2 tteng tteng 4.0K  9月  2 15:46 samples
    drwxr-xr-x  2 tteng tteng 4.0K  9月  2 15:46 security
    drwxr-xr-x  2 tteng tteng 4.0K  9月  2 15:46 tmp
    drwxr-xr-x  3 tteng tteng 4.0K  9月  2 15:46 web

  </code>
</pre>

p.  2, symmetricDS 默认没有自带oracle jdbc驱动，在开始之前需要将附件中oracle驱动(oracle 11g基于jdk1.6拷贝到lib目录) @ cp ojdbc6.jar lib/ @

p.  3, 配置根节点数据库, 根节点数据库可以直接理解为master, symmetricDs与传统的master-slave(比如mysql)区别在于，传统的master更多的倾向与写操作而slave倾向于读(读写分离),而symmetricDs的读写更加强调双向操作。symmetricDs提供了最小配置文件，可以直接拿来使用，将其直接拷贝到 engines 目录 @ cp samples/corp-000.properties engines/ @ 

p.  4, 修改corp-000.properties， 修改对应数据库驱动、用户名与密码
  
  <pre>
    <code class="java">

      engine.name=root-ora_one

      db.driver=oracle.jdbc.driver.OracleDriver

      db.url=jdbc:oracle:thin:@192.168.1.198:1521:ora_one

      db.user=ora_one

      db.password=reach8

      registration.url=  #务必留空

      sync.url=http://localhost:8080/sync/root-ora_one

      group.id=root-ora_one

      external.id=000
    </code>  
  </pre>

p.  5, 配置叶节点数据库， @ cp samples/store-001.properties engines/ @

p.  6, 修改store-001.properties, 指定对应叶节点数据库驱动、用户明与密码以及同步数据的接口

  <pre>
    <code class="java">

      engine.name=node-ora_one

      db.driver=oracle.jdbc.driver.OracleDriver

      db.url=jdbc:oracle:thin:@192.168.1.202:1521:reach

      db.user=ora_one

      db.password=reach8

      registration.url=http://localhost:8080/sync/root-ora_one  #必须与root中的sync.url一致

      group.id=node-ora_one

      external.id=001
    </code>
  </pre>

p.  7, cd samples

p.  8, @ ../bin/dbimport --engine corp-000 --alter --format XML /home/tteng/Workspace/dbs/symmetric-3.6.7/samples/create_sample.xml @ 导入表结构信息

p.  9, @ ../bin/symadmin --engine corp-000 create-sym-tables @ 创建同步所需的表  

p.  10, @ ../bin/dbimport --engine corp-000 /home/tteng/Workspace/dbs/symmetric-3.6.7/samples/insert_sample.sql @ 导入同步信息

p.  11, @ ../bin/dbimport --engine store-001 --alter --format XML /home/tteng/Workspace/dbs/symmetric-3.6.7/samples/create_sample.xml @ 导入表结构信息 @

p.  12, 启动 symmetricDS 服务, @ cd ./bin/sym --port 8080 @, symmetricDS将会在数据库中创建相应的同步信息表,无需改动。

     此时在sqldeveloper中刷新表列表就会看到相应的同步信息表已经从root同步到node中。 

p.  13, 注册节点， @ ../bin/symadmin --engine corp-000 open-registration store 001 @

p.  14, 初始加载同步数据 @ ../bin/symadmin --engine corp-000 reload-node 001 @
