import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/app.dart';
import 'package:daily_stanza/features/daily_poem/data/datasource/firestore_poem_data_source.dart';
import 'package:daily_stanza/features/daily_poem/data/repository/poem_repository_impl.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/favourites/data/datasource/local_favourites_data_source.dart';
import 'package:daily_stanza/features/favourites/data/repository/favourites_repository_impl.dart';
import 'package:daily_stanza/features/favourites/domain/repository/favourites_repository.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/settings/data/datasource/local_language_preferences_data_source.dart';
import 'package:daily_stanza/features/settings/data/repository/language_preferences_repository_impl.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'demo-key',
      appId: '1:000000000000:web:0000000000000000',
      messagingSenderId: '000000000000',
      projectId: 'demo-daily-stanza',
    ),
  );

  if (kDebugMode) {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2:8080'
        : 'localhost:8080';
    FirebaseFirestore.instance.settings = Settings(
      host: host,
      sslEnabled: false,
      persistenceEnabled: true,
    );
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final dataSource = FirestorePoemDataSource();
  final poemRepository = PoemRepositoryImpl(dataSource: dataSource);
  final localDataSource = LocalFavouritesDataSource(
    sharedPreferences: sharedPreferences,
  );
  final favouritesRepository = FavouritesRepositoryImpl(
    dataSource: localDataSource,
  );

  final languagePreferencesDataSource = LocalLanguagePreferencesDataSource(
    sharedPreferences: sharedPreferences,
  );
  final languagePreferencesRepository = LanguagePreferencesRepositoryImpl(
    dataSource: languagePreferencesDataSource,
  );
  PoemLanguage initialLanguage;
  try {
    initialLanguage = await languagePreferencesRepository
        .getPreferredLanguage();
  } catch (_) {
    initialLanguage = PoemLanguage.english;
  }

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PoemRepository>.value(value: poemRepository),
        RepositoryProvider<FavouritesRepository>.value(
          value: favouritesRepository,
        ),
        RepositoryProvider<LanguagePreferencesRepository>.value(
          value: languagePreferencesRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FavouritesCubit>(
            create: (_) => FavouritesCubit(
              favouritesRepository: favouritesRepository,
              poemRepository: poemRepository,
            )..loadFavourites(),
          ),
          BlocProvider<LanguagePreferencesCubit>(
            create: (_) => LanguagePreferencesCubit(
              repository: languagePreferencesRepository,
              initialLanguage: initialLanguage,
            ),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<FavouritesCubit, FavouritesState>(
              listenWhen: (previous, current) {
                final previousError = switch (previous) {
                  FavouritesLoaded(:final mutationError) => mutationError,
                  _ => null,
                };
                final currentError = switch (current) {
                  FavouritesLoaded(:final mutationError) => mutationError,
                  _ => null,
                };
                return currentError != null && currentError != previousError;
              },
              listener: (context, state) {
                final error = switch (state) {
                  FavouritesLoaded(:final mutationError) => mutationError,
                  _ => null,
                };
                if (error == null) return;
                scaffoldMessengerKey.currentState
                  ?..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(error)));
              },
            ),
            BlocListener<LanguagePreferencesCubit, LanguagePreferencesState>(
              listenWhen: (previous, current) {
                return current.mutationError != null &&
                    current.mutationError != previous.mutationError;
              },
              listener: (context, state) {
                final error = state.mutationError;
                if (error == null) return;
                scaffoldMessengerKey.currentState
                  ?..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(error)));
              },
            ),
          ],
          child: App(scaffoldMessengerKey: scaffoldMessengerKey),
        ),
      ),
    ),
  );
}
