defmodule MaximumOfEnglish.Courses.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lessons" do
    field :kind, :string
    field :title, :string
    field :description, :string
    field :file_url, :string
    field :video_url, :string
    field :audio_url, :string
    field :image_url, :string
    field :vocabulary, :string
    field :position, :integer, default: 1

    belongs_to :week, MaximumOfEnglish.Courses.Week
    has_one :lesson_test, MaximumOfEnglish.Tests.LessonTest

    timestamps(type: :utc_datetime)
  end

  @kinds ~w(grammar reading listening)

  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [
      :week_id, :kind, :title, :description, :file_url,
      :video_url, :audio_url, :image_url, :vocabulary, :position
    ])
    |> validate_required([:week_id, :kind, :title, :position])
    |> validate_inclusion(:kind, @kinds)
    |> unique_constraint([:week_id, :kind, :position])
    |> foreign_key_constraint(:week_id)
  end

  def kinds, do: @kinds
end
