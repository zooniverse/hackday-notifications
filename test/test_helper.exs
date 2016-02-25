ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Notifications.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Notifications.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Notifications.Repo)

