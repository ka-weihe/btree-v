module btree

// B-trees are balanced search trees with all leaves
// at the same level. B-trees are generally faster than 
// binary search trees due to the better locality of 
// reference, since multiple keys are stored in one node.

// The number for `degree` has been picked
// through vigorous benchmarking, but can be changed
// to any number > 1. `degree` determines the size
// of each node.
const (
	degree = 6
	mid_index = degree - 1
	max_length = 11// should be 2 * degree - 1
	min_length = degree - 1
	children_size = sizeof(voidptr) * (max_length + 1)
)

// Since a very large portion of the nodes are 
// leaves (has no children), a lot of memory 
// is saved by dynamically allocating memory for
// children.
struct Bnode {
mut:
	keys     [max_length]string
	values   [max_length]int
	children &voidptr
	size     int
}

struct Tree {
mut:
	root &Bnode
pub mut:
	size int
}

fn new_bnode() &Bnode {
	return &Bnode {
		children: 0
		size: 0
	}
}

// The tree is initialized with an empty node
// as root - to avoid having to check whether 
// the root is null for each insertion.
pub fn new_tree() Tree {
	return Tree {
		root: new_bnode()
		size: 0
	}
}

// This implementation does proactive insertion,
// meaning that splits are done top-down and not
// bottom-up. 
pub fn (t mut Tree) set(key string, value int) {
	mut node := t.root
	mut child_index := 0
	mut parent := &Bnode(0)
	for {
		if node.size == max_length {
			if parent == 0 {
				parent = new_bnode()
				t.root = parent
			}
			parent.split_child(child_index, mut node)
			if key == parent.keys[child_index] {
				parent.values[child_index] = value
				return
			}
			node = if key < parent.keys[child_index] {
				&Bnode(parent.children[child_index])
			} else {
				&Bnode(parent.children[child_index + 1])
			}
		}
		mut i := 0
		for i < node.size && key > node.keys[i] { i++ }
		if i != node.size && key == node.keys[i] {
			node.values[i] = value
			return
		}
		if node.children == 0 {
			mut j := node.size - 1
			for j >= 0 && key < node.keys[j] {
				node.keys[j + 1] = node.keys[j]
				node.values[j + 1] = node.values[j]
				j--
			}
			node.keys[j + 1] = key
			node.values[j + 1] = value
			node.size++
			t.size++
			return
		}
		parent = node
		child_index = i
		node = &Bnode(node.children[child_index])
	}
}

fn (n mut Bnode) split_child(child_index int, y mut Bnode) {
	mut z := new_bnode()
	z.size = mid_index
	y.size = mid_index
	for j := mid_index - 1; j >= 0; j-- {
		z.keys[j] = y.keys[j + degree]
		z.values[j] = y.values[j + degree]
	}
	if y.children != 0 {
		z.children = &voidptr(malloc(children_size))
		for j := degree - 1; j >= 0; j-- {
			z.children[j] = y.children[j + degree]
		}
	}
	if n.children == 0 {
		n.children = &voidptr(malloc(children_size))
	}
	n.children[n.size + 1] = n.children[n.size]
	for j := n.size; j > child_index; j-- {
		n.keys[j] = n.keys[j - 1]
		n.values[j] = n.values[j - 1]
		n.children[j] = n.children[j - 1]
	}
	n.keys[child_index] = y.keys[mid_index]
	n.values[child_index] = y.values[mid_index]
	n.children[child_index] = voidptr(y)
	n.children[child_index + 1] = voidptr(z)
	n.size++
}

pub fn (t Tree) get(key string) int {
	mut node := t.root
	for {
		mut i := node.size - 1
		for i >= 0 && key < node.keys[i] { i-- }
		if i != -1 && key == node.keys[i] {
			return node.values[i]
		}
		if node.children == 0 {
			break
		}
		node = &Bnode(node.children[i + 1])
	}
	return 0
}

pub fn (t Tree) exists(key string) bool {
	mut node := t.root
	for {
		mut i := node.size - 1
		for i >= 0 && key < node.keys[i] { i-- }
		if i != -1 && key == node.keys[i] {
			return true
		}
		if node.children == 0 {
			break
		}
		node = &Bnode(node.children[i + 1])
	}
	return false
}

fn (n Bnode) find_key(k string) int { 
	mut idx := 0
	for idx < n.size && n.keys[idx] < k {
		idx++
	}
	return idx
}

fn (n mut Bnode) remove_key(k string) bool {
	idx := n.find_key(k)
	if idx < n.size && n.keys[idx] == k {
		if n.children == 0 {
			n.remove_from_leaf(idx)
		} else {
			n.remove_from_non_leaf(idx)
		}
		return true
	} else {
		if n.children == 0 {
			return false
		}
		flag := if idx == n.size {true} else {false}
		if (&Bnode(n.children[idx])).size < degree {
			n.fill(idx)
		}

		if flag && idx > n.size {
			return (&Bnode(n.children[idx - 1])).remove_key(k)
		} else {
			return (&Bnode(n.children[idx])).remove_key(k)
		}
	}
}

fn (n mut Bnode) remove_from_leaf(idx int) {
	for i := idx + 1; i < n.size; i++ {
		n.keys[i - 1] = n.keys[i]
		n.values[i - 1] = n.values[i]
	}
	n.size--
}

