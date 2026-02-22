# Seeds for Maximum of English
alias MaximumOfEnglish.Repo
alias MaximumOfEnglish.Accounts.User
alias MaximumOfEnglish.Courses.{Course, Week, Lesson}
alias MaximumOfEnglish.Tests.{LessonTest, LessonTestQuestion, LessonTestOption}
alias MaximumOfEnglish.Placement.{PlacementTest, PlacementQuestion, PlacementAnswerOption}

# --- Admin User ---
admin =
  case Repo.get_by(User, email: "admin@example.com") do
    nil ->
      %User{}
      |> User.registration_changeset(%{
        email: "admin@example.com",
        password: "admin123456789",
        role: "admin"
      })
      |> Repo.insert!()

    user ->
      user
  end

IO.puts("Admin created: #{admin.email} (role: #{admin.role})")

# --- Student User ---
student =
  case Repo.get_by(User, email: "student@example.com") do
    nil ->
      %User{}
      |> User.registration_changeset(%{
        email: "student@example.com",
        password: "student123456789",
        role: "student"
      })
      |> Repo.insert!()

    user ->
      user
  end

IO.puts("Student created: #{student.email} (role: #{student.role})")

# --- Course ---
course =
  case Repo.get_by(Course, title: "English A2-B1") do
    nil ->
      %Course{}
      |> Course.changeset(%{
        title: "English A2-B1",
        description: "Structured course for A2-B1 level students.",
        is_active: true
      })
      |> Repo.insert!()

    course ->
      course
  end

IO.puts("Course created: #{course.title}")

# --- Week 1 (unlocked) ---
week1 =
  case Repo.get_by(Week, course_id: course.id, number: 1) do
    nil ->
      %Week{}
      |> Week.changeset(%{
        course_id: course.id,
        number: 1,
        title: "Basics & Introduction",
        is_unlocked: true
      })
      |> Repo.insert!()

    week ->
      week
  end

IO.puts("Week 1 created: #{week1.title} (unlocked: #{week1.is_unlocked})")

# --- Week 2 (locked) ---
week2 =
  case Repo.get_by(Week, course_id: course.id, number: 2) do
    nil ->
      %Week{}
      |> Week.changeset(%{
        course_id: course.id,
        number: 2,
        title: "Daily Routines",
        is_unlocked: false
      })
      |> Repo.insert!()

    week ->
      week
  end

IO.puts("Week 2 created: #{week2.title} (unlocked: #{week2.is_unlocked})")

# --- Helper to create lessons idempotently ---
create_lesson = fn week, kind, position, attrs ->
  case Repo.get_by(Lesson, week_id: week.id, kind: kind, position: position) do
    nil ->
      %Lesson{}
      |> Lesson.changeset(
        Map.merge(attrs, %{week_id: week.id, kind: kind, position: position})
      )
      |> Repo.insert!()

    lesson ->
      lesson
  end
end

# --- Grammar 1 ---
grammar1 =
  create_lesson.(week1, "grammar", 1, %{
    title: "Present Simple",
    description: "<p>The Present Simple tense is used for habits, general truths, and repeated actions.</p><h3>Formation</h3><ul><li><strong>Affirmative:</strong> I/You/We/They + base form; He/She/It + base form + s</li><li><strong>Negative:</strong> Subject + do/does + not + base form</li><li><strong>Question:</strong> Do/Does + subject + base form?</li></ul>",
    video_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
    file_url: "#"
  })

IO.puts("  Grammar 1: #{grammar1.title}")

# --- Reading 1 ---
reading1 =
  create_lesson.(week1, "reading", 1, %{
    title: "My Daily Routine",
    description: "<p>Read the following text and answer the questions.</p><p><em>My name is Sarah. I wake up at 7 o'clock every morning. I have breakfast with my family. Then I go to work by bus. I work in an office from 9 to 5. After work, I go to the gym. In the evening, I cook dinner and watch TV. I usually go to bed at 11 pm.</em></p>",
    vocabulary: "wake up - просыпаться\nbreakfast - завтрак\noffice - офис\ngym - спортзал\ncook dinner - готовить ужин\ngo to bed - ложиться спать"
  })

IO.puts("  Reading 1: #{reading1.title}")

