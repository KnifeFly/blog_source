---
title: MySQL 索引失效
date: 2017-03-15 10:01:29
tags: mysql
---



# MySQL 索引失效

为了测试索引失效，首先创建一个用于测试的数据表

```SQL
create table 
	student(id int not null primary key, name varchar(10) not null, 
	age int, 
	address varchar(200), 
	hobby varchar(200), 
	key(name, age, address)
);

insert into student(id, name, age, address, hobby) 
	values(1, 'a', 20, 'a', 'a'),(2, 'b', 30, 'b', 'b'),(3, 'c', 30, 'c', 'c');
```



索引失效的几种常见场景

1. select语句中有is null或者is not null查询判断。索引是一棵B+树，节点中不会存储NULL值。

```sql
MariaDB [test]> explain select * from student where age is null \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)


MariaDB [test]> explain select * from student where age is not null \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.01 sec)
```



2. 前导模糊查询不能利用索引，例如查询字段使用`like '%XX'`或者`like '%XX%'`

```shell
MariaDB [test]> explain select * from student where name like '%a' \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)


MariaDB [test]> explain select * from student where name like '%a%' \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)


// like 'a%' 场景是可以使用到索引
MariaDB [test]> explain select * from student where name like 'a%' \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: range
possible_keys: name
          key: name
      key_len: 12
          ref: NULL
         rows: 1
        Extra: Using index condition
1 row in set (0.00 sec)
```



3. 查询条件有or

```shell
MariaDB [test]> explain select * from student where name='a' or name='b' \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: name
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)
```



4. 不符合左前缀法则的查询，跳过多列索引的第一列

```
MariaDB [test]> explain select * from student where age=10 \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)

```



5. 范围查询 `> < between`

```
MariaDB [test]> explain select * from student where name>='a' \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: name
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)
```



6. 查询条件使用函数在索引列上，或者对索引列进行运算

```shell
MariaDB [test]> explain select * from student where left(name, 1)='a' \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)
```



7. not in/not exists

```shell
MariaDB [test]> explain select * from student where name not in ('c', 'b') \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: name
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)
```



8. 隐式转换导致索引失效，`name`是一个字符串字段，`select`查询时传入数字，mysql会把数字转换为字符串，然后做全表扫描

```shell
MariaDB [test]> explain select * from student where name = 11 \G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: student
         type: ALL
possible_keys: name
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 3
        Extra: Using where
1 row in set (0.00 sec)
```

