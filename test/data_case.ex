# ---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
# ---
defmodule TestingEcto.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ecto.Changeset
      import TestingEcto.DataCase
      alias TestingEcto.{Factory, Repo}
    end
  end

  setup _tags? do
    Ecto.Adapters.SQL.Sandbox.mode(TestingEcto.Repo, :manual)
  end
end
