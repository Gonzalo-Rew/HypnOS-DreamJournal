# Feature Implementation Pattern Guide

## Objetivo
Guía rápida para implementar nuevas features siguiendo el Repository Pattern y Feature-based modularization establecido en Hypnos.

---

## Template: Implementar nueva feature

### 1. Definir el dominio (data/models/)
```dart
// lib/data/models/feature_model.dart
class MyFeature {
  final String id;
  final String userId;
  final DateTime createdAt;

  MyFeature({
    required this.id,
    required this.userId,
    required this.createdAt,
  });

  factory MyFeature.fromFirestore(Map<String, dynamic> data, String id) {
    return MyFeature(
      id: id,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}
```

### 2. Definir la interfaz del repositorio (data/repositories/)
```dart
// lib/data/repositories/my_feature_repository.dart
abstract class MyFeatureRepository {
  /// Create a new feature entry
  Future<Result<MyFeature>> create({required MyFeature feature});

  /// Get feature by ID
  Future<Result<MyFeature>> getById({required String id});

  /// Get all features for user
  Future<Result<List<MyFeature>>> getByUser({required String userId});

  /// Stream real-time updates
  Stream<List<MyFeature>> streamByUser({required String userId});

  /// Update feature
  Future<Result<void>> update({required MyFeature feature});

  /// Delete feature
  Future<Result<void>> delete({required String id});
}
```

### 3. Implementar el repositorio
```dart
// lib/data/repositories/my_feature_repository.dart (continuación)
class MyFeatureRepositoryImpl implements MyFeatureRepository {
  final FirebaseFirestore _firestore;
  static const _collectionPath = 'my_features';

  MyFeatureRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore;

  @override
  Future<Result<MyFeature>> create({required MyFeature feature}) async {
    try {
      final docRef = await _firestore
          .collection(_collectionPath)
          .add(feature.toFirestore());
      return Success(feature.copyWith(id: docRef.id));
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed: $e'));
    }
  }

  // ... implementar otros métodos
}
```

### 4. Crear feature module (features/my_feature/)
```
features/my_feature/
├── models/              # DTOs específicos de UI
├── pages/               # Pantallas principales
│   ├── list_page.dart
│   ├── detail_page.dart
│   └── create_page.dart
├── providers/           # State management con Provider
│   ├── my_feature_provider.dart
│   └── my_feature_state.dart
└── widgets/             # Componentes reutilizables
    ├── my_feature_card.dart
    └── my_feature_form.dart
```

### 5. Crear Provider para state management
```dart
// lib/features/my_feature/providers/my_feature_provider.dart
import 'package:provider/provider.dart';

/// Provider para la lista de features
final myFeaturesProvider = FutureProvider.family<List<MyFeature>, String>(
  (ref, userId) async {
    final repository = ref.watch(myFeatureRepositoryProvider);
    final result = await repository.getByUser(userId: userId);
    return result.getOrNull() ?? [];
  },
);

/// Provider para el repositorio
final myFeatureRepositoryProvider = Provider<MyFeatureRepository>(
  (ref) => MyFeatureRepositoryImpl(),
);

/// Provider para notificador de estado
final myFeatureNotifierProvider = 
  StateNotifierProvider<MyFeatureNotifier, MyFeatureState>(
    (ref) => MyFeatureNotifier(ref.watch(myFeatureRepositoryProvider)),
  );

class MyFeatureNotifier extends StateNotifier<MyFeatureState> {
  final MyFeatureRepository _repository;

  MyFeatureNotifier(this._repository) : super(const MyFeatureState.initial());

  Future<void> create(MyFeature feature) async {
    state = const MyFeatureState.loading();
    final result = await _repository.create(feature: feature);
    state = result.map(
      (_) => const MyFeatureState.success(),
      (error) => MyFeatureState.error(error),
    );
  }
}

class MyFeatureState {
  // Usar freezed para inmutabilidad
  const MyFeatureState({
    this.status = Status.initial,
    this.data,
    this.error,
  });

  const MyFeatureState.initial() : this(status: Status.initial);
  const MyFeatureState.loading() : this(status: Status.loading);
  const MyFeatureState.success() : this(status: Status.success);
  MyFeatureState.error(Exception error) 
    : this(status: Status.error, error: error);

  final Status status;
  final MyFeature? data;
  final Exception? error;

  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
}

enum Status { initial, loading, success, error }
```

