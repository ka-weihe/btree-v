# btree-v

This is an attempt to create a faster and more memory efficient map for V by using a B-tree instead of a BST. Early benchmarks show a speed increase of ~50% (in what I consider a general case) for lookups and inserts while keeping memory reduced by 50%. These benchmarks are extremely primitive, so take them with a grain of salt. This implementation currently only accepts strings for keys and ints for values. I expect that this implementation will be at least twice as fast, compared to the current map in V - for integral-types. B-trees are faster due to their cache-friendliness, however, they are not faster when keys become incredibly big 128+ characters. But I would argue that the average string in a map would be 20-30 characters (where btree-v is 50% faster). Integral-types are also common keys in maps (where btree-v is going to be at least 200% faster - I expect 1000% faster). Remember this is work in progress! Lower is better in the graph.

![Benchmark](/search.PNG)
