import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialLogin{

  Future<void> loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
    );
    print('Affichage du resultat: ${result.status}');
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken!;
      print('Access token $accessToken');
    } else {
      print(result.status);
      print(result.message);
    }
  }

}