# QueryDSL 使用笔记

QueryDSL 使用配置说明

### 项目配置

1、项目依赖：我们必须在项目的 **pom.xml** 文件的依赖中添加相关的依赖，如下：

```xml
<dependencies>
    <!--SpringDataJPA-->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <dependency>
        <groupId>com.querydsl</groupId>
        <artifactId>querydsl-apt</artifactId>
        <scope>provided</scope>
    </dependency>
    <dependency>
        <groupId>com.querydsl</groupId>
        <artifactId>querydsl-jpa</artifactId>
    </dependency>
</dependencies>

```

2、编译插件：由于 **QueryDSL** 需要一个编译插件生成辅助编写查询代码的实体，由此我们需要在项目的 **pom.xml** 文件的插件中添加如下配置：

```xml
<plugins>
    <plugin>
        <groupId>com.mysema.maven</groupId>
        <artifactId>apt-maven-plugin</artifactId>
        <version>1.1.3</version>
        <executions>
            <execution>
                <!--<phase>generate-sources</phase>-->
                <goals>
                    <goal>process</goal>
                </goals>
                <configuration>
                    <outputDirectory>target/generated-sources/querydsl</outputDirectory>
                    <processor>com.querydsl.apt.jpa.JPAAnnotationProcessor</processor>
                </configuration>
            </execution>
        </executions>
    </plugin>
</plugins>
```

> 注意：如果 IDE 的编译无法生成查询辅助实体，请用 Maven 命令编译一次，保证查询辅助实体的正常生成。

### 案例说明

案例使用到的类有以下几个（为简化案例，我们减少业务层的代码）：
    
* 实体
  
```java
@Data
@Entity
@Table(name = "people")
public class Person {

    @Id
    @GeneratedValue
    private Long id;
    /**
    * 出生日期 
    */
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    @Column(nullable = false)
    private LocalDate dob;
    /**
    * 姓名 
    */
    @Column(nullable = false, length = 32)
    private String name;
    /**
    * 年龄 
    */
    @Formula("timestampdiff('year', dob, now())")
    private Integer age;

    /**
    * 创建人
    */
    private String createBy;
    /**
    * 创建时间
    */
    private LocalDateTime createDate;
    /**
    * 修改人
    */
    private String modifiedBy;
    /**
    * 修改时间
    */
    private LocalDateTime modifiedDate;

    public Person() {
    }

    public Person(String name, LocalDate dob) {
        this.name = name;
        this.dob = dob;
        this.age = Long.valueOf(
            ChronoUnit.YEARS.between(dob, LocalDate.now())
        ).intValue();
    }
}
```

    > **Person** 实体编译后会生成 **QPerson** 类

* 数据操作层

```java
public interface PersonRepo extends BaseRepository<Person, Long>, QuerydslBinderCustomizer<QPerson> {
    
    /**
        * 自定义动态条件处理规则
        */
    @Override
    default void customize(QuerydslBindings bindings, QPerson person) {

        // 排除 ID 字段的查询
        bindings.excluding(person.id);

        // 所有字符串类型的字段都用不区分大小写的模糊查询（like）
        bindings.bind(String.class)
                .first((SingleValueBinding<StringPath, String>) StringExpression::containsIgnoreCase);

        // 为 Person 实体的 age 字段做 between 过滤操作
        bindings.bind(person.age).all((path, value) -> {
            Iterator<? extends Integer> it = value.iterator();
            Integer from = it.next();
            if (value.size() >= 2) {
                Integer to = it.next();
                return Optional.of(path.between(from, to));
            } else {
                return Optional.of(path.goe(from));
            }
        });

        // 为 Person 实体的 dob 字段做 between 过滤操作
        bindings.bind(person.dob).all((path, value) -> {
            Iterator<? extends LocalDate> it = value.iterator();
            LocalDate from = it.next();
            if (value.size() >= 2) {
                LocalDate to = it.next();
                return Optional.of(path.between(from, to));
            } else {
                return Optional.of(path.goe(from));
            }
        });
    }
}
```

* 控制层

```java
@RestController
@RequestMapping("/people")
public class PersonController {

    @Autowired
    private PersonRepo personRepo;

    @GetMapping
    public ResponseEntity getFiltered(
            @QuerydslPredicate(
                root = Person.class, bindings = PersonRepo.class
            ) Predicate predicate,
            @PageableDefault(
                // 默认按照创建时间进行降序排列
                sort = "createdDate", direction = Sort.Direction.DESC
            ) Pageable pageable,
            PagedResourcesAssembler<Person> assembler
    ) {
        return ResponseEntity.ok(
                        assembler.toResource(
                                personRepo.findAll(predicate, pageable),
                                PersonDto::new
                        )
                );
    }
}
```

##### A、客户端动态参数实例

* 客户端需要查询所有 `王` 姓人员时：

    ```text
    GET /people?name=%E7%8E%8B
    ```
    
    > 在 url 的路径上传递参数时，如果参数值是中文，必须要用 **encodeURIComponent** 函数进行转码。因此 `王` 转码后为 `%E7%8E%8B`

* 需要查询年龄在 `18` 到 `30` 岁之间的人员时：

    ```text
    GET /people?age=18&age=30
    ```

* 需要查询出生日期在 `2000-01-01` 到 `2000-12-31` 的人员时：

    ```text
    GET /people?dob=2000-01-01&dob=2000-12-31
    ```

> 分页对象 **Pageable** 的所有，可查看 [Spring data jpa 控制层的分页和排序使用说明](SPRING-DATA-JPA-README.md#pageable)。<br>
> 参考文章： [Querydsl and Spring Data Jpa](https://github.com/Cepr0/sb-querydsl-sd-demo)

##### B、自定义查询映射实体

当我们需要查询所有 `王` 姓人员，并且只需要查询 **id** , **name** , **age** 等三个字段。代码如下：

```java
@RestController
@RequestMapping("/people")
public class PersonController {

    @Autowired
    private PersonRepo personRepo;

    @GetMapping
    public List<Person> getFiltered() {
        JPQLQueryFactory jpqlQuery = personRepo.getJPAQueryFactory();
        QPerson person = QPerson.person;
        
        Predicate predicate = person.name.contains("王");
        return jpqlQuery.select(
                    Projections.bean(
                            Person.class,
                            person.id,
                            person.name,
                            person.age
                    )
            ).from(person).where(predicate).fetch();
    }
}
```

> 注意：`Projections.bean` 是是通过调用 `Introspector.getBeanInfo` 获取到属性的 **set** 方法的，在使用 **lombok** 的 `@Accessors(chain = true)` 时，是获取不到属性的 set 方法的