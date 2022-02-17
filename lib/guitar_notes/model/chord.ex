defmodule GuitarNotes.Model.Chord do
  use Ecto.Schema

  alias Ecto.Changeset

  # The 's' stands for sharp
  @notes [
    a: "a",
    as: "a#",
    b: "b",
    c: "c",
    cs: "c#",
    d: "d",
    ds: "d#",
    e: "e",
    f: "f",
    fs: "f#",
    g: "g",
    gs: "g#"
  ]

  @primary_key false
  schema "abstract chord" do
    field(:tonic, Ecto.Enum, values: @notes, null: false)
    field(:third, Ecto.Enum, values: @notes)
    field(:fifth, Ecto.Enum, values: @notes)
  end

  def new(chord \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    required = [:tonic]
    params = Map.new(params)

    chord
    |> Changeset.cast(params, fields)
    |> Changeset.validate_required(required)
    |> Changeset.apply_action(:insert)
  end
end
