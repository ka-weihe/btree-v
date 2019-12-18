import btree
import rand

fn rnd_test_keys() {
	// This can fail in case of dublicate random strings
	mut arr := []string
	mut b := btree.new_tree()
	for _ in 0..100000 {
		mut buf := []byte
		for j in 0..15 {
			buf << byte(rand.next(int(`z`) - int(`a`)) + `a`)
		}
		s := string(buf)
		b.set(s, 1)
		arr << s
	}
	arr.sort()
	res := b.keys()

	for i in 0..arr.len {
		assert arr[i] == res[i]
	}
}

fn rnd_test_get() {
	mut arr := []string
	mut b := btree.new_tree()
	for i in 0..100000 {
		mut buf := []byte
		for j in 0..15 {
			buf << byte(rand.next(int(`z`) - int(`a`)) + `a`)
		}
		s := string(buf)
		b.set(s, i)
		arr << s
	}
	for i in 0..100000 {
		assert i == b.get(arr[i]) 
	}
}

fn rnd_test_delete() {
	mut arr := []string
	mut b := btree.new_tree()
	for i in 0..100000 {
		mut buf := []byte
		for j in 0..15 {
			buf << byte(rand.next(int(`z`) - int(`a`)) + `a`)
		}
		s := string(buf)
		b.set(s, i)
		arr << s
	}
	for i in 0..100000 {
		// println(i)
		b.delete(arr[i])
	}
	assert b.size == 0 
}

fn rnd_test_exists() {
	mut arr := []string
	mut b := btree.new_tree()
	for i in 0..100000 {
		mut buf := []byte
		for j in 0..5 {
			buf << byte(rand.next(int(`z`) - int(`a`)) + `a`)
		}
		s := string(buf)
		b.set(s, i)
		arr << s
	}
	for i in 0..100000 {
		// println(i)
		b.delete(arr[i])
		b.exists(arr[i])
	}
	// println(b.size)
	// assert b.size == 0 
}

fn test_vs_map() {
	mut arr := []string
	mut b := btree.new_tree()
	mut c := map[string]int
	for i in 0..240000 {
		mut buf := []byte
		for j in 0..4 {
			buf << byte(rand.next(int(`z`) - int(`a`)) + `a`)
		}
		s := string(buf)
		b.set(s, i)
		c[s] = i
		arr << s
	}

	assert b.keys().len == c.keys().len
	assert b.size == c.size
	for i in 0..240000 {
		// println(i)
		b.delete(arr[i])
		c.delete(arr[i])
		// b.exists(arr[i])
	}

	// println(b.keys().len)
	// println(b.size)
	// println(c.keys().len)
	// println(c.size)
	assert b.keys().len == c.keys().len
	assert b.size == c.size
}

fn general_test1() {
	mut m := btree.new_tree()
	assert m.size == 0
	m.set('hi', 80)
	m.set('hello', 101)
	assert m.get('hi') == 80
	assert m.get('hello') == 101
	assert m.exists('hi')
	assert m.exists('hello')
	assert m.size == 2
	keys := m.keys()
	assert keys.len == 2
	assert keys[0] == 'hello'
	assert keys[1] == 'hi'
	m.delete('hi')
	assert m.size == 1
	m.delete('aloha')
	assert m.size == 1
	assert m.exists('hi') == false
	assert m.get('hi') == 0
	assert m.keys().len == 1
}

fn general_test2() {
	mut m := btree.new_tree()
	m.set('hi', 12)
	m.delete('hi')
	m.set('hi', 1233)
	m.delete('his')
	assert m.size == 1
	assert m.exists('hi')
	assert m.exists('his') == false
	assert m.get('hi') == 1233
	assert m.keys().len == 1
	assert m.keys()[0] == 'hi'
	assert m.get('hello') == 0
	assert m.exists('hello') == false
	m.set('hi', 1)
	assert m.get('hi') == 1
	m.set('hi', 2)
	assert m.get('hi') == 2
}

fn test_large_map() {
	mut nums := btree.new_tree()
	N := 30 * 1000
	for i := 0; i < N; i++ {
	key := i.str()
		nums.set(key, i)
	}
	assert nums.get('1') == 1
	assert nums.get('999') == 999
	assert nums.get('1500') == 1500
	assert nums.get('10000') == 10000
	assert nums.get('1000000') == 0
}

fn test_delete() {
	mut m := btree.new_tree()
	m.set('one', 1)
	m.set('two', 2)
	m.delete('two')
	assert m.exists('two') == false
	assert m.exists('one')
	assert m.exists('three') == false
	assert m.size == 1
	m.delete('aloha')
	assert m.size == 1
	m.delete('one')
	assert m.size == 0
}	


fn test_exists() {
	mut m := btree.new_tree()
	m.set('one', 1)
	m.set('two', 2)
	m.set('three', 2)
	m.set('four', 2)
	m.set('five', 2)
	assert m.exists('aloha') == false
	assert m.exists('two')
	assert m.exists('what') == false
	assert m.exists('three')
	assert m.exists('hi') == false
	assert m.exists('four')
	assert m.exists('hello') == false
	assert m.exists('five')
	assert m.exists('welcome') == false
	assert m.exists('one')
	m.delete('one')
	assert m.exists('one') == false
	m.delete('two')
	assert m.exists('two') == false
	m.delete('three')
	assert m.exists('three') == false
	m.delete('four')
	assert m.exists('four') == false
	m.delete('five')
	assert m.exists('five') == false
	assert m.size == 0
}



fn main() {
	rnd_test_keys()
	rnd_test_get()
	rnd_test_delete()
	general_test1()
	general_test2()
	test_large_map()
	test_delete()
	test_exists()
	rnd_test_exists()
	test_vs_map()
}