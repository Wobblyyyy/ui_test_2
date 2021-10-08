import ui
import strconv
import math
import gx

struct App {
mut:
	text   string
	window &ui.Window
	rows   []&ui.Layout
	input  []string
}

fn main() {
	operations := [
		['C', '%', '^', '/'],
		['7', '8', '9', '*'],
		['4', '5', '6', '-'],
		['1', '2', '3', '+'],
		['0', '.', 'n', '='],
	]
	mut app := &App{
		window: 0
	}
	mut children := []ui.Widget{}
	children = [
		ui.textbox(
			text: &app.text
			placeholder: '0'
			fitted_height: true
			text_size: 1.0 / 20
			read_only: true
		),
	]
	for op_row in operations {
		mut row_children := []ui.Widget{}
		for op in op_row {
			row_children << ui.button(
				text: op
				onclick: on_button_click
				text_size: 1.0 / 20
				radius: 0.25
				theme: 'blue'
				hoverable: true
			)
		}
		children << ui.row(
			spacing: 0.02
			widths: ui.stretch
			children: row_children
		)
	}
	app.window = ui.window(
		width: 300
		height: 400
		title: 'resizable'
		state: app
		mode: .resizable
		children: [
			ui.column(
				margin_: 10
				spacing: 0.02
				heights: ui.stretch
				bg_color: gx.rgb(240, 180, 130)
				children: children
			),
		]
	)

	ui.run(app.window)
}

fn calc_expr(a f64, b f64, op Operator) f64 {
	match op {
		.plus { return a + b }
		.minus { return a - b }
		.multiply { return a * b }
		.divide { return a / b }
		.power { return math.pow(a, b) }
	}
}

fn calculate(inputs []string) f64 {
	mut unparsed_num := ''
	mut parsed_nums := []f64{}
	mut operators := []Operator{}
	for i := 0; i < inputs.len; i++ {
		input := inputs[i]
		match input {
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', 'n' {
				unparsed_num += input
			}
			'+', '-', '*', '/', '^', '=' {
				parsed_nums << strconv.atof_quick(unparsed_num.replace('n', '-'))
				unparsed_num = ''
				match input {
					'+' { operators << Operator.plus }
					'-' { operators << Operator.minus }
					'*' { operators << Operator.multiply }
					'/' { operators << Operator.divide }
					'^' { operators << Operator.power }
					else {}
				}
			}
			else {}
		}
	}
	assert parsed_nums.len - 1 == operators.len
	for parsed_nums.len > 1 {
		a := parsed_nums[0]
		b := parsed_nums[1]
		op := operators[0]
		result := calc_expr(a, b, op)
		parsed_nums.delete_many(0, 2)
		operators.delete(0)
		parsed_nums.insert(0, result)
	}
	return parsed_nums[0]
}

fn handle_button_click(mut app App, str string) {
	app.input << str

	if byte(str[0]) == byte(`=`) {
		result := calculate(app.input)
		app.input.clear()
		app.text = result.str()
	} else {
		app.text = app.input.join('')
	}
}

fn on_button_click(mut app App, button &ui.Button) {
	op := button.text
	if op == 'C' {
		app.input.clear()
		app.text = '0'
	} else {
		handle_button_click(mut app, op)
	}
}

enum Operator {
	plus
	minus
	multiply
	divide
	power
}
