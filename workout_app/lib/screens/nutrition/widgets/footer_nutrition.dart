import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class FooterNutrition extends StatefulWidget {
  final DateTime date;
  const FooterNutrition({super.key, required this.date});

  @override
  State<FooterNutrition> createState() => _FooterNutritionState();
}

class _FooterNutritionState extends State<FooterNutrition> {
  Timer? _debounceSelectDate;

  @override
  void dispose() {
    super.dispose();
    _debounceSelectDate?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    return Row(
      children: [
        CustomIcon(
          onTap: () {
            _debounceSelectDate?.cancel();
            _debounceSelectDate = Timer(Duration(milliseconds: 400), () {
              context.read<NutritionBloc>().add(SelectDate(isPrevious: true));
            });
          },
          icon: Icon(Icons.chevron_left, size: 28),
        ),
        SizedBox(width: 15),
        Text(
          "${DateFormat('dd', 'fr_FR').format(date)} ${DateFormat('MMM', 'fr_FR').format(date)}",
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(width: 15),
        CustomIcon(
          onTap: () {
            _debounceSelectDate?.cancel();
            _debounceSelectDate = Timer(Duration(milliseconds: 400), () {
              context.read<NutritionBloc>().add(SelectDate(isPrevious: false));
            });
          },
          icon: Icon(Icons.chevron_right, size: 28),
        ),
        Spacer(),
        _buildPopUpMenu(),
      ],
    );
  }

  Widget _buildPopUpMenu() {
    return CustomIcon(
      onTap: () {},
      icon: PopupMenuButton<String>(
        icon: Icon(Icons.add),
        color: Colors.white,
        iconSize: 25,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        offset: Offset(25, 48),
        onSelected: (value) {},
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'option1',
            height: 30,
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.pizzaSlice, color: Colors.orange),
                SizedBox(width: 10),
                Text(
                  'Ajouter une recette',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: 'option2',
            height: 30,
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.folderOpen, color: Colors.orange),
                SizedBox(width: 10),
                Text(
                  'Statistiques',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
