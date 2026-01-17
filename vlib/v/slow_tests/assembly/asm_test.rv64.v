fn test_inline_asm_rv64() {
	a, mut b := i64(123), i64(0)
	asm rv64 {
		// op dst, src
		mv t0, a
		mv b, t0
		; +r (b)
		; r (a)
		; t0
	}
	assert a == b

	mut c := 0
	asm rv64 {
		li c, 5
		; +r (c)
	}
	assert c == 5

	d, e, mut f := 10, 2, 0
	asm rv64 {
		mv f, d
		add f, f, e
		addi f, f, 5
		; +r (f)
		; r (d)
		  r (e)
	}
	assert d == 10
	assert e == 2
	assert f == 17

	g, h, mut i := 2.3, 4.8, -3.5
	asm rv64 {
		fadd.d i, g, h
		; =f (i)
		; f (g)
		  f (h)
	}
	assert g == 2.3
	assert h == 4.8
	assert i == 7.1

	n1, n2, mut sum, mut prod := 3, 5, -1, -1
	asm rv64 {
		add '%0', '%2', '%3'
		mul '%1', '%2', '%3'
		; =&r (sum)
		  =r (prod)
		; r (n1)
		  r (n2)
	}
	assert sum == 8
	assert prod == 15

	l := 5
	m := &l
	asm rv64 {
		li t0, 7
		sd t0, [m]
		; ; r (m)
		; memory
		  t0
	}
	assert l == 7
}

// Test: Base addressing mode (rs) - load from pointer
fn test_base_addressing() {
	val := i64(42)
	ptr := &val
	mut result := i64(0)
	asm rv64 {
		ld t0, [ptr]
		mv result, t0
		; +r (result)
		; r (ptr)
		; t0
	}
	assert result == 42
}

// Test: Base + displacement addressing mode offset(rs)
fn test_base_plus_displacement() {
	arr := [i64(10), i64(20), i64(30)]
	ptr := arr.data
	mut val := i64(0)
	asm rv64 {
		ld t0, [ptr + 8]
		mv val, t0
		; +r (val)
		; r (ptr)
		; t0
	}
	assert val == 20
}

// Test: Store with displacement
fn test_store_displacement() {
	mut arr := [i64(0), i64(0), i64(0)]
	ptr := arr.data
	asm rv64 {
		li t0, 99
		sd t0, [ptr + 16]
		; ; r (ptr)
		; memory
		  t0
	}
	assert arr[2] == 99
}

// Test: Extended temporary registers (t3-t6)
fn test_extended_temps() {
	a, b := i64(100), i64(200)
	mut result := i64(0)
	asm rv64 {
		mv t3, a
		mv t4, b
		add t5, t3, t4
		mv result, t5
		; +r (result)
		; r (a) r (b)
		; t3 t4 t5
	}
	assert result == 300
}

// Test: Saved registers (s0-s11)
fn test_saved_registers() {
	x := i64(50)
	mut y := i64(0)
	asm rv64 {
		mv s0, x
		slli s1, s0, 1
		mv y, s1
		; +r (y)
		; r (x)
		; s0 s1
	}
	assert y == 100
}

// Test: Argument registers (a0-a7)
fn test_arg_registers() {
	val1, val2 := i64(25), i64(75)
	mut result := i64(0)
	asm rv64 {
		mv a0, val1
		mv a1, val2
		add a2, a0, a1
		mv result, a2
		; +r (result)
		; r (val1) r (val2)
		; a0 a1 a2
	}
	assert result == 100
}

// Test: Raw x registers
fn test_raw_registers() {
	val := i64(123)
	mut out := i64(0)
	asm rv64 {
		mv x5, val
		addi x6, x5, 77
		mv out, x6
		; +r (out)
		; r (val)
		; x5 x6
	}
	assert out == 200
}

// Test: Floating-point double precision operations
fn test_fp_double() {
	a, b := 10.5, 2.5
	mut sum := 0.0
	mut diff := 0.0
	mut prod := 0.0
	mut quot := 0.0
	asm rv64 {
		fadd.d sum, a, b
		fsub.d diff, a, b
		fmul.d prod, a, b
		fdiv.d quot, a, b
		; =f (sum)
		  =f (diff)
		  =f (prod)
		  =f (quot)
		; f (a)
		  f (b)
	}
	assert sum == 13.0
	assert diff == 8.0
	assert prod == 26.25
	assert quot == 4.2
}

// Test: Floating-point temporary registers (ft0-ft11)
fn test_fp_temp_registers() {
	a, b := 3.0, 4.0
	mut result := 0.0
	asm rv64 {
		fmv.d ft0, a
		fmv.d ft1, b
		fmul.d ft2, ft0, ft0
		fmul.d ft3, ft1, ft1
		fadd.d ft4, ft2, ft3
		fsqrt.d result, ft4
		; =f (result)
		; f (a) f (b)
		; ft0 ft1 ft2 ft3 ft4
	}
	assert result == 5.0
}

