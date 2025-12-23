import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_event.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfilBloc, ProfilState>(
      buildWhen: (previous, current) =>
          previous.currentProfil != current.currentProfil,
      listener: (context, state) {
        if (state.editProfilInfoStatus == EditProfilInfoStatus.failure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.profilInfoErrorString ?? "Erreur"),
              backgroundColor: const Color.fromARGB(255, 189, 80, 73),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
                textColor: Colors.white,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final currentProfil = state.currentProfil;
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 238, 228, 206),
                    Color.fromARGB(255, 243, 239, 227),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      Text(
                        "Profil",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 15),
                      CustomIconButton(
                        onTap: () {},
                        icon: Icon(Icons.image, size: 60),
                        radius: 45,
                        size: 100,
                      ),
                      SizedBox(height: 5),
                      Text(
                        currentProfil.name,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.normal,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(155, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(52, 121, 85, 72),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: FaIcon(
                                      (FontAwesomeIcons.person),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Prénom :",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: 50,
                                      child: TextField(
                                        cursorColor: Colors.black,
                                        cursorWidth: 1.0,
                                        cursorHeight: 15.0,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: currentProfil.displayName,
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        onChanged: (value) {
                                          context.read<ProfilBloc>().add(
                                            EditProfilInformation(
                                              editedProfilName: value,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: FaIcon((Icons.people), size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Sexe :",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: 50,
                                      child: TextField(
                                        cursorColor: Colors.black,
                                        cursorWidth: 1.0,
                                        cursorHeight: 15.0,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: state.currentProfil.gender,
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        onChanged: (value) {
                                          context.read<ProfilBloc>().add(
                                            EditProfilInformation(
                                              editedProfilGender: value,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: FaIcon((Icons.numbers), size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Text("Age :", style: TextStyle(fontSize: 20)),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: 50,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        cursorColor: Colors.black,
                                        cursorWidth: 1.0,
                                        cursorHeight: 15.0,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: currentProfil.displayAge,
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        onChanged: (value) {
                                          context.read<ProfilBloc>().add(
                                            EditProfilInformation(
                                              editedProfilAge: int.tryParse(
                                                value,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: FaIcon(
                                      (FontAwesomeIcons.weight),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Poids (kg) :",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: 50,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d{0,2}'),
                                          ),
                                        ],
                                        cursorColor: Colors.black,
                                        cursorWidth: 1.0,
                                        cursorHeight: 15.0,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: currentProfil.displayWeight,
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        onChanged: (value) {
                                          context.read<ProfilBloc>().add(
                                            EditProfilInformation(
                                              editedProfilWeight:
                                                  double.tryParse(value),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: FaIcon(
                                      (FontAwesomeIcons.textHeight),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Taille (cm) :",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: 50,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(3),
                                        ],
                                        cursorColor: Colors.black,
                                        cursorWidth: 1.0,
                                        cursorHeight: 15.0,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: currentProfil.displayHeight,
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        onChanged: (value) {
                                          context.read<ProfilBloc>().add(
                                            EditProfilInformation(
                                              editedProfilHeight: int.tryParse(
                                                value,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text("Calculer ses macros"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
