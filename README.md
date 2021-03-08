# gobatis-flygo-code-generator
A gobatis & flygo code generator

```
Usage of gobatis-flygo-code-generator:

gobatis-flygo-code-generator -mod MODULE -dsn DSN -db DATABASE -OPTIONS

Examples:

gobatis-flygo-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database"
gobatis-flygo-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database" -o "/to/path"
gobatis-flygo-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database" -au "bigboss" -o "/to/path"

Supports options:
  -au string
        The file copyright author (default "bill")
  -c    The Controller enable?
  -cc
        The Controller comment? (default true)
  -cf
        The Config enable?
  -cfc
        The Config comment? (default true)
  -cfns int
        The table to Controller Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]
  -cfp string
        The Config PKG (default "config")
  -cnpx string
        The Controller name prefix
  -cns int
        The table to Controller var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 3)
  -cnsx string
        The Controller name suffix (default "Controller")
  -cp string
        The Controller PKG (default "controller")
  -crpx string
        The Controller route prefix (default "/")
  -crs int
        The table to Controller route strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]
  -crsx string
        The Controller route suffix
  -cvnp string
        The Controller var name prefix
  -cvns string
        The Controller var name suffix (default "Controller")
  -cvs int
        The table to Controller var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 2)
  -db string
        The Database name
  -dsn string
        The MySQL DSN (default "root:123@tcp(127.0.0.1:3306)/test")
  -get string
        The exclude table names[table_a,table_b]
  -git string
        The include table names[table_a,table_b]
  -h    The help info
  -ma
        The Mapper enable?
  -mac
        The Mapper comment? (default true)
  -mafns int
        The table to Mapper Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]
  -manpx string
        The Mapper name prefix
  -mans int
        The table to Mapper var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 2)
  -mansx string
        The Mapper name suffix (default "Mapper")
  -map string
        The Mapper PKG (default "mapper")
  -mavnp string
        The Mapper var name prefix
  -mavns string
        The Mapper var name suffix (default "Mapper")
  -mavs int
        The table to Mapper var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 3)
  -mo
        The model enable? (default true)
  -moc
        The model comment generated? (default true)
  -mocfs int
        The column to field name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 3)
  -mod string
        The project module name
  -mofc
        The model field comment generated? (default true)
  -mofns int
        The table to model Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]
  -mojt
        The model field JSON tag generated? (default true)
  -mojts int
        The column to field name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]
  -mop string
        The model PKG (default "model")
  -motes int
        The table to model name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 3)
  -o string
        The output dir
  -se
        The Service enable?
  -sec
        The Service comment? (default true)
  -sefns int
        The table to Service Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]
  -senpx string
        The Service name prefix
  -sens int
        The table to Service var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 2)
  -sensx string
        The Service name suffix (default "Service")
  -sep string
        The Service PKG (default "service")
  -serpx string
        The Service route prefix (default "/")
  -sers int
        The table to Service route strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]
  -sersx string
        The Service route suffix (default "Service")
  -sevnp string
        The Service var name prefix
  -sevns string
        The Service var name suffix (default "Service")
  -sevs int
        The table to Service var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper] (default 3)
  -v    The version info
  -vb
        The verbose detail show?
```