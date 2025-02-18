#ifndef TEST_INTEROP_CXX_FOREIGN_REFERENCE_INPUTS_MOVE_ONLY_H
#define TEST_INTEROP_CXX_FOREIGN_REFERENCE_INPUTS_MOVE_ONLY_H

#include <stdlib.h>
#if defined(_WIN32)
inline void *operator new(size_t, void *p) { return p; }
#else
#include <new>
#endif

#include "visibility.h"

template <class _Tp>
_Tp &&move(_Tp &t) {
  return static_cast<_Tp &&>(t);
}

SWIFT_BEGIN_NULLABILITY_ANNOTATIONS

struct __attribute__((swift_attr("import_reference"))) MoveOnly {
  MoveOnly() = default;
  MoveOnly(const MoveOnly &) = delete;
  MoveOnly(MoveOnly &&) = default;

  int test() const { return 42; }
  int testMutable() { return 42; }

  static MoveOnly *create() {
    return new (malloc(sizeof(MoveOnly))) MoveOnly();
  }
};

MoveOnly moveIntoResult(MoveOnly &x) { return move(x); }

struct __attribute__((swift_attr("import_reference"))) NoCopyMove {
  NoCopyMove() = default;
  NoCopyMove(const NoCopyMove &) = delete;
  NoCopyMove(NoCopyMove &&) = delete;

  int test() const { return 42; }
  int testMutable() { return 42; }

  static NoCopyMove *create() {
    return new (malloc(sizeof(NoCopyMove))) NoCopyMove();
  }
};

struct __attribute__((swift_attr("import_reference"))) HasMoveOnlyChild {
  MoveOnly child;

  static HasMoveOnlyChild *create() {
    return new (malloc(sizeof(HasMoveOnlyChild))) HasMoveOnlyChild();
  }
};

HasMoveOnlyChild moveIntoResult(HasMoveOnlyChild &x) { return move(x); }

struct __attribute__((swift_attr("import_reference"))) PrivateCopyCtor {
  PrivateCopyCtor() = default;
  PrivateCopyCtor(PrivateCopyCtor &&) = default;

  int test() const { return 42; }
  int testMutable() { return 42; }

  static PrivateCopyCtor *create() {
    return new (malloc(sizeof(PrivateCopyCtor))) PrivateCopyCtor();
  }

private:
  PrivateCopyCtor(const PrivateCopyCtor &) {}
};

PrivateCopyCtor moveIntoResult(PrivateCopyCtor &x) { return move(x); }

struct __attribute__((swift_attr("import_reference"))) BadCopyCtor {
  BadCopyCtor() = default;
  BadCopyCtor(BadCopyCtor &&) = default;
  BadCopyCtor(const BadCopyCtor &) { __builtin_trap(); }

  int test() const { return 42; }
  int testMutable() { return 42; }

  static BadCopyCtor *create() {
    return new (malloc(sizeof(BadCopyCtor))) BadCopyCtor();
  }
};

BadCopyCtor moveIntoResult(BadCopyCtor &x) { return move(x); }

SWIFT_END_NULLABILITY_ANNOTATIONS

#endif // TEST_INTEROP_CXX_FOREIGN_REFERENCE_INPUTS_MOVE_ONLY_H
