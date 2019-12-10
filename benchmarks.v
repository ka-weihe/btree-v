import btree
import rand
import time

fn btree_set_bench(arr []string, repeat int) {
	start_time := time.ticks()
	for _ in 0..repeat {
		mut b := btree.new_tree()
		for x in arr {
			b.set(x, 1)
		}
	}
	end_time := time.ticks() - start_time
	string_len := arr[0].len
	println("btree_set_bench_$string_len: $end_time")
}

fn map_set_bench(arr []string, repeat int) {
	start_time := time.ticks()
	for _ in 0..repeat {
		mut b := map[string]int
		for x in arr {
			b[x] = 1
		}
	}
	end_time := time.ticks() - start_time
	string_len := arr[0].len
	println("map_set_bench_$string_len:   $end_time")
}

fn btree_get_bench(arr []string, repeat int) {
	mut b := btree.new_tree()
	for x in arr {
		b.set(x, 1)
	}
	start_time := time.ticks()
	for _ in 0..repeat {
		for x in arr {
			b.get(x)
		}
	}
	end_time := time.ticks() - start_time
	string_len := arr[0].len
	println("btree_get_bench_$string_len: $end_time")
}

fn map_get_bench(arr []string, repeat int) {
	mut b := map[string]int
	for x in arr {
		b[x] = 1
	}
	start_time := time.ticks()
	for _ in 0..repeat {
		for x in arr {
			b[x]
		}
	}
	end_time := time.ticks() - start_time
	string_len := arr[0].len
	println("map_get_bench_$string_len:   $end_time")
}

fn benchmark_strings() {
	for i := 1; i < 1025; i = i * 2 {
		mut arr := []string
		for _ in 0..10000 {
			mut buf := []byte
			for j in 0..i {
				buf << byte(rand.next(int(`z`) - int(`a`)) + `a`)
			}
			s := string(buf)
			arr << s
		}
		map_set_bench(arr, 10)
		btree_set_bench(arr, 10)
		map_get_bench(arr, 10)
		btree_get_bench(arr, 10)
	}
}

fn benchmark_nums() {
	mut arr := []string
	for i in 0..10000 {
		arr << i.str()
	}
	map_get_bench(arr, 10)
	btree_get_bench(arr, 10)
	map_set_bench(arr, 10)
	btree_set_bench(arr, 10)
}



fn main() {
	benchmark_strings()
	benchmark_nums()
}