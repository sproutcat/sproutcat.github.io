Antlr 使用笔记
=================================

一、参考文章
---------------------------------

* [ANTLR 4进阶](http://liangshuang.name/2017/08/20/antlr/)
* [使用 Antlr 开发领域语言 - 开发一个完整的应用](https://www.ibm.com/developerworks/cn/java/j-lo-antlr-fullapp/)
* [ANTLR4: 实现一个表达式解析器](http://twoyao.cn/2016/03/23/ANTLR4%20%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E7%BC%96%E8%AF%91%E5%99%A8%E5%89%8D%E7%AB%AF/)
* [ANTLR 4简明教程](https://dohkoos.gitbooks.io/antlr4-short-course/content/)


二、g4文件编写语法
---------------------------------

	grammar Name;
	options {...}
	import ...;
	tokens {...}
	@actionName {...}
	<<rule1>>
	...
	<<rule2>>

以上为g4文件的语法结构，接下来做已经简单的说明：

* **grammar Name** 这是词法跟语法都在同一个文件声明的写法，称之为 **combined** 。若要分开，可以使用lexer grammar Name和parser grammar Name；

* **options** 可以是如下四个选项：

	* **superClass**: 用于生成xxxLexer.java、xxxParser.java的父类；
	* **language**：目标语句，如java；
	* **tokenVocab**：toekn词库；
	* **TokenLabelType**：默认的是antlr的Token类型，这里可以使用自定义的token类，如MyToken。需要配合TokenFactory使用。

* **import** 可以导入各个独立的lexer、parser文件，只能用于combined写法；

* **actionName** 可以是如下内容：
    
    * **@header**：定义类文件头。比如嵌入java的package、import声明；
    * **@member**：定义类文件内容。比如类成员、方法。

    >如果要指定在lexer或者parser中，可以使用 @lexer::membere、@parser::member。

* **rule** 语法规则

**lexer示例**

    lexer grammar HelloLexer;
    HI : 'H' 'i'
    ID : [a-z]+;
    WS : [\t\n\r\s]+ -> skip;
    
**parser示例**

    parser grammar HelloParser;
    options {
        language=Java;
        tokenVocab=HelloLexer;
    }
    
    @header {
        package com.laudandjolynn.antlr;
        import java.util.Set;
        import java.util.HashSet;
    }
    @member {
        private int count;
        public int getCount() {
            return count;
        }
    }
    start : HI ID;



    