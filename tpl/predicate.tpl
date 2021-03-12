package {{.Config.Predicate.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

import "fmt"

type (
	Column       string
	Type         uint8
	Predicate    map[Column]Cond
	eq           struct{}
	notEq        struct{}
	like         struct{}
	notLike      struct{}
	leftLike     struct{}
	notLeftLike  struct{}
	rightLike    struct{}
	notRightLike struct{}
	instr        struct{}
	notInstr     struct{}
	gt           struct{}
	notGt        struct{}
	gtEq         struct{}
	notGtEq      struct{}
	lt           struct{}
	notLt        struct{}
	ltEq         struct{}
	notLtEq      struct{}
	betweenAnd   struct {
		left  interface{}
		right interface{}
	}
	notBetweenAnd struct {
		left  interface{}
		right interface{}
	}
)

var (
	Eq           = &eq{}
	NotEq        = &notEq{}
	Like         = &like{}
	NotLike      = &notLike{}
	LeftLike     = &leftLike{}
	NotLeftLike  = &notLeftLike{}
	RightLike    = &rightLike{}
	NotRightLike = &notRightLike{}
	Instr        = &instr{}
	NotInstr     = &notInstr{}
	Gt           = &gt{}
	NotGt        = &notGt{}
	GtEq         = &gtEq{}
	NotGtEq      = &notGtEq{}
	Lt           = &lt{}
	NotLt        = &notLt{}
	LtEq         = &ltEq{}
	NotLtEq      = &notLtEq{}
	BetweenAnd   = func(left, right interface{}) Cond {
		return &betweenAnd{left: left, right: right}
	}
	NotBetweenAnd = func(left, right interface{}) Cond {
		return &notBetweenAnd{left: left, right: right}
	}
)

type Cond interface {
	SQL(column Column) (string, []interface{})
}

func (c *eq) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v = ?", column), nil
}

func (c *notEq) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("NOT t.%v = ?", column), nil
}

func (c *like) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v %s", column, `LIKE CONCAT('%', ?, '%')`), nil
}

func (c *notLike) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v %s", column, `NOT LIKE CONCAT('%', ?, '%')`), nil
}

func (c *leftLike) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v %s", column, `LIKE CONCAT('%', ?)`), nil
}

func (c *notLeftLike) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v %s", column, `NOT LIKE CONCAT('%', ?)`), nil
}

func (c *rightLike) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v %s", column, `LIKE CONCAT(?, '%')`), nil
}

func (c *notRightLike) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v %s", column, `NOT LIKE CONCAT(?, '%')`), nil
}

func (c *instr) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("INSTR(t.%v, ?) > 0", column), nil
}

func (c *notInstr) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("NOT INSTR(t.%v, ?) > 0", column), nil
}

func (c *gt) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v > 0", column), nil
}

func (c *notGt) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("NOT t.%v > 0", column), nil
}

func (c *gtEq) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v >= 0", column), nil
}

func (c *notGtEq) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("NOT t.%v >= 0", column), nil
}

func (c *lt) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v < 0", column), nil
}

func (c *notLt) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("NOT t.%v < 0", column), nil
}

func (c *ltEq) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v <= 0", column), nil
}

func (c *notLtEq) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("NOT t.%v <= 0", column), nil
}

func (c *betweenAnd) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("t.%v BETWEEND ? AND ?", column), []interface{}{c.left, c.right}
}

func (c *notBetweenAnd) SQL(column Column) (string, []interface{}) {
	return fmt.Sprintf("NOT t.%v BETWEEND ? AND ?", column), []interface{}{c.left, c.right}
}