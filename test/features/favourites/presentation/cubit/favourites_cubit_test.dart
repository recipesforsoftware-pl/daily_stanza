import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/favourites/domain/repository/favourites_repository.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

class MockPoemRepository extends Mock implements PoemRepository {}

const _poemA = Poem(
  id: 'a',
  title: 'Poem A',
  author: 'Author A',
  languageCode: 'en',
  countryCode: 'US',
  content: 'Content of poem A.',
  sourceName: 'Source',
  sourceUrl: 'https://example.com/a',
  rightsStatus: 'public_domain',
);

const _poemB = Poem(
  id: 'b',
  title: 'Poem B',
  author: 'Author B',
  languageCode: 'pl',
  countryCode: 'PL',
  content: 'Content of poem B.',
  sourceName: 'Source',
  sourceUrl: 'https://example.com/b',
  rightsStatus: 'public_domain',
);

void main() {
  late MockFavouritesRepository mockFavouritesRepo;
  late MockPoemRepository mockPoemRepo;

  setUpAll(() {
    registerFallbackValue(_poemA);
  });

  setUp(() {
    mockFavouritesRepo = MockFavouritesRepository();
    mockPoemRepo = MockPoemRepository();
  });

  group('FavouritesCubit', () {
    blocTest<FavouritesCubit, FavouritesState>(
      'initial load emits loading then loaded-empty',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => []);
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having((s) => s.poems, 'poems', isEmpty),
      ],
      verify: (_) {
        verify(() => mockFavouritesRepo.getFavouritePoemIds()).called(1);
      },
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'initial load returns stored favourites',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a', 'b']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA, _poemB]);
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>()
            .having((s) => s.poems.length, 'poems.length', 2)
            .having((s) => s.favouriteIds, 'favouriteIds', {'a', 'b'}),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'getPoemsByIds receives the stored IDs',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      verify: (_) {
        verify(() => mockPoemRepo.getPoemsByIds(['a'])).called(1);
      },
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'loaded poems preserve saved-ID order',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['b', 'a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA, _poemB]);
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having(
          (s) => s.poems.map((p) => p.id).toList(),
          'poem order',
          ['b', 'a'],
        ),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'missing poem documents do not crash the cubit',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a', 'missing']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having(
          (s) => s.poems.length,
          'only found poems',
          1,
        ),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'adding a poem updates favouriteIds and poems',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
        when(
          () => mockFavouritesRepo.addFavourite(any()),
        ).thenAnswer((_) async {});
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        await cubit.addFavourite(_poemB);
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having(
          (s) => s.favouriteIds,
          'initial favIds',
          {'a'},
        ),
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating', {
          'b',
        }),
        isA<FavouritesLoaded>()
            .having((s) => s.favouriteIds, 'favouriteIds', {'a', 'b'})
            .having((s) => s.poems.length, 'poems.length', 2),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'adding the same poem twice does not duplicate it',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
        when(
          () => mockFavouritesRepo.addFavourite(any()),
        ).thenAnswer((_) async {});
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        await cubit.addFavourite(_poemB);
        await cubit.addFavourite(_poemB);
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having((s) => s.favouriteIds, 'initial', {'a'}),
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating', {
          'b',
        }),
        isA<FavouritesLoaded>()
            .having((s) => s.favouriteIds, 'after add', {'a', 'b'})
            .having((s) => s.poems.length, 'length', 2),
      ],
      verify: (_) {
        verify(() => mockFavouritesRepo.addFavourite('b')).called(1);
      },
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'removing a poem updates favouriteIds and poems',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a', 'b']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA, _poemB]);
        when(
          () => mockFavouritesRepo.removeFavourite(any()),
        ).thenAnswer((_) async {});
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        await cubit.removeFavourite('a');
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having(
          (s) => s.favouriteIds,
          'initial favIds',
          {'a', 'b'},
        ),
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating', {
          'a',
        }),
        isA<FavouritesLoaded>()
            .having((s) => s.favouriteIds, 'favouriteIds after remove', {'b'})
            .having((s) => s.poems.length, 'poems.length', 1),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'repository exceptions map to failure on initial load',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenThrow(Exception('io error'));
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      expect: () => [isA<FavouritesLoading>(), isA<FavouritesFailure>()],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'retry after failure reloads successfully',
      setUp: () {
        var callCount = 0;
        when(() => mockFavouritesRepo.getFavouritePoemIds()).thenAnswer((
          _,
        ) async {
          callCount++;
          if (callCount == 1) throw Exception('first fail');
          return [];
        });
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        await cubit.loadFavourites();
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesFailure>(),
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having((s) => s.poems, 'poems', isEmpty),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'poem loading failure preserves stored favourite IDs',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a', 'b']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenThrow(Exception('poem fetch failed'));
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>()
            .having((s) => s.poems, 'poems', isEmpty)
            .having((s) => s.favouriteIds, 'stored IDs preserved', {'a', 'b'})
            .having((s) => s.mutationError, 'no mutation error', isNull),
      ],
      verify: (_) {
        verify(() => mockFavouritesRepo.getFavouritePoemIds()).called(1);
        verify(() => mockPoemRepo.getPoemsByIds(['a', 'b'])).called(1);
      },
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'addFavourite failure emits loaded state with mutation error',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
        when(
          () => mockFavouritesRepo.addFavourite(any()),
        ).thenThrow(Exception('fail'));
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        await cubit.addFavourite(_poemB);
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having((s) => s.favouriteIds, 'initial', {'a'}),
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating', {
          'b',
        }),
        isA<FavouritesLoaded>()
            .having((s) => s.favouriteIds, 'favIds unchanged', {'a'})
            .having((s) => s.mutationError, 'has error', isNotNull),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'removeFavourite failure emits loaded state with mutation error',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a', 'b']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA, _poemB]);
        when(
          () => mockFavouritesRepo.removeFavourite(any()),
        ).thenThrow(Exception('fail'));
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        await cubit.removeFavourite('a');
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having((s) => s.favouriteIds, 'initial', {
          'a',
          'b',
        }),
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating', {
          'a',
        }),
        isA<FavouritesLoaded>()
            .having((s) => s.favouriteIds, 'favIds unchanged', {'a', 'b'})
            .having((s) => s.mutationError, 'has error', isNotNull),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'two consecutive mutation failures both carry mutationError',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
        when(
          () => mockFavouritesRepo.addFavourite(any()),
        ).thenThrow(Exception('fail'));
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        await cubit.addFavourite(_poemB);
        await cubit.addFavourite(_poemB);
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having((s) => s.favouriteIds, 'initial', {'a'}),
        // First add: updating
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating 1', {
          'b',
        }),
        // First add: failure with error
        isA<FavouritesLoaded>().having(
          (s) => s.mutationError,
          'error 1',
          isNotNull,
        ),
        // Second add: guard passes again (updatingPoemIds cleared by error state)
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating 2', {
          'b',
        }),
        // Second add: failure with error
        isA<FavouritesLoaded>().having(
          (s) => s.mutationError,
          'error 2',
          isNotNull,
        ),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'mutationError is cleared after a subsequent successful mutation',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
        when(
          () => mockFavouritesRepo.addFavourite(any()),
        ).thenAnswer((_) async {});
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) async {
        await cubit.loadFavourites();
        // First add succeeds
        await cubit.addFavourite(_poemB);
        // If the failure had occurred, mutationError would be set;
        // after a success it must be null
      },
      expect: () => [
        isA<FavouritesLoading>(),
        isA<FavouritesLoaded>().having((s) => s.favouriteIds, 'initial', {'a'}),
        isA<FavouritesLoaded>().having((s) => s.updatingPoemIds, 'updating', {
          'b',
        }),
        isA<FavouritesLoaded>()
            .having((s) => s.favouriteIds, 'after add', {'a', 'b'})
            .having((s) => s.mutationError, 'no error', isNull),
      ],
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'isFavourite reflects the current state',
      setUp: () {
        when(
          () => mockFavouritesRepo.getFavouritePoemIds(),
        ).thenAnswer((_) async => ['a']);
        when(
          () => mockPoemRepo.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_poemA]);
      },
      build: () => FavouritesCubit(
        favouritesRepository: mockFavouritesRepo,
        poemRepository: mockPoemRepo,
      ),
      act: (cubit) => cubit.loadFavourites(),
      verify: (cubit) {
        expect(cubit.isFavourite('a'), isTrue);
        expect(cubit.isFavourite('b'), isFalse);
      },
    );
  });
}
