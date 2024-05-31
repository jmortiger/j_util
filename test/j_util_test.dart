import 'package:j_util/j_util.dart';
import 'package:test/test.dart';

void main() {
  // group('A group of tests', () {
  //   final awesome = Awesome();
  //   setUp(() {
  //     // Additional setup goes here.
  //   });
  //   test('First Test', () {
  //     expect(awesome.isAwesome, isTrue);
  //   });
  // });
  group("List Extensions", () {
    late List<int> l0To4growable;
    late List<int> l5To9growable;
    late List<int> l0To4notGrowable;
    late List<int> l5To9notGrowable;
    setUp(() {
      l0To4growable = List<int>.generate(5, (index) => index, growable: true);
      l0To4notGrowable = List<int>.generate(5, (index) => index, growable: false);
      l5To9growable = List<int>.generate(5, (index) => index + 5, growable: true);
      l5To9notGrowable =
          List<int>.generate(5, (index) => index + 5, growable: false);
      assert([0, 1, 2, 3, 4].toString() == l0To4growable.toString());
      assert([0, 1, 2, 3, 4].toString() == l0To4notGrowable.toString());
      assert([5, 6, 7, 8, 9].toString() == l5To9growable.toString());
      assert([5, 6, 7, 8, 9].toString() == l5To9notGrowable.toString());
    });
    group("List.filter extension", () {
      test("Don't Mutate Non Growable", () {
        expect(l0To4notGrowable.filter((e, i, list) => e % 2 == 0), [0, 2, 4]);
      });
      test("Mutate Growable; fail silently", () {
        var ret = l0To4growable.filter((e, i, list) => e % 2 == 0, mutate: true, failSilently: true);
        expect(ret, [0, 2, 4]);
        expect(l0To4growable, [0, 2, 4]);
        expect(l0To4growable, isNot(same(ret)));
      });
      test("Mutate Growable; don't fail silently", () {
        var ret = l0To4growable.filter((e, i, list) => e % 2 == 0, mutate: true, failSilently: false);
        expect(ret, [0, 2, 4]);
        expect(l0To4growable, [0, 2, 4]);
        expect(l0To4growable, same(ret));
      });
      test("Mutate Non Growable; fail silently", () {
        expect(l0To4notGrowable.filter((e, i, list) => e % 2 == 0, mutate: true, failSilently: true), [0, 2, 4]);
      });
    });
  });
}
