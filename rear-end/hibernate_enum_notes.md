# Hibernate 中的枚举持久化

这里主要记录 Hibernate 的枚举类型字段持久化的三种方式。以下为基础代码：

* 基础枚举接口（IBaseCodeEnum）：

```java
/**
 * 基础枚举接口
 * @author tzg
 */
public interface IBaseCodeEnum<E extends Enum<E> & IBaseCodeEnum<E>> {

    int getCode();

}
```

* 性别枚举（GenderEnum）：

```java
/**
 * 性别枚举
 * @author tzg
 */
public enum GenderEnum implements IBaseCodeEnum<GenderEnum> {
    男(1),女(2);
    
    private final int code;

    GenderEnum(int code) {
        this.code = code;
    }

    @Override
    public int getCode() {
        return code;
    }
}
```

* 用户信息实体（UserEntity）：

```java
/**
 * 用户信息实体
 * @author tzg
 */
@Data
@Accessors(chain = true)
@Entity
public class UserEntity {
    
    @Id
    private Long id;
    
    private String name;
    
    private GenderEnum gender;
    
}
```

## 使用 @Enumerated 实现枚举持久化

使用 `@Enumerated(EnumType.ORDINAL)` 或 `EnumType.STRING` 方式。使用方法如下：

* 如果希望持久化为枚举的索引序列，用户信息实体可这样设置

  ```java
  /**
   * 用户信息实体
   * @author tzg
   */
  @Data
  @Accessors(chain = true)
  @Entity
  public class UserEntity {
      
      @Id
      private Long id;
      
      private String name;
      
      @Enumerated(EnumType.ORDINAL)
      private GenderEnum gender;
      
  }
  ```
  
* 如果希望持久化为枚举的名称，用户信息实体可这样设置

  ```java
  /**
   * 用户信息实体
   * @author tzg
   */
  @Data
  @Accessors(chain = true)
  @Entity
  public class UserEntity {
      
      @Id
      private Long id;
      
      private String name;
      
      /**
       * 枚举默认持久化就是 EnumType.STRING ，因此不加注解也可以
       */
      @Enumerated(EnumType.STRING)
      private GenderEnum gender;
      
  }
  ```

## 使用 AttributeConverter 接口实现枚举的自定义持久化

**Hibernate** 提供了 `javax.persistence.AttributeConverter` 接口指定如何将实体属性转换为数据库列表示。

此方案适用与**数量不多**或者**个别特殊**的枚举。

使用方法如下：

* 实现性别枚举的转换类（GenderEnumConverter ）：

  ```java
  /**
   * 性别枚举的转换类
   * @author tzg
   */
  public class GenderEnumConverter implements AttributeConverter<GenderEnum, Integer> {
      
      @Override
      public Integer convertToDatabaseColumn(GenderEnum attribute) {
          return attribute.getCode();
      }
  
      @Override
      public ComputerState convertToEntityAttribute(Integer dbData) {
          return CodeEnumUtil.codeOf(GenderEnum.class, dbData);
      }
      
  }
  ```

* 用户信息实体的配置如下：

  ```java
  /**
   * 用户信息实体
   * @author tzg
   */
  @Data
  @Accessors(chain = true)
  @Entity
  public class UserEntity {
      
      @Id
      private Long id;
      
      private String name;
      
      @Convert(converter = GenderEnumConverter.class)
      private GenderEnum gender;
      
  }
  ```

  

## 使用 UserType 接口实现枚举的自定义持久化

**Hibernate** 提供用户自定义类型的接口 `org.hibernate.usertype.UserType` 。

此方案适用于具有相似行为的**一组**枚举。

使用方法如下：

* 实现一个自定义的类型处理类：

  ```java
  package com.sproutcat.example;
  
  /**
   * 编码枚举类型字段处理
   *
   * @author tzg
   */
  public class BaseCodeEnumType<E extends Enum<E> & IBaseCodeEnum<E>> implements UserType, DynamicParameterizedType {
  
      private static final int SQL_TYPE = Types.INTEGER;
      private static final String ENUM = "enumClass";
  
      private Class<E> enumClass;
  
      @Override
      public void setParameterValues(Properties parameters) {
          final ParameterType reader = (ParameterType) parameters.get(PARAMETER_TYPE);
  
          if (reader != null) {
              enumClass = reader.getReturnedClass().asSubclass(Enum.class);
          } else {
              final String enumClassName = (String) parameters.get(ENUM);
              try {
                  enumClass = ReflectHelper.classForName(enumClassName, this.getClass()).asSubclass(Enum.class);
              } catch (ClassNotFoundException exception) {
                  throw new HibernateException("Enum class not found: " + enumClassName, exception);
              }
          }
      }
  
      @Override
      public int[] sqlTypes() {
          return new int[]{SQL_TYPE};
      }
  
      @Override
      public Class returnedClass() {
          return enumClass;
      }
  
      @Override
      public boolean equals(Object x, Object y) throws HibernateException {
          return x == y;
      }
  
      @Override
      public int hashCode(Object x) throws HibernateException {
          return x == null ? 0 : x.hashCode();
      }
  
      @Override
      public Object nullSafeGet(ResultSet rs, String[] names, SharedSessionContractImplementor session, Object owner) throws HibernateException, SQLException {
          final int value = rs.getInt(names[0]);
          return rs.wasNull() ? null : getEnumByCode(value);
      }
  
      @Override
      public void nullSafeSet(PreparedStatement st, Object value, int index, SharedSessionContractImplementor session) throws HibernateException, SQLException {
          st.setObject(index, ((IBaseCodeEnum) value).getCode(), SQL_TYPE);
      }
  
      @Override
      public Object deepCopy(Object value) throws HibernateException {
          return value;
      }
  
      @Override
      public boolean isMutable() {
          return false;
      }
  
      @Override
      public Serializable disassemble(Object value) throws HibernateException {
          return (Serializable) value;
      }
  
      @Override
      public Object assemble(Serializable cached, Object owner) throws HibernateException {
          return cached;
      }
  
      @Override
      public Object replace(Object original, Object target, Object owner) throws HibernateException {
          return original;
      }
  
      private E getEnumByCode(int code) {
          try {
              E[] enumConstants = enumClass.getEnumConstants();
              for (E e : enumConstants) {
                  if (e.getCode() == code) {
                      return e;
                  }
              }
              return null;
          } catch (Exception ex) {
              throw new IllegalArgumentException("Cannot convert " + code + " to " + enumClass.getSimpleName() + " by code value.", ex);
          }
      }
  
  }
  
  ```

* 用户信息实体的配置如下：

  ```java
  /**
   * 用户信息实体
   * @author tzg
   */
  @Data
  @Accessors(chain = true)
  @Entity
  public class UserEntity {
      
      @Id
      private Long id;
      
      private String name;
      
      @Type(type = "com.sproutcat.example.BaseCodeEnumType")
      private GenderEnum gender;
      
  }
  ```

  

> 参考文章：https://www.oschina.net/code/snippet_100569_13747
>
> ​				https://segmentfault.com/a/1190000013163938