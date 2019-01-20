import 'package:example/src/generator_example.dart';
import 'package:mobx/mobx.dart';
import 'package:test/test.dart';

void main() {
  void testStoreBasics(String name, User Function() createStore) {
    group(name, () {
      test('@observable works', () {
        final user = createStore();

        var firstName = '';

        autorun((_) {
          firstName = user.firstName;
        });

        expect(firstName, equals('Jane'));

        user.firstName = 'Jill';
        expect(firstName, equals('Jill'));
      });

      test('@computed works', () {
        final user = createStore();

        var fullName = '';

        autorun((_) {
          fullName = user.fullName;
        });

        expect(fullName, equals('Jane Doe'));

        user.firstName = 'John';
        expect(fullName, equals('John Doe'));

        user.lastName = 'Addams';
        expect(fullName, equals('John Addams'));
      });

      test('@action works', () {
        final user = createStore();

        var runCount = 0;
        var fullName = '';

        autorun((_) {
          runCount++;
          fullName = user.fullName;
        });

        expect(fullName, equals('Jane Doe'));
        expect(runCount, equals(1));

        user.updateNames(firstName: 'John', lastName: 'Johnson');
        expect(fullName, equals('John Johnson'));
        expect(runCount, equals(2));
      });
    });
  }

  ({'User': () => User(1), 'Admin': () => Admin(1)}).forEach(testStoreBasics);

  test('Admins new generated field works', () {
    final admin = Admin(1);

    var userName = '';
    autorun((_) => userName = admin.userName);

    expect(userName, equals('admin'));

    admin.userName = 'root';
    expect(userName, equals('root'));
  });
}
