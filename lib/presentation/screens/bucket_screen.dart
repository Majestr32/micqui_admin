import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:micqui_admin/data/models/questions/questions.dart';
import 'package:micqui_admin/presentation/bloc/questionnarie/questionnarie_bloc.dart';
import 'package:micqui_admin/presentation/screens/responses_screen.dart';
import 'package:micqui_admin/presentation/widgets/app_elevated_button.dart';
import 'package:micqui_admin/presentation/widgets/toast.dart';
import 'dart:html' as html;
import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/services/service_locator.dart';
import '../../core/themes/theme.dart';
import '../../data/models/answer/answer.dart';
import '../../data/models/bucket/bucket.dart';
import '../bloc/bucket/bucket_bloc.dart';
import '../widgets/app_checkbox.dart';
import '../widgets/search_field.dart';

class BucketScreen extends StatefulWidget {
  final int bucketId;
  final double? mobileCardPadding;
  final double? mobileHeaderSize;
  final FontWeight? mobileFontWeight;
  final double? mobileBucketSize;
  final double? mobileRowSize;
  final double? mobileSearchIconSize;
  final double? mobileSearchIconSpace;

  const BucketScreen({
    Key? key,
    required this.bucketId,
    this.mobileCardPadding,
    this.mobileHeaderSize,
    this.mobileBucketSize,
    this.mobileRowSize,
    this.mobileSearchIconSize,
    this.mobileSearchIconSpace,
    this.mobileFontWeight,
  }) : super(key: key);

  @override
  State<BucketScreen> createState() => _BucketScreenState();
}

class _BucketScreenState extends State<BucketScreen> {
  final BucketBloc _bloc = sl<BucketBloc>();
  final _searchController = TextEditingController();
  List<TextEditingController> questionControllers = [];
  List<List<TextEditingController>> answerControllers = [];
  List<List<FocusNode>> answerNameFocusNodes = [];
  List<FocusNode> questionNameFocusNodes = [];

  List<Questions> questions = [];
  late bool published;
  late Bucket bucket;

  List<bool> isChecked = [];

