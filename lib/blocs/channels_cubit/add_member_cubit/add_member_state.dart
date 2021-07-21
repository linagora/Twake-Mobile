import 'package:equatable/equatable.dart';
import 'package:twake/models/account/account.dart';

abstract class AddMemberState with EquatableMixin {
  final List<Account> allMembers;
  final List<Account> searchResults;
  final List<Account> selectedMembers;
  final List<Account> frequentlyContacted;

  const AddMemberState(
      {
        this.allMembers = const [],
        this.searchResults = const [],
        this.selectedMembers = const [],
        this.frequentlyContacted = const []
      });

  @override
  List<Object?> get props =>
      [allMembers, searchResults, selectedMembers, frequentlyContacted];
}

class AddMemberInitial extends AddMemberState {
  const AddMemberInitial();

  @override
  List<Object?> get props => [];
}

class AddMemberInSearch extends AddMemberState {

  const AddMemberInSearch(
      {List<Account> allMembers = const [],
      List<Account> searchResults = const [],
      List<Account> selectedMembers = const [],
      List<Account> frequentlyContacted = const []})
      : super(
            allMembers: allMembers,
            searchResults: searchResults,
            selectedMembers: selectedMembers,
            frequentlyContacted: frequentlyContacted);

  @override
  List<Object?> get props => super.props;
}

class AddMemberInFrequentlyContacted extends AddMemberState {

  const AddMemberInFrequentlyContacted(
      {required List<Account> allMembers,
        required List<Account> selectedMembers,
        required List<Account> frequentlyContacted})
      : super(
      allMembers: allMembers,
      selectedMembers: selectedMembers,
      frequentlyContacted: frequentlyContacted);

  @override
  List<Object?> get props => super.props;
}

class AddMemberInProgress extends AddMemberState {
  const AddMemberInProgress();

  @override
  List<Object?> get props => super.props;
}
