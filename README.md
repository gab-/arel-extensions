# Arel Extensions

[![Build Status](https://secure.travis-ci.org/Faveod/arel-extensions.svg)](http://travis-ci.org/Faveod/arel-extensions)
[![Latest Release](https://img.shields.io/gem/v/arel_extensions.svg)](https://rubygems.org/gems/arel_extensions)
![](http://img.shields.io/badge/license-MIT-brightgreen.svg)
![](https://ruby-gem-downloads-badge.herokuapp.com/arel_extensions?type=total)
![](https://ruby-gem-downloads-badge.herokuapp.com/arel_extensions?label=downloads-current-version)

Arel Extensions adds shortcuts, fixes and new ORM mappings (ruby to SQL) to Arel.
It aims to ensure pure ruby syntax for the biggest number of usual cases.
It allows to use more advanced SQL functions for any supported RDBMS.


## Requirements

Arel 6 (Rails 4) or Arel 7+ (Rails 5).


## Examples

t is an Arel::Table for table my_table

## Comparators

```ruby
(t[:date1] > t[:date2]).to_sql # (same as (t[:date1].gt(t[:date2])).to_sql)
# => my_table.date1 > my_table.date2
```

```ruby
(t[:nb] > 42).to_sql # (same as (t[:nb].gt(42)).to_sql)
# => my_table.nb > 42
```

Other operators : <, >=, <=, =~


## Maths

Currently in Arel:
```ruby
(t[:nb] + 42).to_sql
# => my_table.nb + 42
```

But:
```ruby
(t[:nb].sum + 42).to_sql
# => NoMethodError: undefined method `+' for #<Arel::Nodes::Sum>
```

With Arel Extensions:
```ruby
(t[:nb].sum + 42).to_sql
# => SUM(my_table.nb) + 42
```

Other functions : ABS, RAND, ROUND, FLOOR, CEIL, FORMAT

## String operations

```ruby
(t[:name] + ' append').to_sql
# => CONCAT(my_table.name, ' append')

(t[:name].coalesce('default')).to_sql
# => COALESCE(my_table.name, 'default')

(t[:name].blank).to_sql
# => TRIM(TRIM(TRIM(COALESCE(my_table.name, '')), '\t'), '\n') = ''

(t[:name] =~ /\A[a-d_]+/).to_sql
# => my_table.name REGEXP '\^[a-d_]+'
```

Other functions : SOUNDEX, LENGTH, REPLACE, LOCATE, TRIM

### String Array operations

```t[:list]``` is a classical varchar containing a comma separated list ("1,2,3,4")

```ruby
(t[:list] & 3).to_sql
# => FIND_IN_SET('3', my_table.list)

(t[:list] & [2,3]).to_sql
# => FIND_IN_SET('2', my_table.list) OR FIND_IN_SET('3', my_table.list)
```


## Date & Time operations

```ruby
(t[:birthdate] + 10.years).to_sql
# => ADDDATE(my_table.birthdate, INTERVAL 10 YEAR)

((t[:birthdate] - Date.today) * -1).to_sql
# => DATEDIFF(my_table.birthdate, '2017-01-01') * -1

t[:birthdate].week.to_sql
# => WEEK(my_table.birthdate)

t[:birthdate].month.to_sql
# => MONTH(my_table.birthdate)

t[:birthdate].year.to_sql
# => YEAR(my_table.birthdate)

t[:birthdate].format('%Y-%m-%d').to_sql
# => DATE_FORMAT(my_table.birthdate, '%Y-%m-%d')
```

## Unions (in next version)

```ruby
(t.where(t[:name].eq('str')) + t.where(t[:name].eq('test'))).to_sql
# => SELECT * FROM my_table WHERE (name = 'str') UNION SELECT * FROM my_table WHERE (name= 'test')
```

## Stored Procedures and User-defined functions

To optimize queries, some classical functions are defined in databases missing any alternative native functions.
Examples :
- FIND_IN_SET 

## BULK INSERT / UPSERT

Arel Extensions improves InsertManager by adding bulk_insert method, which allows to insert multiple rows in one insert.


```
@cols = ['id', 'name', 'comments', 'created_at']
@data = [
   	[23, 'name1', "sdfdsfdsfsdf", '2016-01-01'],
   	[25, 'name2', "sdfds234sfsdf", '2016-01-01']
]

insert_manager = Arel::InsertManager.new(User).into(User.arel_table)
insert_manager.bulk_insert(@cols, @data)
User.connection.execute(insert_manager.to_sql)
```

## New Arel Functions

<table class="tg arel-functions">
  <thead>
  <tr>
    <th></th>
    <th class="tg-by3v">Function / Example<br/>ToSql</th>
    <th class="tg-pjz5">MySQL / MariaDB</th>
    <th class="tg-pjz5">PostgreSQL</th>
    <th class="tg-pjz5">SQLite</th>
    <th class="tg-pjz5">Oracle</th>
    <th class="tg-pjz5">MS SQL</th>
    <th class="tg-pjz5">DB2<br/>(not tested on real DB)</th>
  </tr>
  </thead>
  <tbody>
  <tr>
    <th class="tg-82sq" rowspan="6"><div>Number functions</div></th>
    <td class="tg-yw4l">ABS<br>column.abs<br></td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">CEIL<br>column.ceil</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">CASE + ROUND</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">CEILING()</td>
    <td class="tg-j6lv">CEILING()</td>
  </tr>
  <tr>
    <td class="tg-yw4l">FLOOR<br>column.floor</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">CASE + ROUND</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">RAND<br>Arel.rand</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">RANDOM()</td>
    <td class="tg-j6lv">dbms_random.value()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">ROUND<br>column.round(precision = 0)</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">SUM / AVG / MIN / MAX + x<br>column.sum + 42</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <th class="tg-ffjm" rowspan="12"><div>String functions</div></th>
    <td class="tg-yw4l">CONCAT<br>column + "string"</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv"> ||</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">+</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">LENGTH<br>column.length</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">LEN()</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">LOCATE<br>column.locate("string")</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">INSTR()</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">CHARINDEX()</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">FIND_IN_SET<br>column &amp; ("l")</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-orpl">db.create_function( "find_in_set", 1 ) <br>do |func, value1, value2|,<br>func.result =value1.index(value2)<br>end <br></td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">SOUNDEX<br>column.soundex</td>
    <td class="ok">✔</td>
    <td class="tg-3oug">require fuzzystrmatch</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">REPLACE<br>column.replace("s","X")</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">REGEXP<br>column =~ "pattern"<br></td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-3oug">require pcre.so</td>
    <td class="tg-j6lv">REGEXP_LIKE</td>
    <td class="tg-j6lv">LIKE</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">NOT_REGEXP<br>column != "pattern"</td>
    <td class="ok">✔</td>
    <td class="ok">✔<br></td>
    <td class="tg-3oug">require pcre.so</td>
    <td class="tg-j6lv">NOT REGEXP_LIKE </td>
    <td class="tg-j6lv">NOT LIKE</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">ILIKE (in Arel6)<br/>column.imatches('%pattern')</td>
    <td class="tg-j6lv">LOWER() LIKE LOWER()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">LOWER() LIKE LOWER()</td>
    <td class="tg-j6lv">LOWER() LIKE LOWER()</td>
    <td class="tg-j6lv">LOWER() LIKE LOWER()</td>
  </tr>
  <tr>
    <td class="tg-yw4l">TRIM (leading)<br>column.trim("LEADING","M")</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">LTRIM()</td>
    <td class="tg-j6lv">LTRIM()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">LTRIM()</td>
  </tr>
  <tr>
    <td class="tg-yw4l">TRIM (trailing)<br>column.trim("TRAILING","g")</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">RTRIM()</td>
    <td class="tg-j6lv">RTRIM()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">Rtrim()</td>
  </tr>
  <tr>
    <td class="tg-yw4l">TRIM (both)<br>column.trim("BOTH","e")</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">TRIM()<br></td>
    <td class="tg-j6lv">TRIM()</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">LTRIM(RTRIM())</td>
    <td class="tg-j6lv">TRIM()</td>
  </tr>
  <tr>
    <th class="tg-4rp9" rowspan="6"><div>Date functions</div></th>
    <td class="tg-yw4l">DATEADD<br>column + 2.year<br></td>
    <td class="tg-j6lv">DATE_ADD()<br></td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">+</td>
  </tr>
  <tr>
    <td class="tg-yw4l">DATEDIFF<br>column - date<br></td>
    <td class="tg-j6lv">DATEDIFF()<br></td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">JULIANDAY() - JULIANDAY()</td>
    <td class="tg-j6lv"> -</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">DAY()</td>
  </tr>
  <tr>
    <td class="tg-yw4l">DAY<br>column.day<br></td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">STRFTIME()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">MONTH<br>column.month<br></td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">STRFTIME()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">WEEK<br>column.week</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">STRFTIME()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">YEAR<br>column.year</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">STRFTIME()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <th class="tg-72dn" rowspan="8"><div>Comparators functions</div></th>
    <td class="tg-yw4l">COALESCE<br>column.coalesce(var)</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">ISNULL<br>column.isnull()</td>
    <td class="tg-j6lv">IFNULL()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="tg-j6lv">NVC()</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">==<br>column == integer</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">!=<br>column != integer</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">&gt;<br>column &gt; integer</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">&gt;=<br>column &gt;= integer</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">&lt; <br>column &lt; integer</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">&lt;=<br>column &lt;= integer</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <th class="tg-9hbo" rowspan="2"><div>Boolean <br/> functions</div></th>
    <td class="tg-yw4l">OR ( ⋁ )<br>column.eq(var).⋁(column.eq(var))</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <td class="tg-yw4l">AND ( ⋀ )<br>column.eq(var).⋀(column.eq(var))</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  <tr>
    <th class="bulk_insert" rowspan="1"><div>Bulk <br/> Insert</div></th>
    <td class="tg-yw4l">insert_manager.bulk_insert(@cols, @data)</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
    <td class="ok">✔</td>
  </tr>
  </tbody>
</table>