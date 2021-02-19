import 'package:biblionantes/models/SummeryAccount.dart';
import 'package:biblionantes/repositories/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryAccountCard extends StatelessWidget {
  final Account account;
  final AccountRepository accountRepository;
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy");

  SummaryAccountCard({Key key, @required this.account, this.accountRepository})
      : assert(account != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Text(account.login, textAlign: TextAlign.center, textScaleFactor: 1.5),
        FutureBuilder(
        future: accountRepository.loadSummaryAccount(account),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text('An error occurred'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          SummeryAccount summary = snapshot.data;
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.supervised_user_circle),
                title: Text("${summary.firstName} ${summary.lastName}"),
                subtitle: Text("Numéro : " + account.login),
              ),
              (summary.hasTrapLevel) ?
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text("Votre carte est bloqué, rapprochez vous de votre bibliothèque"),
              ): SizedBox.shrink(),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text("Expire le ${dateFormat.format(summary.expiryDate)}"),
                subtitle: Text("Depuis le ${dateFormat.format(summary.subscriptionDate)}"),
              ),
              ListTile(
                leading: Icon(Icons.import_contacts),
                title: Text("Emprunts en cours : ${summary.loanCount}/${summary.maxLoans}"),
              ),
              (summary.overdueLoans > 0) ?
              ListTile(
                  leading: Icon(Icons.watch_later, color: Colors.red),
                  title: Text("Emprunts en retards : ${summary.overdueLoans}"),
              ): SizedBox.shrink()
              ,
              ListTile(
                leading: Icon(Icons.my_library_books),
                title: Text("Réservations : ${summary.resvCount}"),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text(summary.emailAddress),
                subtitle: Text("Courriel"),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text(summary.telephone),
                subtitle: Text("Téléphone"),
              ),
              ListTile(
                leading: Icon(Icons.location_pin),
                title: Text( [summary.street, summary.postalCode, summary.city].where((x) => x != null).join(" ")),
                subtitle: Text("Adresse"),
              ),
            ],
          );
        }
        )
        ],
      )


    );
  }

}