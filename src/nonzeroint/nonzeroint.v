// nonzeroint は 0 以外の整数を表す NonZeroInt 構造体を提供するモジュール
module nonzeroint

@[noinit]
pub struct NonZeroInt {
mut:
	value int
}

pub fn new_non_zero_int(value int) !NonZeroInt {
	if value == 0 {
		return error('0 is not allowed')
	}
	return NonZeroInt{value: value}
}

pub fn (n NonZeroInt) get() int {
	return n.value
}

pub fn (mut n NonZeroInt) set(value int) ! {
	if value == 0 {
		return error('0 is not allowed')
	}
	n.value = value
}