  @override
  void initState() {
    bucket = context.read<QuestionnarieBloc>().state.bucket![widget.bucketId];
    questions = List.generate(
        bucket.questions.length, (index) => bucket.questions[index]);
    if (questions.isNotEmpty) {
      questionControllers.clear();
      questionNameFocusNodes.clear();

      // answerControllers = List.generate(
      //     questions.length,
      //     (index) => questions[index]
      //         .variants
      //         .map((e) => TextEditingController(text: e.name ?? 'New Question'))
      //         .toList());
      answerNameFocusNodes = List.generate(
          questions.length,
          (index) =>
              questions[index].variants.map((e) => FocusNode()).toList());

      for (int i = 0; i < questions.length; i++) {
        questionControllers.add(
            TextEditingController(text: questions[i].name ?? 'Question Name'));
        questionNameFocusNodes.add(FocusNode());
      }
    }

    published = bucket.published!;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BucketBloc, BucketState>(
        bloc: _bloc,
        listener: (context, state) {
          state.maybeMap(
              loaded: (_) {
                questions = [...state.questionsList];
                if (state.questionsList.isNotEmpty) {
                  // checkable = List.generate(state.bucket!.length, (index) => false);
                  // selectedValues = List.generate(
                  //     state.bucket!.length,
                  //         (index) =>
                  //     state.bucket?[index].category ?? AppStrings.employee);
                  questionControllers.clear();
                  questionNameFocusNodes.clear();

                  // answerControllers = List.generate(
                  //     questions.length,
                  //     (index) => questions[index]
                  //         .variants
                  //         .map((e) => TextEditingController(
                  //             text: e.name ?? 'New Question'))
                  //         .toList());
                  answerNameFocusNodes = List.generate(
                      questions.length,
                      (index) => questions[index]
                          .variants
                          .map((e) => FocusNode())
                          .toList());

                  for (int i = 0; i < questions.length; i++) {
                    questionControllers.add(TextEditingController(
                        text: questions[i].name ?? 'Question Name'));
                    questionNameFocusNodes.add(FocusNode());
                  }

                }
              },
              orElse: () {});
          state.maybeMap(
              searchLoaded: (_) => questions = state.questionsList,
              loaded: (s) => questions = s.questionsList,
              isPublished: (_) => published = state.isPublished!,
              // questionAdded: (_) => questions.add(state.questions!),
              // answerAdded: (i) => questions[i.questionIndex] = i.question!,
              error: (e) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.accent,
                      duration: const Duration(seconds: 5),
                      content: Text(
                        e.error,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              success: (_) => widget.mobileCardPadding == null
                  ? router.pop()
                  : Navigator.pop(context),
              orElse: () {});
        },
        builder: (context, state) {
          return state.maybeMap(
            error: (e) => Center(
              child: Text(e.error),
            ),
            loading: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
            orElse: () => SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(widget.mobileCardPadding ?? 37),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Card(
                        elevation: 2,
                        child: IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(5),
                            onPressed: () {
                              widget.mobileCardPadding == null
                                  ? router.pop()
                                  : Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back)),
                      ),
                    ),
                    published
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.bucket,
                                    style: AppTheme
                                        .themeData.textTheme.headlineLarge!
                                        .copyWith(
                                            color: AppColors.text,
                                            fontSize:
                                                widget.mobileHeaderSize ?? 38,
                                            fontWeight:
                                                widget.mobileFontWeight ??
                                                    FontWeight.w400),
                                  ),
                                  Text(
                                    bucket.name!,
                                    style: AppTheme
                                        .themeData.textTheme.labelMedium,
                                  ),
                                  Row(
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.solidCircle,
                                        size: 8,
                                        color: AppColors.green,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        AppStrings.published,
                                        style: AppTheme
                                            .themeData.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${bucket.id}',
                                    style: AppTheme
                                        .themeData.textTheme.titleMedium!
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: widget.mobileHeaderSize ?? 32,
                                    ),
                                  ),
                                  SizedBox(
                                    width: widget.mobileHeaderSize ?? 48,
                                  ),
                                  Tooltip(
                                    message: AppStrings.generateCode,
                                    child: GestureDetector(
                                      onTap: () {
                                        // router.pushReplacement('/qrcode/${bucket.id}');

                                        html.window.open(
                                          '/#/qrcode/${bucket.id}',
                                          'qrcode',
                                        );
                                      },
                                      child: FaIcon(
                                        FontAwesomeIcons.qrcode,
                                        size: widget.mobileHeaderSize ?? 64,
                                        color: AppColors.second,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.bucket,
                                    style: AppTheme
                                        .themeData.textTheme.headlineLarge!
                                        .copyWith(
                                            color: AppColors.text,
                                            fontSize:
                                                widget.mobileHeaderSize ?? 38,
                                            fontWeight:
                                                widget.mobileFontWeight ??
                                                    FontWeight.w400),
                                  ),
                                  Text(
                                    bucket.name!,
                                    style: AppTheme
                                        .themeData.textTheme.labelMedium,
                                  ),
                                  Row(
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.solidCircle,
                                        size: 8,
                                        color: AppColors.lightGrey,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        AppStrings.draft,
                                        style: AppTheme
                                            .themeData.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(),
                            ],
                          ),
                    const SizedBox(
                      height: 17,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight:
                            550.0, // set the maximum height of the sized box
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 5,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: widget.mobileRowSize ?? 24,
                                    right: widget.mobileRowSize ?? 24,
                                    top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${AppStrings.questions} (${questions.isEmpty ? 0 : questions.length})",
                                      style: AppTheme
                                          .themeData.textTheme.titleLarge!
                                          .copyWith(
                                              color: AppColors.text,
                                              fontSize:
                                                  widget.mobileBucketSize ??
                                                      16),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: SizedBox(
                                        width: 706,
                                        height: 38,
                                        child: SearchField(
                                          spaceFromIcon:
                                              widget.mobileSearchIconSpace ??
                                                  45,
                                          searchController: _searchController,
                                          onChange: (name) {
                                            _bloc.add(BucketEvent.searchByName(
                                                name: name, bucket: bucket));
                                          },
                                          iconSize:
                                              widget.mobileSearchIconSize ?? 20,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Tooltip(
                                          message: AppStrings.addNewQuestion,
                                          child: IconButton(
                                            onPressed: () {
                                              _bloc.add(BucketEvent.addQuestion(
                                                  questions: questions));
                                            },
                                            icon: const FaIcon(
                                              FontAwesomeIcons.circlePlus,
                                              color: AppColors.green,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                              questions.isEmpty
                                  ? const SizedBox()
                                  : state.maybeMap(
                                      searchLoading: (_) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      orElse: () => questionList(state),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 38,
                    ),
                    published
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: SizedBox(
                                  width: 278,
                                  child: AppElevatedButton(
                                    color: AppColors.signalRed,
                                    text: AppStrings.removeFromRelease,
                                    onPressed: () {
                                      _bloc.add(BucketEvent.removeFromRelease(
                                          bucketId: bucket.id!));
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: SizedBox(
                                  width: 225,
                                  child: AppElevatedButton(
                                    color: AppColors.text,
                                    text: AppStrings.viewResponses,
                                    onPressed: () {
                                      widget.mobileSearchIconSpace == null
                                          ? router.push(
                                              '/responses/${bucket.id}/${bucket.name}')
                                          : Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ResponsesScreen(
                                                  bucketId: bucket.id!,
                                                  mobileSearchIconSpace: widget
                                                      .mobileSearchIconSpace,
                                                  mobileSearchIconSize: widget
                                                      .mobileSearchIconSize,
                                                  mobileRowSize:
                                                      widget.mobileRowSize,
                                                  mobileBucketSize:
                                                      widget.mobileBucketSize,
                                                  mobileHeaderSize:
                                                      widget.mobileHeaderSize,
                                                  mobileCardPadding:
                                                      widget.mobileCardPadding,
                                                  mobileFontWeight:
                                                      widget.mobileFontWeight, bucketName: bucket.name!,
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: SizedBox(
                                  width: 225,
                                  child: AppElevatedButton(
                                    color: AppColors.signalGreen,
                                    text: AppStrings.publish,
                                    onPressed: () {
                                      _bloc.add(BucketEvent.publish(
                                          bucketId: bucket.id!));
                                      showToast(
                                          msg: AppStrings.bucketIsPublished);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: SizedBox(
                                    width: 164,
                                    child: AppElevatedButton(
                                        color: AppColors.signalRed,
                                        text: AppStrings.delete,
                                        onPressed: () {
                                          deleteBucketDialog(context,
                                              text: AppStrings.areYouDelete,
                                              bucketId: bucket.id!);
                                        })),
                              )
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Expanded questionList(BucketState state) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: questions.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: 19, top: 14, left: 23, right: widget.mobileRowSize ?? 37),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Tooltip(
                                  message: AppStrings.pressEnterSaveQuestion,
                                  child: EditableText(
                                    textAlign: TextAlign.start,
                                    controller: questionControllers[index],
                                    focusNode: questionNameFocusNodes[index],
                                    cursorColor: AppColors.primary,
                                    backgroundCursorColor: AppColors.primary,
                                    style: AppTheme
                                        .themeData.textTheme.labelMedium!
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    selectionControls:
                                        MaterialTextSelectionControls(),
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    onSubmitted: (text) {
                                      questionNameFocusNodes[index].unfocus();
                                      _bloc.add(BucketEvent.setQuestion(
                                          bucketId: bucket.id!,
                                          questionId: questions[index].id,
                                          question: Questions(
                                              id: questions[index].id,
                                              name: questionControllers[index]
                                                  .text),
                                          questionIndex: index));
                                      showToast(
                                          msg: AppStrings.questionIsCreated);
                                    },
                                    onSelectionHandleTapped: () {
                                      showAboutDialog(context: context);
                                    },
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: AppStrings.deleteCurrentQuestion,
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(2),
                                  onPressed: () {
                                    deleteQuestionDialog(context,
                                        text: AppStrings.areYouQuestion,
                                        index: index);
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.solidTrashCan,
                                    size: 20,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 20),
                          //   child: answersList(questions[index].variants,
                          //       questions[index], index),
                          // ),
                          // const SizedBox(
                          //   height: 23,
                          // ),
                          // IconButton(
                          //     onPressed: () {
                          //       _bloc.add(BucketEvent.addAnswer(
                          //           question: questions[index],
                          //           questionIndex: index,
                          //           answerList: questions[index].variants,
                          //           questions: questions));
                          //     },
                          //     icon: const FaIcon(
                          //       FontAwesomeIcons.circlePlus,
                          //       color: AppColors.green,
                          //     )),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget answersList(
      List<Answers> answer, Questions currentQuestion, int questionIndex) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: answer.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
              ),
              child: AppCheckbox(
                size: 32,
                iconSize: 22,
                selectedIconColor: AppColors.green,
                selectedColor: AppColors.white,
                borderColor: AppColors.greyWhite,
                isChecked: false,
                onChange: (v) {},
              ),
            ),

            IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(2),
              onPressed: () {
                deleteNewQuestionDialog(context,
                    text: AppStrings.areYouQuestion,
                    index: index,
                    currentQuestion: currentQuestion);
              },
              icon: const FaIcon(
                FontAwesomeIcons.solidTrashCan,
                size: 20,
                color: AppColors.accent,
              ),
            ),
          ],
        );
      },
    );
  }

  deleteQuestionDialog(BuildContext context,
      {required String text, required int index}) {
    Widget cancelButton = TextButton(
      child: const Text(
        AppStrings.cancel,
        style: TextStyle(color: AppColors.text),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        AppStrings.delete,
        style: TextStyle(color: AppColors.text),
      ),
      onPressed: () {
        _bloc.add(BucketEvent.deleteQuestion(
            bucketId: bucket.id!, index: index, questions: questions));
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(AppStrings.warning,
          style: AppTheme.themeData.textTheme.titleSmall),
      content: Text(text, style: AppTheme.themeData.textTheme.bodySmall),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  deleteNewQuestionDialog(BuildContext context,
      {required String text,
      required int index,
      required Questions currentQuestion}) {
    Widget cancelButton = TextButton(
      child: const Text(
        AppStrings.cancel,
        style: TextStyle(color: AppColors.text),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        AppStrings.delete,
        style: TextStyle(color: AppColors.text),
      ),
      onPressed: () {
        _bloc.add(BucketEvent.deleteAnswer(
            bucketId: bucket.id!,
            existedQuestions: currentQuestion,
            indexToDelete: index,
            questions: questions));
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(AppStrings.warning,
          style: AppTheme.themeData.textTheme.titleSmall),
      content: Text(text, style: AppTheme.themeData.textTheme.bodySmall),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  deleteBucketDialog(BuildContext context,
      {required String text, required String bucketId}) {
    Widget cancelButton = TextButton(
      child: const Text(
        AppStrings.cancel,
        style: TextStyle(color: AppColors.text),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        AppStrings.delete,
        style: TextStyle(color: AppColors.text),
      ),
      onPressed: () {
        _bloc.add(BucketEvent.deleteBucket(bucketId: bucketId));
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(AppStrings.warning,
          style: AppTheme.themeData.textTheme.titleSmall),
      content: Text(text, style: AppTheme.themeData.textTheme.bodySmall),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