// Test: Floating-point saved registers (fs0-fs11)
fn test_fp_saved_registers() {
	pi := 3.14159
	mut doubled := 0.0
	asm rv64 {
		fmv.d fs0, pi
		fadd.d fs1, fs0, fs0
		fmv.d doubled, fs1
		; =f (doubled)
		; f (pi)
		; fs0 fs1
	}
	assert doubled == 6.28318
}

// Test: Floating-point argument registers (fa0-fa7)
fn test_fp_arg_registers() {
	x, y := 2.0, 8.0
	mut result := 0.0
	asm rv64 {
		fmv.d fa0, x
		fmv.d fa1, y
		fmul.d fa2, fa0, fa1
		fmv.d result, fa2
		; =f (result)
		; f (x) f (y)
		; fa0 fa1 fa2
	}
	assert result == 16.0
}

// Test: Raw f registers
fn test_raw_fp_registers() {
	val := 7.5
	mut out := 0.0
	asm rv64 {
		fmv.d f0, val
		fadd.d f1, f0, f0
		fmv.d out, f1
		; =f (out)
		; f (val)
		; f0 f1
	}
	assert out == 15.0
}

// Test: Mixed integer and floating-point operations
fn test_mixed_int_fp() {
	n := i64(10)
	mut result := 0.0
	asm rv64 {
		fcvt.d.l ft0, n
		fmul.d ft1, ft0, ft0
		fmv.d result, ft1
		; =f (result)
		; r (n)
		; ft0 ft1
	}
	assert result == 100.0
}

// Test: Multiple memory operations
fn test_multiple_memory_ops() {
	mut arr := [i64(1), i64(2), i64(3), i64(4)]
	ptr := arr.data
	asm rv64 {
		ld t0, [ptr]
		ld t1, [ptr + 8]
		add t2, t0, t1
		sd t2, [ptr + 24]
		ld t3, [ptr + 16]
		add t4, t2, t3
		sd t4, [ptr]
		; ; r (ptr)
		; memory
		  t0 t1 t2 t3 t4
	}
	assert arr[0] == 6
	assert arr[3] == 3
}

// Test: Bitwise operations
fn test_bitwise_ops() {
	a, b := i64(0xFF00), i64(0x0FF0)
	mut and_result := i64(0)
	mut or_result := i64(0)
	mut xor_result := i64(0)
	asm rv64 {
		and and_result, a, b
		or or_result, a, b
		xor xor_result, a, b
		; =r (and_result)
		  =r (or_result)
		  =r (xor_result)
		; r (a) r (b)
	}
	assert and_result == 0x0F00
	assert or_result == 0xFFF0
	assert xor_result == 0xF0F0
}

// Test: Shift operations
fn test_shift_ops() {
	val := i64(0x10)
	mut sll_result := i64(0)
	mut srl_result := i64(0)
	asm rv64 {
		slli sll_result, val, 4
		srli srl_result, val, 2
		; =r (sll_result)
		  =r (srl_result)
		; r (val)
	}
	assert sll_result == 0x100
	assert srl_result == 0x4
}

// Test: Conditional operations (set less than)
fn test_compare_ops() {
	a, b := i64(5), i64(10)
	mut lt_result := i64(0)
	mut ge_result := i64(0)
	asm rv64 {
		slt lt_result, a, b
		slt ge_result, b, a
		; =r (lt_result)
		  =r (ge_result)
		; r (a) r (b)
	}
	assert lt_result == 1
	assert ge_result == 0
}

// Test: Using high temporary registers t6
fn test_t6_register() {
	a := i64(42)
	mut result := i64(0)
	asm rv64 {
		mv t6, a
		addi t6, t6, 8
		mv result, t6
		; +r (result)
		; r (a)
		; t6
	}
	assert result == 50
}

// Test: Using high saved registers s10, s11
fn test_high_saved_registers() {
	x := i64(100)
	mut y := i64(0)
	asm rv64 {
		mv s10, x
		addi s11, s10, 23
		mv y, s11
		; +r (y)
		; r (x)
		; s10 s11
	}
	assert y == 123
}

// Test: Using high FP temporary registers ft8-ft11
fn test_high_fp_temps() {
	a := 2.5
	mut result := 0.0
	asm rv64 {
		fmv.d ft8, a
		fmul.d ft9, ft8, ft8
		fmul.d ft10, ft9, ft8
		fmv.d result, ft10
		; =f (result)
		; f (a)
		; ft8 ft9 ft10
	}
	assert result == 15.625
}

// Test: Using high FP saved registers fs10, fs11
fn test_high_fp_saved() {
	val := 1.5
	mut result := 0.0
	asm rv64 {
		fmv.d fs10, val
		fadd.d fs11, fs10, fs10
		fadd.d result, fs11, fs10
		; =f (result)
		; f (val)
		; fs10 fs11
	}
	assert result == 4.5
}
