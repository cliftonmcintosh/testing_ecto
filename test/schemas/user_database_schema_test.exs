# ---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
# ---
defmodule TestingEcto.Schemas.UserDatabaseSchemaTest do
  use TestingEcto.SchemaCase
  alias TestingEcto.Schemas.UserDatabaseSchema

  @expected_fields_with_types [
    {:id, :binary_id},
    {:date_of_birth, :date},
    {:email, :string},
    {:favorite_number, :float},
    {:first_name, :string},
    {:inserted_at, :utc_datetime_usec},
    {:last_name, :string},
    {:phone_number, :string},
    {:updated_at, :utc_datetime_usec}
  ]
  @optional [:id, :favorite_number]
  describe "fields and types" do
    @tag :schema_definition
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- UserDatabaseSchema.__schema__(:fields) do
          type = UserDatabaseSchema.__schema__(:type, field)
          {field, type}
        end

      assert Enum.sort(actual_fields_with_types) ==
               Enum.sort(@expected_fields_with_types)
    end
  end

  describe "changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@expected_fields_with_types)

      changeset = UserDatabaseSchema.changeset(valid_params)
      assert %Changeset{valid?: true, changes: changes} = changeset

      mutated = [:date_of_birth]

      for {field, _} <- @expected_fields_with_types, field not in mutated do
        assert Map.get(changes, field) == valid_params[Atom.to_string(field)]
      end

      expected_dob = Date.from_iso8601!(valid_params["date_of_birth"])
      assert changes.date_of_birth == expected_dob
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = invalid_params(@expected_fields_with_types)

      assert %Changeset{valid?: false, errors: errors} =
               UserDatabaseSchema.changeset(invalid_params)

      for {field, _} <- @expected_fields_with_types do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               UserDatabaseSchema.changeset(params)

      for {field, _} <- @expected_fields_with_types, field not in @optional do
        assert errors[field], "The field :#{field} is missing from errors."
        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns error changeset when an email address is reused" do
      Ecto.Adapters.SQL.Sandbox.checkout(TestingEcto.Repo)

      {:ok, existing_user} =
        valid_params(@expected_fields_with_types)
        |> UserDatabaseSchema.changeset()
        |> TestingEcto.Repo.insert()

      changeset_with_repeated_email =
        valid_params(@expected_fields_with_types)
        |> Map.put("email", existing_user.email)
        |> UserDatabaseSchema.changeset()

      assert {:error, %Changeset{valid?: false, errors: errors}} =
               TestingEcto.Repo.insert(changeset_with_repeated_email)

      assert errors[:email], "The field :email is missing from errors."
      {_, meta} = errors[:email]

      assert meta[:constraint] == :unique,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end
end
