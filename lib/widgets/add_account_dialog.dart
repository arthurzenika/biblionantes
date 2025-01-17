import 'package:biblionantes/bloc/library_card/library_card_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class AddAccountDialog extends StatelessWidget {
  AddAccountDialog({
    Key? key,
  }) : super(key: key);
  final TextFormField nameField = TextFormField(
      controller: TextEditingController(),
      obscureText: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Entrez un nom de carte';
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Nom de la carte",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ));
  final TextFormField loginField = TextFormField(
      controller: TextEditingController(),
      obscureText: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Entrez le numéro de la carte';
        }
        if (value.length != 10) {
          return 'Le numéro de la carte est de 10 chiffre';
        }
        return null;
      },
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "0000000000",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ));
  final TextFormField passwordField = TextFormField(
      controller: TextEditingController(),
      obscureText: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Entrez le mot de passe';
        }
        return null;
      },
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Défaut date (JJMMAAAA)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ));
  final GlobalKey<ScaffoldState> _scaffoldAlertKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return BlocListener<LibraryCardBloc, AbstractLibraryCardState>(
      listener: (context, state) {
        if (state is AddLibraryCardStateSuccess) {
          Navigator.pop(context);
        }
        if (state is AddLibraryCardStateError) {
          print(state.error);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                "La carte n'existe pas, vérifier le numero de la carte et la date de naissance"),
            backgroundColor: Colors.red[100],
            elevation: 30,
          ));
        }
      },
      child: Scaffold(
        key: _scaffoldAlertKey,
        backgroundColor: Colors.transparent,
        body: AlertDialog(
          title: const Text("Ajouter une carte de bibliothèque"),
          content: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 5.0),
                  const Text("Nom de la carte"),
                  nameField,
                  const SizedBox(height: 5.0),
                  const Text("Numero de la carte"),
                  loginField,
                  const SizedBox(height: 5.0),
                  const Text("Mot de passe"),
                  passwordField,
                ],
              ),
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black45),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            BlocBuilder<LibraryCardBloc, AbstractLibraryCardState>(
                buildWhen: (previous, current) =>
                    current is AddLibraryCardState,
                builder: (context, state) {
                  if (state is AddLibraryCardStateInProgress) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueAccent),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        context.read<LibraryCardBloc>().add(AddLibraryCardEvent(
                            login: loginField.controller!.value.text,
                            name: nameField.controller!.value.text,
                            pass: passwordField.controller!.value.text));
                      }
                    },
                    child: const Text("Ajouter"),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
