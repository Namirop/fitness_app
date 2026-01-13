import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/core/utils/snackbar_helper.dart';
import 'package:workout_app/screens/profil/widgets/profil_info_container.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/profil/calculate_macro_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfilBloc, ProfilState>(
      buildWhen: (previous, current) =>
          previous.currentProfil != current.currentProfil,
      listener: (context, state) {
        _handleStateChanges(state, context);
      },
      builder: (context, state) {
        final currentProfil = state.currentProfil;
        final isLoading = state.loadProfilStatus == LoadProfilStatus.loading;
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.screenBackground),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                      CustomIcon(
                        onTap: () {},
                        icon: Icon(Icons.image, size: 60),
                        radius: 45,
                        size: 100,
                      ),
                      SizedBox(height: 5),
                      BlocBuilder<ProfilBloc, ProfilState>(
                        builder: (context, state) {
                          if (state.loadProfilStatus ==
                              LoadProfilStatus.loading) {
                            return Shimmer.fromColors(
                              baseColor: Color.fromARGB(255, 238, 228, 206),
                              highlightColor: Color.fromARGB(
                                255,
                                243,
                                239,
                                227,
                              ),
                              child: Container(
                                width: 140,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    207,
                                    207,
                                    207,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }
                          return Text(
                            currentProfil.displayName,
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.normal,
                              letterSpacing: -0.5,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      ProfilInfoContainer(
                        currentProfil: currentProfil,
                        isLoading: isLoading,
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalculateMacroScreen(
                                currentProfil: currentProfil,
                              ),
                            ),
                          );
                        },
                        child: Text("Calculer ses macros"),
                      ),
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

  Future<void> _handleStateChanges(
    ProfilState state,
    BuildContext context,
  ) async {
    if (!context.mounted) return;
    if (state.loadProfilStatus == LoadProfilStatus.failure) {
      SnackbarHelper.showError(
        context,
        state.profilErrorString ?? "Erreur affichage nom",
      );
    }
    if (state.editProfilStatus == EditProfilStatus.failure) {
      SnackbarHelper.showError(
        context,
        state.profilErrorString ?? "Erreur de modification",
      );
    }
  }
}