### 6. Crear página principal
```dart
// lib/features/my_feature/pages/list_page.dart
class MyFeatureListPage extends ConsumerWidget {
  const MyFeatureListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Features')),
        body: Center(child: Text('Not authenticated')),
      );
    }

    final featuresAsync = ref.watch(myFeaturesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Features'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyFeatureCreatePage(),
              ),
            ),
          ),
        ],
      ),
      body: featuresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (features) => ListView.builder(
          itemCount: features.length,
          itemBuilder: (context, index) => MyFeatureCard(
            feature: features[index],
          ),
        ),
      ),
    );
  }
}
```

### 7. Crear widget reutilizable
```dart
// lib/features/my_feature/widgets/my_feature_card.dart
class MyFeatureCard extends StatelessWidget {
  final MyFeature feature;

  const MyFeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(feature.id),
        subtitle: Text(feature.createdAt.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Navigate to detail page
          },
        ),
      ),
    );
  }
}
```

### 8. Registrar en el router de la app
```dart
// lib/app/router.dart (a crear)
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/features',
      builder: (context, state) => const MyFeatureListPage(),
    ),
  ],
);
```

---

## Patrón de error handling

### En repositorio
```dart
Future<Result<T>> myOperation() async {
  try {
    // Validar input
    if (input == null) {
      throw ValidationException(message: 'Input required');
    }

    // Ejecutar operación
    final result = await _firestore.collection('...').get();

    return Success(result);
  } on ValidationException catch (e) {
    return Failure(e);
  } on FirebaseException catch (e) {
    return Failure(
      FirestoreException(message: 'Firebase error: ${e.message}')
    );
  } catch (e) {
    return Failure(
      AppException(message: 'Unknown error: $e')
    );
  }
}
```

### En Widget (Consumer)
```dart
ref.watch(myNotifierProvider).whenData((state) {
  if (state.isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${state.error}')),
    );
  }
  if (state.isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Success!')),
    );
  }
});
```

---

## Patrón de validación

```dart
// lib/shared/utils/validators_formatters.dart
class MyFeatureValidators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }
}

// En formulario
TextFormField(
  validator: MyFeatureValidators.validateName,
  onChanged: (value) => ref.watch(myNotifierProvider).setName(value),
)
```

---

## Testing pattern

```dart
// test/features/my_feature/my_feature_repository_test.dart
void main() {
  group('MyFeatureRepository', () {
    test('create returns Success with new feature', () async {
      final repository = MyFeatureRepositoryImpl(
        firestore: mockFirestore,
      );
      
      final result = await repository.create(feature: testFeature);
      
      expect(result, isA<Success>());
    });

    test('create returns Failure on error', () async {
      // Setup mock to throw
      when(mockFirestore.collection(...))
        .thenThrow(FirebaseException(...));

      final repository = MyFeatureRepositoryImpl(
        firestore: mockFirestore,
      );

      final result = await repository.create(feature: testFeature);

      expect(result, isA<Failure>());
    });
  });
}
```

---

## Checklist para nueva feature

- [ ] Modelo Dart creado (lib/data/models/)
- [ ] Repository interface + implementación (lib/data/repositories/)
- [ ] Provider para state management creado
- [ ] Página principal implementada
- [ ] Widgets reutilizables creados
- [ ] Validadores específicos agregados si necesario
- [ ] Error handling implementado
- [ ] Rutas agregadas al router
- [ ] Unit tests escritos
- [ ] Widget tests escritos si aplica
- [ ] Documentación de feature añadida a SETUP_GUIDE.md
- [ ] Riesgos de integración documentados si aplica

---

## Ejemplos en codebase

- **Auth:** lib/features/auth/, lib/data/repositories/auth_repository.dart
- **Dreams:** lib/features/dreams/, lib/data/repositories/dream_repository.dart

---

**Última actualización:** 2026-04-30
