Maven 使用笔记
============================

* 更新 Maven 项目的版本（包含子模块）

     ```bash
     mvn versions:set -DnewVersion=1.0.0-SNAPSHOT
     ```

* 下载某个依赖包的命令为（必须在 Maven 项目根目录下运行）

  ```bash
  mvn dependency:get -Dartifact=org.springframework.boot:spring-boot:2.1.7.RELEASE:jar:sources 
  ```

