import 'package:flutter/material.dart';
import 'dart:math';

const List<String> questionsList = [
  'How would you describe the first crush you ever had?',
  'How many times did you look at a mirror today?',
  'Are you ticklish?',
  'What qualities do you look for in a potential romantic partner?',
  'Choose one: bread or bed? (If you know what I mean.)',
  'Amongst all the smells in the world, which is one is your favorite?',
  'How do you think you would fare in a zombie apocalypse?',
  'Do you want me to find out where your tickle spots are?',
  'What is the most normal thing about you as a person?',
  'If humans were capable of detaching one of their body parts, which one would you want to be able to detach and why?',
  'What songs do you usually sing in the shower?',
  'Who was your first crush?',
  'How vivid are you dreams?',
  'Would you rather trade intelligence for good looks or good looks for intelligence?',
  'Who do you listen to more, your heart or your brain?',
  'Have you ever dreamed about me?',
  'If you were an animal, what would you be ?',
  'If you were a flavor, which one would you be?',
  'If you had a time machine, would you go back to the past or travel to the future?',
  'Do you believe in love at first sight?',
  'Are you spending the best time with your loved one?',
  'What do you wish for most on Christmas day?',
  'What do you hope to change next year?',
  'Who is the person You wished he could be with you on Christmas day?',
  'Who is the person you will take with you on your next trip?'
];

// 2B0E03
const Color kGreenColor = Color(0xFF2B0E03);

class FunnyQuestionsWidget extends StatelessWidget {
  final int index;

  const FunnyQuestionsWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            height: 70,
            child: Card(
              color: kGreenColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                // leading: CircleAvatar(
                //   backgroundColor: Colors.black,
                //   child: Text(
                //     '${index + 1}',
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
                title: Text(
                  questionsList[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // return LayoutBuilder(builder: (context, constraints) {
    //   return Column(
    //     children: [
    //       // Expanded(
    //       //   child: ListView.builder(
    //       //     itemCount: questionsList.length,
    //       //     padding: EdgeInsets.symmetric(horizontal: 30),
    //       //     itemBuilder: (ctx, index) {
    //       //       final question = questionsList[index];
    //       //       return Card(
    //       //         color: kGreenColor,
    //       //         shape: const RoundedRectangleBorder(
    //       //           borderRadius: BorderRadius.all(
    //       //             Radius.circular(10),
    //       //           ),
    //       //         ),
    //       //         child: ListTile(
    //       //           shape: const RoundedRectangleBorder(
    //       //             borderRadius: BorderRadius.all(
    //       //               Radius.circular(20),
    //       //             ),
    //       //           ),
    //       //           leading: CircleAvatar(
    //       //             backgroundColor: Colors.black,
    //       //             child: Text(
    //       //               '${index + 1}',
    //       //               style: const TextStyle(
    //       //                 color: Colors.white,
    //       //                 fontSize: 14,
    //       //               ),
    //       //             ),
    //       //           ),
    //       //           title: Text(
    //       //             question,
    //       //             style: const TextStyle(
    //       //               color: Colors.white,
    //       //               fontSize: 14,
    //       //             ),
    //       //           ),
    //       //         ),
    //       //       );
    //       //     },
    //       //   ),
    //       // ),
    //     ],
    //   );
    // });
  }
}