# --- Reading 2 ---
reading2 =
  create_lesson.(week1, "reading", 2, %{
    title: "Weekend Activities",
    description: "<p>Read the text about weekend activities.</p><p><em>On weekends, Tom likes to relax. On Saturday morning, he goes shopping at the supermarket. In the afternoon, he meets his friends at a cafe. They talk and drink coffee. On Sunday, Tom stays at home. He reads books and plays video games. Sometimes he visits his grandparents.</em></p>",
    vocabulary: "relax - отдыхать\ngo shopping - ходить за покупками\nsupermarket - супермаркет\nmeet friends - встречаться с друзьями\ncafe - кафе\nvisit - навещать"
  })

IO.puts("  Reading 2: #{reading2.title}")

# --- Listening 1 ---
listening1 =
  create_lesson.(week1, "listening", 1, %{
    title: "Introducing Yourself",
    description: "<p>Listen to the audio and answer the questions about self-introduction.</p><p>In this lesson, you will learn common phrases for introducing yourself in English.</p>",
    audio_url: "#"
  })

IO.puts("  Listening 1: #{listening1.title}")

# --- Listening 2 ---
listening2 =
  create_lesson.(week1, "listening", 2, %{
    title: "At the Restaurant",
    description: "<p>Listen to a conversation at a restaurant and complete the exercises.</p>",
    audio_url: "#"
  })

IO.puts("  Listening 2: #{listening2.title}")

# --- Tests for lessons ---
create_test_with_questions = fn lesson, questions_data ->
  test =
    case Repo.get_by(LessonTest, lesson_id: lesson.id) do
      nil ->
        %LessonTest{}
        |> LessonTest.changeset(%{lesson_id: lesson.id})
        |> Repo.insert!()

      test ->
        test
    end

  for {q_text, position, options} <- questions_data do
    question =
      case Repo.get_by(LessonTestQuestion, lesson_test_id: test.id, position: position) do
        nil ->
          %LessonTestQuestion{}
          |> LessonTestQuestion.changeset(%{
            lesson_test_id: test.id,
            text: q_text,
            position: position
          })
          |> Repo.insert!()

        q ->
          q
      end

    for {opt_text, is_correct} <- options do
      case Repo.get_by(LessonTestOption, question_id: question.id, text: opt_text) do
        nil ->
          %LessonTestOption{}
          |> LessonTestOption.changeset(%{
            question_id: question.id,
            text: opt_text,
            is_correct: is_correct
          })
          |> Repo.insert!()

        opt ->
          opt
      end
    end
  end

  test
end

# Grammar test
create_test_with_questions.(grammar1, [
  {"She ___ to work every day.", 1, [
    {"go", false},
    {"goes", true},
    {"going", false},
    {"gone", false}
  ]},
  {"They ___ not like coffee.", 2, [
    {"does", false},
    {"do", true},
    {"is", false},
    {"are", false}
  ]},
  {"___ he play football on weekends?", 3, [
    {"Do", false},
    {"Does", true},
    {"Is", false},
    {"Are", false}
  ]}
])

IO.puts("  Test created for Grammar 1")

# Reading 1 test
create_test_with_questions.(reading1, [
  {"What time does Sarah wake up?", 1, [
    {"6 o'clock", false},
    {"7 o'clock", true},
    {"8 o'clock", false},
    {"9 o'clock", false}
  ]},
  {"How does Sarah go to work?", 2, [
    {"By car", false},
    {"By train", false},
    {"By bus", true},
    {"On foot", false}
  ]},
  {"What does Sarah do after work?", 3, [
    {"She cooks dinner", false},
    {"She goes to the gym", true},
    {"She watches TV", false},
    {"She reads books", false}
  ]}
])

IO.puts("  Test created for Reading 1")

# Reading 2 test
create_test_with_questions.(reading2, [
  {"What does Tom do on Saturday morning?", 1, [
    {"He reads books", false},
    {"He goes shopping", true},
    {"He plays video games", false},
    {"He visits grandparents", false}
  ]},
  {"Where does Tom meet his friends?", 2, [
    {"At home", false},
    {"At a cafe", true},
    {"At the park", false},
    {"At the gym", false}
  ]},
  {"What does Tom do on Sunday?", 3, [
    {"He goes shopping", false},
    {"He meets friends", false},
    {"He stays at home", true},
    {"He goes to work", false}
  ]}
])

