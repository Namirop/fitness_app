import 'package:hive_flutter/adapters.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';

class ProfilCacheService {
  final Box<ProfilEntity> _box;

  ProfilCacheService(this._box);

  ProfilEntity? getCachedProfil() {
    return _box.get("current");
  }

  Future<void> saveCachedProfil(ProfilEntity profil) async {
    await _box.put("current", profil);
  }

  Future<void> clearCachedProfil() async {
    await _box.delete("current");
  }
}
