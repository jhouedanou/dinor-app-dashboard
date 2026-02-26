import 'package:dinor_app/utils/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../services/auth_service/social_login.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool rememberMe = true;

    const miniSpace = SizedBox(height: 5);
    const hr = SizedBox(height: 10);

    final emailField = SizedBox(
      width: MediaQuery.of(context).size.width/1.5,
      child: CustomTextFormField(
          labelText: "E-mail",
          iconData: FontAwesomeIcons.envelope,
          editingController: emailController,
          enabled: true
      ),
    );

    final passwordField = SizedBox(
      width: MediaQuery.of(context).size.width/1.5,
      child: CustomTextFormField(
          labelText: "Mot de passe",
          iconData: FontAwesomeIcons.userSecret,
          editingController: passwordController,
          enabled: true,
          isPasswordField: true,
      ),
    );

    final remindMe = CheckboxListTile(
      title: const Text(
        'Se souvenir de moi',
        style: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          color: Color(0xFF4A5568),
        ),
      ),
      value: rememberMe,
      onChanged: (bool? value) {},
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFFE53E3E),
    );

    final facebookConnectBtn = SignInButton(
      Buttons.facebook,
      text: "Se connecter avec facebook",
      onPressed: () async{
        await SocialLogin().loginWithFacebook();
      },
    );

    const orText = Row(
      children:[
        Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('OU', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(thickness: 1)),
      ],
    );

    final googleConnectBtn = SignInButton(
      Buttons.email,
      text: "Se connecter avec google",
      onPressed: () {},
    );


    final loginBtn = ElevatedButton(
      onPressed: (){
        //TODO:Send submit form
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Se connecter',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final noAccount = TextButton(
      onPressed: (){},
      child: const Text('Pas encore de compte ? S\'inscrire',
        style: TextStyle(
          color: Color(0xFFE53E3E),
          fontSize: 14,
        ),
      ),
    );

    final guestConnection = SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          print('👤 [AuthModal] Bouton "Continuer en tant qu\'invité" appuyé');
          //_continueAsGuest();
        },
        icon: const Icon(Icons.person_outline),
        label: const Text('Continuer en tant qu\'invité'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4A5568),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );

    final loginForm = Form(
        key: formKey,
        child: Column(
          children: [
            emailField,
            passwordField
          ],
        )
    );

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset('assets/images/LOGO_DINOR_monochrono.svg',height: 10, width: 10),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            loginForm,
            miniSpace,
            remindMe,
            miniSpace,
            loginBtn,
            miniSpace,
            noAccount,
            hr,
            facebookConnectBtn,
            miniSpace,
            googleConnectBtn,
            miniSpace,
            guestConnection,
          ],
        ),
      ),
    );
  }
}
