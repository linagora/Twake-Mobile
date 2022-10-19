import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/widgets/common/rounded_image.dart';

import 'add_workspace_tile.dart';
import 'workspace_title.dart';

class WorkspacesManagement extends StatelessWidget {
  const WorkspacesManagement() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: Colors.white70,
            child: BlocBuilder<WorkspacesCubit, WorkspacesState>(
                builder: (context, workspacesState) {
              if (workspacesState is WorkspacesLoadSuccess) {
                return Column(
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                            child: Text(
                              'You are in the workspace ${workspacesState.selected?.name} from the group ${context.read<CompaniesCubit>().getSelectedCompany()?.name}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              icon: Image.asset(imagePathCancel),
                              onPressed: () {}),
                        )
                      ],
                    ),
                    RoundedImage(
                      imageUrl: context
                              .read<CompaniesCubit>()
                              .getSelectedCompany()
                              ?.logo ??
                          '',
                      width: 60.0,
                      height: 60.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Text(workspacesState.selected?.name ?? ''),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black12,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Icon(Icons.settings),
                                width: 50,
                                height: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Settings'),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black12,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Icon(Icons.accessibility),
                                width: 50,
                                height: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Collaborators'),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black12,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Icon(Icons.ballot),
                                width: 50,
                                height: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Integrations'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              }
              return CircularProgressIndicator();
            }),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  AddWorkspaceTile(),
                  BlocBuilder<WorkspacesCubit, WorkspacesState>(
                    builder: (context, workspacesState) {
                      if (workspacesState is WorkspacesLoadSuccess) {
                        return Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom,
                            ),
                            itemCount: workspacesState.workspaces.length,
                            itemBuilder: (context, index) {
                              final workSpaceList = workspacesState.workspaces;
                              return WorkspaceTile(
                                onTap: () => context
                                    .read<WorkspacesCubit>()
                                    .selectWorkspace(
                                        workspaceId: workSpaceList[index].id),
                                image: workSpaceList[index].logo ?? '',
                                title: workSpaceList[index].name,
                                selected: workspacesState.selected?.id ==
                                    workSpaceList[index].id,
                                subtitle: '',
                              );
                            },
                          ),
                        );
                      }
                      return SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
