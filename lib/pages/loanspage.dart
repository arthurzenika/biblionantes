// ignore_for_file: unnecessary_const

import 'package:biblionantes/bloc/loans/loans_bloc.dart';
import 'package:biblionantes/models/loansbook.dart';
import 'package:biblionantes/router.gr.dart';
import 'package:biblionantes/widgets/book_card.dart';
import 'package:biblionantes/widgets/no_result_widget.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

final DateFormat dateFormat = DateFormat("dd/MM/yyyy");

class LoansPage extends StatelessWidget {
  const LoansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final event = LoansBloc(accountRepository: context.read())
      ..add(LoadLoansEvent());
    return BlocBuilder<LoansBloc, LoansState>(
      bloc: event,
      builder: (buildContext, state) {
        return Scaffold(
            appBar: buildAppBar(state, event),
            floatingActionButton: buildFloatingActionButton(state, event),
            body: buildBody(state, event, buildContext));
      },
    );
  }

  AppBar buildAppBar(LoansState state, LoansBloc event) {
    if (state is LoansList) {
      return AppBar(
        title: const Text('Mes livres empruntés'),
        centerTitle: true,
        actions: [
          PopupMenuButton<LoansBookGroupBy>(
              onSelected: (groupBy) {
                event.add(ChangeGroupByLoansEvent(groupBy: groupBy));
              },
              icon: const Icon(Icons.sort),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<LoansBookGroupBy>>[
                  const PopupMenuItem(
                      child: const Text('Grouper les documents par :')),
                  PopupMenuItem<LoansBookGroupBy>(
                    value: LoansBookGroupBy.account,
                    child: ListTile(
                      leading: const Icon(Icons.card_membership),
                      title: const Text('Carte de bibliothèque'),
                      trailing: state.groupBy == LoansBookGroupBy.account
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.circle_outlined),
                    ),
                  ),
                  PopupMenuItem<LoansBookGroupBy>(
                    value: LoansBookGroupBy.returnDate,
                    child: ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text('Date de retour'),
                      trailing: state.groupBy == LoansBookGroupBy.returnDate
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.circle_outlined),
                    ),
                  ),
                ];
              }),
        ],
      );
    }
    return AppBar(
      title: const Text('Mes livres empruntés'),
      centerTitle: true,
    );
  }

  Widget buildBody(LoansState state, LoansBloc event, BuildContext context) {
    if (state is LoansInProgress) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is LoansList) {
      List<LoansBook> list = state.list;
      if (list.isEmpty) {
        return NoResultWidget(
            noResultText: 'Aucun emprunt en cours',
            retryButtonText: 'Rafraichir',
            onRetry: () async {
              event.add(LoadLoansEvent());
            });
      }
      return RefreshIndicator(
        onRefresh: () async {
          event.add(LoadLoansEvent());
        },
        child: GroupedListView<LoansBook, String>(
            elements: list,
            groupBy: groupBy(state.groupBy),
            useStickyGroupSeparators: true,
            physics: const AlwaysScrollableScrollPhysics(),
            groupSeparatorBuilder: (String value) =>
                buildGroupSeparator(value, state.groupBy),
            itemBuilder: (c, element) {
              return GestureDetector(
                  onLongPress: () {
                    event.add(SelectLoansEvent(documentId: element.id));
                  },
                  onTap: () {
                    if (state.isSelectionMode) {
                      event.add(SelectLoansEvent(documentId: element.id));
                    } else {
                      context.pushRoute(DetailRoute(
                        id: element.id,
                        action: element.renewable ? 'renew' : null,
                        account: element.renewable ? element.login : null,
                        documentNumber: element.documentNumber,
                      ));
                    }
                  },
                  child: BookCard(
                    book: element,
                    widget: LoansReturn(loansBook: element),
                    isSelected: state.isSelected(element.id),
                    isSelectedMode: state.isSelectionMode,
                  ));
            }),
      );
    } else {
      return NoResultWidget(
          noResultText: 'Une erreur est apparue',
          retryButtonText: 'Ré-essayer',
          onRetry: () async {
            event.add(LoadLoansEvent());
          });
    }
  }

  Padding buildGroupSeparator(String value, LoansBookGroupBy groupBy) {
    var title = value;
    var color = Colors.blue;
    if (groupBy == LoansBookGroupBy.returnDate) {
      var date = DateTime.parse(value);
      title = dateFormat.format(date);
      if (date.isBefore(DateTime.now())) {
        color = Colors.red;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  String Function(LoansBook) groupBy(LoansBookGroupBy groupByElement) {
    return (element) {
      switch (groupByElement) {
        case LoansBookGroupBy.returnDate:
          return element.returnDate.toString();
        case LoansBookGroupBy.account:
        default:
          return element.account;
      }
    };
  }

  buildFloatingActionButton(LoansState state, LoansBloc event) {
    if (state is LoansList) {
      if (state.isSelectionMode) {
        return FloatingActionButton(
            onPressed: () => event.add(QuitSelectionModeLoansEvent()),
            child: Text(state.selectedFlag.values
                .where((element) => element)
                .length
                .toString()));
      } else {
        return FloatingActionButton(
            onPressed: () => event.add(EnterSelectionModeLoansEvent()),
            child: const Icon(Icons.library_add_check_outlined));
      }
    }
    return null;
  }
}

class LoansReturn extends StatelessWidget {
  const LoansReturn({
    Key? key,
    required this.loansBook,
  }) : super(key: key);

  final LoansBook loansBook;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4.0),
      minVerticalPadding: 0,
      horizontalTitleGap: 0,
      leading: const Icon(Icons.date_range),
      title: Text(dateFormat.format(loansBook.returnDate)),
      subtitle: const Text("Date de retour"),
    );
  }
}
