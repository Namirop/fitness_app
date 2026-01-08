import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:workout_app/data/services/macro_calculator_service.dart';
import 'package:workout_app/screens/profil/widgets/profil_gender_row.dart';
import 'package:workout_app/screens/profil/widgets/profil_info_row.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class CalculateMacroScreen extends StatefulWidget {
  final ProfilEntity currentProfil;
  const CalculateMacroScreen({super.key, required this.currentProfil});

  @override
  State<CalculateMacroScreen> createState() => _CalculateMacroScreenState();
}

class _CalculateMacroScreenState extends State<CalculateMacroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int? selectedActivityIndex;
  int? selectedGoalIndex;

  late String gender;
  late int age;
  late double weight;
  late int height;
  String? activityLevel;
  String? goal;
  List<String> levelsActivity = [
    "Sédentaire",
    "Léger",
    "Modéré",
    "Intense",
    "Extreme",
  ];

  List<String> goals = ["Prise", "Perte"];
  List<String> questions = [
    "Q1 : Confirmez les informations suivantes :",
    "Q2 : Quel est notre niveau d'activité :",
    "Q3 : Quels sont vos objectifs :",
  ];

  @override
  void initState() {
    gender = widget.currentProfil.gender;
    age = widget.currentProfil.age;
    weight = widget.currentProfil.weight;
    height = widget.currentProfil.height;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.screenBackground),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CustomIcon(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(FontAwesomeIcons.remove, size: 22),
                      ),
                      SizedBox(width: 15),
                      Transform.scale(
                        scaleY: 1.1,
                        child: Text(
                          "Calcul des macrosnutriments :",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    height: 260,
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (value) {
                        setState(() {
                          _currentPage = value;
                        });
                      },
                      children: [
                        _buildQuestionConfirmProfil(questions[0]),
                        _buildQuestionActivityLevel(questions[1]),
                        _buildQuestionGoal(questions[2]),
                      ],
                    ),
                  ),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionConfirmProfil(String question) {
    return Column(
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: AppColors.widgetBackground,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(width: 2, color: AppColors.containerBorderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
            child: Column(
              children: [
                ProfilGenderRow(
                  title: "Sélectionner votre sexe :",
                  displayText: gender,
                  onGenderSelected: (selectedGender) {
                    setState(() {
                      gender = selectedGender;
                    });
                  },
                  icon: Icons.people,
                ),
                ProfilInfoRow(
                  rowLabel: "Age",
                  icon: Icons.numbers,
                  currentValue: widget.currentProfil.age,
                  displayText: age.toString(),
                  pickerTitle: "Sélectionner votre âge :",
                  minValue: 10,
                  maxValue: 120,
                  unit: "ans",
                  onValueChanged: (selectedAge) {
                    setState(() {
                      age = selectedAge;
                    });
                  },
                ),
                ProfilInfoRow(
                  rowLabel: "Poids (kg)",
                  currentValue: widget.currentProfil.weight.toInt(),
                  displayText: weight.toString(),
                  pickerTitle: "Sélectionner votre poids :",
                  minValue: 30,
                  maxValue: 200,
                  icon: FontAwesomeIcons.weight,
                  unit: "kg",
                  onValueChanged: (selectedWeight) {
                    setState(() {
                      weight = selectedWeight.toDouble();
                    });
                  },
                ),
                ProfilInfoRow(
                  rowLabel: "Taille (cm)",
                  currentValue: widget.currentProfil.height,
                  displayText: height.toString(),
                  pickerTitle: "Sélectionner votre taille :",
                  minValue: 100,
                  maxValue: 220,
                  icon: FontAwesomeIcons.textHeight,
                  unit: "cm",
                  onValueChanged: (selectedHeight) {
                    setState(() {
                      height = selectedHeight;
                    });
                  },
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionActivityLevel(String question) {
    return Column(
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 25),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.widgetBackground,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(width: 2, color: AppColors.containerBorderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: ListView.builder(
              itemCount: levelsActivity.length,
              itemBuilder: (context, index) {
                final isSelected = selectedActivityIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedActivityIndex = index;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            selectedActivityIndex = value == true
                                ? index
                                : null;
                          });
                        },
                        activeColor: AppColors.buttonColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      SizedBox(width: 8),
                      Text(
                        levelsActivity[index],
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionGoal(String question) {
    return Column(
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 25),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.widgetBackground,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(width: 2, color: AppColors.containerBorderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final isSelected = selectedGoalIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGoalIndex = index;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            selectedGoalIndex = value == true ? index : null;
                          });
                        },
                        activeColor: AppColors.buttonColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      SizedBox(width: 8),
                      Text(
                        goals[index],
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final canProceed =
        _currentPage == 0 ||
        (_currentPage == 1 && selectedActivityIndex != null) ||
        (_currentPage == 2 && selectedGoalIndex != null);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentPage > 0)
          CustomIcon(
            icon: Icon(Icons.chevron_left),
            onTap: () {
              setState(() {
                _pageController.previousPage(
                  duration: Duration(microseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
          ),
        if (_currentPage > 0) SizedBox(width: 10),
        Opacity(
          opacity: canProceed ? 1.0 : 0.5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (canProceed) {
                  _pageController.nextPage(
                    duration: Duration(microseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
                if (canProceed && _currentPage == 2) {
                  final macros = MacroCalculatorService.calculate(
                    age: age,
                    weight: weight,
                    height: height,
                    gender: gender,
                    activityLevel: levelsActivity[selectedActivityIndex!],
                    goal: goals[selectedGoalIndex!],
                  );
                  context.read<ProfilBloc>().add(
                    EditProfilInformation(
                      editedProfilGender: gender,
                      editedProfilAge: age,
                      editedProfilWeight: weight,
                      editedProfilHeight: height,
                      caloriesTarget: macros['caloriesTarget'],
                      carbsTarget: macros['carbsTarget'],
                      proteinsTarget: macros['proteinsTarget'],
                      fatsTarget: macros['fatsTarget'],
                      activityLevel: levelsActivity[selectedActivityIndex!],
                      goal: goals[selectedGoalIndex!],
                    ),
                  );
                  Navigator.pop(context);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                color: AppColors.buttonColor,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 3, 13, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == 2 ? "Valider" : "Suivant",
                      style: const TextStyle(fontSize: 26, color: Colors.white),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: _currentPage == 2 ? 3.5 : 6.4,
                        left: _currentPage == 2 ? 5 : 0,
                      ),
                      child: Icon(
                        _currentPage == 2 ? Icons.check : Icons.chevron_right,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
