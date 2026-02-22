defmodule MaximumOfEnglish.Repo do
  use Ecto.Repo,
    otp_app: :maximum_of_english,
    adapter: Ecto.Adapters.Postgres
end
