import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class QuizSeederService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static List<QuizModel> getSampleQuizzes() {
    return [
      const QuizModel(
        id: 'crt_quant_01',
        title: 'Quantitative Aptitude — Core Speed & Arithmetic',
        topic: 'Quantitative Aptitude',
        difficulty: 'Medium',
        questionCount: 5,
        timeLimitMinutes: 8,
        questions: [
          QuestionModel(
            id: 'q_quant_1',
            questionText:
                'A can do a piece of work in 12 days, and B can do it in 15 days. If they work together for 4 days, what fraction of the work is left?',
            options: ['1/5', '2/5', '3/5', '1/3'],
            correctOptionIndex: 1,
            explanation:
                "A's 1 day work = 1/12. B's 1 day work = 1/15. Together in 1 day = 1/12 + 1/15 = 9/60 = 3/20. In 4 days = 4 * 3/20 = 3/5. Remaining work = 1 - 3/5 = 2/5.",
          ),
          QuestionModel(
            id: 'q_quant_2',
            questionText:
                'A train running at a speed of 72 km/h crosses a 200m long platform in 22 seconds. What is the length of the train?',
            options: ['220 m', '240 m', '200 m', '260 m'],
            correctOptionIndex: 1,
            explanation:
                'Speed in m/s = 72 * (5/18) = 20 m/s. Total distance = Speed * Time = 20 * 22 = 440 m. Train length = Total distance - Platform length = 440 - 200 = 240 m.',
          ),
          QuestionModel(
            id: 'q_quant_3',
            questionText:
                'If the cost price of 20 articles is equal to the selling price of 16 articles, what is the profit percentage?',
            options: ['20%', '25%', '30%', '16.66%'],
            correctOptionIndex: 1,
            explanation:
                'Let CP of 1 article = ₹1. CP of 20 = ₹20. SP of 16 = ₹20 => SP of 1 = 20/16 = ₹1.25. Profit% = ((1.25 - 1) / 1) * 100 = 25%.',
          ),
          QuestionModel(
            id: 'q_quant_4',
            questionText:
                'Two numbers are in the ratio 3 : 5. If 9 is subtracted from each, the new ratio becomes 12 : 23. What is the smaller number?',
            options: ['27', '33', '36', '45'],
            correctOptionIndex: 1,
            explanation:
                'Let numbers be 3x and 5x. (3x - 9)/(5x - 9) = 12/23. 23(3x - 9) = 12(5x - 9) => 69x - 207 = 60x - 108 => 9x = 99 => x = 11. Smaller number = 3 * 11 = 33.',
          ),
          QuestionModel(
            id: 'q_quant_5',
            questionText:
                'In how many different ways can the letters of the word "LEADER" be arranged?',
            options: ['720', '360', '180', '120'],
            correctOptionIndex: 1,
            explanation:
                'Total letters = 6. Letter "E" repeats twice. Arrangements = 6! / 2! = 720 / 2 = 360.',
          ),
        ],
      ),
      const QuizModel(
        id: 'crt_logical_01',
        title: 'Logical Reasoning — Deductive & Analytical',
        topic: 'Logical Reasoning',
        difficulty: 'Easy',
        questionCount: 5,
        timeLimitMinutes: 6,
        questions: [
          QuestionModel(
            id: 'q_log_1',
            questionText:
                'Find the next term in the series: 3, 7, 15, 31, 63, ?',
            options: ['125', '127', '129', '131'],
            correctOptionIndex: 1,
            explanation:
                'The pattern is (* 2 + 1): 3*2+1=7, 7*2+1=15, 15*2+1=31, 31*2+1=63, 63*2+1 = 127.',
          ),
          QuestionModel(
            id: 'q_log_2',
            questionText:
                'Pointing to a photograph of a boy, Suresh said, "He is the son of the only son of my mother." How is Suresh related to that boy?',
            options: ['Brother', 'Uncle', 'Father', 'Cousin'],
            correctOptionIndex: 2,
            explanation:
                'The "only son of Suresh\'s mother" is Suresh himself. So the boy is the son of Suresh. Thus, Suresh is the Father.',
          ),
          QuestionModel(
            id: 'q_log_3',
            questionText:
                'In a certain code, "COMPUTER" is written as "RFUVQNPC". How is "MEDICINE" written in that code?',
            options: ['EOJDJEFM', 'EOJDEJFM', 'MFEJDJOE', 'DJEFMJEO'],
            correctOptionIndex: 0,
            explanation:
                'Reverse the word and shift letters: The first and last letters are swapped/repositioned, and intermediate letters are incremented by 1.',
          ),
          QuestionModel(
            id: 'q_log_4',
            questionText:
                'Statements: (1) All mangoes are golden. (2) No golden things are cheap.\nConclusions: I. All mangoes are cheap. II. Golden mangoes are not cheap.',
            options: [
              'Only Conclusion I follows',
              'Only Conclusion II follows',
              'Both I and II follow',
              'Neither follows'
            ],
            correctOptionIndex: 1,
            explanation:
                'Since all mangoes are golden and no golden thing is cheap, no mango can be cheap. Hence Conclusion II follows.',
          ),
          QuestionModel(
            id: 'q_log_5',
            questionText:
                'A man walks 5 km towards South, then turns right and walks 3 km. He turns left and walks 5 km. In which direction is he from the starting point?',
            options: ['South-West', 'South-East', 'North-West', 'South'],
            correctOptionIndex: 0,
            explanation:
                'He moved South (down), then West (right), then further South. Position is South-West from original point.',
          ),
        ],
      ),
      const QuizModel(
        id: 'crt_verbal_01',
        title: 'Verbal Ability — Grammar, Vocabulary & Error Spotting',
        topic: 'Verbal Ability',
        difficulty: 'Medium',
        questionCount: 5,
        timeLimitMinutes: 5,
        questions: [
          QuestionModel(
            id: 'q_verb_1',
            questionText:
                'Choose the word that is most nearly OPPOSITE in meaning to "CANDID":',
            options: ['Blunt', 'Guarded', 'Sincere', 'Frank'],
            correctOptionIndex: 1,
            explanation:
                '"Candid" means truthful and straightforward. The opposite is "Guarded" or "Deceptive".',
          ),
          QuestionModel(
            id: 'q_verb_2',
            questionText:
                'Spot the grammatical error: "Neither of the two candidates (A) / have paid (B) / their admission fees (C) / No error (D)"',
            options: ['Part A', 'Part B', 'Part C', 'Part D'],
            correctOptionIndex: 1,
            explanation:
                '"Neither of" is singular, so it takes the singular auxiliary verb "has paid" instead of "have paid".',
          ),
          QuestionModel(
            id: 'q_verb_3',
            questionText:
                'Select the correct idiom meaning: "To burn the midnight oil"',
            options: [
              'To waste electricity recklessly',
              'To work or study late into the night',
              'To start an uncontrollable fire',
              'To engage in pointless arguments'
            ],
            correctOptionIndex: 1,
            explanation:
                '"To burn the midnight oil" means to study or work diligently late into the night.',
          ),
          QuestionModel(
            id: 'q_verb_4',
            questionText:
                'Complete the sentence: "Despite the heavy rain, the football match was not ________."',
            options: ['called out', 'called off', 'called in', 'called up'],
            correctOptionIndex: 1,
            explanation:
                '"Called off" is a phrasal verb meaning cancelled or abandoned.',
          ),
          QuestionModel(
            id: 'q_verb_5',
            questionText:
                'Choose the correctly spelled word:',
            options: [
              'Accomodation',
              'Accommodation',
              'Acommodation',
              'Accomadation'
            ],
            correctOptionIndex: 1,
            explanation:
                'The correct spelling is "Accommodation" with double "c" and double "m".',
          ),
        ],
      ),
      const QuizModel(
        id: 'crt_tech_01',
        title: 'Technical Core — Data Structures, DBMS & OOPs',
        topic: 'Technical / CS Core',
        difficulty: 'Hard',
        questionCount: 5,
        timeLimitMinutes: 10,
        questions: [
          QuestionModel(
            id: 'q_tech_1',
            questionText:
                'What is the worst-case time complexity of searching in a standard Binary Search Tree (BST)?',
            options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
            correctOptionIndex: 2,
            explanation:
                'In a skewed/unbalanced BST (like a degenerate linked list), the search degrades to O(n). In balanced trees like AVL/Red-Black, it is O(log n).',
          ),
          QuestionModel(
            id: 'q_tech_2',
            questionText:
                'Which SQL clause is used to filter groups created by the GROUP BY statement?',
            options: ['WHERE', 'HAVING', 'ORDER BY', 'FILTER'],
            correctOptionIndex: 1,
            explanation:
                'WHERE filters individual rows before grouping, whereas HAVING filters aggregated groups after GROUP BY.',
          ),
          QuestionModel(
            id: 'q_tech_3',
            questionText:
                'Which OOP concept is demonstrated by having multiple methods in the same class with the same name but different parameter signatures?',
            options: [
              'Method Overriding (Runtime Polymorphism)',
              'Method Overloading (Compile-time Polymorphism)',
              'Encapsulation',
              'Data Abstraction'
            ],
            correctOptionIndex: 1,
            explanation:
                'Method overloading allows multiple methods with identical names but differing arguments within the same class scope.',
          ),
          QuestionModel(
            id: 'q_tech_4',
            questionText:
                'Which data structure is most suitable for implementing an LRU (Least Recently Used) Cache efficiently with O(1) get and put operations?',
            options: [
              'Array + Stack',
              'HashMap + Doubly Linked List',
              'Binary Min-Heap + Queue',
              'Trie + AVL Tree'
            ],
            correctOptionIndex: 1,
            explanation:
                'A HashMap provides O(1) lookup, and a Doubly Linked List allows O(1) deletion and insertion at the head/tail to track access order.',
          ),
          QuestionModel(
            id: 'q_tech_5',
            questionText:
                'In Operating Systems, what condition is NOT required for a Deadlock to occur (Coffman conditions)?',
            options: [
              'Mutual Exclusion',
              'Hold and Wait',
              'Preemption allowed',
              'Circular Wait'
            ],
            correctOptionIndex: 2,
            explanation:
                'The condition for deadlock is "No Preemption" (resources cannot be forcibly taken away). If preemption is allowed, deadlocks can be avoided.',
          ),
        ],
      ),
    ];
  }

  /// Automatically seeds initial quizzes to Firestore if the collection is empty
  static Future<void> seedInitialQuizzesIfEmpty() async {
    try {
      final snapshot = await _firestore.collection('quizzes').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final quiz in getSampleQuizzes()) {
          final docRef = _firestore.collection('quizzes').doc(quiz.id);
          batch.set(docRef, quiz.toMap());
        }
        await batch.commit();
      }
    } catch (_) {
      // Silently fall back to in-memory sample quizzes if offline or rules block write
    }
  }
}
