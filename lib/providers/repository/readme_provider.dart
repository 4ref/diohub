import 'package:dio_hub/models/repositories/readme_model.dart';
import 'package:dio_hub/providers/proxy_provider.dart';
import 'package:dio_hub/providers/repository/branch_provider.dart';
import 'package:dio_hub/services/repositories/repo_services.dart';

class RepoReadmeProvider
    extends ProxyProvider<RepositoryReadmeModel?, RepoBranchProvider> {
  RepoReadmeProvider(this.repoURL);

  final String repoURL;

  /// Fetch a [RepositoryReadmeModel] and load it in the provider.
  @override
  Future<RepositoryReadmeModel?> setInitData(
      {bool isInitialisation = false}) async {
    final branch = parentProvider.currentSHA;
    RepositoryReadmeModel? _readme;
    final readme =
        await RepositoryServices.fetchReadme(repoURL, branch: branch);
    if (parentProvider.currentSHA == branch) {
      _readme = readme;
    }
    return _readme;
  }
}
