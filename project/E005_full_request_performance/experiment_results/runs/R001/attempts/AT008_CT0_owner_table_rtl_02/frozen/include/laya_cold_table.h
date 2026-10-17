#pragma once

#include <new>
#include <type_traits>

namespace laya::full {

// Used only by the persistent executor's global cold-start construction.
// Ordinary public construction continues to establish every default value.
struct ColdInitTag {};

// Each cell is typed storage with a real C++ union-member lifetime. Cold
// construction leaves its value inactive. initialize() starts that value's
// lifetime with its ordinary constructor; no object bytes or aliasing tricks
// stand in for construction. Callers must finish every cell before any read,
// iteration, copy, or normal lifecycle operation on the table.
template<class T, unsigned N>
class ColdTable {
  static_assert(std::is_trivially_copyable<T>::value,
                "cold tables retain ordinary trivial value-copy semantics");
  static_assert(std::is_trivially_destructible<T>::value,
                "cold table cells require no deferred destruction");
  union Cell {
    T value;
    Cell() {}
  } cells_[N];
public:
  ColdTable() {
    for (unsigned i = 0; i < N; ++i) {
#pragma HLS unroll off
      initialize(i);
    }
  }
  explicit ColdTable(ColdInitTag) {}
  void initialize(unsigned i) {
#pragma HLS inline
    ::new (static_cast<void*>(&cells_[i].value)) T();
  }
  // A nested record may establish metadata now and its own table later.
  void initialize_cold(unsigned i) {
#pragma HLS inline
    ::new (static_cast<void*>(&cells_[i].value)) T(ColdInitTag{});
  }
  T& operator[](unsigned i) { return cells_[i].value; }
  const T& operator[](unsigned i) const { return cells_[i].value; }
  static constexpr unsigned size() { return N; }

  template<bool Const> struct Iterator {
    using Table = typename std::conditional<Const, const ColdTable, ColdTable>::type;
    Table* table;
    unsigned index;
    auto& operator*() const { return (*table)[index]; }
    Iterator& operator++() { ++index; return *this; }
    bool operator!=(const Iterator& other) const { return index != other.index; }
  };
  Iterator<false> begin() { return {this, 0}; }
  Iterator<false> end() { return {this, N}; }
  Iterator<true> begin() const { return {this, 0}; }
  Iterator<true> end() const { return {this, N}; }
};

} // namespace laya::full
