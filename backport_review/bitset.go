package main

type BitSet uint64

func (bs *BitSet) Set(index int) {
	idx := uint(index)
	if idx > 63 {
		panic("Bitset can't handle more than 64 entries")
	}
	var v uint64 = 1
	*bs |= BitSet(v << idx)
}

func (bs *BitSet) Clear(index int) {
	idx := uint(index)
	if idx > 63 {
		panic("Bitset can't handle more than 64 entries")
	}
	var v uint64 = 1
	*bs &= BitSet(^(v << idx))
}

func (bs *BitSet) IsSet(index int) bool {
	idx := uint(index)
	var v uint64 = 1
	return (*bs & BitSet((v << idx))) != 0
}