fn (n mut Bnode) remove_from_non_leaf(idx int) {
	k := n.keys[idx]
	if &Bnode(n.children[idx]).size >= degree {
		mut current := &Bnode(n.children[idx])
		for current.children != 0 {
			current = &Bnode(current.children[current.size])
		}
		predecessor := current.keys[current.size - 1]
		n.keys[idx] = predecessor 
		n.values[idx] = current.values[current.size - 1]
		(&Bnode(n.children[idx])).remove_key(predecessor)
	} else if &Bnode(n.children[idx + 1]).size >= degree {
		mut current := &Bnode(n.children[idx + 1])
		for current.children != 0 {
			current = &Bnode(current.children[0])
		}
		successor := current.keys[0]
		n.keys[idx] = successor
		n.values[idx] = current.values[0]
		(&Bnode(n.children[idx + 1])).remove_key(successor)
	} else {
		n.merge(idx)
		(&Bnode(n.children[idx])).remove_key(k)
	}
}

fn (n mut Bnode) fill(idx int) {
	if idx != 0 && &Bnode(n.children[idx - 1]).size >= degree {
		n.borrow_from_prev(idx)
	} else if idx != n.size && &Bnode(n.children[idx + 1]).size >= degree {
		n.borrow_from_next(idx)
	} else if idx != n.size {
		n.merge(idx)
	} else {
		n.merge(idx - 1)
	}
}

fn (n mut Bnode) borrow_from_prev(idx int) {
	mut child := &Bnode(n.children[idx])
	mut sibling := &Bnode(n.children[idx - 1])
	for i := child.size - 1; i >= 0; i-- {
		child.keys[i + 1] = child.keys[i] 
		child.values[i + 1] = child.values[i] 
	}
	if child.children != 0 { 
		for i := child.size; i >= 0; i-- {
			child.children[i + 1] = child.children[i] 
		}
	}
	child.keys[0] = n.keys[idx - 1] 
	child.values[0] = n.values[idx - 1] 
	if child.children != 0 {
		child.children[0] = sibling.children[sibling.size]
	}
	n.keys[idx - 1] = sibling.keys[sibling.size - 1]
	n.values[idx - 1] = sibling.values[sibling.size - 1]
	child.size++ 
	sibling.size-- 
}

fn (n mut Bnode) borrow_from_next(idx int) {
	mut child := &Bnode(n.children[idx])
	mut sibling := &Bnode(n.children[idx + 1])
	child.keys[child.size] = n.keys[idx]
	child.values[child.size] = n.values[idx]
	if child.children != 0 {
		child.children[child.size + 1] = sibling.children[0]
	}
	n.keys[idx] = sibling.keys[0]
	n.values[idx] = sibling.values[0]
	for i := 1; i < sibling.size; i++ {
		sibling.keys[i - 1] = sibling.keys[i]
		sibling.values[i - 1] = sibling.values[i]
	}
	if sibling.children != 0 {
		for i := 1; i <= sibling.size; i++ {
			sibling.children[i - 1] = sibling.children[i]
		}
	}
	child.size++
	sibling.size--
}

fn (n mut Bnode) merge(idx int) {
	mut child := &Bnode(n.children[idx])
	sibling := &Bnode(n.children[idx + 1])
	child.keys[min_length] = n.keys[idx]
	child.values[min_length] = n.values[idx]
	for i := 0; i < sibling.size; i++ {
		child.keys[i + degree] = sibling.keys[i]
		child.values[i + degree] = sibling.values[i]
	}
	if child.children != 0 {
		for i := 0; i <= sibling.size; i++ {
			child.children[i + degree] = sibling.children[i]
		}
	}
	for i := idx + 1; i < n.size; i++ {
		n.keys[i - 1] = n.keys[i]
		n.values[i - 1] = n.values[i]
	}
	for i := idx + 2; i <= n.size; i++ {
		n.children[i - 1] = n.children[i]
	}
	child.size += sibling.size + 1
	n.size--
	// free(sibling)
}

pub fn (t mut Tree) delete(k string) {
	if t.root.size == 0 {
		return
	}

	removed := t.root.remove_key(k)
	if removed {
		t.size--
	}
	
	if t.root.size == 0 {
		// tmp := t.root
		if t.root.children ==  0 {
			return
		} else {
			t.root = &Bnode(t.root.children[0])
		}
		// free(tmp)
	}
}

fn (n Bnode) free() {
	if !isnil(n.children) {
		for i in 0..n.size + 1 {
			&Bnode(n.children[i]).free()
		}
	}
	// free(n.children)
	// free(n)
}

pub fn (t Tree) free() {
	if isnil(t.root) {
		return
	}
	t.root.free()
	// free(t.root)
}

// Insert all keys of the subtree into array `keys`
// starting at `at`. Keys are inserted in order. 
fn (n Bnode) subkeys(keys mut []string, at int) int {
	mut position := at
	if (n.children != 0) {
		// Traverse children and insert
		// keys inbetween children
		for i in 0..n.size {
			child := &Bnode(n.children[i])
			position += child.subkeys(mut keys, position)
			keys[position] = n.keys[i]
			position++
		}
		// Insert the keys of the last child
		child := &Bnode(n.children[n.size])
		position += child.subkeys(mut keys, position)
	} else {
		// If leaf, insert keys
		for i in 0..n.size {
			keys[position + i] = n.keys[i]
		}
		position += n.size
	}
	// Return # of added keys
	return position - at
}

pub fn (t Tree) keys() []string {
	mut keys := [''].repeat(t.size)
	if (t.root.size == 0) {
		return keys
	}
	t.root.subkeys(mut keys, 0)
	return keys
}
