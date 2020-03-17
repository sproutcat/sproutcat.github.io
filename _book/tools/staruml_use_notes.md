# StarUML 的使用笔记

## 基本使用



## 其他

* `asar` 软件包的使用

    * 安装 `asar` 软件包

        ```bash
        npm install -g asar --registry=https://registry.npm.taobao.org
        ```
    
    * 解压文件

        ```bash
        asar extract app.asar app
        ```

    * 压缩打包

        ```bash
        asar pack app app.asar
        ```

* 打开 **StartUML** 的安装目录，进入 `resources` 目录，把 `app.asar` 拷贝出来

* 用 asar 软件包解压 `app.asar` 文件

    ```bash
    asar extract app.asar app
    ```

* 解压完成后，进入 `app\src\engine` 目录，并打开 `license-manager.js` 文件

    1. 修改 `setStatus` 方法

       ```javascript
       function setStatus (licenseManager, newStat) {
         if (status !== newStat) {
           status = newStat
           licenseManager.emit('statusChanged', 'true') // status修改为'true',注意要带单引号
         }
       }
       ```

    2. 修改 `getLicenseInfo` 方法

       ```javascript
       getLicenseInfo () {
           return licenseInfo
       }
       ```

       改为

       ```javascript
       getLicenseInfo () {
         licenseInfo = {
                 name: "Reborn",
                 product: "Reborn product",
                 licenseType: "PS",
                 quantity: "Reborn Quantity",
                 timestamp: "1529049036",
                 licenseKey: "It's Cracked!!",
                 crackedAuthor: "Reborn"
               };
         return licenseInfo
       }
       ```

    3. 修改 `checkLicenseValidity`  方法

       ```javascript
       checkLicenseValidity () {
         this.valIDAte().then(() => {
           setStatus(this, true)
         }, () => {
           // 原来的代码，如果失败就会将状态设置成false
       //       setStatus(this, false)
       //       UnregisteredDialog.showDialog()
       
           //修改后的代码
           setStatus(this, true)
         })
       }
       ```

* 压缩打包 `app` 目录

    ```bash
    asar pack app app.asar
    ```

* 使用打包好的 `app.asar` 文件覆盖安装目录中的文件。

> 参考链接：https://www.52pojie.cn/forum.php?mod=viewthread&tid=796683&page=1