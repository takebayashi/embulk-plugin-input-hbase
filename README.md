# embulk-plugin-input-hbase

## Example

HBase table:

```ruby
hbase(main):029:0> scan 'example:test'
ROW                                  COLUMN+CELL                                                                                               
 r1                                  column=foo:dig, timestamp=1422458241976, value=\x00\x00\x00\x00\x00\x00\x00\x01                           
 r2                                  column=foo:dig, timestamp=1422458257028, value=\x00\x00\x00\x00\x00\x00\x00\x02                           
 r2                                  column=foo:str, timestamp=1422458830978, value=hello                                                      
 r3                                  column=foo:str, timestamp=1422458270762, value=hey                                                        
3 row(s) in 0.0860 seconds
```

Embulk config:

```yaml
in:
  type: hbase
  host: localhost
  table: 'example:test'
  columns:
    - {name: 'foo:dig', type: long}
    - {name: 'foo:str', type: string}
out:
  type: stdout
```

Embulk preview:

```bash
$ java -jar embulk.jar preview -C $(hbase classpath) example.yml
+--------------+----------------+
| foo:dig:long | foo:str:string |
+--------------+----------------+
|            1 |                |
|            2 |          hello |
|              |            hey |
+--------------+----------------+
```
