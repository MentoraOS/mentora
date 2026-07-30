import '../engine/atlas_engine.dart';
import '../models/team.dart';

class TeamDomain {
  final AtlasEngine engine;

  const TeamDomain(this.engine);

  Future<void> create({required Team team, required String userId}) async {
    await engine.createTeam(team: team, userId: userId);
  }

  Future<void> update({required Team team, required String userId}) async {
    await engine.updateTeam(team: team, userId: userId);
  }

  Future<void> archive({required Team team, required String userId}) async {
    await engine.archiveTeam(team: team, userId: userId);
  }
}