IO.puts("  Test created for Reading 2")

# Listening 1 test
create_test_with_questions.(listening1, [
  {"Which phrase is used to introduce yourself?", 1, [
    {"How are you?", false},
    {"My name is...", true},
    {"Goodbye!", false},
    {"Thank you!", false}
  ]},
  {"What do you say after someone introduces themselves?", 2, [
    {"See you later", false},
    {"Nice to meet you", true},
    {"I'm sorry", false},
    {"Good night", false}
  ]},
  {"'Where are you from?' is a question about your:", 3, [
    {"Age", false},
    {"Job", false},
    {"Origin/Country", true},
    {"Hobby", false}
  ]}
])

IO.puts("  Test created for Listening 1")

# Listening 2 test
create_test_with_questions.(listening2, [
  {"'Can I have the menu, please?' is said by the:", 1, [
    {"Waiter", false},
    {"Customer", true},
    {"Chef", false},
    {"Manager", false}
  ]},
  {"'I'd like to order...' means:", 2, [
    {"I want to pay", false},
    {"I want to leave", false},
    {"I want to eat something specific", true},
    {"I want the bill", false}
  ]},
  {"'The bill, please' is asked:", 3, [
    {"At the beginning of the meal", false},
    {"When ordering food", false},
    {"At the end of the meal", true},
    {"When entering the restaurant", false}
  ]}
])

IO.puts("  Test created for Listening 2")

# --- Placement Test ---
placement_test =
  case Repo.get_by(PlacementTest, title: "English Level Assessment") do
    nil ->
      %PlacementTest{}
      |> PlacementTest.changeset(%{
        title: "English Level Assessment",
        description: "Answer the following questions to determine your English level.",
        is_active: true
      })
      |> Repo.insert!()

    test ->
      test
  end

IO.puts("\nPlacement test created: #{placement_test.title}")

placement_questions = [
  {"I ___ a student.", 1, [{"am", true}, {"is", false}, {"are", false}, {"be", false}]},
  {"She ___ to school every day.", 2, [{"go", false}, {"goes", true}, {"going", false}, {"gone", false}]},
  {"We ___ dinner at 7 pm yesterday.", 3, [{"have", false}, {"has", false}, {"had", true}, {"having", false}]},
  {"If I ___ rich, I would travel the world.", 4, [{"am", false}, {"was", false}, {"were", true}, {"be", false}]},
  {"The book ___ by millions of people.", 5, [{"read", false}, {"has been read", true}, {"is reading", false}, {"reads", false}]},
  {"I wish I ___ speak French fluently.", 6, [{"can", false}, {"could", true}, {"may", false}, {"will", false}]},
  {"By this time next year, I ___ my degree.", 7, [{"finish", false}, {"will finish", false}, {"will have finished", true}, {"finished", false}]},
  {"Not only ___ he arrive late, but he also forgot the documents.", 8, [{"does", false}, {"did", true}, {"has", false}, {"was", false}]},
  {"The project needs ___ before Friday.", 9, [{"complete", false}, {"completing", false}, {"to be completed", true}, {"completed", false}]},
  {"Had I known about the meeting, I ___ attended.", 10, [{"will have", false}, {"would have", true}, {"had", false}, {"would", false}]}
]

for {text, position, options} <- placement_questions do
  question =
    case Repo.get_by(PlacementQuestion, test_id: placement_test.id, position: position) do
      nil ->
        %PlacementQuestion{}
        |> PlacementQuestion.changeset(%{
          test_id: placement_test.id,
          text: text,
          position: position
        })
        |> Repo.insert!()

      q ->
        q
    end

  for {opt_text, is_correct} <- options do
    case Repo.get_by(PlacementAnswerOption, question_id: question.id, text: opt_text) do
      nil ->
        %PlacementAnswerOption{}
        |> PlacementAnswerOption.changeset(%{
          question_id: question.id,
          text: opt_text,
          is_correct: is_correct
        })
        |> Repo.insert!()

      opt ->
        opt
    end
  end
end

IO.puts("  #{length(placement_questions)} placement questions created")

IO.puts("\nSeeding complete!")
IO.puts("  Admin: admin@example.com / admin123456789")
IO.puts("  Student: student@example.com / student123456789")
